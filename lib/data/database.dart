import 'package:hive_flutter/adapters.dart';

class ToDoDatabase {
  List toDoList = [];

  //reference box
  final _toDoBox = Hive.box("ToDoBox");

  //it only runs the first time ever opening this app to put placeholder tasks
  void CreateInitialPlaceholderData() {
    toDoList = [
      ["Watched the tutorial how to use the app", true],
      ["Create your first todo", false],
    ];
  }

  //load the data from db
  void loadData() {

  }

  //update db
  void updateDataBase() {

  }
}