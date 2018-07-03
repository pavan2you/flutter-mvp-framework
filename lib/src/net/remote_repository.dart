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

import 'package:jvanila_flutter/src/data/data.dart';
import 'package:jvanila_flutter/src/injection/di.dart';
import 'package:jvanila_flutter/src/net/net.dart';
import 'package:jvanila_flutter/src/net/polling_pool.dart';
import 'package:jvanila_flutter/src/net/net_request_queue.dart';
import 'package:jvanila_flutter/src/net/undelivarable_request_event.dart';

class RemoteRepository<T extends DataObject> extends DataSource<T> {

  RemoteRepository() {
    Contextify.context.network.registry.putIfAbsent(
        this.runtimeType.toString(), () => this);
  }

  @override
  Future create(T entity) {
    throw new Exception("MethodNotSupportedException");
  }

  @override
  Future delete(T entity) {
    throw new Exception("MethodNotSupportedException");
  }

  @override
  Future fetchAll() {
    throw new Exception("MethodNotSupportedException");
  }

  @override
  Future update(T entity) {
    throw new Exception("MethodNotSupportedException");
  }

  void success(NetResponse response) {

    NetRequestQueue _q = Contextify.context.network.queue;

    if (!response.request.requestPolicy.fireImmediate) {
      _q.complete(response.request);
    }
  }

  void failure(NetResponse response) {
    FailureResponse error = response.error;

    switch (error.type) {
    case FailureResponse.kTypeServerFailure:
      serverFailure(response);
      break;

    case FailureResponse.kTypeAuthFailure:
      authFailure(response);
      break;

    case FailureResponse.kTypeNoNetwork:
    case FailureResponse.kTypeClientFailure:
    default:
    anyClientFailure(response);
      break;
    }

    onInterceptFailure(response, error);

    ResponsePolicy responsePolicy = response.request.responsePolicy;
    bool isSubscribedFailureType = responsePolicy.notifyErrors.contains(
        error.type);
    if (isSubscribedFailureType) {
      Contextify.context.eventBus.publish(error);
    }
  }

  void serverFailure(NetResponse response) {

    NetRequestQueue _q = Contextify.context.network.queue;
    RequestPolicy requestPolicy = response.request.requestPolicy;
    RetryPolicy retryPolicy = response.request.retryPolicy;
    ResponsePolicy responsePolicy = response.request.responsePolicy;

    bool isQueueable = response.request.fireImmediate;

    if (responsePolicy.serveAs == RequestPolicy.kFireSequential ||
        requestPolicy.persistable ||
        retryPolicy.limit > 0) {
      if (isQueueable) {
        _q.failed(response.request);
      }

      if (!retryPolicy.canRetry && retryPolicy.sendAsDump) {
        _triggerIfMaxRetryLimitReached(response.request);
      }
    }
    else {
      if (isQueueable) {
        _q.complete(response.request);
      }
    }
  }

  void authFailure(NetResponse response) {

    NetRequestQueue _q = Contextify.context.network.queue;
    PollingPool pollingPool = Contextify.context.network.pollingPool;

    pollingPool.stopPolling();
    _q.pause();
    _q.clearParallelQs();
    _q.clearOngoing();
    _q.removeByEntityCrud('R');

    anyClientFailure(response);
  }

  void anyClientFailure(NetResponse response) {

    FailureResponse error = response.error;

    NetRequestQueue _q = Contextify.context.network.queue;
    RequestPolicy requestPolicy = response.request.requestPolicy;
    RetryPolicy retryPolicy = response.request.retryPolicy;
    ResponsePolicy responsePolicy = response.request.responsePolicy;

    bool isQueueable = response.request.fireImmediate;

    if (responsePolicy.treatAnyResponseAsSuccess == true) {
      if (isQueueable) {
        _q.resumeSequentialQ();
        _q.complete(response.request);
      }
    }
    else {

      if (error.message != null && error.message.startsWith("4")) {

        if (responsePolicy.serveAs == RequestPolicy.kFireSequential
            || requestPolicy.persistable) {

          retryPolicy.currentAttempts = retryPolicy.limit;

          if (isQueueable) {
            _q.failed(response.request);
          }

          if (!retryPolicy.canRetry && retryPolicy.sendAsDump) {
            _triggerIfMaxRetryLimitReached(response.request);
          }
        }
        else {
          if (isQueueable) {
            _q.complete(response.request);
          }
        }
      }
      else {
        if (isQueueable) {
          _q.incomplete(response.request);
        }
      }
    }
  }

  void _triggerIfMaxRetryLimitReached(NetRequest request) {
    UndeliverableRequestEvent event = new UndeliverableRequestEvent();
    event.request = request;
    Contextify.context.eventBus.publish(event);
  }

  void onInterceptFailure(NetResponse response, FailureResponse error) {
    //NA
  }
}