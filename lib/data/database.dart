import 'package:hive_flutter/adapters.dart';
import 'package:todo_app/Entities/todo.dart';

class ToDoDatabase {
  Map<String, List<Todo>> workspaces = {};

  //reference box
  final _toDoBox = Hive.box("ToDoBox");

  //it only runs the first time ever opening this app to put placeholder tasks
  void createInitialPlaceholderData() {
    workspaces = {
      "Generale": [
        Todo(taskName: "Watched the tutorial how to use the app", isChecked: true),
        Todo(taskName: "Create your first todo", isChecked: false)
      ],
    };
  }

  //load the data from db
  void loadData() {
  var rawData = _toDoBox.get("WORKSPACES", defaultValue: {});
  workspaces = Map<String, List<Todo>>.from(rawData);
}


  //update db
  void update() {
    _toDoBox.put("WORKSPACES", workspaces);
  }
}