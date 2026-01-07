import 'package:flutter/material.dart';
import 'package:flutterapp/UI/screens/home/welcome_screen.dart';
import 'package:flutterapp/core/theme/app_theme.dart'; // Import your merged file
import 'package:flutterapp/UI/widgets/fullscreen_wrapper.dart'; // Import wrapper

void main() async {
  // 1. Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load the saved theme (Dark or Light) from the phone's memory
  await AppTheme.init();
  
  runApp(const StudyFlowApp());
}

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Listen to the AppTheme's value notifier
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeMode,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'StudyFlow',
          debugShowCheckedModeBanner: false,
          
          // Use your merged theme getters
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: currentMode,
          
          // 4. Wrap the home screen to handle Android Fullscreen/Immersive logic
          home: const FullscreenWrapper(
            child: Welcomescreen(),
          ),
        );
      },
    );
  }
}