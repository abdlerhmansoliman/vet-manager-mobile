import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/app/app.dart';
import 'package:vet_manager_mobile/features/auth/data/auth_repository.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('VetManagerApp boots and displays Smart Login initial step', (WidgetTester tester) async {
    final mockRepo = MockAuthRepository();
    when(() => mockRepo.hasActiveSession()).thenAnswer((_) async => false);

    await tester.pumpWidget(VetManagerApp(authRepository: mockRepo));
    await tester.pumpAndSettle();

    expect(find.text('VetManager'), findsOneWidget);
    expect(find.text('Step 1 of 2: Discover Clinics'), findsOneWidget);
    expect(find.text('Discover My Clinics'), findsOneWidget);
  });
}
