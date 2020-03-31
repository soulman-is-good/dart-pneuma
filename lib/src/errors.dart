// Copyright (c) 2018, Maxim Savin
// for details. All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'dart:io';

class ServerStatusException implements Exception {
  final int code;
  final String message;

  ServerStatusException(
      [this.code = HttpStatus.internalServerError,
      this.message = 'Internal server error']);

  @override
  String toString() {
    if (code == null) {
      return 'Unknown server error';
    }

    return message == null ? code.toString() : message;
  }
}

class HTTPNotFoundException extends ServerStatusException {
  HTTPNotFoundException() : super(HttpStatus.notFound, 'Not found');
}

class HTTPMethodNotSupportedException extends ServerStatusException {
  HTTPMethodNotSupportedException()
      : super(HttpStatus.methodNotAllowed, 'Not supported');
}
