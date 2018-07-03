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
import 'package:randomwords/src/words/favorite_word_list_presenter.dart';
import 'package:randomwords/src/words/word_list_item_widget.dart';
import 'package:randomwords/src/words/word_model.dart';

class FavoriteWordListWidget extends StatefulWidget {

  final List<WordModel> wordList;
  final BuildContext context;

  FavoriteWordListWidget(this.context, this.wordList);

  @override
  createState() => new FavoriteWordListStateView(context, wordList);
}

class FavoriteWordListStateView
    extends PresentableStateView<FavoriteWordListWidget>
    implements IFavoriteWordListView {

  final List<WordModel> wordList;
  FavoriteWordListPresenter thisPresenter;

  FavoriteWordListStateView(BuildContext context, this.wordList)
      : super(context);

  @override
  Presenter<IFavoriteWordListView> createPresenter() {
    thisPresenter = FavoriteWordListPresenter(this, wordList);
    return thisPresenter;
  }

  @override
  void setAppBarWithTitle(String title) {
    widgetTree["appBar"] = new AppBar(title: new Text(title));
  }

  @override
  void setListModel(List<WordModel> list) {
    final Iterable<Widget> itemWidgets = list.map((model) {
      return new WordListItemView(null, context).bind([model]);
    });

    final List<Widget> dividedItemWidgets = ListTile.divideTiles(
      context: context, tiles: itemWidgets,).toList();

    widgetTree["body"] = new ListView(children: dividedItemWidgets);
  }

  @override
  Widget loadView(BuildContext context) {
    return new Scaffold(appBar: widgetTree["appBar"], body: widgetTree["body"]);
  }

  @override
  void showCallerView() {
    //just pop the stack
  }
}