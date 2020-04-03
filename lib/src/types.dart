// Copyright (c) 2018, Maxim Savin
// for details. All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

library pneuma.types;

import 'dart:async';

import 'request.dart';
import 'response.dart';

typedef WaterfallHandler = void Function([Exception]);
typedef MiddlewareHandler = void Function(Request, Response, WaterfallHandler);
typedef ActionHandler = Future<void> Function(Request, Response, [List<String>]);

class RequestMethod {
  final String name;

  static RequestMethod GET = const RequestMethod('GET');
  static RequestMethod POST = const RequestMethod('POST');
  static RequestMethod PUT = const RequestMethod('PUT');
  static RequestMethod PATCH = const RequestMethod('PATCH');
  static RequestMethod DELETE = const RequestMethod('DELETE');
  static RequestMethod HEAD = const RequestMethod('HEAD');
  static RequestMethod OPTIONS = const RequestMethod('OPTIONS');
  static RequestMethod CONNECT = const RequestMethod('CONNECT');
  static RequestMethod TRACE = const RequestMethod('TRACE');

  const RequestMethod(this.name);

  static Map<String, RequestMethod> values = {
    'GET': GET,
    'POST': POST,
    'PUT': PUT,
    'PATCH': PATCH,
    'DELETE': DELETE,
    'HEAD': HEAD,
    'OPTIONS': OPTIONS,
    'CONNECT': CONNECT,
    'TRACE': TRACE,
  };

  static List<RequestMethod> restMethods = <RequestMethod>[
    GET,
    POST,
    PUT,
    PATCH,
    DELETE,
  ];

  static List<RequestMethod> methods = <RequestMethod>[
    GET,
    POST,
    PUT,
    PATCH,
    DELETE,
    HEAD,
    OPTIONS,
    CONNECT,
    TRACE,
  ];

  @override
  String toString() => name;
}

enum ServerStatus {
  IDLE,
  NOT_STARTED,
  ERROR,
  STOPPED,
}
