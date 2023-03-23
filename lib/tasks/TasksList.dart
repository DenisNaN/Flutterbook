import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterbook/tasks/TasksModel.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'TasksDBWorker.dart';

/// ********************************************************************************************************************
/// The Tasks List sub-screen.
/// ********************************************************************************************************************
class TasksList extends StatelessWidget {
  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(BuildContext inContext) {
    print("## TasksList.build()");

    // Return widget.
    return ScopedModel(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
            builder: (inContext, Widget? inChild, TasksModel inModel) {
          return Scaffold(
              // Add task.
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    tasksModel.entityBeingEdited = Task();
                    tasksModel.setStackIndex(1);
                  }),
              body: ListView.builder(
                  // Get the first Card out of the shadow.
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  itemCount: tasksModel.entityList.length,
                  itemBuilder: (BuildContext inBuildContext, int inIndex) {
                    Task task = tasksModel.entityList[inIndex];
                    // Get the date, if any, in a human-readable format.
                    String sDueDate = "";
                    if (task.dueDate != "") {
                      List dateParts = task.dueDate.split(",");
                      DateTime dueDate = DateTime(int.parse(dateParts[0]),
                          int.parse(dateParts[1]), int.parse(dateParts[2]));
                      sDueDate =
                          DateFormat.yMMMMd("en_US").format(dueDate.toLocal());
                    }
                    // Create the Slidable.
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            label: 'Delete',
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            onPressed: (inContext) {
                              _deleteTask(inBuildContext, task);
                            },
                          ),
                        ],
                      ),
                      child: ListTile(
                          leading: Checkbox(
                              value: task.completed == "true" ? true : false,
                              onChanged: (inValue) async {
                                // Update the completed value for this task and refresh the list.
                                task.completed = inValue.toString();
                                await TasksDBWorker.db.update(task);
                                tasksModel.loadData("tasks", TasksDBWorker.db);
                              }),
                          title: Text("${task.description}",
                              // Dim and strikethrough the text when the task is completed.
                              style: task.completed == "true"
                                  ? TextStyle(
                                      color: Theme.of(inContext).disabledColor,
                                      decoration: TextDecoration.lineThrough)
                                  : TextStyle(
                                      color: Theme.of(inContext)
                                          .textTheme
                                          .titleMedium
                                          ?.color)),
                          subtitle: task.dueDate == null
                              ? null
                              : Text(sDueDate,
                                  // Dim and strikethrough the text when the task is completed.
                                  style: task.completed == "true"
                                      ? TextStyle(
                                          color:
                                              Theme.of(inContext).disabledColor,
                                          decoration:
                                              TextDecoration.lineThrough)
                                      : TextStyle(
                                          color: Theme.of(inContext)
                                              .textTheme
                                              .titleMedium
                                              ?.color)),
                          // Edit existing task.
                          onTap: () async {
                            // Can't edit a completed task.
                            if (task.completed == "true") return;
                            // Get the data from the database and send to the edit view.
                            tasksModel.entityBeingEdited =
                                await TasksDBWorker.db.get(task.id as int);
                            // Parse out the due date, if any, and set it in the model for display.
                            if (tasksModel.entityBeingEdited.dueDate == null) {
                              tasksModel.setChosenDate("");
                            } else {
                              tasksModel.setChosenDate(sDueDate);
                            }
                            tasksModel.setStackIndex(1);
                          }),
                    );
                  }));
        }));
  }

  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext The parent build context.
  /// @param  inTask    The task (potentially) being deleted.
  /// @return           Future.
  Future<void> _deleteTask(BuildContext inContext, Task inTask) {
    print("## TasksList._deleteTask(): inTask = $inTask");
    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: Text("Delete Task"),
            content:
                Text("Are you sure you want to delete ${inTask.description}?"),
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
                    await TasksDBWorker.db.delete(inTask.id as int);
                    Future(() {
                      Navigator.of(inAlertContext).pop();
                      ScaffoldMessenger.of(inContext).showSnackBar(SnackBar(
                          content: Text("Task deleted"),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2)));
                    });
                    // Reload data from database to update list.
                    tasksModel.loadData("tasks", TasksDBWorker.db);
                  })
            ],
          );
        });
  }
}
