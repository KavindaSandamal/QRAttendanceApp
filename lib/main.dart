import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qrattendanceapp/screens/login_page.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:qrattendanceapp/repository/user_repository.dart';
import 'package:qrattendanceapp/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(UserRepository());
  runApp(SplashApp());
}

class SplashApp extends StatelessWidget {
  const SplashApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      theme: ThemeData(
        // Customize the theme if needed
        primarySwatch: Colors.blue,
      ),
    );
  }
}
