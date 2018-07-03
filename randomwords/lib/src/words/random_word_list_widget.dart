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
import 'package:randomwords/src/words/favorite_word_list_widget.dart';
import 'package:randomwords/src/words/random_word_list_presenter.dart';
import 'package:randomwords/src/words/word_list_item_widget.dart';
import 'package:randomwords/src/words/word_model.dart';

class RandomWordListWidget extends RefreshableStateWidget {

  final BuildContext context;

  RandomWordListWidget(this.context);

  @override
  createRefreshableState() => new RandomWordListStateView(context);
}

class RandomWordListStateView
    extends PresentableStateView<RandomWordListWidget>
    implements IRandomWordListView {

  RandomWordListPresenter thisPresenter;

  RandomWordListStateView(BuildContext context) : super(context);

  @override
  RandomWordListPresenter createPresenter() {
    return thisPresenter = RandomWordListPresenter(this);
  }

  @override
  void setTitle(String title) {
    if (widgetTree['appBar:title'] != null) {
      return; // build app bar title only once
    }

    widgetTree['appBar:title'] = Text(title);
  }

  @override
  void setFavListMenuIcon(IconData iconData, onPressedCallback()) {
    if (widgetTree['appBar:actions'] != null) {
      return; // build app bar icon only once
    }

    final IconButton listIconButton = new IconButton(icon: new Icon(iconData),
      onPressed: onPressedCallback,);

    WidgetList actionButtons = widgetTree['appBar:actions'];

    if (actionButtons == null) {
      actionButtons = WidgetList(<Widget>[]);
      widgetTree['appBar:actions'] = actionButtons;
    }
    actionButtons.add(listIconButton);
  }

  @override
  void setAppBar() {
    if (widgetTree['appBar'] != null) {
      return; // build app bar only once
    }

    WidgetList actionButtons = widgetTree['appBar:actions'];
    widgetTree['appBar'] = new AppBar(title: widgetTree['appBar:title'],
      actions: actionButtons.list,);
  }

  @override
  void setListWithDynamicModel() {
    widgetTree['body'] =  new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) => _buildListItem(context, index),
    );
  }

  Widget _buildListItem(BuildContext context, int position) {
    return (position.isOdd) ? new Divider() : newWordWidget(context, position);
  }

  Widget newWordWidget(BuildContext context, int position) {
    WordModel model = thisPresenter.getDynamicModelFor(position);

    //Stateless Item
    /*return WordListItemView(thisPresenter.onListItemTap, null, context)
        .bind([model], context);*/

    //Stateful Item
    /*return WordListItemStatefulWidget(thisPresenter.onListItemTap, context, [model]);*/

    //Stateless, but refreshable [RefreshableWidget]
    return new WordListItemWidget(new WordListItemView.varArgs(
        thisPresenter.onListItemTap, context, [model]),);
  }

  @override
  Widget loadView(BuildContext context) {
    return new Scaffold(appBar: widgetTree['appBar'], body: widgetTree['body']);
  }

  @override
  void showFavoriteWordListView(List<WordModel> list) {
    Routing.push(context, new FavoriteWordListWidget(context, list));
  }
}