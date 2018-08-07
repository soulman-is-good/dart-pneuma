// Copyright (c) 2018, Maxim Savin
// for details. All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

library pneuma.middleware;

import 'dart:async';
import 'dart:collection';

import 'request.dart';
import 'response.dart';

abstract class Middleware extends LinkedListEntry {
  Future<Middleware> run(Request req, Response res);
}