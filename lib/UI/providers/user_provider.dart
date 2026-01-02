import 'package:flutter/material.dart';
import 'package:flutterapp/domain/models/user_stats.dart';
import 'package:flutterapp/domain/repositories/i_user_repository.dart';

class UserProvider extends ChangeNotifier {
  final IUserRepository userRepository;
  UserStats? _stats;

  UserProvider({required this.userRepository});

  UserStats? get stats => _stats;

  Future<void> init() async {
    _stats = await userRepository.getUserStats("local_user");
    notifyListeners();
  }

  Future<void> addProgress (int exp) async {
    if (_stats == null) return;

    _stats!.addEXP(exp);

    await userRepository.updateUserStats(_stats!);
    notifyListeners();
  }
}