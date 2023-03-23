import '../BaseModel.dart';

/// A class representing this PIM entity type.
class Task {
  /// The fields this entity type contains.
  int? id;
  String description = "";
  String dueDate = ""; // YYYY,MM,DD
  String completed = "false";

  /// Just for debugging, so we get something useful in the console.
  @override
  String toString() {
    return "{ id=$id, description=$description, dueDate=$dueDate, completed=$completed }";
  }
}

/// ********************************************************************************************************************
/// The model backing this entity type's views.
/// ********************************************************************************************************************
class TasksModel extends BaseModel {}

// The one and only instance of this model.
TasksModel tasksModel = TasksModel();
