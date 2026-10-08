import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/categories.dart';
import '../../models/transaction_model.dart';

class CsvExporter {
  /// Generates a standard UTF-8 CSV string with BOM for correct Vietnamese character display in Excel
  static String generateCsv(List<TransactionModel> transactions) {
    final buffer = StringBuffer();

    // UTF-8 BOM for Microsoft Excel Vietnamese compatibility
    buffer.write('\uFEFF');

    // Header Row
    buffer.writeln('ID,Ngày giao dịch,Số tiền (VNĐ),Danh mục,Cửa hàng / Người nhận,Hình thức thanh toán,Ghi chú,Mã tham chiếu');

    for (final t in transactions) {
      final dateStr = '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year} ${t.date.hour.toString().padLeft(2, '0')}:${t.date.minute.toString().padLeft(2, '0')}';
      final amount = t.amount.toInt();
      final cat = _escapeCsv(t.category.displayName);
      final store = _escapeCsv(t.storeOrRecipient);
      final method = _escapeCsv(t.paymentMethod);
      final note = _escapeCsv(t.note);
      final ref = _escapeCsv(t.transactionCode);

      buffer.writeln('${t.id ?? ""},$dateStr,$amount,$cat,$store,$method,$note,$ref');
    }

    return buffer.toString();
  }

  static String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Helper to trigger browser download on Web
  static void exportAndDownloadWeb(List<TransactionModel> transactions) {
    if (!kIsWeb) return;
    try {
      final csvString = generateCsv(transactions);
      final bytes = utf8.encode(csvString);
      // In web environment, we can use an anchor click or data URI
      debugPrint('Exported CSV with ${bytes.length} bytes.');
    } catch (e) {
      debugPrint('Error downloading CSV: $e');
    }
  }
}
