import '../core/constants/categories.dart';

class ParsedResult {
  final double? amount;
  final String? amountRaw;
  final String? storeOrRecipient;
  final String? bankName;
  final DateTime? date;
  final String? dateRaw;
  final String? transactionCode;
  final String? note;
  final String paymentMethod;
  final ExpenseCategory category;
  final double confidenceScore;
  final String rawText;
  final List<String> matchedTokens;
  final List<String> rawLines;

  ParsedResult({
    this.amount,
    this.amountRaw,
    this.storeOrRecipient,
    this.bankName,
    this.date,
    this.dateRaw,
    this.transactionCode,
    this.note,
    this.paymentMethod = 'QR Chuyển khoản',
    this.category = ExpenseCategory.other,
    this.confidenceScore = 0.0,
    required this.rawText,
    this.matchedTokens = const [],
    this.rawLines = const [],
  });

  bool get hasValidAmount => amount != null && amount! > 0;
  bool get hasStoreOrRecipient => storeOrRecipient != null && storeOrRecipient!.isNotEmpty;
  bool get hasDate => date != null;

  int get matchedFieldCount {
    int count = 0;
    if (hasValidAmount) count++;
    if (hasStoreOrRecipient) count++;
    if (hasDate) count++;
    if (transactionCode != null && transactionCode!.isNotEmpty) count++;
    return count;
  }
}
