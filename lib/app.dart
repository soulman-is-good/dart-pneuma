library pneuma.app;

import 'dart:collection';
import 'dart:io';
import 'dart:async';
import 'package:pneuma/pneuma.dart';
import 'package:pneuma/middlewares/conditional_middleware.dart';

const REQUEST_TIMEOUT = 5;

class Pneuma {
  final int port;
  final String host;
  LinkedList<Middleware> _middlewares;
  List<MiddlewareHandler> _handlers;
  Duration requestTimeoutDuration = new Duration(seconds: REQUEST_TIMEOUT);

  Pneuma({String host, int port}):
    this.host = host ?? Platform.environment['IP'],
    this.port = port ?? int.parse(Platform.environment['PORT'], onError: () => 8080)
  {
    _handlers = new List();
    _middlewares = new LinkedList<Middleware>();
  }

  Pneuma use(Middleware middleware) {
    _middlewares.add(middleware);

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
    HttpServer server = await HttpServer.bind(this.host, this.port);

    print("Bound to ${this.host}:${this.port}");
    server.listen(_handler);

    return server;
  }

  Future _handler(HttpRequest request) async {
    int len = _handlers.length;
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
}
