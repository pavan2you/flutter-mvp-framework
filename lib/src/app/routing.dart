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

class Routing {

  static runAppWidget(Widget app) {
    runApp(app);
  }

  static Map<Type, Widget> _widgets = new Map();
  static List<Widget> _stack = <Widget>[];

  static void push(BuildContext context, Widget widget) {
    PageRoute nextPage = new MaterialPageRoute(
      builder: (context) => widget,
      settings: new RouteSettings(name : "/" + widget.runtimeType.toString(),
          isInitialRoute: false)
    );

    _widgets[widget.runtimeType] = widget;
    _stack.add(widget);

    Navigator.of(context).push(nextPage);
  }

  static void pop(BuildContext context, Type widgetType) {
    PageRoute nextPage = new MaterialPageRoute(
      builder: (context) => null,
      settings: new RouteSettings(name : "/" + widgetType.toString(),
            isInitialRoute: false),
    );

    //pop stack till widgetType is found
    for (int i = _stack.length - 1; i >= 0; i--) {
      Widget widget = _stack[i];
      if (widget.runtimeType != widgetType) {
        _stack.removeAt(i);
        _widgets.remove(widget.runtimeType);
      }
      break;
    }

    RoutePredicate predicate = (Route<dynamic> route) =>
      route.settings.name == nextPage.settings.name;

    Navigator.of(context).popUntil(predicate);
  }

  static void popToRoot(BuildContext context) {
    PageRoute nextPage = new MaterialPageRoute(
      builder: (context) => null,
      settings: new RouteSettings(name : "/",
          isInitialRoute: true),
    );

    RoutePredicate predicate = (Route<dynamic> route) =>
    route.settings.name == nextPage.settings.name;

    Navigator.of(context).popUntil(predicate);
  }

  static void popWithResult(BuildContext context, Type widgetType,
      Widget from, Object result) {
    Widget widget = _widgets[widgetType];
  }

  static void replaceTop(BuildContext context, Widget widget) {
    PageRoute nextPage = new MaterialPageRoute(
        builder: (context) => widget,
        settings: new RouteSettings(name : "/" + widget.runtimeType.toString(),
            isInitialRoute: false)
    );

    if (_stack.length > 0) {
      Widget top = _stack.last;
      _widgets.remove(top.runtimeType);
      _stack.removeLast();
    }

    _widgets[widget.runtimeType] = widget;
    _stack.add(widget);

    Navigator.of(context).pushReplacement(nextPage);
  }
}
