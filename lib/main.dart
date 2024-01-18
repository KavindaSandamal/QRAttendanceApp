import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qrattendanceapp/screens/login_page.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:qrattendanceapp/repository/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(UserRepository());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp(); // Add const here

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
