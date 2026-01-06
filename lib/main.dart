import 'package:flutter/material.dart';
import 'package:flutterapp/UI/screens/home/home_screen.dart';
import 'package:flutterapp/UI/screens/home/welcome_screen.dart';

void main() async {
  // 1. Ensure Flutter is initialized before calling any native code (SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const StudyFlowApp());
}

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        useMaterial3: true,
        fontFamily: 'Inter', 
      ),
      home: const Welcomescreen(),
    );
  }
}