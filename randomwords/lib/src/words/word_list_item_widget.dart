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
import 'package:jvanila_flutter/jvanila.dart';
import 'package:randomwords/src/words/word_list_item_binder.dart';
import 'package:randomwords/src/words/word_model.dart';

///
/// Do cell-model biding using a [RefreshableWidget] as ListItem and inject
/// [WordListItemView]
///
class WordListItemWidget extends RefreshableWidget {

  WordListItemWidget(View view) : super(view);
}

///
/// Do cell-model biding using a [StatefulWidget] as ListItem and using [State]
/// as [BindableState] or [BindableStateView].
///
class WordListItemStatefulWidget extends StatefulWidget {

  final ItemCallback callback;
  final BuildContext context;
  final List varArgs;

  WordListItemStatefulWidget(this.callback, this.context, this.varArgs);

  @override
  createState() => new WordListItemBindableState(callback, varArgs, context);
                  // or new WordListItemStateView(callback, varArgs, context);

}

///
/// Do cell-model biding using a Widget as ListItem.
///
/// Advantage :
/// 1. No need to use a [StatefulWidget] and [State] combination.
/// 2. A simplistic approach when directly using as [Widget].
/// 3. This can be enclosed as part of [State].
///
///
/// Disadvantage :
/// 1. It might trigger entire [ListView] refresh while using as [Widget].
///
class WordListItemView extends BindableView<WordModel>
    implements IWordListItemView {

  final TextStyle _biggerFont = new TextStyle(fontSize: 18.0);
  var _onTapCallback;

  bool canRefresh;

  WordListItemView(f(IWordListItemView itemView, WordModel model),
    BuildContext context) : super(context) {

    _onTapCallback = f;
    canRefresh = false;
  }

  WordListItemView.varArgs(f(IWordListItemView itemView, WordModel model),
    BuildContext context, List varArgs) : super(context) {

    currentVarArgs = varArgs;
    _onTapCallback = f;
    canRefresh = true;
  }

  @override
  DataBinder<IWordListItemView> createBinder() {
    return WordListItemDataBinder(this);
  }

  @override
  void setLabel(String label) {
    widgetTree["title"] = new Text(label, style: _biggerFont);
  }

  @override
  void setFavoriteIcon(IconData iconData, Color color) {
    widgetTree["trailing"] = new Icon(iconData, color: color);
  }

  bool isStateful() {
    return canRefresh;
  }

  @override
  Widget loadView(BuildContext context) {
    var onTapSetState = () =>
    _onTapCallback == null ? null : _onTapCallback(this, tag);

    return new ListTile(
        title: widgetTree["title"],
        trailing: widgetTree["trailing"],
        onTap: onTapSetState
    );
  }
}


///
/// Do cell-model biding using a StatefulWidget as ListItem and using [State] as
/// [BindableStateView].
///
class WordListItemStateView
    extends BindableStateView<WordListItemStatefulWidget, WordModel>
    implements IWordListItemView {

  final TextStyle _biggerFont = new TextStyle(fontSize: 18.0);
  final ItemCallback _onTapCallback;

  @override
  var currentVarArgs;

  WordListItemStateView(this._onTapCallback, this.currentVarArgs,
      BuildContext context) : super(context);

  @override
  DataBinder<IWordListItemView> createBinder() {
    return WordListItemDataBinder(this);
  }

  @override
  void setLabel(String label) {
    widgetTree["title"] = new Text(label, style: _biggerFont);
  }

  @override
  void setFavoriteIcon(IconData iconData, Color color) {
    widgetTree["trailing"] = new Icon(iconData, color: color);
  }

  bool isStateful() {
    return true;
  }

  @override
  Widget loadView(BuildContext context) {
    var onTapSetState = () =>
    _onTapCallback == null ? null : _onTapCallback(this, tag);

    return new ListTile(
      title: widgetTree["title"],
      trailing: widgetTree["trailing"],
      onTap: onTapSetState,
    );
  }
}

///
/// Do cell-model biding using a StatefulWidget as ListItem and using [State] as
/// [BindableState].
///
class WordListItemBindableState extends BindableState<WordListItemStatefulWidget> {

  final ItemCallback _onTapCallback;
  final varArgs;
  final BuildContext context;

  WordListItemBindableState(this._onTapCallback, this.varArgs, this.context);

  @override
  BindableView<DataObject> createView() {
    return WordListItemView.varArgs(this._onTapCallback, context, varArgs,);
  }
}