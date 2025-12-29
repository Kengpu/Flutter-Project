import '../models/user_stats.dart';

abstract class IUserRepository {
  Future<UserStats> getUserStats(String userId);
  Future<void> updateUserStats(UserStats stats);
}
