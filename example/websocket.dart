import 'dart:async';
import 'dart:io';
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

class WebsocketMiddleware extends Middleware {
  final String baseUrl;

  WebsocketMiddleware(this.baseUrl);

  @override
  Future<Middleware> run(Request req, Response res,
      {String baseUrl = '/'}) async {
    if (req.path == baseUrl) {
      print('Upgrading to a websocket...');
      WebSocket ws = await req.upgrade();

      ws.listen((data) {
        print(data);
        ws.add('test');
        Timer(Duration(seconds: 3), () {
          ws.add('More test');
        });
      });

      return null;
    }

    return this.next;
  }
}

main() async {
  Pneuma srv = Pneuma();

  srv
    ..use(WebsocketMiddleware('/ws'))
    ..use(LogMiddleware())
    ..get('/', (req, res, next) {
      res.send('''
<!doctype>
<html>
  <head>
    <title>Websocket test</title>
  </head>
  <body>
    <script>
    function main() {
      var connection = new WebSocket('wss://dart-pneuma-soul-man.c9users.io/ws');
      // When the connection is open, send some data to the server
      connection.onopen = function () {
        connection.send('Ping'); // Send the message 'Ping' to the server
      };
      
      // Log errors
      connection.onerror = function (error) {
        console.log('WebSocket Error ' + error);
      };
      
      // Log messages from the server
      connection.onmessage = function (e) {
        console.log('Server: ' + e.data);
      };
    }
    main();
    </script>
  </body>
</html>
      ''', contentType: ContentType.html.toString());
    });

  srv.start();
}
