import 'package:uuid/uuid.dart';

class Todo {
  final String id;
  final String taskName;
  final bool isChecked;

  Todo({String? id, required this.taskName, required this.isChecked})
    : id = id?? const Uuid().v4(); //generate an unique Id if it is null

  Todo copyWith({String? taskName, bool? isChecked}){
    return Todo(
      id: id, //it maintains the same id
      taskName: taskName?? this.taskName,
      isChecked: isChecked ?? this.isChecked
    );
  }
}