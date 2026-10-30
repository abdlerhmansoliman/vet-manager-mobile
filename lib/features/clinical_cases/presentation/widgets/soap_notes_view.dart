import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../domain/entities/progress_note_entity.dart';
import 'create_addendum_dialog.dart';
import 'create_soap_note_sheet.dart';

/// Clinical widget rendering veterinary SOAP examination logs and immutable addenda.
class SoapNotesView extends StatelessWidget {
  final List<ProgressNoteEntity> notes;
  final String? defaultVetName;
  final void Function({
    String? subjective,
    String? objective,
    String? assessment,
    String? plan,
    double? temperatureCelsius,
    int? heartRateBpm,
    int? respiratoryRateBpm,
    int? bodyConditionScore,
    int? painScore,
    String? vetName,
  }) onAddSoapNote;
  final void Function(String addendumText, String vetName) onAddAddendum;

  const SoapNotesView({
    super.key,
    required this.notes,
    this.defaultVetName,
    required this.onAddSoapNote,
    required this.onAddAddendum,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Bar & Title
        Row(
          children: [
            Text(
              'Clinical Progress Notes',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textCharcoal,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryEmeraldLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${notes.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryEmeraldDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: AnimatedPressable(
                onTap: () {
                  CreateSoapNoteSheet.show(
                    context: context,
                    defaultVetName: defaultVetName ?? 'Dr. Attending Clinician, DVM',
                    onConfirm: onAddSoapNote,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.primaryEmerald,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        'Record SOAP Exam',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AnimatedPressable(
                onTap: () {
                  CreateAddendumDialog.show(
                    context: context,
                    defaultVetName: defaultVetName ?? 'Dr. Attending Clinician, DVM',
                    onConfirm: onAddAddendum,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondaryCoral, width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.note_add_outlined, size: 16, color: AppColors.secondaryCoral),
                      const SizedBox(width: 6),
                      Text(
                        'Append Addendum',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.secondaryCoral,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Notes List or Empty State
        if (notes.isEmpty)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final note = notes[index];
              return note.isAddendum
                  ? _buildAddendumCard(note, index)
                  : _buildSoapCard(note, index);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.backgroundCream,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 32,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Examination Notes Yet',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Record the initial SOAP physical examination or sign an append-only medical addendum.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddendumCard(ProgressNoteEntity note, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.badgeObsAmberText.withValues(alpha: 0.35), width: 1.2),
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
          Text(
            note.assessment ?? note.subjective ?? 'Clinical addendum note appended.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textCharcoal,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
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
        .fadeIn(duration: 250.ms, delay: (index * 40).ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildSoapCard(ProgressNoteEntity note, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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

          // Vitals Grid
          if (note.hasVitals) ...[
            _buildVitalsRow(note),
            const SizedBox(height: 14),
          ],

          // S, O, A, P Sections
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
        .fadeIn(duration: 250.ms, delay: (index * 40).ms)
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$letter: $title',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryEmeraldDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
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
