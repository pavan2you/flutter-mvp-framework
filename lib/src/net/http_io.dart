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
import 'dart:io';

import 'package:http/http.dart';
import 'package:jvanila_flutter/src/net/failure_response.dart';
import 'package:jvanila_flutter/src/net/net.dart';
import 'package:jvanila_flutter/src/net/protocol_io.dart';
import 'package:jvanila_flutter/src/net/utils.dart';

class HttpGateway extends ProtocolGateway {

  Map<String, Client> _activeClients = new Map();

  Client getClient(String server) => _activeClients[server] ??= new Client();

  HttpGateway();

  Future<NetResponse> serveRequest(NetRequest netRequest) async {

    Client client = getClient(netRequest.endPoint.server);

    Request request = toRequest(netRequest);
    try {
      Future<Response> response = Response.fromStream(
          await client.send(request));

      return response.then((response) {

        if (_canRedirect(response.statusCode) && netRequest.canRedirect) {
          netRequest.redirectPolicy.currentAttempts++;
          String newUrl = response.headers['Location'];
          netRequest.endPoint.url = newUrl;

          if (newUrl.startsWith(netRequest.endPoint.uri.scheme)) {
            return serveRequest(netRequest);
          }
          else {
            print(
                "Http:redirect:ignore - ${netRequest.endPoint.uri} to $newUrl");
          }
        }

        return _toNetResponse(response, netRequest);
      });
    }
    on Exception catch(e) {

      String reason = e.toString();

      if (e is ClientException) {
        reason = e.message;
      }
      else if (e is HttpException) {
        reason = e.message;
      }
      else if (e is SocketException) {
        reason = e.message;
      }
      else if (e is TimeoutException) {
        reason = e.message;
      }

      FailureResponse failureResponse = new FailureResponse(
          FailureResponse.kTypeClientFailure, reason, netRequest);

      return NetResponse.withError(failureResponse);
    }
  }

  NetResponse _toNetResponse(Response response, NetRequest netRequest) {

    NetResponse netResponse = toNetResponse(response, netRequest);

    int failureType;

    if (response.statusCode < HttpStatus.OK ||
        response.statusCode >= HttpStatus.MULTIPLE_CHOICES) {

      failureType = FailureResponse.kTypeForever;
    }
    /* {401, 403} */
    else if (netResponse.statusCode == HttpStatus.UNAUTHORIZED ||
        netResponse.statusCode == HttpStatus.FORBIDDEN) {

      //auth failure
      failureType = FailureResponse.kTypeAuthFailure;

    }
    /*{400 to 499} - {401, 403} */
    else if (netResponse.statusCode >= HttpStatus.BAD_REQUEST &&
        netResponse.statusCode < HttpStatus.INTERNAL_SERVER_ERROR) {

      //keep quite
      failureType = FailureResponse.kTypeClientFailure;
    }
    /*{500 to 599} */
    else if (netResponse.statusCode >= HttpStatus.INTERNAL_SERVER_ERROR &&
        netResponse.statusCode <= HttpStatus.NETWORK_CONNECT_TIMEOUT_ERROR) {

      //retry
      failureType = FailureResponse.kTypeServerFailure;
    }

    if (failureType != null) {
      netResponse.error =
      new FailureResponse(failureType, response.reasonPhrase, netRequest);
    }

    return netResponse;
  }

  bool _canRedirect(int statusCode) {
    return statusCode == HttpStatus.MOVED_TEMPORARILY ||
        statusCode == HttpStatus.MOVED_PERMANENTLY ||
        statusCode == HttpStatus.SEE_OTHER;
  }

  Future<StreamedNetResponse> serveRequestStream(NetRequest netRequest) async {
    Client client = getClient(netRequest.endPoint.server);
    Request request = toRequest(netRequest);
    StreamedResponse streamedResponse = await client.send(request);
    return toStreamedNetResponse(streamedResponse, netRequest);
  }

  close() {
    _activeClients.forEach((server, client) {
      client.close();
    });
  }

  void closeBy(String server) {
    _activeClients[server]?.close();
  }
}
