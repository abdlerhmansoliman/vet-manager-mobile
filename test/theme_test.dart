import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vet_manager_mobile/app/theme/app_colors.dart';
import 'package:vet_manager_mobile/app/theme/app_theme.dart';
import 'package:vet_manager_mobile/core/widgets/animal_species_avatar.dart';
import 'package:vet_manager_mobile/core/widgets/triage_priority_badge.dart';

void main() {
  test('AppColors tokens match agreed specifications', () {
    expect(AppColors.backgroundCream, const Color(0xFFFAF8F5));
    expect(AppColors.primaryEmerald, const Color(0xFF0D9488));
    expect(AppColors.secondaryCoral, const Color(0xFFFF7E67));
    expect(AppColors.badgeStableMint, const Color(0xFFD1FAE5));
    expect(AppColors.badgeObsAmber, const Color(0xFFFEF3C7));
    expect(AppColors.badgeCriticalRose, const Color(0xFFFFE4E6));
  });

  test('AppTheme generates valid ThemeData', () {
    final theme = AppTheme.lightTheme;
    expect(theme.scaffoldBackgroundColor, AppColors.backgroundCream);
    expect(theme.colorScheme.primary, AppColors.primaryEmerald);
    expect(theme.colorScheme.secondary, AppColors.secondaryCoral);
  });

  testWidgets('TriagePriorityBadge displays correct priority labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TriagePriorityBadge(priority: TriagePriority.routine),
              TriagePriorityBadge(priority: TriagePriority.urgent),
              TriagePriorityBadge(priority: TriagePriority.critical),
            ],
          ),
        ),
      ),
    );

    expect(find.text('ROUTINE'), findsOneWidget);
    expect(find.text('URGENT'), findsOneWidget);
    expect(find.text('CRITICAL'), findsOneWidget);
  });

  testWidgets('AnimalSpeciesAvatar renders without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimalSpeciesAvatar(species: 'Canine'),
        ),
      ),
    );

    expect(find.byType(AnimalSpeciesAvatar), findsOneWidget);
    expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
  });
}
