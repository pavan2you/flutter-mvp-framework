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

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:jvanila_flutter/src/net/net.dart';

Request toRequest(NetRequest request) {

  var httpRequest = new Request(request.endPoint.method, request.endPoint.uri);

  Map<String, String> headers = request.headers;

  if (headers != null) {
    httpRequest.headers.addAll(headers);
  }

  if (request.payload.encoding != null) {
    httpRequest.encoding = request.payload.encoding;
  }

  var body = request.payload.body;
  if (body != null) {
    if (body is String) {
      httpRequest.body = body;
    }
    else if (body is List) {
      httpRequest.bodyBytes = DelegatingList.typed(body);
    }
    else if (body is Map) {
      httpRequest.bodyFields = DelegatingMap.typed(body);
    }
    else {
      throw new ArgumentError('Invalid request body "$body".');
    }
  }

  return httpRequest;
}

NetResponse toNetResponse(Response response, NetRequest netRequest) {
  if (netRequest.serveAsBytes) {
    return NetResponse.bytes(
        response.bodyBytes,
        response.statusCode,
        request: netRequest,
        headers: response.headers,
        reasonPhrase: response.reasonPhrase);
  }

  return NetResponse(
      response.body,
      response.statusCode,
      request: netRequest,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase);
}

StreamedNetResponse toStreamedNetResponse(StreamedResponse response,
    NetRequest request) {
  return StreamedNetResponse(
      response.stream, response.statusCode, request: request,
      reasonPhrase: response.reasonPhrase);
}

/// If [stream] is already a [ByteStream], returns it. Otherwise, wraps it in a
/// [ByteStream].
ByteStream toByteStream(Stream<List<int>> stream) {
  if (stream is ByteStream) return stream;
  return new ByteStream(stream);
}