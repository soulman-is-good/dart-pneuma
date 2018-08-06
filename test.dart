import 'dart:async';
import 'dart:io';
import 'package:pneuma/pneuma.dart';

class LogMiddleware extends Middleware {
  @override
  Future<Middleware> run(Request req, Response res) {
    DateTime start = new DateTime.now();
    
    res.done.then((_res) {
      DateTime sent = new DateTime.now();
      String stamp = sent.toIso8601String();
      double timeTaken = (sent.millisecondsSinceEpoch - start.millisecondsSinceEpoch) / 1000;

      print('[$stamp]: ${req.method.name} ${_res.statusCode} ${req.uri.toString()} took ${timeTaken} sec.');
    });

    return new Future.value(this.next);
  }
}

class CustomMiddleware extends Middleware {
  @override
  Future<Middleware> run(Request req, Response res) async {
    if (req.path == '/test') {
      await new Future.delayed(new Duration(seconds: 1));

      return this.next;
    } else if (req.path == '/error') {
      throw new Exception('CustomError');
    } else if (req.path == '/timeout') {
      return new Future.delayed(new Duration(seconds: 10));
    }

    return this.next;
  }
}

main() async {
  Pneuma srv = new Pneuma();

  srv
    ..use(new LogMiddleware())
    ..use(new CustomMiddleware())
    ..get('/new', (Request req, Response res, next) {
      res.send('Welcome');
    })
    ..post('/new', (Request req, Response res, next) {
      req.body.then((data) {
        print(data.body);
        res.send('Welcome post');
      });
    })
    ..match("/test", (req, res, next) async {
      var body = await req.body;

      res.json(body.body);
    })
    ..match(new RegExp(r'.*'), (req, res, next) {
      res
        ..statusCode = 404
        ..write('Not Found')
        ..close();
    });

  srv.start();
}
