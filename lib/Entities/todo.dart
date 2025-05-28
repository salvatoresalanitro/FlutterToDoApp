class Todo {
  final String taskName;
  final bool isChecked;

  Todo({required this.taskName, required this.isChecked});

  Todo copyWith({String? taskName, bool? isChecked}){
    return Todo(
      taskName: taskName?? this.taskName,
      isChecked: isChecked ?? this.isChecked
    );
  }
}