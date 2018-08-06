import 'dart:async';
import 'dart:io';
import 'package:pneuma/pneuma.dart';

class CustomMiddleware extends Middleware {
  @override
  Future<Middleware> run(Request req, Response res) async {
    if (req.path == '/test') {
      await new Future.delayed(new Duration(seconds: 1));

      return this.next;
    }
    res.send('end');
  }
}

main() async {
  int port = int.parse(Platform.environment['PORT'], onError: () => 8080);
  String host = Platform.environment['IP'] ?? '127.0.0.1';
  
  Pneuma srv = new Pneuma();

  srv
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
  srv.start(port: port, host: host);
}
