import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../domain/entities/progress_note_entity.dart';

/// Reusable card rendering an immutable, append-only signed medical addendum.
class ImmutableAddendumCard extends StatelessWidget {
  final ProgressNoteEntity note;
  final int animationIndex;

  const ImmutableAddendumCard({
    super.key,
    required this.note,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.badgeObsAmberText.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.badgeObsAmber,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded, size: 11, color: AppColors.badgeObsAmberText),
                    const SizedBox(width: 4),
                    Text(
                      'IMMUTABLE ADDENDUM',
                      style: AppTextStyles.badgeLabel.copyWith(
                        color: AppColors.badgeObsAmberText,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                _formatTimestamp(note.recordedAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Addendum content
          Text(
            note.assessment ?? note.subjective ?? 'Clinical addendum note appended.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textCharcoal,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          // Signing clinician
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, size: 14, color: AppColors.primaryEmerald),
              const SizedBox(width: 4),
              Text(
                'Signed by ${note.veterinarianName}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryEmeraldDark,
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
