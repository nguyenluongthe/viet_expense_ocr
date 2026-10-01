import '../core/constants/categories.dart';

class TransactionModel {
  final int? id;
  final double amount;
  final String storeOrRecipient;
  final DateTime date;
  final ExpenseCategory category;
  final String note;
  final String transactionCode;
  final String paymentMethod; // e.g. "QR Chuyển khoản", "Banking", "Ví điện tử", "Hóa đơn giấy"
  final String? imagePath;
  final String? rawText;
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.amount,
    required this.storeOrRecipient,
    required this.date,
    required this.category,
    this.note = '',
    this.transactionCode = '',
    this.paymentMethod = 'QR Chuyển khoản',
    this.imagePath,
    this.rawText,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'store_or_recipient': storeOrRecipient,
      'date': date.toIso8601String(),
      'category': category.name,
      'note': note,
      'transaction_code': transactionCode,
      'payment_method': paymentMethod,
      'image_path': imagePath,
      'raw_text': rawText,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      storeOrRecipient: map['store_or_recipient'] as String? ?? 'Chưa rõ',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      category: ExpenseCategoryExt.fromString(map['category'] as String?),
      note: map['note'] as String? ?? '',
      transactionCode: map['transaction_code'] as String? ?? '',
      paymentMethod: map['payment_method'] as String? ?? 'QR Chuyển khoản',
      imagePath: map['image_path'] as String?,
      rawText: map['raw_text'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  TransactionModel copyWith({
    int? id,
    double? amount,
    String? storeOrRecipient,
    DateTime? date,
    ExpenseCategory? category,
    String? note,
    String? transactionCode,
    String? paymentMethod,
    String? imagePath,
    String? rawText,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      storeOrRecipient: storeOrRecipient ?? this.storeOrRecipient,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
      transactionCode: transactionCode ?? this.transactionCode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      imagePath: imagePath ?? this.imagePath,
      rawText: rawText ?? this.rawText,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
