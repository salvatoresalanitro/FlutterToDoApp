import 'package:flutter/material.dart';
import 'package:todo_app/pages/home_page.dart';
import 'package:todo_app/services/authentication_service';

class LoginPage extends StatelessWidget {
  final AuthenticationService authenticationService;

  const LoginPage({super.key, required this.authenticationService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.login),
          label: Text("Accedi con Google"),
          onPressed: () async {
            final user = await authenticationService.signInWithGoogle();
            if (user != null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomePage())
              );
            }
          },
        ),
      ),
    );
  }
}
