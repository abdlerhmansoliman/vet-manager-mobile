import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../domain/entities/dose_administration_entity.dart';

/// Reusable card displaying an administered medication dose record.
class DoseAdministrationCard extends StatelessWidget {
  final DoseAdministrationEntity dose;
  final int animationIndex;

  const DoseAdministrationCard({
    super.key,
    required this.dose,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryEmeraldLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.vaccines_rounded,
                  size: 16,
                  color: AppColors.primaryEmeraldDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dose.medicineName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCream,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderWarm),
                          ),
                          child: Text(
                            '${dose.doseQuantity} ${dose.unit}',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryEmeraldDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dose.route,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _formatTimestamp(dose.administeredAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (dose.clinicalNotes != null && dose.clinicalNotes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundCream,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dose.clinicalNotes!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textCharcoal,
                  fontSize: 11,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                'Administered by ${dose.veterinarianName}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms, delay: (animationIndex * 40).ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad);
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}
