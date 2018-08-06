# Pneuma 
> The vital spirit, soul, or creative force of a person.<br>
> "In Stoic philosophy, the pneuma penetrates all things, holding things together."<br>
> [Wikipedia](https://en.wikipedia.org/wiki/Pneuma)

Basically, yet another server framework, that provides middleware architecture and possibility to write MVC backend applications.
Fast and very simple. Kickoff in a minute. If you used expressjs before then this framework will not be hard for you to understand.

### Installation & setup
Put `dart_pneuma` package into your __pubspec.yaml__ dependencies section and run `pub get`.
Import the dependency inside your main file
```dart
import 'package:pneuma/pneuma.dart';

void main() {
  Pneuma app = new Pneuma();

  app.start();
}
```
This will start basic http server on default host and port `127.0.0.1:8080`
You can either provide `host` and `port` named parametes into the constructor or use environment variables: `IP` and `PORT`

### Usage
Pneuma could be used in three ways:
1) Writing routed handlers
2) Using middlewares
3) Writing controllers with route maps 

#### Writing routed handlers
Idea is the same as in nodejs's expressjs library. You can just map paths to a specific handler which will process the request or pass it forward by calling `next` callback.

```dart
import 'package:pneuma/pneuma.dart';

final RegExp allRoutes = new RegExp('.*');

void main() {
  Pneuma app = new Pneuma()
    ..get('/user', (req, res, next) {
      res.send('Hello user');
    })
    .post('/user', (req, res, next) async {
      dynamic body = await req.body;
      
      print(body);
      res.send('User has been updated');
    })
    .match(allRoutes, (req, res, next) {
      res.send('Not found');
    });

  app.start();
}
```

#### Using middlewares
`Middleware` abstract class should be extended to create your middleware. You will need to override `run` method, which will receive `Request` and `Response` instances as an arguments and should return `Future` of null or next `Middleware` usually accessible with `this.next` property, as `Middleware` is `LinkedListEntity`

```dart
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

void main() {
  Pneuma app = new Pneuma()
    ..use(new LogMiddleware())
    ..get('/user', (req, res, next) {
      res.send('Hello user');
    });

  app.start();
}
```

#### Writing controllers with route map
As once popular and still widely used, MVC architectural pattern is very usefull to build large scale applications.
Extended from `Middleware`, `Controller` class can also be extended to let you map application routes to specific action methods, which should process the request as an endpoints of the app.

```dart
class UserController extends Controller {
  TestController() {
    routeMap = {
      new RegExp(r'^\/user'): indexAction,
    };
  }

  void indexAction(Request req, Response res) {
    res.send('Index Page');
  }
}

void main() {
  Pneuma app = new Pneuma()
    ..use(new UserController());

  app.start();
}
```

`routeMap` is a `Map<RegExp, Invocation>` which, in oreder for actions to be mapped to specified paths, should be defined.

Next step for the controllers will be defining _annotations_ to marks actions for a specific route in a more friendlier manner.

```dart
class UserController extends Controller {
  @Route(r'^\/user')
  void indexAction(Request req, Response res) {
    res.send('Index Page');
  }
}
```
