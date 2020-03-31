// Copyright (c) 2018, Maxim Savin
// for details. All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'dart:async';

import 'middleware.dart';
import 'request.dart';
import 'response.dart';
import 'types.dart';

/// MVC approach middleware.
///
/// Allows to use MVC approach by mapping route regular expressions
/// to methods and actions.
/// ```dart
/// class TestController extends Controller {
///   TestController() {
///     routeMap = {
///       RegExp(r'\/test\/(.*)$'): {
///         RequestMethod.GET: getTestAction,
///       },
///     };
///   }
///
///   void getTestAction(Request req, Response res, String param) {
///     res.send('Param: $param');
///   }
/// }
/// ```
abstract class Controller extends Middleware {
  Map<RegExp, Map<RequestMethod, Function>> get routeMap;

  @override
  Future<Middleware> run(Request req, Response res,
      {String baseUrl = '/'}) async {
    String url = req.path;

    if (routeMap == null || !url.startsWith(baseUrl)) {
      return this.next;
    }
    bool hasMatch = false;

    url = url.replaceFirst(baseUrl.replaceAll(RegExp(r'/$'), ''), '');
    for (RegExp route in routeMap.keys) {
      Match match = route.firstMatch(url);
      int groupCount = match?.groupCount;
      Map<RequestMethod, Function> actions = routeMap[route];

      if (groupCount != null && actions.containsKey(req.method)) {
        final action = actions[req.method];
        final indexes = List<int>.generate(groupCount, (int i) => i + 1);

        hasMatch = true;
        await Function.apply(action, [req, res]..addAll(match.groups(indexes)));
        break;
      }
    }

    if (!hasMatch) {
      return this.next;
    }
    return null;
  }
}
