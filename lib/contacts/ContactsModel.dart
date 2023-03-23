import '../BaseModel.dart';

/// A class representing this PIM entity type.
class Contact {
  /// The fields this entity type contains.
  int? id;
  String name = "";
  String phone = "";
  String email = "";
  String birthday = ""; // YYYY,MM,DD

  /// Just for debugging, so we get something useful in the console.
  @override
  String toString() {
    return "{ id=$id, title=$name, description=$phone, apptDate=$email, apptTime=$birthday }";
  }
}

/// ********************************************************************************************************************
/// The model backing this entity type's views.
/// ********************************************************************************************************************
class ContactsModel extends BaseModel {
  /// "Force" a rebuild of the entry page (when selecting an avatar image).
  void trrigerRebuild() {
    print("## ContactsModel.triggerRebuild()");
    notifyListeners();
  }
}

// The one and only instance of this model.
ContactsModel contactsModel = ContactsModel();
