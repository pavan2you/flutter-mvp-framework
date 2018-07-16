
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

import 'package:jvanila_flutter/jvanila.dart';
import 'package:jvanila_flutter/src/net/header_builder.dart';

///
/// Must Override to enhance injection
///
class Injector {

  ApplicationContext context;

  Injector(ApplicationContext context) {
    Contextify.context = context;
    this.context = context;
  }

  injectApplication(IApplicationView app) {
    context.application = app;
    injectOnAppCreate();
  }

  injectOnAppCreate() {
    injectEventBus();
    injectDiskAccessor();
    injectNetworkAccessor();
    injectApisOnAppCreate();
  }

  injectEventBus() {
    context.eventBus = new EventBus();
  }

  injectDiskAccessor() {
    context.disk = new FileAccessor();
  }

  injectNetworkAccessor() {
    context.network = new NetworkAccessor(new HeaderBuilder());
  }

  injectDataAccessors(SqliteDatabase database) {
    /*
     * 1. database
     * 2. repo factory
     * 3. network accessor
     */
    context.database = database;
    injectRepoFactory(database);
    injectApisOnReady();
  }

  injectRepoFactory(SqliteDatabase database) {
    context.repoFactory = newRepoFactory();
  }

  ///
  /// Must Override to customize
  ///
  RepositoryFactory newRepoFactory() {
    return null;
  }

  ///
  /// Must Override to customize
  ///
  /// When app created,
  /// Any third party app specific APIs can be initialised here.
  ///
  /// ex : My3rdPartyService _my3rdPartyService = new My3rdPartyService(...)
  /// context.apis['My3rdPartyService'] = _my3rdPartyService;
  ///
  void injectApisOnAppCreate() {
  }

  ///
  /// Must Override to customize
  ///
  /// When app resolved dependencies and it is ready,
  /// Any third party app specific APIs can be initialised here.
  ///
  /// ex : My3rdPartyService _my3rdPartyService = new My3rdPartyService(...)
  /// context.apis['My3rdPartyService'] = _my3rdPartyService;
  ///
  void injectApisOnReady() {
  }
}


