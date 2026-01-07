import 'package:flutter/material.dart';
import 'package:flutterapp/UI/screens/home/welcome_screen.dart';
import 'package:flutterapp/core/theme/app_theme.dart'; 
import 'package:flutterapp/UI/widgets/fullscreen_wrapper.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppTheme.init();
  runApp(const StudyFlowApp());
}

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeMode,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'StudyFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: currentMode,
          home: const FullscreenWrapper(
            child: Welcomescreen(),
          ),
        );
      },
    );
  }
}