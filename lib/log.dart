library pneuma.log;

void logger(req, res, next) {
  DateTime start = res.headers.date;
  DateTime end = new DateTime.now();
  Duration d = end.difference(start);
  print("${req.method} ${req.uri.toFilePath()} ${res.statusCode} ${d.inMilliseconds}ms");
  next();
}
