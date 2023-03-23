import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'ContactsDBWorker.dart';
import 'ContactsList.dart';
import 'ContactsEntry.dart';
import 'ContactsModel.dart' show Contact, Contacts, ContactsModel, contactsModel;

/// ********************************************************************************************************************
/// The Contacts screen.
/// ********************************************************************************************************************
class Contacts extends StatelessWidget{

  /// Constructor.
  Contacts(){

    print("## Contacts.constructor");

    // Initial load of data.
    contactsModel.entityBeingEdited = Contact();
    contactsModel.loadData("contacts", ContactsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {

    print("## Contacts.build()");
    return ScopedModel<ContactsModel>(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(
            builder: (BuildContext inContext, Widget? inChild,
                ContactsModel inModel){
              return IndexedStack(
                  index: inModel.stackIndex,
                  children: [
                    ContactsList(),
                    ContactsEntry()
                  ]
              );
            }
        ));
  }
}