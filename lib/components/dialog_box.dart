import 'package:flutter/material.dart';
import 'package:todo_app/components/custom_button.dart';

class DialogBox extends StatelessWidget {
  const DialogBox({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.yellow[600],
      content: SizedBox(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //get user input
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Add a new task",
              ),
            ),

            //buttons save + cancel
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //save button

                CustomButton(todoText: "Save", onPressed:() {
                  },
                ),

                SizedBox(width: 8,),

                //cancel button
                CustomButton(todoText: "Cancel", onPressed:() {
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}