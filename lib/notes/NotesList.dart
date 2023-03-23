import 'package:flutter/material.dart';
import 'package:flutterbook/notes/NotesModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'NotesDBWorker.dart';

/// ****************************************************************************
/// The Notes List sub-screen.
/// ****************************************************************************
class NotesList extends StatelessWidget {
  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {
    print("## NotesList.build()");

    // Return widget.
    return ScopedModel(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
            builder: (inContext, Widget? inChild, NotesModel inModel) {
          return Scaffold(
              // Add note.
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    notesModel.entityBeingEdited = Note();
                    notesModel.setColor("");
                    notesModel.setStackIndex(1);
                  }),
              body: ListView.builder(
                  itemCount: notesModel.entityList.length,
                  itemBuilder: (BuildContext inBuildContext, int inIndex) {
                    Note note = notesModel.entityList[inIndex];
                    // Determine note background color (default to white if none was selected).
                    Color color = Colors.white;
                    switch (note.color) {
                      case "red":
                        color = Colors.red;
                        break;
                      case "green":
                        color = Colors.green;
                        break;
                      case "blue":
                        color = Colors.blue;
                        break;
                      case "yellow":
                        color = Colors.yellow;
                        break;
                      case "grey":
                        color = Colors.grey;
                        break;
                      case "purple":
                        color = Colors.purple;
                        break;
                    }
                    return Container(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Slidable(
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  label: 'Delete',
                                  backgroundColor: Colors.red,
                                  icon: Icons.delete,
                                  onPressed: (inContext) {
                                    _deleteNote(inBuildContext, note);
                                  },
                                ),
                              ],
                            ),
                            child: Card(
                                elevation: 8,
                                color: color,
                                child: ListTile(
                                    // Edit existing note.
                                    onTap: () async {
                                      // Get the data from the database and send to the edit view.
                                      notesModel.entityBeingEdited =
                                          await NotesDBWorker.db
                                              .get(note.id as int);
                                      notesModel.setColor(
                                          notesModel.entityBeingEdited!.color);
                                      notesModel.setStackIndex(1);
                                    },
                                    title: Text("${note.title}"),
                                    subtitle: Text("${note.content}")))));
                  }));
        }));
  }

  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext The BuildContext of the parent Widget.
  /// @param  inNote    The note (potentially) being deleted.
  /// @return           Future.
  Future<void> _deleteNote(BuildContext inContext, Note inNote) {
    print("## NotestList._deleteNote(): inNote = $inNote");
    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: Text("Delete Note"),
            content: Text("Are you sure you want to delete ${inNote.title}?"),
            actions: [
              TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    // Just hide dialog.
                    Navigator.of(inAlertContext).pop();
                  }),
              TextButton(
                  child: Text("Delete"),
                  onPressed: () async {
                    // Delete from database, then hide dialog, show SnackBar, then re-load data for the list.
                    await NotesDBWorker.db.delete(inNote.id as int);
                    Future(() {
                      Navigator.of(inAlertContext).pop();
                      ScaffoldMessenger.of(inContext).showSnackBar(SnackBar(
                          content: Text("Note deleted"),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2)));
                    });
                    // Reload data from database to update list.
                    notesModel.loadData("notes", NotesDBWorker.db);
                  })
            ],
          );
        });
  }
}
