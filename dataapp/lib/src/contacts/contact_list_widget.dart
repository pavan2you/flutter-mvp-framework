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

import 'package:dataapp/src/contacts/contact.dart';
import 'package:dataapp/src/contacts/contact_list_presenter.dart';
import 'package:flutter/material.dart';
import 'package:jvanila_flutter/jvanila.dart';

class ContactListWidget extends RefreshableStateWidget {

  final BuildContext context;

  ContactListWidget(this.context);

  @override
  createRefreshableState() => new ContactListWidgetStateView(context);
}

class ContactListWidgetStateView extends PresentableStateView
    implements IContactListView {

  ContactListWidgetStateView(BuildContext context) : super(context);

  @override
  Presenter<IContactListView> createPresenter() {
    return new ContactListPresenter(this);
  }

  @override
  void setTitle(String title) {
    widgetTree['appBar'] = new AppBar(title: new Text(title));
  }

  @override
  Widget loadView(BuildContext context) {
    return new Scaffold(
      appBar: widgetTree['appBar'],);
  }

  @override
  void setDataModel(List<Contact> list) {
    // TODO: implement setDataModel
  }
}