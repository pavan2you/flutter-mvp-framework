
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

import 'package:dataapp/src/app/dataapp_injector.dart';
import 'package:dataapp/src/contacts/contact_list_widget.dart';
import 'package:jvanila_flutter/jvanila.dart';

class DataApplication extends ApplicationView {

  @override
  Injector newInjector(ApplicationContext context) {
    return new DataAppInjector(context);
  }

  @override
  SqliteParams newSqliteParams() {
    SqliteParams params = new SqliteParams();
    params.name = 'contacts.db';
    params.version = 1;
    params.createSchemas = ['create_schema.sql'];
    params.deleteSchemas = ['delete_schema.sql'];
    return params;
  }

  @override
  void setHomeView() {
    if (widgetTree['home'] == null) {
      widgetTree['home'] = new ContactListWidget(context);
    }
    else {
      ContactListWidget home = widgetTree['home'];
      home.refresh();
    }
  }
}