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

import 'package:jvanila_flutter/src/data/data.dart';

abstract class SQLiteTableInfo<T extends DataObject> {

  String name;
  String primaryKey;
  String foreignKey;
  List<String> compositePrimaryKey;
  List<String> compositeForeignKey;

  SQLiteTableInfo(String name, [String primaryKey, String foreignKey,
      List<String> compositePrimaryKey, List<String> compositeForeignKey]) {

    this.name = name;
    this.primaryKey = primaryKey;
    this.foreignKey = foreignKey;
    this.compositePrimaryKey = compositePrimaryKey;
    this.compositeForeignKey = compositeForeignKey;
  }

  bool isHavingPrimaryKey() {
    return primaryKey != null;
  }

  bool isComposite() {
    return compositePrimaryKey != null;
  }

  bool isDependsOnComposite() {
    return compositeForeignKey != null;
  }

  bool isHavingForeignKey() {
    return foreignKey != null;
  }

  String getPrimaryKey() {
    return primaryKey;
  }

  String getForeignKey() {
    return foreignKey;
  }

  List<String> getCompositePrimaryKey() {
    return compositePrimaryKey;
  }

  List<String> getCompositeForeignKey() {
    return compositeForeignKey;
  }

  String getDefaultWhereFilter() {
    String whereClause = "";
    if (isHavingPrimaryKey()) {
      whereClause = primaryKey + " = ?";
    } else if (isComposite()) {
      for (String s in compositePrimaryKey) {
        whereClause +=
            (((whereClause.length > 0) ? " AND " : "") + s + " = ? ");
      }
    }
    return whereClause;
  }

  String getDependsOnWhereFilter() {
    String whereClause = "";
    if (isHavingPrimaryKey()) {
      whereClause = foreignKey + " = ?";
    } else if (isComposite()) {
      for (String s in compositeForeignKey) {
        whereClause += (((whereClause.length > 0) ? " AND" : "") + s + " = ? ");
      }
    }
    return whereClause;
  }

  String getValueOf(T dto, String key) {
    return null;
  }

  List<String> getCompositeValueOf(T dto, List<String> compositeKey) {
    return null;
  }
}
