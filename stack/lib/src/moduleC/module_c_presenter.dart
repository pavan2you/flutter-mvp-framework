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

abstract class IModuleCView extends IPresentableView {

  void setTitle(String title);

  void setPopButtonLabel(String label, callback());

  void showModuleAView(String fromLabel);

}

class ModuleCPresenter extends Presenter<IModuleCView> {

  ModuleCPresenter(IModuleCView view) : super(view);

  @override
  void onReady() {
    view.setTitle("ModuleC");
    view.setPopButtonLabel("Click To Move Back to ModuleA", onPopButtonTab);
  }

  onPopButtonTab() {
    view.showModuleAView("Popped from C");
  }
}