import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vet_manager_mobile/app/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('VetManagerApp boots and displays branding showcase headline', (WidgetTester tester) async {
    await tester.pumpWidget(const VetManagerApp());
    await tester.pumpAndSettle();

    expect(find.text('VetManager UI System'), findsOneWidget);
    expect(find.text('Warm Cream & Fresh Emerald Foundation'), findsOneWidget);
  });
}
