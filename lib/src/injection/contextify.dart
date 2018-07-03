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

import 'package:jvanila_flutter/src/eventbus/event_bus.dart';
import 'package:jvanila_flutter/src/io/file_io.dart';
import 'package:jvanila_flutter/src/mvp/mvp.dart';
import 'package:jvanila_flutter/src/net/net.dart';
import 'package:jvanila_flutter/src/sqlite/sqlite.dart';
import 'package:jvanila_flutter/src/sync/repository_factory.dart';

class Contextify {

  static ApplicationContext _context;

  static ApplicationContext get context => _context;

  static set context(appContext) => _context = appContext;

}

class ApplicationContext {

  IApplicationView application;

  FileAccessor disk;

  SqliteDatabase database;

  NetworkAccessor network;

  RepositoryFactory repoFactory;

  EventBus eventBus;
}