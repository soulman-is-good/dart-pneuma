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

const DEFAULT_REQUEST_TIMEOUT = 60;

class Pneuma {
  final int port;
  final String host;
  final StreamController<ServerStatus> _statusController = new StreamController<ServerStatus>(); 
  HttpServer _server;
  ServerStatus _serverStatus = ServerStatus.NOT_STARTED;
  LinkedList<Middleware> _middlewares;
  Duration requestTimeoutDuration = new Duration(seconds: DEFAULT_REQUEST_TIMEOUT);

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

  Pneuma get(dynamic path, MiddlewareHandler handler) => match(path, handler, method: RequestMethod.GET);
  Pneuma post(dynamic path, MiddlewareHandler handler) => match(path, handler, method: RequestMethod.POST);
  Pneuma put(dynamic path, MiddlewareHandler handler) => match(path, handler, method: RequestMethod.PUT);
  Pneuma delete(dynamic path, MiddlewareHandler handler) => match(path, handler, method: RequestMethod.DELETE);
  Pneuma patch(dynamic path, MiddlewareHandler handler) => match(path, handler, method: RequestMethod.PATCH);

  Future start() async {
    try {
      _server = await HttpServer.bind(this.host, this.port);
    } on Exception catch(err) {
      _setStatus(ServerStatus.ERROR);

      throw err;
    }
    _setStatus(ServerStatus.IDLE);
    _server.listen(_handler, cancelOnError: true, onError: (err) {
      _setStatus(ServerStatus.ERROR);
    });

    return _server;
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
    headers.forEach((String name, Object value) {
    _server.defaultResponseHeaders.add(name, value);
    });
  }

  void clearDefaultHeaders() {
    _server.defaultResponseHeaders.clear();
  }

  void removeDefaultHeader(String name) {
    _server.defaultResponseHeaders.removeAll(name);
  }

  Future _handler(HttpRequest request) async {
    bool resSent = false;
    Request req = new Request(request, this);
    Response res = new Response(request.response);
    
    res.done.then((_) {
      resSent = true;
    });

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
    } catch(err) {
      res.status(500).send(err.toString());
    }
  }
  void _setStatus(ServerStatus status) {
    _serverStatus = status;
    _statusController.sink.add(status);
  }

  ServerStatus get status => _serverStatus;
  Stream<ServerStatus> get statusStream => _statusController.stream.asBroadcastStream();
}
