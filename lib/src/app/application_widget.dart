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
import 'package:jvanila_flutter/src/injection/contextify.dart';
import 'package:jvanila_flutter/src/injection/injector.dart';
import 'package:jvanila_flutter/src/mvp/application_presenter.dart';
import 'package:jvanila_flutter/src/mvp/mvp.dart';
import 'package:jvanila_flutter/src/sqlite/sqlite.dart';


class ApplicationWidget extends RefreshableWidget {

  ApplicationWidget(ApplicationView view) : super(view);
}

abstract class ApplicationView extends PresentableView
    implements IApplicationView {

  @override
  bool appReady;

  Injector injector;

  Map<String, WidgetBuilder> routes;

  ApplicationView({BuildContext context, this.routes}) : super(context) {
    if (routes == null) {
      routes = <String, WidgetBuilder> {
      };
    }
  }

  void create() {
    injector = newInjector(new ApplicationContext());
    injector.injectApplication(this);
    super.create();
  }

  ///
  /// Must Override to customize
  ///
  Injector newInjector(ApplicationContext context) {
    return _newDefaultInjector(context);
  }

  Injector _newDefaultInjector(ApplicationContext context) {
    return new Injector(context);
  }

  @override
  Presenter<IApplicationView> createPresenter() {
    return createApplicationPresenter();
  }

  ///
  /// Must Override to customize
  ///
  ApplicationPresenter<IApplicationView> createApplicationPresenter() {
    return new ApplicationPresenter(this);
  }

  @override
  Future<dynamic> loadLaunchTimeDependencies() async {
    SqliteParams params = newSqliteParams();
    SqliteDatabase database;

    if (params != null) {
      database = SqliteDatabase(params: params);
      await database.open();
    }

    injector.injectDataAccessors(database);
    return database;
  }

  ///
  /// Must Override to customize
  ///
  SqliteParams newSqliteParams() {
    return null;
  }

  ///
  /// Override this if more args need to supply to [MaterialApp]
  ///
  @override
  Widget loadView(BuildContext context) {
    return new MaterialApp(home: widgetTree["home"], routes: routes,);
  }
}