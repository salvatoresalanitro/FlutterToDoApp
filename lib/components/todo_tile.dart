import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final int taskIndex;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;
  final VoidCallback? onTap;

  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();

  ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    required this.taskIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, top: 25.0, right: 25.0),
      child: Slidable(
          endActionPane: ActionPane(
            motion: StretchMotion(),
            children: [
              // Custom slidable to put an effect gradient into
              CustomSlidableAction(
                onPressed: deleteFunction,
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.zero, //set padding to 0
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14.0),
                  bottomRight: Radius.circular(14.0),
                ),

                //Is needed to has decoration
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.05, 0.35],
                      colors: [
                        Colors.yellow[300] ?? Colors.yellow,
                        Colors.red.shade300,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14.0),
                      bottomRight: Radius.circular(14.0),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ),
            ]
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.yellow[600],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    //checkbox
                    Checkbox(
                      value: taskCompleted,
                      onChanged: onChanged,
                      activeColor: Colors.brown[500],
                    ),

                    //Task name
                    Expanded(
                      child: GestureDetector(
                        onLongPress: () {
                          final TooltipState? tooltip = _tooltipKey.currentState;
                          tooltip?.ensureTooltipVisible();
                        },
                        child: Tooltip(
                          key: _tooltipKey,
                          message: taskName,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: TextStyle(color: Colors.white),
                          showDuration: Duration(seconds: 2),
                          child: Text(
                            taskName,
                            style: TextStyle(
                              decoration: taskCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),

                    //Icon to drag and drop task
                    ReorderableDragStartListener(
                      index: taskIndex,
                      child: Icon(Icons.drag_handle, color: Colors.grey,),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}