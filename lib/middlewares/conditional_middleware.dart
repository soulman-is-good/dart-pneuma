import 'package:pneuma/pneuma.dart';

class ConditionalMiddleware extends Middleware {
  final RegExp _condition;
  final RequestMethod _method;
  final dynamic _handler;

  ConditionalMiddleware(this._condition, this._method, this._handler);

  @override
  Future<Middleware> run(Request req, Response res) async {
    Middleware middleware = this.next;

    if (_condition.hasMatch(req.path) && (_method == null || req.method == _method)) {
      if (_handler is Middleware) {
        await _handler.run(req, res);
      } else if (_handler is MiddlewareHandler) {
        StreamController controller = new StreamController();

        _handler(req, res, ([Exception error = null]) {
          controller.sink.add(error);
          controller.sink.close();
        });
        await controller.stream.first;
      } else {
        throw new Exception('Handler is not proper middleware on ${_condition.toString()}');
      }
    }

    return middleware;
  }
}