import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/models/workspace.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -------------------- WORKSPACES --------------------

  Future<List<Workspace>> getUserWorkspaces(String userId) async {
    final workspaceSnapshots = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workspaces')
        .get();

    List<Workspace> workspaces = [];

    for (var wsDoc in workspaceSnapshots.docs) {
      final todosSnapshot = await wsDoc.reference.collection('todos').get();

      List<Todo> todos = todosSnapshot.docs.map((todoDoc) {
        final data = todoDoc.data();
        return Todo(
          id: todoDoc.id,
          taskName: data['taskName'],
          isChecked: data['isChecked'],
        );
      }).toList();

      workspaces.add(Workspace(
        id: wsDoc.id,
        workspaceName: wsDoc['name'],
        todos: todos,
      ));
    }

    return workspaces;
  }

  Future<void> createOrUpdateWorkspace(String userId, Workspace workspace) async {
    final wsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workspaces')
        .doc(workspace.id);

    await wsRef.set({'name': workspace.workspaceName});
  }

  Future<void> renameWorkspace(String userId, String workspaceId, String newName) async {
    final wsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workspaces')
        .doc(workspaceId);

    await wsRef.update({'name': newName});
  }

  Future<void> deleteWorkspace(String userId, String workspaceId) async {
    final wsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workspaces')
        .doc(workspaceId);

    final todos = await wsRef.collection('todos').get();
    for (var doc in todos.docs) {
      await doc.reference.delete();
    }

    await wsRef.delete();
  }

  // -------------------- TODOS --------------------

  Future<void> addOrUpdateTodo(String userId, String workspaceId, Todo todo) async {
    final todoRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workspaces')
        .doc(workspaceId)
        .collection('todos')
        .doc(todo.id);

    await todoRef.set({
      'taskName': todo.taskName,
      'isChecked': todo.isChecked,
    });
  }

  Future<void> deleteTodo(String userId, String workspaceId, String todoId) async {
    final todoRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workspaces')
        .doc(workspaceId)
        .collection('todos')
        .doc(todoId);

    await todoRef.delete();
  }
}
