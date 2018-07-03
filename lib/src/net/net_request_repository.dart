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
import 'package:jvanila_flutter/src/net/net.dart';
import 'package:jvanila_flutter/src/sqlite/local_data_repository.dart';
import 'package:jvanila_flutter/src/sqlite/sqlite_accessor.dart';
import 'package:jvanila_flutter/src/sqlite/sqlite_table_info.dart';
import 'package:sqflite/sqflite.dart';

class NetRequestRepository extends DataRepository<NetRequest,
    NetRequestDAO, DataSource> {

  Future<List<NetRequest>> load() async {
    if (local == null) {
      SqliteDatabase database = await _initDatabase();
      local = new NetRequestDAO(database.database);
    }
    return await local.getAllRecords();
  }

  Future<SqliteDatabase> _initDatabase() async {
    SqliteParams params = new SqliteParams();
    params.name = 'jvanila.db';
    params.version = 1;
    params.createSchemas = ['create_jv_schema.sql'];
    params.deleteSchemas = ['delete_jv_schema.sql'];
    SqliteDatabase database = new SqliteDatabase(params: params);
    await database.open();
    return database;
  }
}

class NetRequestTableInfo extends SQLiteTableInfo<NetRequest> {

  NetRequestTableInfo(String name, [String primaryKey, String foreignKey,
      List<String> compositePrimaryKey, List<String> compositeForeignKey])
      : super(
      name, primaryKey, foreignKey, compositePrimaryKey, compositeForeignKey);

  String getValueOf(NetRequest dto, String key) {
    if (key == primaryKey) {
      return dto.requestId;
    }
    return null;
  }
}

class NetRequestDAO extends LocalRepository<NetRequest> {

  @override
  final SQLiteTableInfo<NetRequest> tableInfo;

  NetRequestDAO(Database database, [SQLiteTableInfo<NetRequest> tableInfo])
      : this.tableInfo = new NetRequestTableInfo("NetRequest", "requestId"),
        super(tableInfo, database);

  @override
  NetRequest toDataObject(Map<String, dynamic> map) {
    return NetRequest.fromMap(map);
  }
}
