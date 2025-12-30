import '../../domain/models/user_stats.dart';

class UserStatsModel {
  final int totalEXP;
  final int level;
  final int dailyStreak;
  final DateTime lastStudyDate;

  UserStatsModel({
    required this.totalEXP,
    required this.level,
    required this.dailyStreak,
    required this.lastStudyDate,
  });

  factory UserStatsModel.fromEntity(UserStats entity) {
    return UserStatsModel(
      totalEXP: entity.totalEXP,
      level: entity.level,
      dailyStreak: entity.dailyStreak,
      lastStudyDate: entity.lastStudyDate,
    );
  }

  UserStats toEntity() {
    return UserStats(
      totalEXP: totalEXP,
      level: level,
      dailyStreak: dailyStreak,
      lastStudyDate: lastStudyDate,
    );
  }

  Map<String, dynamic> toJson() => {
    "totalEXP": totalEXP,
    "level": level,
    "dailyStreak": dailyStreak,
    "lastStudyDate": lastStudyDate.toIso8601String(), 
  };

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalEXP: json["totalEXP"],
      level: json["level"],
      dailyStreak: json["dailyStreak"],
      lastStudyDate: DateTime.parse(json["lastStudyDate"]), 
    );
  }
}