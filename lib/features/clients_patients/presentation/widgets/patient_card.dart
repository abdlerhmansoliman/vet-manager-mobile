import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animal_species_avatar.dart';
import '../../domain/entities/patient_entity.dart';
import '../screens/patient_detail_screen.dart';

/// Clinical patient card featuring seamless [OpenContainer] Material motion transform.
class PatientCard extends StatelessWidget {
  final PatientEntity patient;
  final int index;

  const PatientCard({
    super.key,
    required this.patient,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final staggerMs = (index * 40).clamp(0, 400);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OpenContainer(
        closedElevation: 0,
        openElevation: 0,
        closedColor: Colors.transparent,
        openColor: AppColors.backgroundCream,
        transitionDuration: const Duration(milliseconds: 350),
        transitionType: ContainerTransitionType.fadeThrough,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        closedBuilder: (context, openContainer) {
          return InkWell(
            onTap: openContainer,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderWarm),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimalSpeciesAvatar(
                    species: patient.species,
                    radius: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                patient.nameOrTag,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textCharcoal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (patient.breed != null && patient.breed!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                '• ${patient.breed}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              patient.species,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryEmeraldDark,
                              ),
                            ),
                            Text(
                              ' • ${patient.formattedAge}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            if (patient.currentWeightKg != null)
                              Text(
                                ' • ${patient.currentWeightKg!.toStringAsFixed(1)} kg',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${patient.client.name} (${patient.client.phonePrimary})',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textCharcoal,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (patient.allergies.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.badgeCriticalRose,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: AppColors.badgeCriticalRoseText,
                          ),
                        ),
                      if (patient.syncStatus != 'synced')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.badgeObsAmber,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'OFFLINE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.badgeObsAmberText,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        openBuilder: (context, closeContainer) {
          return PatientDetailScreen(patient: patient);
        },
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms, delay: staggerMs.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad);
  }
}
