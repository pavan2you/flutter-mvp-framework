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

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:jvanila_flutter/jvanila.dart';

part 'contact.g.dart';

@JsonSerializable(nullable: false)
class Contact extends DataObject with _$ContactSerializerMixin {

  String contactId;
  String fullName;
  String email;

  Contact({this.fullName, this.email}) : contactId = uuid();

  factory Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);

  @override
  String jsonify() {
    return new JsonEncoder().convert(toJson());
  }

  Map<String, dynamic> toMap([Map<String, dynamic> map]) {
    map ??= new Map<String, dynamic>();
    map["contactId"] = contactId;
    map["fullName"] = fullName;
    map["email"] = email;
    return map;
  }
}

