// Copyright (c) 2018, Maxim Savin
// for details. All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

library pneuma.body;

import 'dart:async';
import 'dart:io';
import 'package:http_server/http_server.dart';

class Body {
  HttpRequest _req;
  HttpRequestBody _body;

  Body(this._req);

  Future processRequest() async {
    if (_body == null) {
      _body = await HttpBodyHandler.processRequest(_req);
    }
  }

  get body => _body?.body;

  String get type => _body?.type;
}
