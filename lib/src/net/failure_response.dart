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
import 'package:jvanila_flutter/src/net/net.dart';

class FailureResponse extends DataObject {

  static const int kTypeInternal      = 0;
  static const int kTypeNoNetwork     = 1;
  static const int kTypeForever       = 2;
  static const int kTypeClientFailure = 3;
  static const int kTypeAuthFailure   = 4;
  static const int kTypeServerFailure = 5;

  final int type;
  final String message;
  final NetRequest request;
  final DataObject requestedObject;

  FailureResponse(this.type, this.message, this.request,
      [this.requestedObject]);
}