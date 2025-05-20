import 'package:flutter/material.dart';
import 'package:todo_app/components/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List toDoList = [
    ["PlaceHolder", false],
    ["PlaceHolder", false]
  ];

  void _checkBoxChanged(bool? value, int index) {
    setState(() {
      toDoList[index][1] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[300],
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: Center(child: Text("TO DO",)),
      ),
      body: ListView.builder(
        itemCount: toDoList.length,
        itemBuilder:(context, index) {
          return ToDoTile(
            taskName: toDoList[index][0],
            taskCompleted: toDoList[index][1],
            onChanged: (value) => _checkBoxChanged(value, index),
          );
        }
      )
    );
  }
}