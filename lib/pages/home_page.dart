import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/Entities/task_filter_type.dart';
import 'package:todo_app/components/dialog_box.dart';
import 'package:todo_app/components/todo_tile.dart';
import 'package:todo_app/data/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //reference the hive box
  final _toDoBox = Hive.box("ToDoBox");
  ToDoDatabase db = ToDoDatabase();

  @override
  void initState() {

    if(_toDoBox.get("TODOLIST") != null) {
      db.loadData();
    } else {
      // If is null then is the first time user open the app,
      //it will create a default data
      db.createInitialPlaceholderData();
    }

    super.initState();
  }

  final _controller = TextEditingController();
  TaskFilterType taskFilterType = TaskFilterType.allTask;

  void _checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = value;
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
          onCancel: () => Navigator.of(context).pop(),
        );
      }
    );
    db.update();
  }

  void _deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.update();
  }

  void _editTask(int index, bool value){
    TextEditingController editingController = TextEditingController(
      text: db.toDoList[index][0],
    );

    editingController.text = db.toDoList[index][0];

    showDialog(
      context: context,
      builder:(context) {
        return DialogBox(
          controller: editingController,
          onSAve: () => _updateTask(index, value, editingController.text),
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _updateTask(int index, bool value, String newTaskText) {
    setState(() {
      db.toDoList[index] = [newTaskText, value];
    });
    Navigator.of(context).pop();
    db.update();
  }

  void orderTaskPosition(int oldIndex, int newIndex) {
    setState(() {
      if(newIndex > oldIndex) {
        newIndex--;
      }
      final task = db.toDoList.removeAt(oldIndex);
      db.toDoList.insert(newIndex, task);
      db.update();
    });
  }

  void _sortTask(TaskFilterType selectedFilter) {
    setState(() {
      taskFilterType = selectedFilter;
    });
  }

  void _saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[300],
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: Center(
          child: Text(
            "TO DO",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          )
        ),
        leading: PopupMenuButton<TaskFilterType>(
          icon: Icon(Icons.filter_list),
          onSelected: _sortTask,
          itemBuilder: (context) => [
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
          ],
        ),
        actions: [
          //add task
          IconButton(
            onPressed: _createNewTask,
            icon: Icon(Icons.add)
          )
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: db.toDoList.where((task) {
          if(taskFilterType == TaskFilterType.tasksCompleted) return task[1] == true;
          if(taskFilterType == TaskFilterType.tasksPending) return task[1] == false;
          return true;
        }).length,

        proxyDecorator: (child, index, animation) {
          return Material(
            elevation: 0,
            color: Colors.transparent,
            child: child,
          );
        },
        onReorder: (oldIndex, newIndex) {
         orderTaskPosition(oldIndex, newIndex);
        },


        itemBuilder:(context, index) {

          var filteredList = db.toDoList.where((task) {
            if(taskFilterType == TaskFilterType.tasksCompleted) return task[1] == true;
            if(taskFilterType == TaskFilterType.tasksPending) return task[1] == false;
            return true;
          }).toList();

          return
            ToDoTile(
              key: ValueKey(index),
              taskName: filteredList[index][0],
              taskCompleted: filteredList[index][1],
              onChanged: (value) => _checkBoxChanged(value, index),
              deleteFunction: (context) => _deleteTask(index),
              taskIndex: index,
              onTap: () => _editTask(index, filteredList[index][1]),
            );
        }
      ),
    );
  }
}