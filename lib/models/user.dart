import 'package:todo_app/models/workspace.dart';

class User {
  final String id;
  final String email;
  List<Workspace> workspaces;

  User({required this.id,required this.email, List<Workspace>? workspaces}) : workspaces = workspaces ?? [];

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
    );
  }
}