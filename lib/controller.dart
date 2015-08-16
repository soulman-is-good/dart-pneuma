library pneuma.controller;

import 'dart:io';
import 'dart:mirrors';
import 'events.dart';

class Controller extends Events {
  final String name;
  final String action;
  final HttpRequest request;
  final HttpResponse response;

  Controller([this.name, this.action, this.request, this.response]);

  void run() {
    InstanceMirror obj = reflect(this);
    obj.invoke(new Symbol(action), new List(0));
  }

  void noSuchMethod(Invocation iv) {
    response
      ..statusCode = 404
      ..write("Action not found")
      ..close();
  }
}
