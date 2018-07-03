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
import 'package:helloworld/src/hello/hello_presenter.dart';
import 'package:jvanila_flutter/jvanila.dart';

class HelloWorldView extends PresentableView implements IHelloWorldView {

  HelloWorldPresenter thisPresenter;

  @override
  Presenter<IHelloWorldView> createPresenter() {
    return thisPresenter = new HelloWorldPresenter(this);
  }

  @override
  void setTitle(String title) {
    propertyTree['title'] = title;
    widgetTree['appBar'] = new AppBar(title: new Text(propertyTree['title']));
  }

  @override
  void showFabButton({dynamic Function() onClick}) {
    widgetTree['floatingActionButton'] = new FloatingActionButton(
      onPressed: onClick,
      tooltip: 'Increment',
      child: new Icon(Icons.add),
    );
  }

  @override
  void setContent(String content) {
    widgetTree['body'] = new Center(child: new Text(content));
  }

  @override
  Widget loadView(BuildContext context) {
    return new Scaffold(
      appBar: widgetTree['appBar'],
      body: widgetTree['body'],
      floatingActionButton: widgetTree['floatingActionButton'],);
  }
}

