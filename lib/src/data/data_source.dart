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

import 'package:jvanila_flutter/src/data/data_object.dart';

abstract class DataSource<T extends DataObject> {

  Future<dynamic> create(T entity);

  Future<dynamic> update(T entity);

  Future<dynamic> delete(T entity);

  Future<dynamic> fetchAll();
}

class NullDataSource<T extends DataObject> extends DataSource {

  @override
  Future create(DataObject entity) {
    return null;
  }

  @override
  Future delete(DataObject entity) {
    return null;
  }

  @override
  Future fetchAll() {
    return null;
  }

  @override
  Future update(DataObject entity) {
    return null;
  }

}
