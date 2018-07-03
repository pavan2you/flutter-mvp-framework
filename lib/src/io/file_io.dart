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
import 'dart:convert';
import 'dart:io';

import 'package:jvanila_flutter/src/data/data_object.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';

class FileAccessor {

  final JsonDecoder _decoder = new JsonDecoder();

  Future<String> getBasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> getLocalFile(String fileName) async {
    final path = await getBasePath();
    return File('$path/$fileName');
  }

  Future<Object> write(Object object, String fileName) {
    if (object is DataObject) {
      return writeDataObject(object);
    }
    else {
      return _writeObject(object, fileName);
    }
  }

  Future<String> read(String fileName) async {
    return _readObject(fileName);
  }

  Future<Null> writeBytes(List<int> bytes, String fileName) async {
    try {
      final file = await getLocalFile(fileName);
      await file.writeAsBytes(bytes);
    }
    catch (e) {
      throw e;
    }
  }

  Future<List<int>> readBytes(String fileName) async {
    try {
      final file = await getLocalFile(fileName);
      final List<int> data = await file.readAsBytes();
      return data;
    }
    catch (e) {
      throw e;
    }
  }

  Future<DataObject> writeDataObject(DataObject dataObject) async {
    try {
      final String json = dataObject.jsonify();

      final file = await getLocalFile(dataObject.getClassName());
      await file.writeAsString(json);
      return dataObject;
    }
    catch (e) {
      throw e;
    }
  }

  Future<DataObject> readDataObject(String fileName,
      reviver(Map<String, dynamic> map)) async {

    try {
      final String contents = await _readObject(fileName);
      Map<String, dynamic> json = _decoder.convert(contents);
      DataObject dataObject = reviver(json);

      return dataObject;
    }
    catch (e) {
      throw e;
    }
  }

  Future<Object> _writeObject(Object object, String fileName) async {
    try {
      final String json = object.toString();
      final file = await getLocalFile(fileName);
      await file.writeAsString(json);
      return object;
    }
    catch (e) {
      throw e;
    }
  }

  Future<String> _readObject(String fileName) async {
    try {
      final file = await getLocalFile(fileName);
      final String object = await file.readAsString();
      return object;
    }
    catch (e) {
      throw e;
    }
  }

  Future<bool> isFileExists(String fileName) async {
    final file = await getLocalFile(fileName);
    return file.exists();
  }

  Future<bool> delete(String fileName, bool recursiveDelete) async {
    final file = await getLocalFile(fileName);
    Future<FileSystemEntity> fse = file.delete(recursive: recursiveDelete);
    fse.then(
      (FileSystemEntity deletedEntity) async {
        bool stillExists = await deletedEntity.exists();
        return !stillExists;
      }
    ).catchError(
      (onError) {
        return false;
      }
    );
    return false;
  }

  Future<String> getAsset({@required String path}) async {
    return await rootBundle.loadString(path);
  }
}

String joinPaths(String part1, String part2) {
  return join(part1, part2);
}
