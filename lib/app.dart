library pneuma.app;

import 'dart:collection';
import 'dart:io';
import 'dart:async';
import 'package:pneuma/pneuma.dart';

class Pneuma {
  int port;
  String host;
  LinkedList<Middleware> _middlewares;
  List<MiddlewareHandler> _handlers;

  Pneuma({String host: '127.0.0.1', int port: 8080}) {
    this.port = port;
    this.host = host;
    _handlers = new List();
    _middlewares = new LinkedList<Middleware>();
  }

  Pneuma use(Middleware middleware) {
    _middlewares.add(middleware);

    return this;
  }

  Pneuma match(dynamic/*RegExp|String*/ path, MiddlewareHandler handler, {RequestMethod method}) {
    RegExp url = path is RegExp ? path : new RegExp("^" + path);

    _handlers.add((req, res, next) {
      try {
        if (url.hasMatch(req.uri.toString()) && (method == null || req.method == method)) {
          handler(req, res, next);
        } else {
          next();
        }
      } catch (e) {
        // TODO: error handler
        print(e);
        res.status(500).send(e.toString());
      }
    });

    return this;
  }

  Pneuma get(dynamic path, MiddlewareHandler handler) => match(path, handler, method: RequestMethod.GET);
  Pneuma post(dynamic path, MiddlewareHandler handler) => match(path, handler, method: RequestMethod.POST);
  Pneuma put(dynamic path, MiddlewareHandler handler) => match(path, handler, method: RequestMethod.PUT);
  Pneuma delete(dynamic path, MiddlewareHandler handler) => match(path, handler, method: RequestMethod.DELETE);
  Pneuma patch(dynamic path, MiddlewareHandler handler) => match(path, handler, method: RequestMethod.PATCH);

  Future start({String host: '127.0.0.1', int port: 8080}) async {
    this.port = port;
    this.host = host;
    HttpServer server = await HttpServer.bind(this.host, this.port);

    print("Bound to ${this.host}:${this.port}");
    server.listen(_handler);

    return server;
  }

  Future _handler(HttpRequest request) async {
    int len = _handlers.length;
    Request req = new Request(request);
    Response res = new Response(request.response);
    void next(int i) {
      if (i < len) {
        // TODO: Catch errors and handle with error handler
        _handlers[i](req, res, () {
          next(i + 1);
        });
      }
    }
    Middleware middleware = _middlewares.first;

    while ((middleware = await middleware.run(req, res)) is Middleware);

    next(0);
  }
}
