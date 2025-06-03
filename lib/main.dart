import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_app/pages/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/pages/login_page.dart';
import 'package:todo_app/services/authentication_service';

Future<void> main() async {
  //init the hive
  await Hive.initFlutter();

  // open a box
  await Hive.openBox("ToDoBox");

  // hide system bar
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp();
  
  runApp(const ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthenticationService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.yellow),
      home: StreamBuilder(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return LoginPage(authenticationService: authService);
          }
        },
      ),
    );
  }
}