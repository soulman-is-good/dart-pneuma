library pneuma.types;

import 'request.dart';
import 'response.dart';

typedef void WaterfallHandler([Exception error]);
typedef void MiddlewareHandler(Request req, Response res, WaterfallHandler next);

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

  static List<String> restMethods = <String>[
    GET.name,
    POST.name,
    PUT.name,
    PATCH.name,  
    DELETE.name,
  ];

  static List<String> methods = <String>[
    GET.name,
    POST.name,
    PUT.name,
    PATCH.name,
    DELETE.name,
    HEAD.name,
    OPTIONS.name,
    CONNECT.name,
    TRACE.name,
  ]; 

  @override
  String toString() => name;
}