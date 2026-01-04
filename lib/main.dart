import 'package:flutter/material.dart';
import 'package:flutterapp/UI/providers/deck_provider.dart';
import 'package:flutterapp/UI/providers/study_provider.dart';
import 'package:flutterapp/UI/providers/user_provider.dart';
import 'package:flutterapp/UI/screens/home/home_screen.dart';
import 'package:flutterapp/data/datascource/local_database.dart';
import 'package:flutterapp/data/repositories/deck_repository_impl.dart';
import 'package:flutterapp/data/repositories/user_repository_impl.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'package:flutterapp/UI/screens/home/welcome_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localDataSource = LocalDataSource(); 
  final deckRepo = DeckRepositoryImpl(localDataSource);
  final userRepo = UserRepositoryImpl(localDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DeckProvider(deckRepository: deckRepo)..loadDeck(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(userRepository: userRepo)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => StudyProvider(),
        ),
      ],
      child: const StudyFlowApp(),
    ),
  );
}

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyFlow',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primaryOrange,
      ),
      home: const Welcomescreen(),
    );
  }
}