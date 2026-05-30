class InsightService {
  static List<String> generateInsights({
    required double totalSpent,

    required double budget,
  }) {
    final List<String> insights = [];

    final remaining = budget - totalSpent;

    /// OVER BUDGET

    if (totalSpent > budget) {
      insights.add('⚠️ You exceeded your monthly budget.');

      insights.add('Try reducing unnecessary expenses.');
    }
    /// CLOSE TO LIMIT
    else if (totalSpent > budget * 0.8) {
      insights.add('⚠️ You already used 80% of your budget.');

      insights.add('Spend carefully for the rest of the month.');
    }
    /// GOOD SAVINGS
    else {
      insights.add('✅ Great job managing your expenses.');

      insights.add('You are saving money effectively.');
    }

    /// REMAINING MONEY

    insights.add('💰 Remaining Budget: ₹ ${remaining.toStringAsFixed(0)}');

    return insights;
  }
}
