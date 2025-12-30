import '../datascource/local_database.dart';
import '../models/user_stats_model.dart';
import '../../domain/models/user_stats.dart';
import '../../domain/repositories/i_user_repository.dart';

class UserRepositoryImpl implements IUserRepository{
  final LocalDataSource localDataSource;

  UserRepositoryImpl(this.localDataSource);
  @override
  Future<UserStats> getUserStats(String userId) async{
    final model = await localDataSource.loadUserStats();
    if (model == null) {
      return UserStats(lastStudyDate: DateTime.now());
    }

    return model.toEntity();
  }

  @override
  Future<void> updateUserStats(UserStats stats) async {
    final model = UserStatsModel.fromEntity(stats);
    await localDataSource.saveUserStats(model);
  }
}