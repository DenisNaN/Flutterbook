import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'NotesDBWorker.dart';
import 'NotesModel.dart' show Note, NotesModel, notesModel;

/// ****************************************************************************
/// The Notes Entry sub-screen.
/// ****************************************************************************
class NotesEntry extends StatelessWidget {
  /// Controllers for TextFields.
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController =
      TextEditingController();

  // Key for form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Constructor.
  NotesEntry() {
    print("## NotesEntry.constructor");

    // Attach event listeners to controllers to capture entries in model.
    _titleEditingController.addListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      notesModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext context) {
    print("## NotesEntry.build()");

    // Set value of controllers.
    if (notesModel.entityBeingEdited != null) {
      _titleEditingController.text = notesModel.entityBeingEdited.title;
      _contentEditingController.text = notesModel.entityBeingEdited.content;
    }

    // Return widget.
    return ScopedModel(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(builder:
            (BuildContext inContext, Widget? inChild, NotesModel inModel) {
          return Scaffold(
              bottomNavigationBar: Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          // Hide soft keyboard.
                          FocusScope.of(inContext).requestFocus(FocusNode());
                          // Go back to the list view.
                          inModel.setStackIndex(0);
                        },
                        child: Text("Cancel")),
                    Spacer(),
                    TextButton(
                        onPressed: () {
                          _save(inContext, notesModel);
                        },
                        child: Text("Save"))
                  ],
                ),
              ),
              body: Form(
                  key: _formKey,
                  child: ListView(children: [
                    // Title.
                    ListTile(
                        leading: Icon(Icons.title),
                        title: TextFormField(
                            decoration: InputDecoration(hintText: "Title"),
                            controller: _titleEditingController,
                            validator: (inValue) {
                              if (inValue == null || inValue.isEmpty)
                                return "Please enter a value";
                              return null;
                            })),
                    // Content.
                    ListTile(
                        leading: Icon(Icons.content_paste),
                        title: TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 8,
                            decoration: InputDecoration(hintText: "Content"),
                            controller: _contentEditingController,
                            validator: (inValue) {
                              if (inValue!.isEmpty)
                                return "Please enter content";
                              return null;
                            })),
                    // Note color.
                    ListTile(
                        leading: Icon(Icons.color_lens),
                        title: Row(children: [
                          GestureDetector(
                            onTap: () {
                              notesModel.entityBeingEdited!.color = "red";
                              notesModel.setColor("red");
                            },
                            child: Container(
                                decoration: ShapeDecoration(
                                    shape: Border.all(
                                            width: 18, color: Colors.red) +
                                        Border.all(
                                            width: 6,
                                            color: notesModel.color == "red"
                                                ? Colors.red
                                                : Theme.of(inContext)
                                                    .canvasColor))),
                          ),
                          Spacer(),
                          GestureDetector(
                              child: Container(
                                  decoration: ShapeDecoration(
                                      shape: Border.all(
                                              width: 18, color: Colors.green) +
                                          Border.all(
                                              width: 6,
                                              color: notesModel.color == "green"
                                                  ? Colors.green
                                                  : Theme.of(inContext)
                                                      .canvasColor))),
                              onTap: () {
                                notesModel.entityBeingEdited!.color = "green";
                                notesModel.setColor("green");
                              }),
                          Spacer(),
                          GestureDetector(
                              child: Container(
                                  decoration: ShapeDecoration(
                                      shape: Border.all(
                                              width: 18, color: Colors.blue) +
                                          Border.all(
                                              width: 6,
                                              color: notesModel.color == "blue"
                                                  ? Colors.blue
                                                  : Theme.of(inContext)
                                                      .canvasColor))),
                              onTap: () {
                                notesModel.entityBeingEdited!.color = "blue";
                                notesModel.setColor("blue");
                              }),
                          Spacer(),
                          GestureDetector(
                              child: Container(
                                  decoration: ShapeDecoration(
                                      shape: Border.all(
                                              width: 18, color: Colors.yellow) +
                                          Border.all(
                                              width: 6,
                                              color:
                                                  notesModel.color == "yellow"
                                                      ? Colors.yellow
                                                      : Theme.of(inContext)
                                                          .canvasColor))),
                              onTap: () {
                                notesModel.entityBeingEdited!.color = "yellow";
                                notesModel.setColor("yellow");
                              }),
                          Spacer(),
                          GestureDetector(
                              child: Container(
                                  decoration: ShapeDecoration(
                                      shape: Border.all(
                                              width: 18, color: Colors.grey) +
                                          Border.all(
                                              width: 6,
                                              color: notesModel.color == "grey"
                                                  ? Colors.grey
                                                  : Theme.of(inContext)
                                                      .canvasColor))),
                              onTap: () {
                                notesModel.entityBeingEdited!.color = "grey";
                                notesModel.setColor("grey");
                              }),
                          Spacer(),
                          GestureDetector(
                              child: Container(
                                  decoration: ShapeDecoration(
                                      shape: Border.all(
                                              width: 18, color: Colors.purple) +
                                          Border.all(
                                              width: 6,
                                              color:
                                                  notesModel.color == "purple"
                                                      ? Colors.purple
                                                      : Theme.of(inContext)
                                                          .canvasColor))),
                              onTap: () {
                                notesModel.entityBeingEdited!.color = "purple";
                                notesModel.setColor("purple");
                              })
                        ]))
                  ])));
        }));
  }

  /// Save this contact to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The NotesModel.
  void _save(BuildContext inContext, NotesModel inModel) async {
    print("## NotesEntry._save()");

    // Abort if form isn't valid.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Creating a new note.
    if (inModel.entityBeingEdited.id == null) {
      print("## NotesEntry._save(): Creating: ${inModel.entityBeingEdited}");
      await NotesDBWorker.db.create(notesModel.entityBeingEdited);

      // Updating an existing note.
    } else {
      print("## NotesEntry._save(): Updating: ${inModel.entityBeingEdited}");
      await NotesDBWorker.db.update(notesModel.entityBeingEdited);
    }

    // Reload data from database to update list.
    notesModel.loadData("notes", NotesDBWorker.db);

    // Go back to the list view.
    inModel.setStackIndex(0);

    // Show SnackBar.
    ScaffoldMessenger.of(inContext).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Saved")));
  }
}
