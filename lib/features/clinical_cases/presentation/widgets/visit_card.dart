import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../domain/entities/visit_entity.dart';

/// Interactive clinical card representing a specific Visit / Encounter within a Case.
class VisitCard extends StatelessWidget {
  final VisitEntity visit;
  final VoidCallback onTap;
  final int animationIndex;

  const VisitCard({
    super.key,
    required this.visit,
    required this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: visit.isLocked
                ? AppColors.primaryEmerald.withValues(alpha: 0.25)
                : AppColors.borderWarm,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: visit.isLocked
                    ? AppColors.badgeStableMint
                    : AppColors.primaryEmeraldLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                visit.isLocked ? Icons.lock_outline_rounded : Icons.calendar_month_outlined,
                size: 18,
                color: AppColors.primaryEmeraldDark,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visit.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textCharcoal,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatDate(visit.visitDate),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms, delay: (animationIndex * 50).ms)
        .slideY(begin: 0.06, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildStatusBadge() {
    if (visit.isLocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: AppColors.badgeStableMint,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded, size: 10, color: Color(0xFF065F46)),
            const SizedBox(width: 3),
            Text(
              'SIGNED & LOCKED',
              style: AppTextStyles.badgeLabel.copyWith(
                color: const Color(0xFF065F46),
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: AppColors.badgeObsAmber,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pending_actions_rounded, size: 10, color: AppColors.badgeObsAmberText),
          const SizedBox(width: 3),
          Text(
            'ACTIVE ENCOUNTER',
            style: AppTextStyles.badgeLabel.copyWith(
              color: AppColors.badgeObsAmberText,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }


  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
