import 'package:todo_app/Entities/todo.dart';
import 'package:uuid/uuid.dart';

class Workspace {
  final String id;
  final String workspaceName;
  final List<Todo> todosList;

  Workspace({String? id, required this.workspaceName, required this.todosList})
    : id = id ?? const Uuid().v4();


  Workspace copyWith({String? workspaceName, List<Todo>? todosList}){
    return Workspace(
      id: id,
      workspaceName: this.workspaceName,
      todosList: this.todosList,
    );
  }
}