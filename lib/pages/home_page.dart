import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/components/dialog_box.dart';
import 'package:todo_app/components/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //reference the hive box
  final _toDoBox = Hive.openBox("ToDoBox");

  final _controller = TextEditingController();

  List toDoList = [
    ["PlaceHolder", false],
    ["PlaceHolder", false]
  ];

  void _checkBoxChanged(bool? value, int index) {
    setState(() {
      toDoList[index][1] = value;
    });
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
  }

  void _deleteTask(int index) {
    setState(() {
      toDoList.removeAt(index);
    });
  }

  void _saveNewTask() {
    setState(() {
      toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[300],
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: Center(child: Text("TO DO",)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTask,
        backgroundColor: Colors.yellow[600],
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: toDoList.length,
        itemBuilder:(context, index) {
          return ToDoTile(
            taskName: toDoList[index][0],
            taskCompleted: toDoList[index][1],
            onChanged: (value) => _checkBoxChanged(value, index),
            deleteFunction: (context) => _deleteTask(index),
          );
        }
      )
    );
  }
}