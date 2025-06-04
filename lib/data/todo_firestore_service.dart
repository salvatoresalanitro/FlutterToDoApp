import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/models/todo.dart';

class TodoFirestoreService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> addTodo(String userId, String workspaceId, Todo todo) async {
    int nextOrder = await getMaxTodoOrder(userId, workspaceId);

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
      'order': nextOrder,
    });
  }

  Future<void> updateTodo(String userId, String workspaceId, Todo todo) async {
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

  Future<int> getMaxTodoOrder(String userId, String workspaceId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("workspaces")
        .doc(workspaceId)
        .collection("todos")
        .orderBy("todoOrder", descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return 0;

    return snapshot.docs.first["todoOrder"] + 1;
  }

  Future<void> renameTodo(String userId, String workspaceId, String todoId, String newName) async {
    final todoRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('workspaces')
      .doc(workspaceId)
      .collection('todos')
      .doc(todoId);

    await todoRef.update({'taskName': newName});
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

  Future<void> updateTodoOrder(String userId, String workspaceId, List<Todo> todos) async {
    WriteBatch batch = _firestore.batch();

    for (int i = 0; i < todos.length; i++) {
    final todoRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('workspaces')
      .doc(workspaceId)
      .collection('todos')
      .doc(todos[i].id);

      batch.update(todoRef, {"order": i});
    }

    await batch.commit();
  }
}