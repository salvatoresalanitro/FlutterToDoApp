import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/models/user.dart';
import 'package:todo_app/models/workspace.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(User user) async {
    await _db.collection("users").doc(user.id).set(user.toMap());
  }

  Future<void> saveWorkspace(String userId, Workspace workspace) async {
    await _db
        .collection("users")
        .doc(userId)
        .collection("workspaces")
        .doc(workspace.id)
        .set({
          "name": workspace.workspaceName,
        });

    for (var todo in workspace.todos) {
      await _db
          .collection("users")
          .doc(userId)
          .collection("workspaces")
          .doc(workspace.id)
          .collection("todos")
          .doc(todo.id)
          .set({
            "taskName": todo.taskName,
            "isChecked": todo.isChecked,
          });
    }
  }

  Future<List<Workspace>> loadWorkspaces(String userId) async {
    final wsSnap = await _db
        .collection("users")
        .doc(userId)
        .collection("workspaces")
        .get();

    List<Workspace> workspaces = [];

    for (var wsDoc in wsSnap.docs) {
      final todosSnap = await wsDoc.reference.collection("todos").get();
      final todos = todosSnap.docs.map((todo) {
        final data = todo.data();
        return Todo(
          id: todo.id,
          taskName: data["taskName"],
          isChecked: data["isChecked"],
        );
      }).toList();

      workspaces.add(
        Workspace(
          id: wsDoc.id,
          workspaceName: wsDoc["name"],
          todos: todos,
        ),
      );
    }

    return workspaces;
  }
}
