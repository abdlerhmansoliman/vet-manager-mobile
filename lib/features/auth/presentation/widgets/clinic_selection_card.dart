import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../domain/models/clinic_tenant.dart';

/// Interactive card component displaying a discovered clinic tenant.
class ClinicSelectionCard extends StatelessWidget {
  final ClinicTenant tenant;
  final bool isSelected;
  final VoidCallback onTap;

  const ClinicSelectionCard({
    super.key,
    required this.tenant,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primaryEmerald : AppColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryEmerald.withValues(alpha: 0.1)
                    : AppColors.backgroundCream,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.local_hospital_rounded,
                color: isSelected ? AppColors.primaryEmerald : AppColors.textMuted,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenant.name,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primaryEmerald : AppColors.textCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tenant.slug}.vetmanager.io',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.badgeStableMint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tenant.plan.toUpperCase(),
                style: AppTextStyles.badgeLabel.copyWith(
                  color: AppColors.badgeStableMintText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
