import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'ContactsModel.dart';

/// ********************************************************************************************************************
/// Database provider class for contacts.
/// ********************************************************************************************************************
class ContactsDBWorker {
  /// Static instance and private constructor, since this is a singleton.
  ContactsDBWorker._();

  static final ContactsDBWorker db = ContactsDBWorker._();

  /// The one and only database instance.
  Database? _db;

  /// Get singleton instance, create if not available yet.
  ///
  /// @return The one and only Database instance.
  Future get database async {
    _db ??= await init();

    print("## Contacts ContactsDBWorker.get-database(): _db = $_db");
    return _db;
  }

  /// Initialize database.
  ///
  /// @return A Database instance.
  Future<Database> init() async {
    print("Contacts ContactsDBWorker.init()");
    String path = join(utils.docsDir!.path, "contacts.db");
    print("## contacts ContactsDBWorker.init(): path = $path");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
      await inDB.execute("CREATE TABLE IF NOT EXISTS contacts ("
          "id INTEGER PRIMARY KEY, name TEXT, email TEXT, phone TEXT, birthday TEXT)");
    });
    return db;
  }

  /// Create a Contact from a Map.
  Contact contactFromMap(Map inMap) {
    print("## Contacts ContactsDBWorker.contactFromMap(): inMap = $inMap");
    Contact contact = Contact();
    contact.id = inMap["id"];
    contact.name = inMap["name"];
    contact.email = inMap["email"];
    contact.phone = inMap["phone"];
    contact.birthday = inMap["birthday"];
    print("## Contacts ContactsDBWorker.contactFromMap(): contact = $contact");

    return contact;
  }

  /// Create a Map from a Contact.
  Map<String, dynamic> contactToMap(Contact inContact) {
    print(
        "## Contacts ContactsDBWorker.contactToMap(): inContact = $inContact");
    Map<String, dynamic> map = <String, dynamic>{};
    map["id"] = inContact.id;
    map["name"] = inContact.name;
    map["email"] = inContact.email;
    map["phone"] = inContact.phone;
    map["birthday"] = inContact.birthday;
    print("## Contacts ContactsDBWorker.contactToMap(): map = $map");

    return map;
  }

  /// Create a contact.
  ///
  /// @param  inContact the Contact object to create.
  /// @return           The ID of the created contact.
  Future create(Contact inContact) async {
    print("## Contacts ContactsDBWorker.create(): inContact = $inContact");
    Database db = await database;

    // Get largest current id in the table, plus one, to be the new ID.
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM contacts");
    int id = val.first["id"] == null ? 1 : val.first["id"] as int;

    // Insert into table.
    return await db.rawInsert(
        "INSERT INTO contacts (id, name, email, phone, birthday) "
        "VALUES (?, ?, ?, ?, ?)",
        [
          id,
          inContact.name,
          inContact.email,
          inContact.phone,
          inContact.birthday
        ]);
  }

  /// Get a specific contact.
  ///
  /// @param  inID The ID of the contact to get.
  /// @return      The corresponding Contact object.
  Future<Contact> get(int inID) async {
    print("## Contacts ContactsDBWorker.get(): inID = $inID");
    Database db = await database;
    var rec = await db.query("contacts", where: "id = ?", whereArgs: [inID]);

    print("## Contacts ContactsDBWorker.get(): rec.first = $rec.first");
    return contactFromMap(rec.first);
  }

  /// Get all contacts.
  ///
  /// @return A List of Contact objects.
  Future<List> getAll() async {
    print("## Contacts ContactsDBWorker.getAll()");
    Database db = await database;
    var recs = await db.query("contacts");
    var list =
        recs.isNotEmpty ? recs.map((m) => contactFromMap(m)).toList() : [];

    print("## Contacts ContactsDBWorker.getAll(): list = $list");
    return list;
  }

  /// Update a contact.
  ///
  /// @param  inContact The contact to update.
  /// @return           Future.
  Future update(Contact inContact) async {
    print("## Contacts ContactsDBWorker.update(): inContact = $inContact");
    Database db = await database;
    return await db.update("contacts", contactToMap(inContact),
        where: "id = ?", whereArgs: [inContact.id]);
  }

  /// Delete a contact.
  ///
  /// @param  inID The ID of the contact to delete.
  /// @return      Future.
  Future delete(int inID) async {
    print("## Contacts ContactsDBWorker.delete(): inID = $inID");
    Database db = await database;
    return await db.delete("contacts", where: "id = ?", whereArgs: [inID]);
  }
}
