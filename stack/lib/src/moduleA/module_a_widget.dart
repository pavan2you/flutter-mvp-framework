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

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:jvanila_flutter/jvanila.dart';
import 'package:stack/src/moduleA/module_a_presenter.dart';
import 'package:stack/src/moduleB/module_b_widget.dart';

class ModuleAWidget extends RefreshableWidget {

  ModuleAWidget(View view) : super(view);
}

class ModuleAView extends PresentableView implements IModuleAView {

  @override
  Presenter<IModuleAView> createPresenter() {
    return new ModuleAPresenter(this);
  }

  @override
  void setTitle(String title) {
    widgetTree['appBar'] = new AppBar(title: new Text(title),);
  }

  @override
  void setNextButtonLabel(String label, Function() callback) {
    widgetTree['body'] = new Center(
      child: new RaisedButton(child: new Text(label), onPressed: callback,),);
  }

  @override
  void showModuleBView() {
//    Routing.push(context, new ModuleBWidget(new ModuleBView()));
    Navigator.of(context).pushNamed('/moduleB');
  }

  @override
  Widget loadView(BuildContext context) {
    return new Scaffold(
      appBar: widgetTree['appBar'], body: widgetTree['body'],);
  }

}