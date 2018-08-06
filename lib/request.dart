library pneuma.request;

import 'dart:async';
import 'dart:io';
import 'package:pneuma/app.dart';
import 'package:pneuma/body.dart';
import 'package:pneuma/types.dart';

class Request {
  final HttpRequest _req;
  final Body _body;
  final Pneuma app;

  Request(this._req, this.app): _body = new Body(_req);

  Uri get uri => _req.uri;
  Map<String, String> get query => _req.uri.queryParameters;
  String get path => _req.uri.path;
  RequestMethod get method => RequestMethod.values[_req.method];
  Future<WebSocket> upgrade() => WebSocketTransformer.upgrade(_req);

  Future<Body> get body async {
    await _body.processRequest();

    return _body;
  }

  bool get isGet => method == RequestMethod.GET;
  bool get isPost => method == RequestMethod.POST;
  bool get isPut => method == RequestMethod.PUT;
  bool get isDelete => method == RequestMethod.DELETE;
  bool get isPatch => method == RequestMethod.PATCH;
}
