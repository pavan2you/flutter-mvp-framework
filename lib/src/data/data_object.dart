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

import 'package:json_annotation/json_annotation.dart';
import 'package:jvanila_flutter/src/eventbus/event.dart';

///
/// The value object, the model component of MVX.
///
class DataObject extends Event {

  @JsonKey(ignore: true)
  List<dynamic> tagList;

  @JsonKey(ignore: true)
  bool doNotRemoveSameClassTags;

  String crudOperation;

  DataObject() {
    tagList = new List();
    doNotRemoveSameClassTags = false;
    crudOperation = 'U';
  }

  String getClassName() {
    return runtimeType.toString();
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////  DATA BINDING  ////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  void addTag(Object object) {

    List<dynamic> tags = tagList;

    if (tags == null) {
      print("BindingDebug : failed to tag $this for $object");
      return;
    }

    bool found = false;
    int startSize = tags.length;

    for (int i = 0; i < tags.length; i++) {
      Object view = tags[i];

      if (view == object) {
        found = true;
        break;
      }
      else if (!doNotRemoveSameClassTags && view != null &&
          (view.runtimeType == object.runtimeType)) {

        tags.remove(object);
        break;
      }

      int newSize = tags.length;
      if (startSize > newSize) {
        i = i - (startSize - newSize);
      }
    }

    if (!found) {
      tags.add(object);
    }
  }


  //////////////////////////////////////////////////////////////////////////////
  ////////////////////////////  DATA CONVERSION  ///////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  ///
  /// All the json conversion needed subclasses should have similar method
  ///
  factory DataObject.fromJson(Map<String, dynamic> json) => new DataObject();

  ///
  /// to store object to the file system.
  ///
  String jsonify() {
    return "{Do-it-if-required}";
  }

  ///
  /// for Database inserts
  ///
  Map<String, dynamic> toMap([Map<String, dynamic> map]) {
    map ??= new Map<String, dynamic>();
    //fill here
    return map;
  }

  ///
  /// to read from database, the subclasses should maintain a similar factory
  /// method
  ///
  factory DataObject.fromMap(Map<String, dynamic> map) => new DataObject();
}

class DataObjectList<T extends DataObject> extends DataObject {

  final List<T> list;

  DataObjectList(this.list);

  Type get enclosedType => T;
}
