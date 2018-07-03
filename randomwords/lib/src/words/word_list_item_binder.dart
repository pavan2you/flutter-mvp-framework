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
import 'package:randomwords/src/words/word_model.dart';

abstract class IWordListItemView extends IBindableView<WordModel> {

  void setLabel(String label);

  void setFavoriteIcon(IconData iconData, Color color);

  bool isStateful();

}

typedef void ItemCallback(IWordListItemView itemView, WordModel model);

class WordListItemDataBinder extends DataBinder<IWordListItemView> {

  WordListItemDataBinder(IWordListItemView view) : super(view);

  @override
  void onBind(List varArgs) {
    WordModel wordModel = varArgs[0] as WordModel;
    onBindRandomWordModel(wordModel);
  }

  void onBindRandomWordModel(WordModel model) {
    view.addTag(model);
    view.setLabel(model.wordPair.asPascalCase);

    bool isSaved = model.saved;
    IconData icon = isSaved ? Icons.favorite : Icons.favorite_border;
    Color color = isSaved ? Colors.red : null;
    view.setFavoriteIcon(icon, color);
  }
}