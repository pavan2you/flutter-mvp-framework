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

import 'dart:convert';

import 'package:jvanila_flutter/src/data/data.dart';
import 'package:jvanila_flutter/src/injection/contextify.dart';

class NetRequest extends DataObject implements Comparable<NetRequest> {

  //////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////  Repo Creation  //////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

/*  static NetRequestRepository _repo;

  static get repo {
    assert(Contextify.context.database != null);
    _repo ??= new NetRequestRepository(local: new NetRequestDAO(
        Contextify.context.database));
    Contextify.context.repoFactory.repos[NetRequest] = _repo;
  }

  static void releaseRepo = _repo = null;*/

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  final String requestId;

  final int createdAt;

  final String delegateType;

  final EndPoint endPoint;

  final Payload payload;

  Map<String, String> headers;

  final RequestPolicy requestPolicy;

  final ResponsePolicy responsePolicy;

  final RetryPolicy retryPolicy;

  final RedirectPolicy redirectPolicy;

  final PollingPolicy pollingPolicy;

  NetRequest(this.requestId, this.createdAt, this.delegateType, this.endPoint,
      this.payload, this.requestPolicy, this.responsePolicy, this.retryPolicy,
      [this.redirectPolicy, this.pollingPolicy]);

  @override
  int compareTo(NetRequest other) {
    int result = requestPolicy.compareTo(other.requestPolicy);
    if (result == 0) {
      result = createdAt.compareTo(other.createdAt);
    }
    return result;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NetRequest &&
              runtimeType == other.runtimeType &&
              requestId == other.requestId;

  @override
  int get hashCode => requestId.hashCode;

  bool get serveAsBytes => responsePolicy.serveAsBytes;

  bool get serveAsStream => responsePolicy.serveAsStream;

  bool get fireImmediate => requestPolicy.fireImmediate;

  bool get fireSequential => requestPolicy.fireSequential;

  bool get fireParallel => requestPolicy.fireParallel;

  bool get sendAsDump => requestPolicy.transactional || retryPolicy.sendAsDump;

  bool get canRetry => retryPolicy?.canRetry;

  bool get canRedirect => redirectPolicy?.canRedirect;

  bool isSameEntity(NetRequest that) =>
      (this.payload?.entityType == that.payload?.entityType &&
          this.payload?.entityUuid == that.payload?.entityUuid);

  bool havingSamePayload(NetRequest that) =>
      this.payload?.body == that.payload?.body;

  bool get isHttp => endPoint.isHttp;

  void send() => Contextify.context.network.send(this);

  Map<String, dynamic> toMap([Map<String, dynamic> map]) {
    map ??= new Map<String, dynamic>();

    map["requestId"] = requestId;
    map["createdAt"] = createdAt;
    map["delegateType"] = delegateType;

    endPoint?.toMap(map);
    payload?.toMap(map);
    requestPolicy?.toMap(map);
    responsePolicy?.toMap(map);
    retryPolicy?.toMap(map);
    redirectPolicy?.toMap(map);
    pollingPolicy?.toMap(map);

    return map;
  }

  factory NetRequest.fromMap(Map<String, dynamic> map) {
    String requestId = map["requestId"];
    int createdAt = map["createdAt"];
    String delegateType = map["delegateType"];

    EndPoint endPoint = EndPoint.fromMap(map);
    Payload payload = Payload.fromMap(map);
    RequestPolicy requestPolicy = RequestPolicy.fromMap(map);
    ResponsePolicy responsePolicy = ResponsePolicy.fromMap(map);
    RetryPolicy retryPolicy = RetryPolicy.fromMap(map);
    RedirectPolicy redirectPolicy = RedirectPolicy.fromMap(map);
    PollingPolicy pollingPolicy = PollingPolicy.fromMap(map);

    return new NetRequest(requestId, createdAt, delegateType, endPoint, payload,
      requestPolicy, responsePolicy, retryPolicy, redirectPolicy,
      pollingPolicy,);
  }
}

class RequestPolicy extends DataObject implements Comparable<RequestPolicy> {

  static final int kPriorityTxn       = 0;
  static final int kPriorityGet       = 1;
  static final int kPriorityAnalytics = 2;

  static final int kFireImmediate     = 0;
  static final int kFireParallel      = 1;
  static final int kFireSequential    = 2;

  final int fireAs;

  final int priority;

  final bool canOverwrite;

  final bool persistable;

  bool processing;

  RequestPolicy(this.persistable, [int fireAs, int priority, bool canOverwrite])
      : this.fireAs = kFireParallel,
        this.priority = kPriorityGet,
        this.canOverwrite = false,
        processing = false;

  bool get fireImmediate => fireAs == kFireImmediate;

  bool get fireSequential => fireAs == kFireSequential;

  bool get fireParallel => fireAs == kFireParallel;

  bool get transactional => priority == kPriorityTxn;

  @override
  int compareTo(RequestPolicy other) {
    return priority.compareTo(other.priority);
  }

  Map<String, dynamic> toMap([Map<String, dynamic> map]) {
    map ??= new Map<String, dynamic>();

    map["requestPolicy_fireAs"] = fireAs;
    map["requestPolicy_priority"] = priority;
    map["requestPolicy_canOverwrite"] = canOverwrite;
    map["requestPolicy_persistable"] = persistable;

    return map;
  }

  factory RequestPolicy.fromMap(Map<String, dynamic> map) {
    RequestPolicy requestPolicy;

    //Request Policy
    if (map.containsKey("requestPolicy_fireAs")) {
      requestPolicy = new RequestPolicy(map["requestPolicy_persistable"],
          map["requestPolicy_fireAs"], map["requestPolicy_priority"],
          map["requestPolicy_canOverwrite"]);
    }

    return requestPolicy;
  }
}

class ResponsePolicy extends DataObject {

  static final int kServeAsString     = 0;
  static final int kServeAsBytes      = 1;
  static final int kServeAsByteStream = 2;

  final int serveAs;

  var treatAnyResponseAsSuccess;

  var notifyErrors;

  ResponsePolicy(this.serveAs)
      :this.treatAnyResponseAsSuccess = false,
        notifyErrors = [];

  bool get serveAsBytes => serveAs == kServeAsBytes;

  bool get serveAsStream => serveAs == kServeAsByteStream;

  Map<String, dynamic> toMap([Map<String, dynamic> map]) {
    map ??= new Map<String, dynamic>();

    map["responsePolicy_serveAs"] = serveAs;
    map["responsePolicy_treatAnyResponseAsSuccess"] = treatAnyResponseAsSuccess;
    map["responsePolicy_notifyErrors"] = notifyErrors;

    return map;
  }

  factory ResponsePolicy.fromMap(Map<String, dynamic> map) {
    ResponsePolicy responsePolicy;

    if (map.containsKey("responsePolicy_serveAs")) {
      responsePolicy = new ResponsePolicy(map["responsePolicy_serveAs"]);
      responsePolicy.treatAnyResponseAsSuccess =
      map["responsePolicy_treatAnyResponseAsSuccess"];
      responsePolicy.notifyErrors = map["responsePolicy_notifyErrors"];
    }

    return responsePolicy;
  }

}

class EndPoint extends DataObject {

  final String server;

  final String method;

  String _url;

  set url(String url) {
    _url = url;
    _uri = null;
  }

  Uri _uri;

  Uri get uri => _uri ??= Uri.parse(_url);

  bool get isHttp => _url.startsWith('http');

  EndPoint(this.server, this.method, [String url]) {
    _url = url;
  }

  Map<String, dynamic> toMap([Map<String, dynamic> map]) {
    map ??= new Map<String, dynamic>();

    map["endPoint_server"] = server;
    map["endpoint_method"] = method;
    map["endpoint_url"] = _url;

    return map;
  }

  factory EndPoint.fromMap(Map<String, dynamic> map) {
    EndPoint endPoint;
    if (map.containsKey('endPoint_server')) {
      endPoint = new EndPoint(
        map["endPoint_server"], map["endpoint_method"], map["endpoint_url"],);
    }
    return endPoint;
  }
}

class Payload extends DataObject {

  final String entityType;

  final String entityUuid;

  final DataObject entity;

  final dynamic body;

  //todo :  fill this along with headers
  final Encoding encoding;

  String encrypted;

  Payload(String crudOperation, this.entityUuid, this.entityType,
      [this.body, this.encoding, this.entity]) {

    this.crudOperation = crudOperation;
  }

  bool isSameEntity(NetRequest that) =>
      (this.entityType == that.payload?.entityType &&
          this.entityUuid == that.payload?.entityUuid);

  bool havingSamePayload(NetRequest that) =>
      this.body == that.payload?.body;

  Map<String, dynamic> toMap([Map<String, dynamic> map]) {
    map ??= new Map<String, dynamic>();

    map["payload_crudOperation"] = crudOperation;
    map["payload_entityType"] = entityType;
    map["payload_entityUuid"] = entityUuid;
    map["payload_body"] = body;
    map["payload_encrypted"] = encrypted;

    return map;
  }

  factory Payload.fromMap(Map<String, dynamic> map) {
    Payload payload;

    if (map.containsKey("payload_entityType")) {
      payload = new Payload(map["payload_entityType"],
          map["payload_entityUuid"], map["payload_body"]);

      payload.crudOperation = map["payload_crudOperation"];
      payload.encrypted = map["payload_encrypted"];
    }

    return payload;
  }
}

class RetryPolicy extends DataObject {

  static final int kDefaultRetryLimit = 5;

  int limit;

  int currentAttempts;

  int retryAfterMillis;

  bool sendAsDump;

  get canRetry => currentAttempts < limit;

  RetryPolicy() {
    limit = kDefaultRetryLimit;
    currentAttempts = 0;
    sendAsDump = false;
    retryAfterMillis = 0;
  }

  Map<String, dynamic> toMap([Map<String, dynamic> map]) {
    map ??= new Map<String, dynamic>();

    map["retryPolicy_limit"] = limit;
    map["retryPolicy_currentAttempts"] = currentAttempts;
    map["retryPolicy_retryAfterMillis"] = retryAfterMillis;
    map["retryPolicy_sendAsDump"] = sendAsDump;

    return map;
  }

  factory RetryPolicy.fromMap(Map<String, dynamic> map) {
    RetryPolicy retryPolicy = new RetryPolicy();
    retryPolicy.limit = map["retryPolicy_limit"];
    retryPolicy.currentAttempts = map["retryPolicy_currentAttempts"];
    retryPolicy.retryAfterMillis = map["retryPolicy_retryAfterMillis"];
    retryPolicy.sendAsDump = map["retryPolicy_sendAsDump"];
    return retryPolicy;
  }
}

class RedirectPolicy extends DataObject {

  static final int kDefaultRedirectLimit = 5;

  int limit = kDefaultRedirectLimit;

  bool allowRedirects;

  int currentAttempts;

  get canRedirect => currentAttempts < limit;

  RedirectPolicy(this.allowRedirects) {
    currentAttempts = 0;
  }

  Map<String, dynamic> toMap([Map<String, dynamic> map]) {
    map ??= new Map<String, dynamic>();

    map["redirectPolicy_limit"] = limit;
    map["redirectPolicy_allowRedirects"] = allowRedirects;
    map["redirectPolicy_currentAttempts"] = currentAttempts;

    return map;
  }

  factory RedirectPolicy.fromMap(Map<String, dynamic> map) {
    RedirectPolicy redirectPolicy;
    if (map.containsKey("RedirectPolicy_allowRedirects")) {
      redirectPolicy = new RedirectPolicy(map["RedirectPolicy_allowRedirects"]);
      redirectPolicy.limit = map["RedirectPolicy_limit"];
      redirectPolicy.currentAttempts = map["RedirectPolicy_currentAttempts"];
    }
    return redirectPolicy;
  }
}

class PollingPolicy extends DataObject {

  final int intervalInMillis;

  PollingPolicy(this.intervalInMillis);

  Map<String, dynamic> toMap([Map<String, dynamic> map]) {
    map ??= new Map<String, dynamic>();

    map["pollingPolicy_intervalInMillis"] = intervalInMillis;

    return map;
  }

  factory PollingPolicy.fromMap(Map<String, dynamic> map) {
    PollingPolicy pollingPolicy;
    if (map.containsKey("PollingPolicy_intervalInMillis")) {
      pollingPolicy = new PollingPolicy(map["PollingPolicy_intervalInMillis"]);
    }
    return pollingPolicy;
  }

}