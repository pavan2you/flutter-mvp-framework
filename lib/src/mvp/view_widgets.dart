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
import 'package:jvanila_flutter/src/core/utils.dart';
import 'package:jvanila_flutter/src/data/data.dart';
import 'package:jvanila_flutter/src/mvp/mvp.dart';


////////////////////////////////////////////////////////////////////////////////
////////////////////////////  RefreshableWidget  ///////////////////////////////
////////////////////////////////////////////////////////////////////////////////

abstract class RefreshableWidget extends StatelessWidget
  implements IRefreshable {

  final View view;
  final ElementHolder elementHolder;

  RefreshableWidget(this.view): elementHolder = new ElementHolder() {

    /*
     * Inject host, a very important step, which lets refreshing.
     */
    view.host = this;
    view.activate();
  }

  @override
  Widget build(BuildContext context) {
    return view.build(context);
  }

  @override
  StatelessElement createElement() {
    return elementHolder.element = new StatelessElement(this);
  }

  @override
  void refresh() {

    /*
     * Refresh the referenced view only by [View.load], calling [View.refresh]
     * will produce the cyclic call.
     */
    view.load();
    elementHolder.element.markNeedsBuild();
  }
}

///
/// A clean hack or fix, which lets to refresh or change the state of
/// [StatelessWidget].
///
class ElementHolder {
  Element element;
}


////////////////////////////////////////////////////////////////////////////////
/////////////////////////  RefreshableStateWidget  /////////////////////////////
////////////////////////////////////////////////////////////////////////////////

abstract class RefreshableStateWidget extends StatefulWidget
    implements IRefreshable {

  final RefreshableStateHolder stateHolder = new RefreshableStateHolder();

  State createState() => stateHolder.state = createRefreshableState();

  @override
  void refresh() {
    stateHolder.state.refresh();
  }

  @protected
  RefreshableState<StatefulWidget> createRefreshableState();
}

class RefreshableStateHolder<T extends RefreshableStateWidget> {
  RefreshableState<T> state;
}

abstract class RefreshableState<T extends StatefulWidget> extends State<T>
    implements IRefreshable {
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////  PresentableState  ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

abstract class PresentableState<T extends StatefulWidget>
    extends RefreshableState<T> {

  PresentableView view;

  PresentableState() {
    view = createView();
    view.host = this;
  }

  PresentableView createView();

  @override
  void initState() {
    super.initState();
    view.activate();
  }

  @override
  Widget build(BuildContext context) {
    return view.build(context);
  }

  @override
  void refresh() {
    setState(() => {});
  }

  @override
  void setState(VoidCallback fn) {
    view.load();
    super.setState(fn);
  }

  @override
  void deactivate() {
    view.deactivate();
    super.deactivate();
  }

  @override
  void dispose() {
    view.dispose();
    super.dispose();
  }
}


////////////////////////////////////////////////////////////////////////////////
//////////////////////////  PresentableStateView  //////////////////////////////
////////////////////////////////////////////////////////////////////////////////

abstract class PresentableStateView<T extends StatefulWidget>
    extends RefreshableState<T> implements PresentableView {

  @override
  BuildContext context;

  @override
  Widget builtWidget;

  @override
  Presenter<IPresentableView> presenter;

  @override
  Processor<IView> processor;

  @override
  Map<String, Object> propertyTree;

  @override
  Map<String, Widget> widgetTree;

  @override
  var host;

  PresentableStateView(this.context) {
    widgetTree = <String, Widget>{};
    propertyTree = <String, Widget>{};
    create();
  }

  @override
  create() {
    processor = createProcessor();
    processor.onCreate();
  }

  Processor<IPresentableView> createProcessor() {
    return presenter = createPresenter();
  }

  @override
  Presenter<IPresentableView> createPresenter();

  @override
  Processor<IView> getProcessor() {
    return processor;
  }

  @override
  Presenter<IPresentableView> getPresenter() {
    return presenter ??= NullPresenter(this);
  }

  @override
  IRefreshable getHost() {
    return host;
  }

  @override
  void inject(IRefreshable host) {
    this.host = host;
  }

  @override
  void initState() {
    super.initState();
    activate();
  }

  @override
  void activate() {
    presenter.onActivate();
  }

  @override
  void refresh() {
    setState(nullMethod);
  }

  @override
  void setState(VoidCallback fn) {
    load();
    super.setState(fn);
  }

  @override
  void load() {
    if (this.context == null) {
      throw Exception("ContextNotInitiatisedException");
    }
    presenter.onLoad();
    builtWidget = loadView(context);
  }

  @override
  Widget build(BuildContext context) {
    //always overwrite context
    this.context = context;

    if (builtWidget == null) {
      load();
    }

    return builtWidget;
  }

  @override
  void deactivate() {
    super.deactivate();
    presenter.onDeactivate();
  }

  @override
  void dispose() {
    context = null;
    widgetTree = null;
    propertyTree = null;
    builtWidget = null;
    processor.onDestroy();
    super.dispose();
  }
}


////////////////////////////////////////////////////////////////////////////////
/////////////////////////////  BindableState  //////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

abstract class BindableState<T extends StatefulWidget>
    extends RefreshableState<T> {

  BindableView view;

  BindableState() {
    view = createView();
    view.host = this;
    view.activate();
  }

  BindableView createView();

  @override
  Widget build(BuildContext context) {
    return view.build(context);
  }

  @override
  void refresh() {
    setState(nullMethod);
  }

  @override
  void setState(VoidCallback fn) {
    view.load();
    super.setState(fn);
  }

  @override
  void dispose() {
    view.dispose();
    super.dispose();
  }
}


////////////////////////////////////////////////////////////////////////////////
///////////////////////////  BindableStateView  ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

abstract class BindableStateView<W extends StatefulWidget, T extends DataObject>
    extends RefreshableState<W> implements BindableView<T> {

  @override
  BuildContext context;

  @override
  Widget builtWidget;

  @override
  DataBinder<IBindableView> binder;

  @override
  Processor<IView> processor;

  @override
  Map<String, Object> propertyTree;

  @override
  Map<String, Widget> widgetTree;

  @override
  List currentVarArgs;

  @override
  T tag;

  @override
  var host;

  BindableStateView(this.context) {
    widgetTree = <String, Widget>{};
    propertyTree = <String, Widget>{};
    create();
  }

  create() {
    processor = createProcessor();
    processor.onCreate();
  }

  Processor<IBindableView> createProcessor() {
    return binder = createBinder();
  }

  ///
  /// Flutter doesn't support reflection, so leave the responsibility of
  /// creating [DataBinder] to sub classes.
  ///
  DataBinder<IBindableView> createBinder();

  @override
  Processor<IView> getProcessor() {
    return processor;
  }

  @override
  DataBinder<IBindableView> getDataBinder() {
    return binder ??= NullBinder(this);
  }

  @override
  IRefreshable getHost() {
    return host;
  }

  @override
  void inject(IRefreshable host) {
    this.host = host;
  }

  @override
  void initState() {
    super.initState();
    activate();
  }

  @override
  void activate() {
    binder.onActivate();
  }

  @override
  Widget build(BuildContext context) {
    //always overwrite context
    this.context = context;

    if (builtWidget == null) {
      load();
    }

    return builtWidget;
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

  @override
  void refresh() {
    setState(nullMethod);
  }

  @override
  void setState(VoidCallback fn) {
    load();
    super.setState(fn);
  }

  @override
  void deactivate() {
    super.deactivate();
    binder.onDeactivate();
  }

  @override
  void dispose() {
    context = null;
    widgetTree = null;
    propertyTree = null;
    builtWidget = null;
    processor.onDestroy();
    super.dispose();
  }
}


////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////  HELPERS  ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

class WidgetList extends Widget {

  final List<Widget> list;

  WidgetList(this.list);

  @override
  Element createElement() {
    return null;
  }

  void add(Widget widget) {
    list.add(widget);
  }

}