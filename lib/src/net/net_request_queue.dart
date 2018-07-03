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

import 'package:jvanila_flutter/src/net/net_request.dart';
import 'package:jvanila_flutter/src/net/net_request_repository.dart';
import 'package:jvanila_flutter/src/net/network_accessor.dart';

class NetRequestQueue {

  static const int kStateInit     = 0;
  static const int kStateLoading  = 1;
  static const int kStateLoaded   = 2;
  static const int kStatePaused   = 3;
  static const int kStateProcess  = 4;
  static const int kStateDead     = 5;

  final NetworkDispatcher dispatcher;
  NetRequestRepository repo;

  int _queueState;

  List<NetRequest> _immediateQ;
  List<NetRequest> _parallelQ;
  Map<int, List<NetRequest>> _priorityQ;

  bool _pauseSequentialQ;

  NetRequestQueue(this.dispatcher) {
    _queueState = kStateInit;
    _pauseSequentialQ = false;

    repo = new NetRequestRepository();
  }

  bool get isLoaded => _queueState == kStateLoaded;

  bool get canProcess => _queueState == kStateProcess;

  Future<Null> loadIfNeeded() async {
    if (isLoaded) {
      return;
    }
    await load();
  }

  load() async {
    if (_queueState != kStateInit) {
      return;
    }

    _queueState = kStateLoading;
    await _loadCache(await repo.load());
    _queueState = kStateLoaded;
  }

  _loadCache(List<NetRequest> storedRequests) async {
    if (storedRequests == null) {
      _loadEmptyQueues();
      return;
    }

    _immediateQ = storedRequests.where((n) {
      n.requestPolicy.fireImmediate;
    });

    _parallelQ = storedRequests.where((n) {
      n.requestPolicy.fireParallel;
    });

    List<NetRequest> _sequential = storedRequests.where((n) {
      n.requestPolicy.fireSequential;
    });

    _loadEmptyQueues();

    if (_sequential != null) {
      _sequential.forEach((request) {
        int priority = request.requestPolicy.priority;
        _priorityQ.putIfAbsent(priority, () => new List<NetRequest>());
        _priorityQ[priority].add(request);
      });
    }
  }

  _loadEmptyQueues() {
    if (_immediateQ == null) {
      _immediateQ = [];
    }

    if (_parallelQ == null) {
      _parallelQ = [];
    }

    if (_priorityQ == null) {
      _priorityQ = new Map();
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Future<Null> add(NetRequest request) async {
    await loadIfNeeded();

    bool valid = await _addIfValid(request);
    if (valid) {
      if (isLoaded) {
        _queueState = kStateProcess;
      }
      await process();
    }
  }

  Future<bool> _addIfValid(NetRequest request) async {

    NetRequest _oldOf(NetRequest request, List<NetRequest> list) {
      return list.isEmpty ? null :
        list.firstWhere((n) => n.isSameEntity(request));
    }

    List<NetRequest> list = _findListOf(request);
    NetRequest oldRequest = _oldOf(request, list);
    bool result = false;

    if (oldRequest == null) {
      _addRequest(request, list);
      result = true;
    }
    else if (request.requestPolicy.canOverwrite) {

      if (!request.requestPolicy.processing) {
        _removeRequest(oldRequest, list);
        result = true;
      }
      else if (request.crudOperation != 'R' &&
          !request.havingSamePayload(oldRequest)) {

        _addRequest(request, list);
        result = true;
      }
    }

    return result;
  }

  Future<Null> _addRequest(NetRequest request, List<NetRequest> list) async {
    list.add(request);
    repo.local.update(request);
  }

  Future<Null> _removeRequest(NetRequest request, List<NetRequest> list) async {
    list.add(request);
    repo.local.delete(request);
  }

  List<NetRequest> _findListOf(NetRequest request) {
    List<NetRequest> list;

    if (request.fireSequential) {
      _priorityQ.putIfAbsent(
          request.requestPolicy.priority, () => new List<NetRequest>());
      list = _priorityQ[request.requestPolicy.priority];
    }
    else {
      list = request.fireParallel ? _parallelQ : _immediateQ;
    }

    return list;
  }

  Future<Null> remove(NetRequest request) async {
    await loadIfNeeded();
    await _removeRequest(request, _findListOf(request));
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////


  Future<Null> complete(NetRequest request) async {
    remove(request);
    process();
  }

  Future<Null> failed(NetRequest request) async {
    loadIfNeeded();

    if (request.retryPolicy.canRetry) {
      request.requestPolicy.processing = false;
      request.retryPolicy.currentAttempts++;
      repo.local.update(request);
    }
    else {
      await remove(request);
    }

    process();
  }

  Future<Null> incomplete(NetRequest request) async {
    loadIfNeeded();
    request.requestPolicy.processing = false;
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////


  Future<Null> process() async {
    if (!canProcess) {
      return;
    }

    _immediateQ.forEach((request) async {
      if (!request.requestPolicy.processing) {
        await _fire(request);
      }
    });

    _parallelQ.forEach((request) async {
      if (!request.requestPolicy.processing) {
        await _fire(request);
      }
    });

    if (_pauseSequentialQ) {
      return;
    }

    List<int> _priorities = _sortedPriorities();
    for (int i = 0; i < _priorities.length; i++) {
      List<NetRequest> _priorityXRequests = _priorityQ[_priorities[0]];
      if (_priorityXRequests.length == 0) {
        continue;
      }
      NetRequest _zerothRequest = _priorityXRequests[0];
      if (_zerothRequest.requestPolicy.processing) {
        continue;
      }
      _fire(_zerothRequest);
    }
  }

  List<int> _sortedPriorities() {
    List<int> keys = _priorityQ.keys.toList();
    keys.sort((i1, i2) => i1.compareTo(i2));
    return keys;
  }

  Future<Null> _fire(NetRequest request) async {
    request.requestPolicy.processing = true;
    await dispatcher.fire(request);
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  void flush() async {
    _queueState = kStateInit;
    _clear();
  }

  void _clear() {
    _clearCache();
    _clearDatabase();
  }

  void _clearCache() {
    _immediateQ.clear();
    _parallelQ.clear();
    _priorityQ.clear();
  }

  void _clearDatabase() {
    repo.local.deleteAll();
  }

  void release() {
    _queueState = kStateDead;
    _clear();
  }

  void pause() {
    _queueState = kStatePaused;
    _pauseSequentialQ = true;
  }

  void clearParallelQs() {
    _immediateQ.clear();
    _parallelQ.clear();
  }

  void clearOngoing() {
    dispatcher.clearOngoing();
  }

  void removeByEntityCrud(String crud) {

    _removeByEntityCrud(List<NetRequest> list, String crud) {
      list.removeWhere((request) {
        request.payload.crudOperation == crud;
      });
    }

    _removeByEntityCrud(_immediateQ, crud);
    _removeByEntityCrud(_parallelQ, crud);

    List<int> _priorities = _sortedPriorities();
    for (int i = 0; i < _priorities.length; i++) {
      List<NetRequest> _priorityXRequests = _priorityQ[_priorities[0]];
      if (_priorityXRequests.length == 0) {
        continue;
      }

      _removeByEntityCrud(_priorityXRequests, crud);
    }
  }

  void pauseSequentialQ() {
    _pauseSequentialQ = true;
  }

  void resumeSequentialQ() {
    _pauseSequentialQ = false;
  }
}