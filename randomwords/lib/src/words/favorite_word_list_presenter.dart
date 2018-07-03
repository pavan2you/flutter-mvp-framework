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

import 'package:jvanila_flutter/jvanila.dart';
import 'package:randomwords/src/words/word_model.dart';

abstract class IFavoriteWordListView extends IPresentableView {

  void setAppBarWithTitle(String title);

  void setListModel(List<WordModel> list);

  void showCallerView();
}

class FavoriteWordListPresenter extends Presenter<IFavoriteWordListView> {

  final List<WordModel> modelList;

  FavoriteWordListPresenter(IFavoriteWordListView view,
      this.modelList) : super(view);

  @override
  void onReady() {
    view.setAppBarWithTitle('Saved Suggestions');
    view.setListModel(modelList);
  }
}