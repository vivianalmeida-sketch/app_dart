import 'package:flutter_test/flutter_test.dart';
import 'package:newpay/app.dart';

void main() {
  testWidgets('NewPay app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const NewPayApp());

    expect(find.text('NewPay'), findsOneWidget);
  });
}