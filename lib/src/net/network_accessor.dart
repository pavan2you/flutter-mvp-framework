
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

import 'package:connectivity/connectivity.dart';
import 'package:jvanila_flutter/src/injection/contextify.dart';
import 'package:jvanila_flutter/src/eventbus/event_bus.dart';
import 'package:jvanila_flutter/src/net/header_builder.dart';
import 'package:jvanila_flutter/src/net/http_io.dart';
import 'package:jvanila_flutter/src/net/net.dart';
import 'package:jvanila_flutter/src/net/polling_pool.dart';
import 'package:jvanila_flutter/src/net/net_request_queue.dart';
import 'package:jvanila_flutter/src/net/remote_repository.dart';

class NetworkAccessor {

  HeaderBuilder headerBuilder;
  ConnectivityWatcher _connectivityWatcher;
  NetworkDispatcher dispatcher;
  NetRequestQueue queue;
  PollingPool pollingPool;
  Map<String, RemoteRepository> registry;

  bool networkAvailable;

  NetworkAccessor(this.headerBuilder) {
    networkAvailable = false;
    registry = Map();

    _connectivityWatcher = new ConnectivityWatcher();
    addConnectivityListener();

    pollingPool = new PollingPool();

    dispatcher = new NetworkDispatcher(this);
    queue = new NetRequestQueue(dispatcher);
  }

  void addConnectivityListener() {
    _connectivityWatcher.addListener(connectivityResult);
    _connectivityWatcher.check().then(connectivityResult);
  }

  void removeConnectivityListener() {
    _connectivityWatcher.removeListener(connectivityResult);
  }

  RemoteRepository gateway(String gateway) => registry[gateway];

  Future send(NetRequest request) async {
    if (request.fireImmediate) {
      await dispatcher.fire(request);
    }
    else {
      await queue.add(request);
    }
  }

  void receive(NetResponse response) {
    RemoteRepository gateway = registry[response.request.delegateType];
    if (response.error == null) {
      gateway.success(response);
    }
    else if (response.error != null) {
      gateway.failure(response);
    }
  }

  connectivityResult(ConnectivityResult result) {
    switch (result) {
    case ConnectivityResult.none:
      networkAvailable = false;
      Contextify.context.eventBus.publish(
          ConnectivityChangeEvent.asOffline());
      break;

    case ConnectivityResult.wifi:
      networkAvailable = true;
      Contextify.context.eventBus.publish(ConnectivityChangeEvent.asOnline(
          ConnectivityChangeEvent.kTypeWifi));
      break;

    default:
      networkAvailable = true;
      Contextify.context.eventBus.publish(ConnectivityChangeEvent.asOnline(
          ConnectivityChangeEvent.kTypeMobile));
    break;
    }
  }

  release() {
    removeConnectivityListener();
    dispatcher.release();
    queue.release();
  }
}

class NetworkDispatcher {

  HttpGateway httpGateway;
  NetworkAccessor accessor;

  NetworkDispatcher(this.accessor) {
    httpGateway = new HttpGateway();
  }

  Future fire(NetRequest request) async {
    NetResponse response;

    if (accessor.networkAvailable) {
      if (request.isHttp) {
        accessor.headerBuilder.build(request);
        response = await httpGateway.serveRequest(request);
      }
      else {
        FailureResponse failureResponse = new FailureResponse(
            FailureResponse.kTypeForever, "Unsupported Protocol", request);
        response = new NetResponse.withError(failureResponse);
      }
    }
    else {
      response = new NetResponse.offline(request);
    }

    accessor.receive(response);
  }

  void clearOngoing() {
    //NA
  }

  void release() {
    httpGateway.close();
  }
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

class ConnectivityChangeEvent extends Event {

  static final int kNotReachable  = 0;
  static final int kReachable     = 1;

  static final int kTypeNone        = -1;
  static final int kTypeMobile      = 0;
  static final int kTypeWifi        = 1;
  static final int kTypeEthernet    = 9;

  int reachability;

  int type;

  bool get offline => reachability == kNotReachable;

  ConnectivityChangeEvent.asOffline() {
    this.reachability = kNotReachable;
    this.type = kTypeNone;
  }

  ConnectivityChangeEvent.asOnline(int type) {
    this.reachability = kReachable;
    this.type = type;
  }
}

class ConnectivityWatcher {

  final Connectivity _connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Map<ConnectivityListener,
      StreamSubscription<ConnectivityResult>> listenerSubscriptions = Map();

  start() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          print("Connectivity changed to $result");
        });
  }

  stop() {
    listenerSubscriptions.forEach((listener, subscription) {
      subscription.cancel();
    });
    listenerSubscriptions.clear();

    _connectivitySubscription.cancel();
  }

  StreamSubscription<ConnectivityResult> addListener(
      ConnectivityListener listenerListen) {

    if (listenerSubscriptions[listenerListen] != null) {
      return listenerSubscriptions[listenerListen];
    }

    StreamSubscription<ConnectivityResult> subscription = _connectivity
        .onConnectivityChanged.listen(listenerListen);

    listenerSubscriptions[listenerListen] = subscription;

    return subscription;
  }

  void removeListener(Function listenerListen) {
    StreamSubscription<ConnectivityResult> subscription =
      listenerSubscriptions[listenerListen];
    subscription.cancel();
    listenerSubscriptions.remove(listenerListen);
  }

  Future<ConnectivityResult> check() async {
    return await (new Connectivity().checkConnectivity());
  }
}

typedef ConnectivityListener(ConnectivityResult result);
