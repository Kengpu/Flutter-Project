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

  int get nextLevel => level * 100;
  double get progress => totalEXP / nextLevel;

  void addEXP (int amount){
    totalEXP += amount;
    while (totalEXP >= nextLevel) {
      totalEXP -= nextLevel;
      level++;
    }
  }

  void updateStreak(){
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(lastStudyDate.year,lastStudyDate.month, lastStudyDate.day);
    final difference = today.difference(lastDate).inDays;

    if (difference == 1) {
      dailyStreak++;
    } else if (difference > 1 || dailyStreak == 0) {
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