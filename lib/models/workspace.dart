import 'package:todo_app/models/todo.dart';
import 'package:uuid/uuid.dart';

class Workspace {
  final String id;
  final String workspaceName;
  List<Todo> todos;

  Workspace({String? id, required this.workspaceName, List<Todo>? todos})
    : id = id ?? const Uuid().v4(),
    todos = todos ?? [];

  Workspace.empty()
    : id = const Uuid().v4(),
    workspaceName = "",
    todos = [];

  Workspace copyWith({String? workspaceName}) {
    return Workspace(
      id: id,
      workspaceName: workspaceName ?? this.workspaceName,
      todos: todos
    );
  }
}