import 'dart:async';
import 'dart:collection';
import 'package:pneuma/pneuma.dart';

abstract class Middleware extends LinkedListEntry {
  Future<Middleware> run(Request req, Response res);
}