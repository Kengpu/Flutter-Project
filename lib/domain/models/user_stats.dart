

class UserStats {
  int totalEXP;
  int level;
  int dailyStreak;
  DateTime lastStudyDate;

  UserStats({
    this.totalEXP = 0,
    this.level = 1,
    this.dailyStreak = 0,
    required this.lastStudyDate,
  });

  bool addEXP (int amount){
    totalEXP += amount;
    int newLevel = (totalEXP / 100).toInt() + 1;

    if (newLevel > level)
    {
      level = newLevel;
      return true;
    }
    return false;
  }

  void updateStreak(){
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(lastStudyDate.year,lastStudyDate.month, lastStudyDate.day);
    final difference = today.difference(lastDate).inDays;

    if (difference == 1) {
      dailyStreak++;
    } else if (difference > 1) {
      dailyStreak = 1;
    }

    lastStudyDate = now;
  }

  @override
  String toString() {
    return """
- Total EXP: $totalEXP,
- Level: $level,
- Daily Streak: $dailyStreak,
- Last Active: $lastStudyDate
""";
  }
}