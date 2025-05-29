import 'package:todo_app/Entities/todo.dart';
import 'package:uuid/uuid.dart';

class Workspace {
  final String id;
  final String workspaceName;
  List<Todo> todos;

  Workspace({String? id, required this.workspaceName, List<Todo>? todos})
    : id = id ?? const Uuid().v4(),
    todos = todos ?? [];

  Workspace copyWith({String? workspaceName, List<Todo>? todos}) {
    return Workspace(
      id: id,
      workspaceName: this.workspaceName,
      todos: this.todos
    );
  }
}