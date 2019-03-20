library pneuma.middleware.conditional;

import 'dart:async';
import '../middleware.dart';
import '../request.dart';
import '../response.dart';
import '../types.dart';

class ConditionalMiddleware extends Middleware {
  final RegExp _condition;
  final RequestMethod _method;
  final dynamic _handler;

  ConditionalMiddleware(this._condition, this._method, this._handler);

  @override
  Future<Middleware> run(Request req, Response res, {String baseUrl = '/'}) async {
    Middleware middleware;
    String url = req.path;

    if (!url.startsWith(baseUrl)) {
      return this.next;
    }
    url = url.replaceFirst(baseUrl.replaceAll(RegExp(r'/$'), ''), '');
    if (_condition.hasMatch(url) && (_method == null || req.method == _method)) {
      if (_handler is Middleware) {
        middleware = await _handler.run(req, res);
      } else if (_handler is MiddlewareHandler) {
        StreamController controller = new StreamController();

        _handler(req, res, ([Exception error]) {
          if (error == null) {
            controller.sink.add(this.next);
          } else {
            controller.sink.addError(error);
          }
          controller.sink.close();
        });

        await controller.stream.first;
      } else {
        throw new Exception('Handler is not proper middleware on ${_condition.toString()}');
      }
    } else {
      middleware = this.next;
    }

    return middleware;
  }
}