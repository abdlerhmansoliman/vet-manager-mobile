import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../domain/entities/progress_note_entity.dart';

/// Reusable card rendering veterinary SOAP examination findings and objective vitals.
class SoapProgressCard extends StatelessWidget {
  final ProgressNoteEntity note;
  final int animationIndex;
  final bool isSigned;

  const SoapProgressCard({
    super.key,
    required this.note,
    this.animationIndex = 0,
    this.isSigned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: AppColors.warmAmbientShadow,
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
                  color: AppColors.primaryEmeraldLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'SOAP PROGRESS NOTE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryEmeraldDark,
                  ),
                ),
              ),
              if (isSigned) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.badgeStableMint,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 10, color: Color(0xFF065F46)),
                      const SizedBox(width: 3),
                      Text(
                        'SIGNED',
                        style: AppTextStyles.badgeLabel.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
          const SizedBox(height: 12),

          // Objective Vitals Grid
          if (note.hasVitals) ...[
            _buildVitalsRow(note),
            const SizedBox(height: 14),
          ],

          // Structured S, O, A, P Sections
          if (note.subjective != null && note.subjective!.isNotEmpty)
            _buildSoapSection('S', 'Subjective', note.subjective!),
          if (note.objective != null && note.objective!.isNotEmpty)
            _buildSoapSection('O', 'Objective', note.objective!),
          if (note.assessment != null && note.assessment!.isNotEmpty)
            _buildSoapSection('A', 'Assessment', note.assessment!),
          if (note.plan != null && note.plan!.isNotEmpty)
            _buildSoapSection('P', 'Plan', note.plan!),

          const SizedBox(height: 8),
          Divider(color: AppColors.borderWarm.withValues(alpha: 0.5)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                note.veterinarianName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
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

  Widget _buildVitalsRow(ProgressNoteEntity note) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          if (note.temperatureCelsius != null)
            _vitalChip('Temp', '${note.temperatureCelsius!.toStringAsFixed(1)}°C'),
          if (note.heartRateBpm != null)
            _vitalChip('HR', '${note.heartRateBpm} bpm'),
          if (note.respiratoryRateBpm != null)
            _vitalChip('RR', '${note.respiratoryRateBpm} bpm'),
          if (note.painScore != null)
            _vitalChip('Pain', '${note.painScore}/4'),
          if (note.bodyConditionScore != null)
            _vitalChip('BCS', '${note.bodyConditionScore}/9'),
        ],
      ),
    );
  }

  Widget _vitalChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textCharcoal,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSoapSection(String letter, String title, String content) {
    Color badgeBg;
    Color badgeFg;
    switch (letter) {
      case 'S':
        badgeBg = AppColors.badgeObsAmber;
        badgeFg = AppColors.badgeObsAmberText;
        break;
      case 'O':
        badgeBg = AppColors.primaryEmeraldLight;
        badgeFg = AppColors.primaryEmeraldDark;
        break;
      case 'A':
        badgeBg = AppColors.badgeStableMint;
        badgeFg = const Color(0xFF065F46);
        break;
      case 'P':
      default:
        badgeBg = AppColors.badgeCriticalRose;
        badgeFg = AppColors.badgeCriticalRoseText;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderWarm.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: badgeFg,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$letter: $title',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textCharcoal,
                    ),
                  ),
                ],
              ),
              Text(
                '${content.length} chars',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textCharcoal,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
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
