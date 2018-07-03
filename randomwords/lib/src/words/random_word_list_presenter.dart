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

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:jvanila_flutter/jvanila.dart';
import 'package:randomwords/src/words/word_list_item_binder.dart';
import 'package:randomwords/src/words/word_model.dart';


abstract class IRandomWordListView extends IPresentableView {

  void showFavoriteWordListView(List<WordModel> list);

  void setTitle(String title);

  void setFavListMenuIcon(IconData iconData, onPressedCallback());

  void setAppBar();

  void setListWithDynamicModel();

}

class RandomWordListPresenter extends Presenter<IRandomWordListView> {

  final _suggestions = <WordModel>[];
  final _saved = List<WordModel>();

  RandomWordListPresenter(IRandomWordListView view) : super(view);

  @override
  void onReady() {
    view.setTitle('Startup Names Generator');
    view.setFavListMenuIcon(Icons.list, onShowFavoritesTap);
    view.setAppBar();

    view.setListWithDynamicModel();
  }

  WordModel getDynamicModelFor(int position) {
    WordModel result;

    final index = position ~/ 2;
    if (index >= _suggestions.length) {
      List<WordModel> generatedModels = generateWordPairs().take(10).map((
          word) => _toWordModel(word)).toList();
      _suggestions.addAll(generatedModels);
    }
    result = _suggestions[index];

    return result;
  }

  WordModel _toWordModel(WordPair word) {
    WordModel model = WordModel();
    model.wordPair = word;
    return model;
  }

  onListItemTap(IWordListItemView itemView, WordModel model) {
    if (model == null) {
      return;
    }

    model.saved = !model.saved;
    if (model.saved) {
      _saved.add(model);
    }
    else {
      _saved.remove(model);
    }

    if (itemView.isStateful()) {
      itemView.refresh();

      /*
      or

      to refresh multiple associated views

      model.tagList.map((taggedView) {
        if (taggedView is IRefreshable) {
          taggedView.refresh();
        }
      });

      */
    }
    else {
      view.refresh();
    }
  }

  onShowFavoritesTap() {
    view.showFavoriteWordListView(_saved);
  }
}
