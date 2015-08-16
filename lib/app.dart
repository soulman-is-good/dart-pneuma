library pneuma.app;

import 'dart:io';
import 'dart:async';
import 'types.dart';

class Pneuma {
  int port;
  String host;
  List<Handler> _handlers;

  X4_Server({String host: '127.0.0.1', int port: 8080}) {
    this.port = port;
    this.host = host;
    _handlers = new List();
  }

  void and(Handler fnc) {
    _handlers.add(fnc);
  }

  Future start() {
    return HttpServer.bind(this.host, this.port).then((HttpServer server) {
      print("Bound to ${this.host}:${this.port}");
      server.listen(_handler);
    });
  }

  void _handler(HttpRequest req) {
    int len = _handlers.length;
    next(int i) {
      if(i < len) {
        _handlers[i](req, req.response, (){
          next(i + 1);
        });
      }
    }
    next(0);
  }
}
