library pneuma.middleware.conditional;

import 'dart:async';
import '../middleware.dart';

class ConditionalMiddleware extends Middleware {
  final RegExp _condition;
  final RequestMethod _method;
  final dynamic _handler;

  ConditionalMiddleware(this._condition, this._method, this._handler);

  @override
  Future<Middleware> run(Request req, Response res) async {
    Middleware middleware;

    if (_condition.hasMatch(req.path) && (_method == null || req.method == _method)) {
      if (_handler is Middleware) {
        middleware = await _handler.run(req, res);
      } else if (_handler is MiddlewareHandler) {
        StreamController controller = new StreamController();

        _handler(req, res, ([Exception error]) {
          if (err == null) {
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