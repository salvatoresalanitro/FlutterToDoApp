import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/data/firestore_service.dart';
import 'package:todo_app/models/task_filter_type.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/models/workspace.dart';
import 'package:todo_app/components/dialog_box.dart';
import 'package:todo_app/components/todo_tile.dart';
import 'package:todo_app/data/todo_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //reference the hive box
  final _toDoBox = Hive.box("ToDoBox");
  ToDoDatabase db = ToDoDatabase();

  final _controller = TextEditingController();
  TaskFilterType taskFilterType = TaskFilterType.allTask;

  String selectedWorkspaceId = "";

  @override
void initState() {
  super.initState();
  _loadUserData();
}

Future<void> _loadUserData() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId != null) {
    final firestoreService = FirestoreService();
    try {
      db.workspaces = await firestoreService.getUserWorkspaces(userId);
      if (db.workspaces.isEmpty) {
        db.createInitialPlaceholderData();
      }
      db.update(); // update hive
    } catch (e) {
      print("Errore Firestore: $e");
      if (_toDoBox.get("WORKSPACES") != null) {
        db.loadData(); // fallback
      } else {
        db.createInitialPlaceholderData();
      }
    }
  } else {
    if (_toDoBox.get("WORKSPACES") != null) {
      db.loadData();
    } else {
      db.createInitialPlaceholderData();
    }
  }

  if (mounted && db.workspaces.isNotEmpty) {
    setState(() {
      selectedWorkspaceId = db.workspaces.first.id;
    });
  }
}

  void _checkBoxChanged(bool? value, int index) {
    setState(() {
      Workspace activeWorkSpace = _getActiveWorkspace();
      activeWorkSpace.todos[index] = activeWorkSpace.todos[index].copyWith(isChecked: value);
    });
    db.update();
  }

  void _createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSAve: _saveNewTask,
          onCancel: () {
            _controller.clear();
            Navigator.of(context).pop();
          }
        );
      }
    );
    db.update();
  }

  void _createNewWorkspace() {
    TextEditingController wsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Nuovo Workspace"),
          content: TextField(
            controller: wsController,
            decoration: InputDecoration(hintText: "Nome workspace"),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => _newWorkspace(wsController),
              child: Text("Crea"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Annulla"),
            ),
          ],
        );
      },
    );
  }

  void _newWorkspace(TextEditingController wsController) async{
    Workspace newWorkspace = Workspace(workspaceName: wsController.text);
    setState(() {
      db.workspaces.add(newWorkspace);
      selectedWorkspaceId = newWorkspace.id;
      db.update();
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirestoreService().saveWorkspace(userId, newWorkspace);
    }

    Navigator.of(context).pop();
  }

  void _renameWorkspace(Workspace workspace) {
    TextEditingController wsController = TextEditingController(text: workspace.workspaceName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rinomina Workspace"),
          content: TextField(
            controller: wsController,
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => _updateWorkspaceName(workspace, wsController),
              child: Text("Salva"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Annulla"),
            ),
          ],
        );
      },
    );
  }

  void _updateWorkspaceName(Workspace workspace, TextEditingController wsController) async{
    setState(() {
      int indexWorkSpace = db.workspaces.indexWhere((x) => x.id == workspace.id);
      if (indexWorkSpace != -1) {
        db.workspaces[indexWorkSpace] = workspace.copyWith(workspaceName: wsController.text.trim());
        db.update();
      }
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirestoreService().saveWorkspace(userId, workspace);
    }

    Navigator.of(context).pop();
  }

  void _deleteAllCheckedWorkspaceTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Eliminazione task completati"),
          content: Text("Vuoi eliminare tutti i task completati di questo workspace?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  Workspace activeWorkspace = _getActiveWorkspace();
                  activeWorkspace.todos.removeWhere((todo) => todo.isChecked);
                  db.update();
                });
                Navigator.of(context).pop();
              },
              child: Text("Si")
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("No"),
            )
          ],
        );
      }
    );
  }

  void _deleteWorkspace(Workspace workspace, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Conferma eliminazione"),
          content: Text("Così facendo rimuoverai l'intero workspace e tutti i suoi todo all'interno, vuoi procedere?"),
          actions: [
            TextButton(
              onPressed: () => _removeWorkspace(workspace, index),
              child: Text("Si"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeWorkspace(Workspace workspace, int index) async {
    setState(() {
      db.workspaces.remove(workspace);

      if(db.workspaces.isNotEmpty) {
        selectedWorkspaceId = index -1 >= 0
          ? db.workspaces[index - 1].id
          : db.workspaces.first.id;
      }
      else {
        selectedWorkspaceId = "";
      }
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if(userId != null) {
      await FirestoreService().deleteWorkspace(userId, workspace.id);
    }

    db.update();

    Navigator.of(context).pop();
  }

  bool _isAnyWorkspaceTodosChecked() => _getActiveWorkspace().todos.any((todo) => todo.isChecked == true);

  Iterable<Todo> _getTodos() {
    Workspace activeWorkSpace = _getActiveWorkspace();

    return activeWorkSpace.todos.where((todo) {
      switch (taskFilterType) {
        case TaskFilterType.tasksCompleted:
          return todo.isChecked == true;
        case TaskFilterType.tasksPending:
          return todo.isChecked == false;
        default:
          return true;
      }
    });
  }

  Workspace _getActiveWorkspace() {
    Workspace activeWorkSpace = db.workspaces.firstWhere(
        (ws) => ws.id == selectedWorkspaceId,
        orElse: () => Workspace.empty(),
      );

    return activeWorkSpace;
  }

  void _deleteTask(int index) async{
    setState(() {
      Workspace activeWorkSpace = _getActiveWorkspace();
      activeWorkSpace.todos.removeAt(index);
    });
    db.update();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirestoreService().saveWorkspace(userId, _getActiveWorkspace());
    }
  }

  void _editTask(int index, bool value){
    Workspace activeWorkSpace = _getActiveWorkspace();
    TextEditingController editingController = TextEditingController(
      text: activeWorkSpace.todos[index].taskName,
    );

    showDialog(
      context: context,
      builder:(context) {
        return DialogBox(
          controller: editingController,
          onSAve: () => _updateTask(index, value, editingController.text),
          onCancel: () {
            editingController.clear();
            Navigator.of(context).pop();
          }
        );
      },
    );
  }

  void _updateTask(int index, bool value, String newTaskText) async {
    Workspace activeWorkSpace = _getActiveWorkspace();
    setState(() {
      activeWorkSpace.todos[index] = activeWorkSpace.todos[index]
        .copyWith(taskName: newTaskText, isChecked: value);
    });

    Navigator.of(context).pop();
    db.update();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirestoreService().saveWorkspace(userId, _getActiveWorkspace());
    }
  }

  void _orderTaskPosition(int oldIndex, int newIndex) {
    Workspace activeWorkSpace = _getActiveWorkspace();
    setState(() {
      if(newIndex > oldIndex) {
        newIndex--;
      }
      final todo = activeWorkSpace.todos.removeAt(oldIndex);
      activeWorkSpace.todos.insert(newIndex, todo);
      db.update();
    });

  }

  void _sortTask(TaskFilterType selectedFilter) {
    if(db.workspaces.isEmpty) {

    }

    setState(() {
      taskFilterType = selectedFilter;
    });
  }

  void _saveNewTask() async{
    if(_controller.text.trim().isEmpty) {
      _showWarningTodoDialog();
      return;
    }

    setState(() {
      Workspace activeWorkSpace = _getActiveWorkspace();
      activeWorkSpace.todos.add(Todo(taskName: _controller.text, isChecked: false));
      _controller.clear();
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirestoreService().saveWorkspace(userId, _getActiveWorkspace());
    }

    Navigator.of(context).pop();
    db.update();
  }

  void _showWarningTodoDialog(){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.yellow[600],
          title: Text("Attenzione!"),
          content: Text("Il To Do non può essere vuoto, aggiungi del testo nel To Do."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Ok"),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[300],
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: Text(
          "TO DO",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => Scaffold.of(context).openDrawer(), // Using the correct context to use the Drawer,
              child: Icon(
                Icons.menu,
                color: Colors.black,
              ),
            );
          }
        ),
        actions: [
          PopupMenuButton<TaskFilterType>(
            color: Colors.yellow[600],
            icon: Icon(Icons.filter_list, color: db.workspaces.isNotEmpty ? Colors.black : Colors.black26,),
            onSelected: db.workspaces.isNotEmpty ? _sortTask : null,
            itemBuilder: (context) => db.workspaces.isNotEmpty
            ? [
              PopupMenuItem(
                value: TaskFilterType.allTask,
                child: Text("Tutti i task"),
              ),
              PopupMenuItem(
                value: TaskFilterType.tasksCompleted,
                child: Text("Completati"),
              ),
              PopupMenuItem(
                value: TaskFilterType.tasksPending,
                child: Text("Da completare"),
              ),
            ] : [],
          ),
          //delete all checked tasks
          IconButton(
            onPressed: _isAnyWorkspaceTodosChecked()
                ? _deleteAllCheckedWorkspaceTask
                : null,
            icon: Icon(Icons.delete_forever),
          ),
          //add task
          IconButton(
            onPressed: db.workspaces.isNotEmpty ? _createNewTask : null,
            icon: Icon(Icons.add),
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.yellow[600],
        child: Column(
          children: [
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity, // Take all width
              child: TextButton.icon(
                icon: Icon(Icons.add, size: 24),
                label: Text(
                  "Aggiungi Workspace",
                  style: TextStyle(fontSize: 18),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.yellow[600],
                  foregroundColor: Colors.black,
                ),
                onPressed: _createNewWorkspace,
              ),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: db.workspaces.length,
                itemBuilder: (context, index) {
                  bool isWorkSpaceSelected = db.workspaces[index].id == selectedWorkspaceId;

                  return ListTile(
                    selected: isWorkSpaceSelected,
                    selectedColor: Colors.white,
                    selectedTileColor: Colors.black,
                    title: Text(
                      db.workspaces[index].workspaceName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _renameWorkspace(db.workspaces[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteWorkspace(db.workspaces[index], index),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedWorkspaceId = db.workspaces[index].id;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: ReorderableListView.builder(
        itemCount: _getTodos().length,
        proxyDecorator: (child, index, animation) {
          return Material(
            elevation: 0,
            color: Colors.transparent,
            child: child,
          );
        },
        onReorder: (oldIndex, newIndex) {
         _orderTaskPosition(oldIndex, newIndex);
        },
        itemBuilder:(context, index) {
          var filteredTodos = _getTodos().toList();
          var isLastItem = index == filteredTodos.length - 1;

          return
            Padding(
              key: ValueKey(filteredTodos[index].id),
              padding: EdgeInsets.only(bottom: isLastItem ? 25 : 0),
              child: ToDoTile(
                taskName: filteredTodos[index].taskName,
                taskCompleted: filteredTodos[index].isChecked,
                onChanged: (value) => _checkBoxChanged(value, index),
                deleteFunction: (context) => _deleteTask(index),
                taskIndex: index,
                onTap: () => _editTask(index, filteredTodos[index].isChecked),
              ),
            );
        }
      ),
    );
  }
}