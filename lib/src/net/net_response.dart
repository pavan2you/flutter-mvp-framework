/*
 * Copyright (C) 2018 The jVanila Open Source Project
 * Copyright (C) 2018 The Purnatva Solutions Private limited
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *        http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 * author - pavan.jvanila@gmail.com
 */

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jvanila_flutter/src/data/data.dart';
import 'package:jvanila_flutter/src/net/failure_response.dart';
import 'package:jvanila_flutter/src/net/net_request.dart';
import 'package:jvanila_flutter/src/net/utils.dart';

class NetResponse extends DataObject {

  /// The (frozen) request that triggered this response.
  final NetRequest request;

  /// The status code of the response.
  final int statusCode;

  /// The reason phrase associated with the status code.
  final String reasonPhrase;

  final Map<String, String> headers;

  final Uint8List bodyBytes;

  FailureResponse error;

  String get body => _encodingForHeaders(headers).decode(bodyBytes);

  bool get isFailure => error != null;

  NetResponse(String body,
      int statusCode,
      {NetRequest request,
        Map<String, String> headers: const {},
        String reasonPhrase})
      : this.bytes(
        _encodingForHeaders(headers).encode(body),
        statusCode,
        request: request,
        headers: headers,
        reasonPhrase: reasonPhrase);

  NetResponse.bytes(this.bodyBytes,
      this.statusCode,
      {this.request,
        this.headers: const {},
        this.reasonPhrase});

  NetResponse.withError(this.error)
      : this.bodyBytes = null,
        this.statusCode = 0,
        this.request = error.request,
        this.headers = null,
        this.reasonPhrase = null;

  NetResponse.offline(this.request)
      : this.bodyBytes = null,
        this.statusCode = 0,
        this.headers = null,
        this.reasonPhrase = null,
        this.error = new FailureResponse(
            FailureResponse.kTypeNoNetwork, "No network", request);
}

class StreamedNetResponse extends NetResponse {
  /// The stream from which the response body data can be read. This should
  /// always be a single-subscription stream.
  final ByteStream stream;

  /// Creates a new streaming response. [stream] should be a single-subscription
  /// stream.
  StreamedNetResponse(
      Stream<List<int>> stream,
      int statusCode,
      {NetRequest request,
        Map<String, String> headers: const {},
        String reasonPhrase})
      : this.stream = toByteStream(stream),
        super(
          null,
          statusCode,
          request: request,
          headers: headers,
          reasonPhrase: reasonPhrase);
}

/// Returns the encoding to use for a response with the given headers. This
/// defaults to [latin1] if the headers don't specify a charset or
/// if that charset is unknown.
Encoding _encodingForHeaders(Map<String, String> headers) =>
    _encodingForCharset(_contentTypeForHeaders(headers).parameters['charset']);

/// Returns the [MediaType] object for the given headers's content-type.
///
/// Defaults to `application/octet-stream`.
MediaType _contentTypeForHeaders(Map<String, String> headers) {
  var contentType = headers['content-type'];
  if (contentType != null) {
    return new MediaType.parse(contentType);
  }
  return new MediaType("application", "octet-stream");
}

Encoding _encodingForCharset(String charset, [Encoding fallback = latin1]) {
  if (charset == null) {
    return fallback;
  }
  var encoding = Encoding.getByName(charset);
  return encoding == null ? fallback : encoding;
}