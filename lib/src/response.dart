// Copyright (c) 2018, Maxim Savin
// for details. All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

library pneuma.response;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

final JsonCodec _codec = new JsonCodec();

class Response {
  HttpResponse _res;
  bool _headersSent = false;

  Response(this._res);

  add(data) => _res.add(data);
  addError(data, [StackTrace stacktrace]) => _res.addError(data, stacktrace);
  Future<dynamic> addStream(Stream<List<int>> stream) => _res.addStream(stream);
  bool get bufferOutput => _res.bufferOutput;
  Future close() {_headersSent = true; return _res.close();}
  HttpConnectionInfo get connectionInfo => _res.connectionInfo;
  int get contentLength => _res.contentLength;
  List<Cookie> get cookies => _res.cookies;
  int get statusCode => _res.statusCode;
  set statusCode(int code) {_res.statusCode = code;}
  Duration get deadline => _res.deadline;
  set deadline(Duration dl) {_res.deadline = dl;}
  Future<Socket> detachSocket({bool writeHeaders: true}) => _res.detachSocket(writeHeaders: writeHeaders);
  Future get done => _res.done;
  Encoding get encoding => _res.encoding;
  Future<dynamic> flush() => _res.flush();
  int get hashCode => _res.hashCode;
  HttpHeaders get headers => _res.headers;
  bool get persistentConnection => _res.persistentConnection;
  set persistentConnection(bool pc) {_res.persistentConnection = pc;}
  String get reasonPhrase => _res.reasonPhrase;
  Future<dynamic> redirect(Uri location, {status: HttpStatus.MOVED_TEMPORARILY}) => _res.redirect(location, status: status);
  void write(obj) => _res.write(obj);
  void writeln([Object obj = ""]) => _res.writeln(obj);
  void writeAll(Iterable<dynamic> objects, [String separator = ""]) => _res.writeAll(objects, separator);
  void writeCharCode(int charCode) => _res.writeCharCode(charCode);

  bool get headersSent => _headersSent;

  Response status(int code) {
    statusCode = code;

    return this;
  }

  Future send(String message, {ContentType contentType}) {
    headers.set(
      HttpHeaders.CONTENT_TYPE,
      (contentType ?? ContentType.TEXT).toString()
    );
    write(message);

    return close();
  }

  Future json(Object json) {
    this
      ..headers.set(HttpHeaders.CONTENT_TYPE, ContentType.JSON)
      ..write(_codec.encode(json));
    return close();
  }
}
