import 'package:hive_flutter/adapters.dart';
import 'package:todo_app/Entities/todo.dart';

class ToDoDatabase {
  List<Todo> toDoList = [];

  //reference box
  final _toDoBox = Hive.box("ToDoBox");

  //it only runs the first time ever opening this app to put placeholder tasks
  void createInitialPlaceholderData() {
    toDoList = [
      Todo(taskName: "Watched the tutorial how to use the app", isChecked: true),
      Todo(taskName: "Create your first todo", isChecked: false)
    ];
  }

  //load the data from db
  void loadData() {
  var rawList = _toDoBox.get("TODOLIST", defaultValue: []);
  toDoList = (rawList as List).map((item) => Todo(
    taskName: item["taskName"],
    isChecked: item["isChecked"]
  )).toList();
}


  //update db
  void update() {
    _toDoBox.put("TODOLIST", toDoList.map((todo) => {
      "taskName": todo.taskName,
      "isChecked": todo.isChecked
      })
    .toList());
  }
}