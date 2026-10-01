import 'package:flutter_test/flutter_test.dart';
import 'package:viet_expense_ocr/core/constants/categories.dart';
import 'package:viet_expense_ocr/core/utils/currency_formatter.dart';
import 'package:viet_expense_ocr/services/heuristic_parser.dart';

void main() {
  group('HeuristicParser Tests for Vietnamese Banking & QR Transfers', () {
    test('Correctly parses Vietcombank QR transfer screenshot with 65.000 VND', () {
      const rawText = '''
Vietcombank Digibank
CHUYỂN TIỀN THÀNH CÔNG
Quét mã VietQR - 247
Số tiền: 65.000 VND
Bằng chữ: Sáu mươi lăm nghìn đồng
Người nhận: HIGHLANDS COFFEE
Ngân hàng: Ngân hàng Ngoại Thương (Vietcombank)
Thời gian: 01/10/2026 09:15:30
Mã giao dịch: VCB918237192
Nội dung: Thanh toan 2 ly Freeze tra xanh
      ''';

      final result = HeuristicParser.parse(rawText: rawText);

      expect(result.amount, equals(65000));
      expect(result.storeOrRecipient, contains('HIGHLANDS COFFEE'));
      expect(result.bankName, equals('Vietcombank'));
      expect(result.date?.day, equals(1));
      expect(result.date?.month, equals(10));
      expect(result.date?.year, equals(2026));
      expect(result.transactionCode, equals('VCB918237192'));
      expect(result.paymentMethod, contains('VietQR'));
      expect(result.category, equals(ExpenseCategory.food));
    });

    test('Correctly parses MB Bank transfer with negative amount -85.000 VND', () {
      const rawText = '''
MB Bank - Giao dịch thành công
Chuyển khoản liên ngân hàng 24/7
Số tiền giao dịch: -85.000 VND
Tên người nhận: CƠM TẤM PHÚC LỘC THỌ
Tại ngân hàng: MBBank
Thời gian: 30/09/2026 12:35
Mã GD: MB9921827419
Nội dung chuyển khoản: Com tam bi cha va canh
      ''';

      final result = HeuristicParser.parse(rawText: rawText);

      expect(result.amount, equals(85000));
      expect(result.storeOrRecipient, contains('CƠM TẤM'));
      expect(result.bankName, equals('MBBank'));
      expect(result.transactionCode, equals('MB9921827419'));
      expect(result.category, equals(ExpenseCategory.food));
    });

    test('Correctly parses 45k suffix notation on POS Bill', () {
      const rawText = '''
CIRCLE K VIETNAM
PHIẾU THANH TOÁN
Tổng cộng: 45.000 đ
Thanh toán: 45k
Ngày: 28/09/2026 21:10
      ''';

      final result = HeuristicParser.parse(rawText: rawText);

      expect(result.amount, equals(45000));
      expect(result.storeOrRecipient, contains('CIRCLE K'));
      expect(result.category, equals(ExpenseCategory.shopping));
    });

    test('Correctly parses comma thousand separators: TOTAL: 120,000', () {
      const rawText = '''
WINMART VINHOMES
TOTAL: 120,000
Người thụ hưởng: WINMART
Ngân hàng: Techcombank
Thời gian: 29/09/2026 18:40
      ''';

      final result = HeuristicParser.parse(rawText: rawText);

      expect(result.amount, equals(120000));
      expect(result.storeOrRecipient, contains('WINMART'));
      expect(result.category, equals(ExpenseCategory.shopping));
    });

    test('CurrencyFormatter parses varied Vietnamese number notations correctly', () {
      expect(CurrencyFormatter.parseAmount('65.000 đ'), equals(65000));
      expect(CurrencyFormatter.parseAmount('120,000 VND'), equals(120000));
      expect(CurrencyFormatter.parseAmount('45k'), equals(45000));
      expect(CurrencyFormatter.parseAmount('2.5tr'), equals(2500000));
      expect(CurrencyFormatter.parseAmount('-85.000'), equals(85000));
      expect(CurrencyFormatter.parseAmount('+500.000 VND'), equals(500000));
    });
  });
}
