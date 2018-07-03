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
import 'package:jvanila_flutter/src/sqlite/sqlite.dart';
import 'package:jvanila_flutter/src/sqlite/sqlite_query.dart';
import 'package:sqflite/sqflite.dart';

abstract class LocalRepository<T extends DataObject> extends DataSource<T>
    implements ToDataObjectConverter<T> {

  Database database;

  final SQLiteTableInfo<T> tableInfo;

  LocalRepository(this.tableInfo, Database database) {
    this.database = database;
  }

  List<LocalRepository<DataObject>> loadDependableDaoList() {
    return null;
  }

  SQLiteTableInfo getTableInfo() {
    return tableInfo;
  }

  @override
  T toDataObjectTree(Map<String, dynamic> record, int childPolicy) {
    return toDataObject(record);
  }

  T toDataObject(Map<String, dynamic> record);

  bool needDependableDAODeleteCall(T dto) {
    return true;
  }

  //////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////  DataSource  ////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  @override
  Future<List<T>> fetchAll() async {
    return await getAllRecords();
  }

  //////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////  CREATE RECORDS  /////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  ///
  /// Subclass who need cascade inserts must override this, otherwise defaulted
  /// to [LocalRepository.createShallow].
  ///
  @override
  Future<int> create(T dto) async {
    return await createShallow(dto);
  }

  Future<int> createShallow(T dto) async {
    return await database.insert(tableInfo.name, dto.toMap());
  }

  Future<int> update(T dto) async {
    await deleteByIdAndPublish(tableInfo.getValueOf(dto, tableInfo.primaryKey),
        false);
    return await create(dto);
  }

  Future<int> updateShallow(T dto) async {
    deleteByColumn(tableInfo.primaryKey,
        tableInfo.getValueOf(dto, tableInfo.primaryKey));
    return createShallow(dto);
  }

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////  DELETE RECORDS  ///////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Future<bool> deleteAll() async {
    List<LocalRepository<
        DataObject>> dependableDaos = loadDependableDaoList();
    if (dependableDaos != null && dependableDaos.length > 0) {
      for (LocalRepository<DataObject> dao in dependableDaos) {
        dao.deleteAll();
      }
    }

    String query = "DELETE FROM " + tableInfo.name;

    return await new SQLiteQuery<T>(database, query, null, this).execute();
  }

  Future<bool> delete(T dto) async {
    bool needDependableDelete = needDependableDAODeleteCall(dto);

    return await deleteCascadeByIdAndPublish(
        tableInfo.getValueOf(dto, tableInfo.primaryKey), true, 
        needDependableDelete);
  }

  Future<bool> deleteById(String primaryKey) async {
    return await deleteByIdAndPublish(primaryKey, true);
  }

  Future<bool> deleteByIdAndPublish(String primaryKey, 
      bool isPublishable) async {
    return await deleteCascadeByIdAndPublish(primaryKey, isPublishable, true);
  }

  Future<bool> deleteCascadeByIdAndPublish(String primaryKey,
      bool isPublishable, bool needDependableDAODelete) async {

    if (needDependableDAODelete) {
      
      List<LocalRepository<DataObject>> dependableDaos = 
        loadDependableDaoList();
      
      if (dependableDaos != null && dependableDaos.length > 0) {
        T dto = await getRecord(primaryKey);
        if (dto != null) {
          for (LocalRepository<DataObject> dao in dependableDaos) {
          await dao.deleteByColumn(dao.getTableInfo().foreignKey, primaryKey);
          }
        }
      }
    }

    bool result = await deleteByColumn(tableInfo.primaryKey, primaryKey);
    if (result && isPublishable) {
      //todo : publish
    }

    return result;
  }

  Future<bool> deleteByColumn(String columnName, String columnValue) async {
    String query = "DELETE FROM " + tableInfo.name + " WHERE " + columnName +
        " = ?";
    List<String> params = [columnValue];

    return await new SQLiteQuery<T>(database, query, params, this).execute();
  }

  Future<bool> deleteByIdList(List<String> idList) async {

    List<LocalRepository<DataObject>> dependableDaos =
      loadDependableDaoList();

    if (dependableDaos != null && dependableDaos.length > 0) {
      for (LocalRepository<DataObject> dao in dependableDaos) {
        await dao.deleteByColumnInList(dao.getTableInfo().foreignKey, idList);
      }
    }

    return await deleteByColumnInList(tableInfo.primaryKey, idList);
  }

  bool deleteByIdListChunkByChunk(List<String> idList) {
    bool result = false;
    /*if (idList != null && idList.length > 0) {
      List<List<String>> uuidListChunks = getUuidListChunks(idList);
      for (List<String> chunk in uuidListChunks) {
        //todo : result |= deleteByIdList(chunk);
      }
    }*/
    return result;
  }

  Future<bool> deleteByColumnInList(String columnName,
      List<String> idList) async {

    String query = "DELETE FROM " + tableInfo.name + " WHERE " + columnName +
        " IN " + getInClausePlaceHolders(idList.length);

    return await new SQLiteQuery<T>(database, query, idList, this).execute();
  }

  void deleteByRequestCode(int requestCode, List<String> params) {
  //Empty
  }


  //////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////  GET RECORDS  ////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Future<int> getRecordCount() async {
    String query = "SELECT * FROM " + tableInfo.name;

    return await new SQLiteQuery<T>(database, query, null, this).getCount();
  }

  Future<List<T>> getAllRecords() async {
    String query = "SELECT * FROM " + tableInfo.name;

    return await new SQLiteQuery<T>(database, query, null, this)
        .getRecordList();
  }

  Future<T> getRecord(String primaryKey) async {
    String query = "SELECT * FROM " + tableInfo.name + " WHERE "
        + tableInfo.primaryKey + " =?";
    List<String> params = [primaryKey];

    return await new SQLiteQuery<T>(database, query, params, this).getRecord();
  }

  Future<bool> isRecordExits(String primaryKey) async {
    String query = "SELECT * FROM " + tableInfo.name + " WHERE " +
        tableInfo.primaryKey
        + " = ?";
    List<String> params = [primaryKey];

    return await new SQLiteQuery<T>(database, query, params, this).getCount()
        .then((size) => size > 0);
  }

  Future<T> getRecordByColumn(String columnName, String columnValue) async {
    String query = "SELECT * FROM " + tableInfo.name + " WHERE " + columnName +
        " = ?";
    List<String> params = [columnValue];

    return await new SQLiteQuery<T>(database, query, params, this).getRecord();
  }

  Future<List<T>> getRecordListByColumn(String columnName,
      String columnValue) async {

    String query = "SELECT * FROM " + tableInfo.name + " WHERE " + columnName +
        " = ?";
    List<String> params = [columnValue];

    return await new SQLiteQuery<T>(database, query, params, this)
        .getRecordList();
  }

  Future<List<T>> getRecordListByColumnIn(String columnName,
      List<String> list) async {
    String query = "SELECT * FROM " + tableInfo.name + " WHERE " + columnName +
        " IN " + getInClausePlaceHolders(list.length);

    return await new SQLiteQuery<T>(database, query, list, this)
        .getRecordList();
  }


  Future<List<T>> getWhere(Map<String, dynamic> whereValues) {
    //todo
    return null;
  }

  //////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////  UTILITIES  /////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  String getInClausePlaceHolders(int size) {
    StringBuffer queryBuilder = new StringBuffer("(");
    for (int i = 0; i < size; i++) {
      queryBuilder.write("?");
      if (i != size - 1) {
        queryBuilder.write(", ");
      }
    }
    queryBuilder.write(")");
    return queryBuilder.toString();
  }

  List<List<String>> getUuidListChunks(List<String> idList) {
    List<List<String>> uuidListChunks = [];
    List<String> uuidListChunk = [];
    uuidListChunks.add(uuidListChunk);

    for (int i = 0, j = 0; i < idList.length; i++) {
      uuidListChunk.add(idList[i]);
      if (j++ == 100) {
        //reset
        uuidListChunk = [];
        uuidListChunks.add(uuidListChunk);
        j = 0;
      }
    }
    return uuidListChunks;
  }
}