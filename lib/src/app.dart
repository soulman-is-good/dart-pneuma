// Copyright (c) 2018, Maxim Savin
// for details. All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

library pneuma.app;

import 'dart:collection';
import 'dart:io';
import 'dart:async';

import 'middleware/conditional_middleware.dart';
import 'request.dart';
import 'response.dart';
import 'middleware.dart';
import 'types.dart';

const DEFAULT_REQUEST_TIMEOUT = 30;
const DEFAULT_RESPONSE_TIMEOUT = 60;

class Pneuma {
  final int port;
  final String host;
  final StreamController<ServerStatus> _statusController = new StreamController<ServerStatus>(); 
  HttpServer _server;
  Map<String, Object> _headers = new Map();
  ServerStatus _serverStatus = ServerStatus.NOT_STARTED;
  LinkedList<Middleware> _middlewares;
  Duration requestTimeoutDuration = new Duration(seconds: DEFAULT_REQUEST_TIMEOUT);
  Duration responseDeadline = new Duration(seconds: DEFAULT_RESPONSE_TIMEOUT);

  Pneuma({String host, int port}):
    this.host = host ?? Platform.environment['IP'] ?? '127.0.0.1',
    this.port = port ?? int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080
  {
    _statusController.sink.add(_serverStatus);
    _middlewares = new LinkedList<Middleware>();
  }

  Pneuma use(Middleware middleware) {
    _middlewares.add(middleware);

    return this;
  }

  Pneuma useAll(List<Middleware> middlewares) {
    _middlewares.addAll(middlewares);

    return this;
  }

  Pneuma match(
    dynamic/*RegExp|String*/ path,
    dynamic/*Middleware|MiddlewareHandler*/ handler,
    {RequestMethod method}
  ) {
    RegExp condition = path is RegExp ? path : new RegExp("^" + path);

    if (handler is! Middleware && handler is! MiddlewareHandler) {
      throw new Exception('Handler should be of type Middleware or MiddlewareHandler');
    }
    
    _middlewares.add(new ConditionalMiddleware(condition, method, handler));

    return this;
  }

  Pneuma get(dynamic path, dynamic handler) => match(path, handler, method: RequestMethod.GET);
  Pneuma post(dynamic path, dynamic handler) => match(path, handler, method: RequestMethod.POST);
  Pneuma put(dynamic path, dynamic handler) => match(path, handler, method: RequestMethod.PUT);
  Pneuma delete(dynamic path, dynamic handler) => match(path, handler, method: RequestMethod.DELETE);
  Pneuma patch(dynamic path, dynamic handler) => match(path, handler, method: RequestMethod.PATCH);

  Future<Pneuma> start() async {
    try {
      _server = await HttpServer.bind(this.host, this.port);

    } on Exception catch(err) {
      _setStatus(ServerStatus.ERROR);

      throw err;
    }
    _setStatus(ServerStatus.IDLE);
    _server
      .listen(
        _handler,
        cancelOnError: true,
        onError: (err) {
          _setStatus(ServerStatus.ERROR);
          print(err);
        }
      );
    _setupOnStart();

    return this;
  }

  Future stop({bool force = false}) async {
    if (_server == null) {
      return null;
    }
    try {
      await _server.close(force: force);
    } on Exception catch(err) {
      _setStatus(ServerStatus.ERROR);

      throw err;
    }

    return null;
  }

  void addDefaultHeaders(Map<String, Object> headers) {
    if (_serverStatus == ServerStatus.IDLE) {
      headers.forEach((String name, Object value) {
        _server.defaultResponseHeaders.add(name, value);
      });
    } else {
      _headers.addAll(headers);
    }
  }

  void clearDefaultHeaders() {
    if (_serverStatus == ServerStatus.IDLE) {
      _server.defaultResponseHeaders.clear();
    } else {
      _headers.clear();
    }
  }

  void removeDefaultHeader(String name) {
    if (_serverStatus == ServerStatus.IDLE) {
      _server.defaultResponseHeaders.removeAll(name);
    } else {
      _headers.remove(name);
    }
  }

  Future _handler(HttpRequest request) async {
    bool resSent = false;
    Request req = new Request(request, this);
    Response res = new Response(request.response);
    
    res.done.then((_) {
      resSent = true;
    });
    res.deadline = responseDeadline;

    Middleware middleware = _middlewares.first;

    try {
      while (middleware != null) {
        middleware = await middleware.run(req, res).timeout(requestTimeoutDuration, onTimeout: () {
          if (!resSent) {
            throw new TimeoutException('Request timeout');
          }
        });
      }
    } on TimeoutException catch(err) {
      // TODO: Custom handler
      res.status(504).send(err.message);
    } catch(err, stack) {
      // Wait if response is sent - done should trigger
      Timer.run(() {
        // TODO: Custom handler and processing
        if (!resSent) {
          res.status(500).send(err.toString());
        }
      });
      print(err);
      print(stack);
    }
  }

  void _setStatus(ServerStatus status) {
    _serverStatus = status;
    _statusController.sink.add(status);
  }

  void _setupOnStart() {
    if (_headers.isNotEmpty) {
      _headers.forEach((String name, Object value) {
        _server.defaultResponseHeaders.add(name, value);
      });
      _headers.clear();
    }
    _server.serverHeader = 'Pneuma server';
    _server.autoCompress = true;
    _server.idleTimeout = requestTimeoutDuration;
  }

  ServerStatus get status => _serverStatus;
  Stream<ServerStatus> get statusStream => _statusController.stream.asBroadcastStream();
}
