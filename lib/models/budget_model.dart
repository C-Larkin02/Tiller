class Budget {
  String uid;
  Map<String, double> categoryLimits;
  double totalWeeklySpend;
  double totalMonthlySpend;
  double totalYearlySpend;

  Budget({
    required this.uid,
    required this.categoryLimits,
    required this.totalWeeklySpend,
    required this.totalMonthlySpend,
    required this.totalYearlySpend,
  });

  factory Budget.initial(String uid) {
    return Budget(
      uid: uid,
      categoryLimits: {},
      totalWeeklySpend: 0,
      totalMonthlySpend: 0,
      totalYearlySpend: 0,
    );
  }

  // Update category spending limit
  void updateCategoryLimit(String category, double limit) {
    categoryLimits[category] = limit;
  }

  void updateTotalSpend(double amount, String period) {
    switch (period) {
      case 'week':
        totalWeeklySpend += amount;
        break;
      case 'month':
        totalMonthlySpend += amount;
        break;
      case 'year':
        totalYearlySpend += amount;
        break;
    }
  }

  @override
  String toString() {
    return 'Budget{uid: $uid, categoryLimits: $categoryLimits, totalWeeklySpend: $totalWeeklySpend, totalMonthlySpend: $totalMonthlySpend, totalYearlySpend: $totalYearlySpend}';
  }
}
