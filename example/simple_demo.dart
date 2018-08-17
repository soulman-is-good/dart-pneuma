import 'dart:async';
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

class TestController extends Controller {
  TestController() {
    routeMap = {
      new RegExp(r'^\/controller\/timeout$'): {
        RequestMethod.GET: timeoutAction,
      },
      new RegExp(r'^\/controller\/error$'): {
        RequestMethod.GET: errorAction,
      },
      new RegExp(r'^\/controller\/params\/(\d+)\/(.+)$'): {
        RequestMethod.GET: paramsAction,
      },
      new RegExp(r'^\/controller'): {
        RequestMethod.GET: indexAction,
      }
    };
  }
  
  void indexAction(Request req, Response res) {
    res.send('Index Page');
  }
  
  void paramsAction(Request req, Response res, String index, String other) {
    res.send('Index: $index, and $other');
  }
  
  Future timeoutAction(Request req, Response res) async {
    await new Future.delayed(new Duration(seconds: 10));
  }
  
  void errorAction(Request req, Response res) {
    throw new Exception('Oops controller');
  }
}

main() async {
  Pneuma srv = new Pneuma(port: 8080);

  srv
    ..use(new LogMiddleware())
    ..use(new CustomMiddleware())
    ..use(new TestController())
    ..get('/new', (Request req, Response res, next) {
      res.send('Welcome');
    })
    ..post('/new', (Request req, Response res, next) {
      req.body.then((data) {
        print(data.body);
        res.send('Welcome post');
      });
    });

  await srv.start();
  print('Server started at ${srv.host}:${srv.port}');
}
