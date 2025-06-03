import 'package:hive_flutter/adapters.dart';
import 'package:todo_app/data/firestore_service.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/models/workspace.dart';

class ToDoDatabase {
  List<Workspace> workspaces = [];
  final firestore = FirestoreService();

  //reference box
  final _toDoBox = Hive.box("ToDoBox");

  //it only runs the first time ever opening this app to put placeholder tasks
  void createInitialPlaceholderData() {
    workspaces = [
      Workspace(workspaceName: "Generale", todos: [
        Todo(taskName: "Watched the tutorial how to use the app", isChecked: true),
        Todo(taskName: "Create your first todo", isChecked: false),
      ])
    ];
  }

  //load the data from db
  void loadData() {
    var rawData = _toDoBox.get("WORKSPACES");
    workspaces = (rawData as List).map((ws) => Workspace(
      id: ws["id"],
      workspaceName: ws["name"],
      todos: (ws["todos"] as List).map((t) => Todo(
        taskName: t["taskName"],
        isChecked: t["isChecked"],
      )).toList(),
    )).toList();

  }

  //update db
  void update() {
    _toDoBox.put("WORKSPACES", workspaces.map((ws) => {
      "id": ws.id,
      "name": ws.workspaceName,
      "todos": ws.todos.map((t) => {
        "taskName": t.taskName,
        "isChecked": t.isChecked
      }).toList()
    }).toList());
  }

  Future<void> syncToFirebase(String userId) async {
    for (var workspace in workspaces) {
      await firestore.saveWorkspace(userId, workspace);
    }
  }

  Future<void> loadFromFirebase(String userId) async {
    workspaces = await firestore.getUserWorkspaces(userId);
    update(); // update Hive after fetch
  }
}