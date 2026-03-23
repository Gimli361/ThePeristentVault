import 'package:flutter_test/flutter_test.dart';
import 'package:the_persistent_vault/main.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const PersistentVaultApp());
    expect(find.text('The Persistent'), findsOneWidget);
  });
}
