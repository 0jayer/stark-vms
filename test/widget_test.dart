import 'package:flutter_test/flutter_test.dart';
import 'package:vms_frontend/main.dart';

void main() {
  testWidgets('App renders login screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const VmsApp());
    await tester.pumpAndSettle();

    // Verify login screen elements are present
    expect(find.text('Vehicle Management System'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
