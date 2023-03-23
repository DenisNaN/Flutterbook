import 'package:flutter/material.dart';
import "dart:io";
import "package:path_provider/path_provider.dart";
import "appointments/Appointments.dart";
import "contacts/Contacts.dart";
import "notes/Notes.dart";
import "tasks/Tasks.dart";
import "utils.dart" as utils;

/// Start it up!
void main() {
  startMeUp() async {
    WidgetsFlutterBinding.ensureInitialized();

    print("## main(): FlutterBook Starting");

    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(FlutterBook());
  }

  startMeUp();
}

/// ********************************************************************************************************************
/// Main app widget.
/// ********************************************************************************************************************
class FlutterBook extends StatelessWidget {
  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {
    print("## FlutterBook.build()");

    return MaterialApp(
        home: DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: AppBar(
                  title: const Text("FlutterBook"),
                  bottom: const TabBar(tabs: [
                    Tab(icon: Icon(Icons.date_range), text: "Appointments"),
                    Tab(icon: Icon(Icons.contacts), text: "Contacts"),
                    Tab(icon: Icon(Icons.note), text: "Notes"),
                    Tab(icon: Icon(Icons.assignment_turned_in), text: "Tasks")
                  ])),
              body: TabBarView(
                  children: [Appointments(), Contacts(), Notes(), Tasks()]),
              // children: [Appointments(), Contacts(), Notes(), Tasks()]),
            )));
  }
}
