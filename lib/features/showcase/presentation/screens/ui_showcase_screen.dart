import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/animal_species_avatar.dart';
import '../../../../core/widgets/blurred_bottom_sheet.dart';
import '../../../../core/widgets/triage_priority_badge.dart';

/// Interactive UI Showcase Screen demonstrating the Cheerful Clinical Design System,
/// Plus Jakarta Sans typography, tactile micro-animations, and pastel badge tokens.
class UiShowcaseScreen extends StatelessWidget {
  const UiShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Showcase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _openInfoBottomSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Hero Banner
            _buildHeaderBanner()
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
            const SizedBox(height: 24),

            // 1. Color Palette Tokens
            _buildSectionHeader('1. Warm & Cheerful Colors'),
            const SizedBox(height: 12),
            _buildColorPalette()
                .animate(delay: 100.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
            const SizedBox(height: 24),

            // 2. Triage Status Badges
            _buildSectionHeader('2. Triage & Audit Status Badges'),
            const SizedBox(height: 12),
            _buildTriageBadges()
                .animate(delay: 200.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
            const SizedBox(height: 24),

            // 3. Animal Species Avatars
            _buildSectionHeader('3. Clinical Species Avatars'),
            const SizedBox(height: 12),
            _buildSpeciesAvatars()
                .animate(delay: 300.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
            const SizedBox(height: 24),

            // 4. Interactive Micro-Motion & Bottom Sheets
            _buildSectionHeader('4. Tactile Micro-Animations'),
            const SizedBox(height: 12),
            _buildInteractiveMotion(context)
                .animate(delay: 400.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTextStyles.headlineSmall);
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryEmeraldLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primaryEmerald,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VetManager UI System', style: AppTextStyles.headlineMedium),
                    Text(
                      'Warm Cream & Fresh Emerald Foundation',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Designed with compassionate warmth to reduce clinician cognitive fatigue during critical medical shifts.',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildColorPalette() {
    final colors = [
      ('Warm Cream', '#FAF8F5', AppColors.backgroundCream, AppColors.textCharcoal),
      ('Fresh Emerald', '#0D9488', AppColors.primaryEmerald, Colors.white),
      ('Warm Coral', '#FF7E67', AppColors.secondaryCoral, Colors.white),
      ('Stable Mint', '#D1FAE5', AppColors.badgeStableMint, AppColors.badgeStableMintText),
      ('Obs Amber', '#FEF3C7', AppColors.badgeObsAmber, AppColors.badgeObsAmberText),
      ('Critical Rose', '#FFE4E6', AppColors.badgeCriticalRose, AppColors.badgeCriticalRoseText),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((item) {
        return Container(
          width: 105,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: item.$3,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderWarm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.$1,
                style: AppTextStyles.titleSmall.copyWith(
                  color: item.$4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.$2,
                style: AppTextStyles.bodySmall.copyWith(
                  color: item.$4.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTriageBadges() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: const Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          TriagePriorityBadge(priority: TriagePriority.routine),
          TriagePriorityBadge(priority: TriagePriority.urgent),
          TriagePriorityBadge(priority: TriagePriority.critical),
          TriagePriorityBadge(
            priority: TriagePriority.routine,
            customLabel: 'SEALED VIAL',
          ),
          TriagePriorityBadge(
            priority: TriagePriority.urgent,
            customLabel: 'OPEN VIAL (7.5 ml)',
          ),
          TriagePriorityBadge(
            priority: TriagePriority.critical,
            customLabel: 'VOIDED REVERSAL',
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesAvatars() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              AnimalSpeciesAvatar(species: 'Canine', radius: 24),
              SizedBox(height: 6),
              Text('Canine', style: TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            children: [
              AnimalSpeciesAvatar(species: 'Feline', radius: 24),
              SizedBox(height: 6),
              Text('Feline', style: TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            children: [
              AnimalSpeciesAvatar(species: 'Equine', radius: 24),
              SizedBox(height: 6),
              Text('Equine', style: TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            children: [
              AnimalSpeciesAvatar(species: 'Bovine', radius: 24),
              SizedBox(height: 6),
              Text('Bovine', style: TextStyle(fontSize: 12)),
            ],
          ),
          Column(
            children: [
              AnimalSpeciesAvatar(species: 'Avian', radius: 24),
              SizedBox(height: 6),
              Text('Avian', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveMotion(BuildContext context) {
    return Column(
      children: [
        // Tactile Pressable Card
        AnimatedPressable(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Card tapped with elastic 0.97 scale feedback!'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderWarm),
            ),
            child: Row(
              children: [
                const AnimalSpeciesAvatar(species: 'Canine', radius: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Max (Golden Retriever)', style: AppTextStyles.titleLarge),
                      Text('Case #2026-104 • Post-Op Exam', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const TriagePriorityBadge(priority: TriagePriority.routine),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Blurred Bottom Sheet Trigger Button
        ElevatedButton.icon(
          onPressed: () => _openInfoBottomSheet(context),
          icon: const Icon(Icons.blur_on_rounded),
          label: const Text('Test Blurred Backdrop Spring Sheet'),
        ),
      ],
    );
  }

  void _openInfoBottomSheet(BuildContext context) {
    showBlurredBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Blurred Backdrop Spring Sheet', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Uses BackdropFilter with Gaussian sigma 8 blur and Curves.easeOutBack spring curve for tactile medical interactions.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Close Bottom Sheet'),
              ),
            ],
          ),
        );
      },
    );
  }
}
