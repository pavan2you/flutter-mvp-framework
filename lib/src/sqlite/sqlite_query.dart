
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
import 'package:sqflite/sqflite.dart';

abstract class ToDataObjectConverter<T extends DataObject> {
  
  T toDataObjectTree(Map<String, dynamic> record, int childPolicy);
}

class SQLiteQuery<T extends DataObject> {

  String query;
  List<String> params;
  ToDataObjectConverter<T> converter;
  Database database;
  int childPolicy;

  SQLiteQuery(this.database, this.query, this.params, this.converter)
      :childPolicy = -1;

  SQLiteQuery.tree(this.database, this.query, this.params,
      this.converter, int childPolicy);

  void handleNoSuchColumnException(Exception e) {

    if (e.toString().contains("has no column") ||
        e.toString().contains("no such column")) {

      /*todo if (BuildConfig.DEBUG) {
        Toast.makeText(context, context.getApplicationContext().getPackageName()
            + " has some unrecoverable failure, please uninstall and install",
            Toast.LENGTH_LONG).show();
      }*/
    }
  }

  Future<String> getColumn(String columnName) async {
    String column;
    try {
      List<Map<String, dynamic>> results = await database.rawQuery(query,
          params);
      if (results.length > 0) {
        column = results[0][columnName];
      }
    }
    on Exception catch (e) {
      handleNoSuchColumnException(e);
    }
    
    return column;
  }

  Future<List<String>> getColumnList(String columnName) async {
    List<String> columnList;
    List<Map<String, dynamic>> results;
    try {

      results = await database.rawQuery(query, params);
      if (results.length > 0) {
        columnList = [];
        results.forEach((Map<String, dynamic> record) {
          columnList.add(record[columnName]);
        });
      }
    }
    on Exception catch (e) {
      handleNoSuchColumnException(e);
      print('$e');
    }

    return columnList;
  }

  Future<List<T>> getRecordList() async {

    List<T> dtoList;
    List<Map<String, dynamic>> results;
    try {
      results = await database.rawQuery(query, params);
      if (results.length > 0) {
        dtoList = [];
        results.forEach((Map<String, dynamic> record) {
          try {
            dtoList.add(converter.toDataObjectTree(record, childPolicy));
          }
          on Exception catch (e) {
            print('$e');
          }
        });
      }
    }
    on Exception catch (e) {
      handleNoSuchColumnException(e);
      print('$e');
    }

    return dtoList;
  }

  Future<T> getRecord() async {

    T dto;
    List<Map<String, dynamic>> results;
    try {
      results = await database.rawQuery(query, params);
      if (results.length > 0) {
        dto = converter.toDataObjectTree(results[0], childPolicy);
      }
    }
    on Exception catch (e) {
      handleNoSuchColumnException(e);
      print('$e');
    }

    return dto;
  }

  Future<int> getCount() async {
    int count = 0;
    List<Map<String, dynamic>> results;
    try {
      results = await database.rawQuery(query, params);
      count = results.length;
    }
    on Exception catch (e) {
      handleNoSuchColumnException(e);
      print('$e');
    }

    return count;
  }

  Future<bool> execute() async {
    int count = 0;
    List<Map<String, dynamic>> results;
    try {
      if (query.startsWith("DELETE")) {
        int indexOfFrom = query.indexOf("FROM") + "FROM".length;
        int indexOfWhere = query.indexOf("WHERE");
        String table = "";
        String whereClause;
        if (indexOfWhere == -1) {
          table = query.substring(indexOfFrom).trim();
        }
        else {
          table = query.substring(indexOfFrom, indexOfWhere).trim();
          whereClause = query.substring(indexOfWhere + "WHERE".length).trim();
        }

        count = await database.delete(table, where: whereClause,
            whereArgs: params);
      }
      else {
        results = await database.rawQuery(query, params);
        count = results.length;
      }
    }
    on Exception catch (e) {
      handleNoSuchColumnException(e);
      print('$e');
    }

    return count > 0;
  }

  void cancel() {
    /*todo if (mAsyncJob != null) {
      mAsyncJob.cancel();
    }*/
  }
}