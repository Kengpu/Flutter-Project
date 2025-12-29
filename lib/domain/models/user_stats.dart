
class UserStats {
  const UserStats({
    required this.totalEXP,
    required this.level,
    required this.dailyStreak,
    required this.lastStudyDate,
  });
  
  final int totalEXP;
  final int level;
  final int dailyStreak;
  final DateTime lastStudyDate;

  void updateEXP(int amount){}
  void getStatus(){}
  void syncStreak(){}
}
