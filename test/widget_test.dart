import 'package:flutter_test/flutter_test.dart';
import 'package:vet_manager_mobile/app/app.dart';

void main() {
  testWidgets('VetManagerApp boots and displays branding headline', (WidgetTester tester) async {
    await tester.pumpWidget(const VetManagerApp());
    expect(find.text('VetManager Mobile'), findsOneWidget);
    expect(find.text('Enterprise Clinical Client'), findsOneWidget);
  });
}
