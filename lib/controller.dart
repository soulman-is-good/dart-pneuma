import 'dart:async';
import 'package:pneuma/pneuma.dart';

class Controller extends Middleware {
  Map<RegExp, Function> routeMap;

  @override
  Future<Middleware> run(Request req, Response res) async {
    if (routeMap == null) {
      return this.next;
    }
    bool hasMatch = false;
    String url = req.path;
    List<RegExp> routes = routeMap.keys;

    for (RegExp route in routes) {
      if (route.hasMatch(url)) {
        hasMatch = true;
        Function action = routeMap[route];

        await action(req, res);
        break;
      }
    }
    
    if (!hasMatch) {
      return this.next;
    }
    return null;
  }
}
