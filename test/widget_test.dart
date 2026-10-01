import 'package:flutter_test/flutter_test.dart';
import 'package:viet_expense_ocr/main.dart';

void main() {
  testWidgets('App launches and displays home screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VietExpenseApp());
    expect(find.text('Viet Expense OCR'), findsOneWidget);
  });
}
