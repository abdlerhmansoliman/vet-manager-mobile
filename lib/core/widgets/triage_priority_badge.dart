import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/text_styles.dart';

enum TriagePriority { routine, urgent, critical }

/// Visual status badge using pastel pills (Mint, Amber, Rose) with dot indicators.
class TriagePriorityBadge extends StatelessWidget {
  final TriagePriority priority;
  final String? customLabel;

  const TriagePriorityBadge({
    super.key,
    required this.priority,
    this.customLabel,
  });

  factory TriagePriorityBadge.fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'critical':
      case 'emergency':
        return const TriagePriorityBadge(priority: TriagePriority.critical);
      case 'urgent':
      case 'observation':
        return const TriagePriorityBadge(priority: TriagePriority.urgent);
      case 'routine':
      case 'stable':
      default:
        return const TriagePriorityBadge(priority: TriagePriority.routine);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, dotColor, defaultLabel) = switch (priority) {
      TriagePriority.routine => (
          AppColors.badgeStableMint,
          AppColors.badgeStableMintText,
          const Color(0xFF10B981),
          'ROUTINE',
        ),
      TriagePriority.urgent => (
          AppColors.badgeObsAmber,
          AppColors.badgeObsAmberText,
          const Color(0xFFF59E0B),
          'URGENT',
        ),
      TriagePriority.critical => (
          AppColors.badgeCriticalRose,
          AppColors.badgeCriticalRoseText,
          const Color(0xFFF43F5E),
          'CRITICAL',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            (customLabel ?? defaultLabel).toUpperCase(),
            style: AppTextStyles.badgeLabel.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
