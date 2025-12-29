class User_state {
  const User_state({
    required this.totalEXP,
    required this.level,
    required this.dailyStreak,
    required this.lastStudyDate,
  });
  
  final int totalEXP;
  final int level;
  final int dailyStreak;
  final Datetime lastStudyDate;

  void updateEXP(int amount){}
  void getStatus(){}
  void syncStreak(){}
}


class Datetime {

}