import 'dart:async';
import 'package:pneuma/pneuma.dart';

class LogMiddleware extends Middleware {
  @override
  Future<Middleware> run(Request req, Response res, {String baseUrl = '/'}) {
    DateTime start = DateTime.now();

    res.done.then((_res) {
      DateTime sent = DateTime.now();
      String stamp = sent.toIso8601String();
      double timeTaken =
          (sent.millisecondsSinceEpoch - start.millisecondsSinceEpoch) / 1000;

      print(
          '[$stamp]: ${req.method.name} ${_res.statusCode} ${req.uri.toString()} took ${timeTaken} sec.');
    });

    return Future.value(this.next);
  }
}

class CustomMiddleware extends Middleware {
  @override
  Future<Middleware> run(Request req, Response res,
      {String baseUrl = '/'}) async {
    if (req.path == '/test') {
      await Future.delayed(Duration(seconds: 1));

      return this.next;
    } else if (req.path == '/error') {
      throw Exception('CustomError');
    } else if (req.path == '/timeout') {
      return Future.delayed(Duration(seconds: 10));
    }

    return this.next;
  }
}

class TestController extends Controller {
  @override
  get routeMap => {
        RegExp(r'^\/controller\/timeout$'): {
          RequestMethod.GET: timeoutAction,
        },
        RegExp(r'^\/controller\/error$'): {
          RequestMethod.GET: errorAction,
        },
        RegExp(r'^\/controller\/params\/(\d+)\/(.+)$'): {
          RequestMethod.GET: paramsAction,
        },
        RegExp(r'^\/controller'): {
          RequestMethod.GET: indexAction,
        }
      };

  void indexAction(Request req, Response res) {
    res.send('Index Page');
  }

  void paramsAction(Request req, Response res, String index, String other) {
    res.send('Index: $index, and $other');
  }

  Future timeoutAction(Request req, Response res) async {
    await Future.delayed(Duration(seconds: 10));
  }

  void errorAction(Request req, Response res) {
    throw Exception('Oops controller');
  }
}

main() async {
  Pneuma srv = Pneuma(port: 8080);

  srv
    ..use(LogMiddleware())
    ..use(CustomMiddleware())
    ..use(TestController())
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
