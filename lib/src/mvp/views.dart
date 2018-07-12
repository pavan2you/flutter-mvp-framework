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
import 'package:jvanila_flutter/src/data/data.dart';
import 'package:jvanila_flutter/src/mvp/mvp.dart';
import 'package:meta/meta.dart';


////////////////////////////////////////////////////////////////////////////////
//////////////////////////////  Abstract View  /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

///
/// A refreshable component
///
abstract class IRefreshable {

  ///
  /// every [IRefreshable] should be refreshable
  ///
  void refresh();
}

///
/// A refreshable view component
///
abstract class IView implements IRefreshable {

  ///
  /// Get the associated intelligent processing component
  ///
  Processor<IView> getProcessor();

  ///
  /// The view, where it is associated / referenced / injected
  ///
  IRefreshable getHost();
}

///
/// A loosely coupled View representation from [StatelessWidget],
/// [StatefulWidget] and [State]
///
abstract class View implements IView {

  ///
  /// To build widgets the context is needed
  ///
  BuildContext context;

  ///
  /// The intelligent component glued to this
  ///
  Processor<IView> processor;

  ///
  /// A cached of version of this View's widget hierarchy
  ///
  Map<String, Widget> widgetTree;

  ///
  /// A cached of version of this View's property collection
  ///
  Map<String, Object> propertyTree;

  ///
  /// The current built Widget result
  ///
  Widget builtWidget;

  ///
  /// Where this view is referenced
  ///
  var host;

  View([this.context]) {
    widgetTree = <String, Widget>{};
    propertyTree = <String, Object>{};
    create();
  }

  void create() {
    processor = _createProcessor();
    processor.onCreate();
  }

  ///
  /// Leave [Processor] creation to respective views
  ///
  Processor<IView> _createProcessor();

  @override
  Processor<IView> getProcessor() {
    return processor;
  }

  ///
  /// If this [View] can't be refreshed by itself, then it can be accomplished
  /// by the host a [IRefreshable] component. Also check [refresh] method.
  ///
  void inject(IRefreshable host) {
    this.host = host;
  }

  @override
  IRefreshable getHost() {
    return host;
  }

  void activate() {
    processor.onActivate();
  }

  ///
  /// By default, map refresh to load, make sure no cycle between [refresh] and
  /// [State.setState] or [IRefreshable.refresh] to [View.refresh]
  ///
  void refresh() {
    host != null ? host.refresh() : load();
  }

  ///
  /// call [View.load] from [State.setState], so that the associated Brainee
  /// or Smart Component [Presenter] or [DataBinder] will prepare the view for
  /// the following [StatefulWidget.build] call.
  ///
  load() {
    if (this.context != null) {
      builtWidget = loadView(context);
    }
    else {
      print("Ignored {$this}.load");
    }
  }

  ///
  /// 1. The subclasses need to override this to build builtWidget from cached
  /// widgetTree or new one.
  ///
  /// 2. Either rebuild by access built widgets hierarchy to build the final
  /// widget or return cached instance builtWidget
  ///
  @protected
  Widget loadView(BuildContext context);

  ///
  /// Call this from [StatefulWidget.build] or [State.build] or
  /// [StatelessWidget.build] methods.
  ///
  Widget build(BuildContext context) {

    //always overwrite context
    if (context != null) {
      this.context = context;
    }

    if (this.context == null) {
      throw Exception("ContextNotInitiatisedException");
    }
    
    if (builtWidget == null) {
      load();
    }

    return builtWidget;
  }

  ///
  /// make the view unusable
  ///
  void deactivate() {
    processor.onDeactivate();
  }

  ///
  /// destroy or release the view
  ///
  void dispose() {
    context = null;
    widgetTree = null;
    propertyTree = null;
    builtWidget = null;
    processor.onDestroy();
  }
}


////////////////////////////////////////////////////////////////////////////////
/////////////////////////////  Presentable View  ///////////////////////////////
////////////////////////////////////////////////////////////////////////////////

///
/// Presentable Views are top level views, which contains a deep widget tree.
///
abstract class IPresentableView extends IView {

  Presenter<IPresentableView> getPresenter();
}

abstract class PresentableView extends View implements IPresentableView {

  Presenter<IPresentableView> presenter;

  PresentableView([BuildContext context]) : super(context);

  PresentableView.withRefreshable(BuildContext context) : super(context);

  @override
  Processor<IPresentableView> _createProcessor() {
    return presenter = createPresenter();
  }

  ///
  /// Flutter doesn't support reflection, so leave the responsibility of
  /// creating [Presenter] to sub classes otherwise default it to
  /// [NullPresenter]
  ///
  @protected
  Presenter<IPresentableView> createPresenter();

  @override
  Presenter<IPresentableView> getPresenter() {
    return presenter ??= NullPresenter(this);
  }

  @override
  void load() {
    presenter.onLoad();
    super.load();
  }
}


////////////////////////////////////////////////////////////////////////////////
//////////////////////////////  Bindable View  /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

///
/// Bindable Views represents are component views binds to a data item.
/// List's cell / row / item is an example of this.
///
abstract class IBindableView<T> extends IView {

  void addTag(T tag);

  T getTag();

  DataBinder<IBindableView> getDataBinder();
}

abstract class BindableView<T extends DataObject> extends View
    implements IBindableView<T> {

  DataBinder<IBindableView> binder;

  List currentVarArgs;

  T tag;

  BindableView([BuildContext context]) : super(context);

  @override
  Processor<IBindableView> _createProcessor() {
    return binder = createBinder();
  }

  ///
  /// Flutter doesn't support reflection, so leave the responsibility of
  /// creating [DataBinder] to sub classes.
  ///
  DataBinder<IBindableView> createBinder();

  DataBinder<IBindableView> getDataBinder() {
    return binder ??= NullBinder(this);
  }

  void activate() {
    super.activate();
    binder.onActivate();
  }

  Widget bind(List varArgs, [BuildContext context]) {
    currentVarArgs = varArgs;
    return build(context);
  }

  void _bindInternal(List varArgs) {
    currentVarArgs = varArgs;
    binder.onBind(varArgs);
    builtWidget = loadView(context);
  }

  @override
  void load() {
    if (this.context == null) {
      throw Exception("ContextNotInitiatisedException");
    }

    _bindInternal(currentVarArgs);
  }

  void addTag(T tag) {
    if (tag == null || !(tag is DataObject)) {
      return;
    }

    this.tag = tag;
    DataObject dataObject = tag;
    dataObject.addTag(this);
  }

  T getTag() {
    return tag;
  }

  void dispose() {
    super.dispose();
    binder.onDestroy();
  }
}