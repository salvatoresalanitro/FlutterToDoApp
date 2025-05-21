import 'package:flutter/material.dart';
import 'package:todo_app/components/custom_button.dart';

class DialogBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSAve;
  final VoidCallback onCancel;

  const DialogBox({
    super.key,
    required this.controller,
    required this.onSAve,
    required this.onCancel,
  });

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
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
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

                CustomButton(todoText: "Save", onPressed: onSAve,),

                SizedBox(width: 8,),

                //cancel button
                CustomButton(todoText: "Cancel", onPressed: onCancel,)
              ],
            )
          ],
        ),
      ),
    );
  }
}