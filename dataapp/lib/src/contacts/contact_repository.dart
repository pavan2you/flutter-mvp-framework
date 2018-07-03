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
import 'dart:convert';

import 'package:dataapp/src/app/app.dart';
import 'package:dataapp/src/contacts/contact.dart';
import 'package:jvanila_flutter/jvanila.dart';
import 'package:sqflite/sqflite.dart';

class ContactRepository
    extends DataRepository<Contact, ContactDAO, ContactGateway> {

  ContactRepository({ContactDAO local, ContactGateway remote}) {
    ApplicationContext context = Contextify.context;

    if (local == null) {
      local = new ContactDAO(context.database.database);
    }

    if (remote == null) {
      remote = new ContactGateway();
      context.network.registry
          .putIfAbsent(remote.runtimeType.toString(), () => remote);
    }

    this.local = local;
    this.remote = remote;
  }
}

class ContactTableInfo extends SQLiteTableInfo<Contact> {

  ContactTableInfo(String name, [String pk, String fk, List<String> cpk,
      List<String> cfk]) : super(name, pk, fk, cpk, cfk);

  String getValueOf(Contact dto, String key) {
    if (key == primaryKey) {
      return dto.contactId;
    }
    return null;
  }
}

class ContactDAO extends LocalRepository<Contact> {

  @override
  final SQLiteTableInfo<Contact> tableInfo;

  ContactDAO(Database database, [SQLiteTableInfo<Contact> tableInfo])
      : this.tableInfo = new ContactTableInfo("Contact", "contactId"),
        super(tableInfo, database);

  @override
  Future<int> create(Contact dto) async {
    int res = await database.insert("Contact", dto.toMap());
    return res;
  }

  @override
  Contact toDataObject(Map<String, dynamic> record) {
    Contact contact = new Contact();
    if (record.containsKey("contactId")) {
      contact.contactId = record["contactId"];
    }
    if (record.containsKey("fullName")) {
      contact.fullName = record["fullName"];
    }
    if (record.containsKey("email")) {
      contact.email = record["email"];
    }
    return contact;
  }
}

class ContactGateway extends RemoteRepository<Contact> {

  static const String READ_CONTACT_URL = 'http://api.randomuser.me/?results=15';

  void fireReadListRequest() {

    EndPoint endPoint = new EndPoint(
      "http://api.randomuser.me", "GET", READ_CONTACT_URL,);

    Payload payload = new Payload('R', "Contact", "Contact");

    RequestPolicy requestPolicy = new RequestPolicy(
      true, RequestPolicy.kFireParallel, RequestPolicy.kPriorityGet, true,);

    ResponsePolicy responsePolicy = new ResponsePolicy(
      ResponsePolicy.kServeAsString,);

    int createdAt = new DateTime.now().millisecondsSinceEpoch;

    NetRequest netRequest = new NetRequest(uuid(), createdAt,
      name(ContactGateway), endPoint, payload, requestPolicy, responsePolicy,
      new RetryPolicy(),);

    netRequest.send();
  }

  @override
  void success(NetResponse response) {
    super.success(response);

    switch (response.request.payload.crudOperation) {
      case 'R':
        onReadContactListSuccess(response);
        break;
    }
  }

  Future<Null> onReadContactListSuccess(NetResponse response) async {
    final JsonDecoder decoder = new JsonDecoder();
    final jsonResponse = decoder.convert(response.body);
    final List jsonArray = jsonResponse['results'];

    final List<Contact> contacts = _toContactList(jsonArray);
    await _storeToDatabase(contacts);

    final NetResponseEvent event = NetResponseEvent(
      response, new DataObjectList<Contact>(contacts),);
    Contextify.context.eventBus.publish(event);
  }

  Future<Null> _storeToDatabase(List<Contact> contacts) async {
    DataAppRepoFactory repo = Contextify.context.repoFactory;
    ContactDAO contactDAO = repo.contactRepository.local;

    contacts.forEach((contact) {
      Future<int> result = contactDAO.create(contact);
      result.then((onValue) {
        if (onValue > -1) {
          print("Contact with id - " + contact.contactId + "inserted.");
        }
      });
    });
  }

  List<Contact> _toContactList(List jsonArray) {
    List<Contact> contacts = [];
    jsonArray.forEach((jsonObject) {
      Contact contact = _toContact(jsonObject);
      contacts.add(contact);
    });
    return contacts;
  }

  Contact _toContact(jsonObject) {
    Contact contact = Contact.fromJson(jsonObject);
    contact.contactId = uuid();
    return contact;
  }
}
