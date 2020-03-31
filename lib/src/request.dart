// Copyright (c) 2018, Maxim Savin
// for details. All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

library pneuma.request;

import 'dart:async';
import 'dart:io';

import 'app.dart';
import 'body.dart';
import 'types.dart';

class Request {
  final HttpRequest _req;
  final Body _body;
  final Map<String, dynamic> _additionalParams;
  final Pneuma app;

  Request(this._req, this.app)
      : _body = Body(_req),
        _additionalParams = Map();

  Future<WebSocket> upgrade() => WebSocketTransformer.upgrade(_req);

  Uri get uri => _req.uri;
  Map<String, String> get query => _req.uri.queryParameters;
  String get path => _req.uri.path;
  HttpSession get session => _req.session;
  List<Cookie> get cookies => _req.cookies;
  RequestMethod get method => RequestMethod.values[_req.method];
  String get ip => _req.connectionInfo.remoteAddress.address;
  HttpHeaders get headers => _req.headers;
  Future<Body> get body async {
    await _body.processRequest();

    return _body;
  }

  dynamic operator [](String key) => _additionalParams[key];
  void operator []=(String key, dynamic value) {
    _additionalParams[key] = value;
  }

  bool get isGet => method == RequestMethod.GET;
  bool get isPost => method == RequestMethod.POST;
  bool get isPut => method == RequestMethod.PUT;
  bool get isDelete => method == RequestMethod.DELETE;
  bool get isPatch => method == RequestMethod.PATCH;
}
