import 'package:hive_flutter/adapters.dart';

class ToDoDatabase {
  List toDoList = [];

  //reference box
  final _toDoBox = Hive.openBox("ToDoBox");
}