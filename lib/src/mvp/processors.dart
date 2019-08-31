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

import 'package:jvanila_flutter/src/eventbus/event_bus.dart';
import 'package:jvanila_flutter/src/injection/di.dart';
import 'package:jvanila_flutter/src/mvp/mvp.dart';

///
/// A generic representation of Controller / Presenter / ViewModel /
/// DataBinder / Intent / SmartComponent
///
abstract class Processor<V extends IView> {

  V view;
  ApplicationContext context;

  Processor(this.view);

  void onCreate() {
    context = Contextify.context;
    print("LauchDebug : page : onCreate - " + this.runtimeType.toString());
  }

  ///
  /// call this when the view wants to present its widget tree
  ///
  void onActivate() {}

  void onDeactivate() {}

  void onDestroy() {
    view = null;
  }

}

abstract class Presenter<V extends IPresentableView> extends Processor<V>
    implements EventSubscriber {

  Presenter(V view) : super(view);

  void onLoad() {
    print("LauchDebug : page : onLoad " + this.runtimeType.toString());
    bool appReady = Contextify.context.application.appReady;
    if (appReady) {
      print("LauchDebug : page : onLoad-onReady - trigger "
          + this.runtimeType.toString());
      onReady();
    }
    else {
      print("LauchDebug : page : onLoad-onReady - await "
          + this.runtimeType.toString());
    }
  }

  void onReady();

  void onEvent(var event) {
    //if required subclasses need to override this.
  }
}

class NullPresenter extends Presenter<IPresentableView> {

  NullPresenter(IPresentableView view) : super(view);

  @override
  void onReady() {
  }

}

abstract class DataBinder<V extends IBindableView> extends Processor<V> {

  DataBinder(V view) : super(view);

  void onBind(List varArgs);
}

class NullBinder extends DataBinder<IBindableView> {

  NullBinder(IBindableView view) : super(view);

  @override
  void onBind(List varArgs) {
  }

}