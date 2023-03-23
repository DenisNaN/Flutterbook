import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'TasksDBWorker.dart';
import 'TasksModel.dart' show Task, TasksModel, tasksModel;
import 'package:flutterbook/utils.dart' as utils;

/// ********************************************************************************************************************
/// The Tasks Entry sub-screen.
/// ********************************************************************************************************************
class TasksEntry extends StatelessWidget {
  /// Controllers for TextFields.
  final TextEditingController _descriptionEditingController =
      TextEditingController();
  final TextEditingController _dueDateEditingController =
      TextEditingController();

  // Key for form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Constructor.
  NotesEntry() {
    print("## TasksList.constructor");

    // Attach event listeners to controllers to capture entries in model.
    _descriptionEditingController.addListener(() {
      tasksModel.entityBeingEdited.description =
          _descriptionEditingController.text;
    });
    _dueDateEditingController.addListener(() {
      tasksModel.entityBeingEdited.dueDate = _dueDateEditingController.text;
    });
  }

  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext context) {
    print("## TasksEntry.build()");

    // Set value of controllers.
    _descriptionEditingController.text =
        tasksModel.entityBeingEdited.description;
    _dueDateEditingController.text = tasksModel.entityBeingEdited.dueDate;

    // Return widget.
    return ScopedModel(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(builder:
            (BuildContext inContext, Widget? inChild, TasksModel inModel) {
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
                          _save(inContext, inModel);
                        },
                        child: Text("Save"))
                  ],
                ),
              ),
              body: Form(
                  key: _formKey,
                  child: ListView(children: [
                    // Description.
                    ListTile(
                        leading: Icon(Icons.description),
                        title: TextFormField(
                            decoration:
                                InputDecoration(hintText: "Description"),
                            controller: _descriptionEditingController,
                            validator: (inValue) {
                              if (inValue == null || inValue.isEmpty)
                                return "Please enter a description";
                              inModel.entityBeingEdited.description =
                                  _descriptionEditingController.text;
                              return null;
                            })),
                    // Due date.
                    ListTile(
                        leading: Icon(Icons.today),
                        title: Text("Due date"),
                        subtitle: Text(tasksModel.chosenDate == ""
                            ? ""
                            : tasksModel.chosenDate),
                        trailing: IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.blue,
                            onPressed: () async {
                              // Request a date from the user.  If one is returned, store it.
                              String chosenDate = await utils.selectDate(
                                  inContext,
                                  tasksModel,
                                  tasksModel.entityBeingEdited.dueDate);
                              if (chosenDate != "")
                                tasksModel.entityBeingEdited.dueDate =
                                    chosenDate;
                            }))
                  ])));
        }));
  }

  /// Save this contact to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The TasksModel.
  void _save(BuildContext inContext, TasksModel inModel) async {
    print("## TasksEntry._save()");

    // Abort if form isn't valid.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Creating a new task.
    if (inModel.entityBeingEdited.id == null) {
      print("## TasksEntry._save(): Creating: ${inModel.entityBeingEdited}");
      await TasksDBWorker.db.create(inModel.entityBeingEdited);

      // Updating an existing task.
    } else {
      print("## TasksEntry._save(): Updating: ${inModel.entityBeingEdited}");
      await TasksDBWorker.db.update(inModel.entityBeingEdited);
    }

    // Reload data from database to update list.
    inModel.loadData("tasks", TasksDBWorker.db);

    // Go back to the list view.
    inModel.setStackIndex(0);

    // Show SnackBar.
    ScaffoldMessenger.of(inContext).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Saved")));
  }
}
