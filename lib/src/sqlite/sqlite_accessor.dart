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

import 'package:jvanila_flutter/src/io/io.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

class SqliteParams {
  String name;
  int version;
  List<String> createSchemas;
  List<String> deleteSchemas;
}

abstract class SqliteDatabase {

  static const int _kStateIdle     = 0;
  static const int _kStateOpening  = 1;
  static const int _kStateFailed   = 2;
  static const int _kStateOpened   = 3;
  static const int _kStateClosed   = 4;

  SqliteParams params;
  int _currentState;
  int migratedVersionNumber;

  Database database;

  factory SqliteDatabase({@required SqliteParams params}) {
    return new _SqliteAccessor(params: params);
  }

  Future<Database> open();

  bool isOpening();

  bool isOpen();

  Future close();

  bool isCorrupted();

  bool isSecure();

  Future upgradeSchema(int oldVersion, int newVersion,
      List<String> oldVersionDeleteSchemaFileNames);

  int getMigratedFromVersionNumber();
}

class _SqliteAccessor implements SqliteDatabase {

  @override
  SqliteParams params;

  @override
  Database database;

  @override
  int _currentState;

  @override
  int migratedVersionNumber;

  _SqliteAccessor({@required SqliteParams params}) {
    _currentState = SqliteDatabase._kStateIdle;
    this.params = params;
  }

  @override
  Future<Database> open() async {
    var databasesPath = await getDatabasesPath();
    String path = joinPaths(databasesPath, params.name);

    _currentState = SqliteDatabase._kStateOpening;

    database = await openDatabase(path, version: params.version,
      onConfigure: _onConfigure, onCreate: _onCreate, onUpgrade: _onUpgrade,
      onOpen: _onOpen);

    return database;
  }

  Future _onConfigure(Database db) async {
    print("SqliteDebug : Configuring database $db");
  }

  Future _onCreate(Database db, int version) async {
    print("SqliteDebug : Creating database $db with version $version");
    await _createSchema(db, version);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print(
        "SqliteDebug : Upgrading database $db from $oldVersion to $newVersion");
  }

  Future _onOpen(Database db) async {
    _currentState = SqliteDatabase._kStateOpened;
    print("SqliteDebug : opened database $db");
  }

  @override
  Future close() async {
    await database.close();
    _currentState = SqliteDatabase._kStateClosed;
  }

  Future _createSchema(Database db, int version) async {
    params.createSchemas.forEach((schema) {
      SqlFileParser.executeSchema(db, schema);
    });
  }

  @override
  Future upgradeSchema(int oldVersion, int newVersion,
      List<String> oldVersionDeleteSchemaFileNames) async {

    await _upgradeSchema(database, oldVersion, newVersion,
        oldVersionDeleteSchemaFileNames);
  }

  Future _upgradeSchema(Database db, int oldVersion, int newVersion,
      List<String> migrationDeleteSchemaFileNames) async {

    migratedVersionNumber = oldVersion;

    migrationDeleteSchemaFileNames?.forEach((schemaName) async {
      await SqlFileParser.executeSchema(db, schemaName);
    });

    params.deleteSchemas?.forEach((schemaName) async {
      await SqlFileParser.executeSchema(db, schemaName);
    });

    _createSchema(db, newVersion);
  }

  @override
  int getMigratedFromVersionNumber() {
    return migratedVersionNumber;
  }

  @override
  bool isCorrupted() {
    return _currentState == SqliteDatabase._kStateFailed;
  }

  @override
  bool isOpening() {
    return _currentState == SqliteDatabase._kStateOpening;
  }

  @override
  bool isSecure() {
    return false;
  }

  @override
  bool isOpen() {
    return database != null;
  }
}

class SqlFileParser {

  static Future executeSchema(Database db, String schemaFileName) async {
    List<String> statements = await parseSQLFileFromAssets(schemaFileName);
    statements.forEach((statement) async {
      if (statement.isNotEmpty) {
        statement = statement.trim();
        print("SqlDebug : executing schema... -> " + statement);
        await db.execute(statement);
      }
    });
  }

  static Future<List<String>> parseSQLFileFromAssets(String path) async {
    path = joinPaths("assets/sql/", path);
    String data = await FileAccessor().getAsset(path: path);
    List<String> sqlStatements = data.split(";");
    return sqlStatements;
  }
}