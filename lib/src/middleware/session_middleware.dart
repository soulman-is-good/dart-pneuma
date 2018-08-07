library pneuma.middleware.session;

import 'dart:async';
import '../middleware.dart';

class SessionMiddleware extends Middleware {
  @override
  Future<Middleware> run(Request req, Response res) async {
    if (req.session.isNew) {
      print('new session!!!');
      req.session['test'] = 'hello';
    }
    print(req.session);

    return this.next;
  }
}