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

import 'dart:async';

import 'package:dataapp/src/app/app.dart';
import 'package:dataapp/src/contacts/contact.dart';
import 'package:dataapp/src/contacts/contact_repository.dart';
import 'package:jvanila_flutter/jvanila.dart';

abstract class IContactListView extends IPresentableView {

  void setTitle(String title);

  void setDataModel(List<Contact> list);
}


class ContactListPresenter extends Presenter<IContactListView> {

  List<Contact> _contactList;

  ContactListPresenter(IContactListView view) : super(view);

  @override
  void onActivate() {
    super.onActivate();
    subscribeToEvents();
  }

  subscribeToEvents() {
    context.eventBus.subscribe(TypeOf<NetResponseEvent>(), this);
  }

  unsubscribeToEvents() {
    context.eventBus.unsubscribe(TypeOf<NetResponseEvent>(), this);
  }

  @override
  void onReady() {
    view.setTitle("Contacts");

    if (_contactList == null || _contactList.isEmpty) {
      _loadModel();
    }
    else {
      _showListOrInfo(_contactList);
    }
  }

  Future<Null> _loadModel() async {

    DataAppRepoFactory repoFactory = context.repoFactory;
    ContactRepository repo = repoFactory.contactRepository;
    ContactDAO dao = repo.local;

    List<Contact> contacts = await dao.getAllRecords();
    if (contacts == null || contacts.isEmpty) {
      ContactGateway gateway = repo.remote;
      gateway.fireReadListRequest();
    }
    else {
      _refreshWith(contacts);
    }
  }

  void _refreshWith(List<Contact> list) {
    _contactList = list;
    view.refresh();
  }

  void _showListOrInfo(List<Contact> list) {
    view.setDataModel(list);
  }

  @override
  void onEvent(event) {
    super.onEvent(event);

    if (event is NetResponseEvent) {
      onReadContactsSuccess(event.result);
    }
  }

  void onReadContactsSuccess(DataObjectList<Contact> objectList) {
    _refreshWith(objectList.list);
  }

  @override
  void onDeactivate() {
    unsubscribeToEvents();
    super.onDeactivate();
  }
}