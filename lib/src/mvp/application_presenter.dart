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

import 'package:flutter/material.dart';
import 'package:jvanila_flutter/src/mvp/mvp.dart';
import 'package:meta/meta.dart';


abstract class IApplicationView extends IPresentableView {

  bool appReady;

  Future<dynamic> loadLaunchTimeDependencies();

  void setHomeView();
}


class ApplicationPresenter<V extends IApplicationView> extends Presenter<V> {

  ApplicationPresenter(V view) : super(view);

  @override @mustCallSuper
  void onCreate() {
    super.onCreate();
    view.appReady = false;
    loadLaunchTimeDependencies();
  }

  Future<dynamic> loadLaunchTimeDependencies() async {
     await view.loadLaunchTimeDependencies();
      onApplicationReady();
  }
  
  @override
  void onLoad() {
    onReady();
  }

  @override
  void onReady() {
    view.setHomeView();
  }

  @mustCallSuper
  void onApplicationReady() {
    view.appReady = true;
    view.refresh();
  }
}