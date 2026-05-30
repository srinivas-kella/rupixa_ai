class ExpenseParserService {
  static Map<String, dynamic> parseExpense(String text) {
    final lower = text.toLowerCase();

    String category = 'Others';

    String title = text;

    double amount = 0;

    /// CATEGORY DETECTION

    if (lower.contains('food') ||
        lower.contains('pizza') ||
        lower.contains('burger') ||
        lower.contains('swiggy') ||
        lower.contains('zomato')) {
      category = 'Food';
    } else if (lower.contains('uber') ||
        lower.contains('ola') ||
        lower.contains('transport')) {
      category = 'Transport';
    } else if (lower.contains('amazon') ||
        lower.contains('shopping') ||
        lower.contains('flipkart')) {
      category = 'Shopping';
    } else if (lower.contains('movie') ||
        lower.contains('netflix') ||
        lower.contains('prime')) {
      category = 'Entertainment';
    }

    /// AMOUNT EXTRACTION

    final regex = RegExp(r'\d+');

    final match = regex.firstMatch(text);

    if (match != null) {
      amount = double.tryParse(match.group(0)!) ?? 0;
    }

    return {'title': title, 'category': category, 'amount': amount};
  }
}
