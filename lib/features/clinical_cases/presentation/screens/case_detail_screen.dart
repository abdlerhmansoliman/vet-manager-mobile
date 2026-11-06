import '../../../../core/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animal_species_avatar.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/triage_priority_badge.dart';
import '../../domain/entities/case_entity.dart';
import '../../domain/repositories/case_repository.dart';
import '../bloc/case_detail_bloc.dart';
import '../bloc/case_detail_event.dart';
import '../bloc/case_detail_state.dart';
import '../widgets/soap_notes_view.dart';
import '../../../media/domain/repositories/media_repository.dart';
import '../../../media/presentation/widgets/diagnostic_media_gallery.dart';

/// Comprehensive clinical encounter detail screen featuring real-time SOAP logs,
/// instant triage severity switching, and append-only signed addenda.
class CaseDetailScreen extends StatelessWidget {
  final String caseId;
  final ICaseRepository? repository;
  final CaseDetailEntity? initialDetail;
  final IMediaRepository? mediaRepository;

  const CaseDetailScreen({
    super.key,
    required this.caseId,
    this.repository,
    this.initialDetail,
    this.mediaRepository,
  });

  @override
  Widget build(BuildContext context) {
    if (repository == null) {
      // In testing or when repository is already provided up the tree
      return _CaseDetailView(
        caseId: caseId,
        initialDetail: initialDetail,
        mediaRepository: mediaRepository,
      );
    }

    return BlocProvider<CaseDetailBloc>(
      create: (context) => CaseDetailBloc(repository: repository!)
        ..add(CaseDetailLoaded(caseId)),
      child: _CaseDetailView(
        caseId: caseId,
        initialDetail: initialDetail,
        mediaRepository: mediaRepository,
      ),
    );
  }
}

class _CaseDetailView extends StatefulWidget {
  final String caseId;
  final CaseDetailEntity? initialDetail;
  final IMediaRepository? mediaRepository;

  const _CaseDetailView({
    required this.caseId,
    this.initialDetail,
    this.mediaRepository,
  });

  @override
  State<_CaseDetailView> createState() => _CaseDetailViewState();
}

class _CaseDetailViewState extends State<_CaseDetailView> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<CaseDetailBloc?>();
    if (bloc != null && bloc.state.status == CaseDetailStatus.initial) {
      bloc.add(CaseDetailLoaded(widget.caseId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CaseDetailBloc, CaseDetailState>(
      listener: (context, state) {
        if (state.actionFeedback != null) {
          AppSnackbar.showSuccess(context, state.actionFeedback!);
        }
        if (state.errorMessage != null) {
          AppSnackbar.showError(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        final detail = state.caseDetail ?? widget.initialDetail;

        if (detail == null && state.status == CaseDetailStatus.loading) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundCream,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryEmerald),
            ),
          );
        }

        if (detail == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundCream,
            appBar: AppBar(
              backgroundColor: AppColors.surfaceWhite,
              leading: const BackButton(color: AppColors.textCharcoal),
            ),
            body: Center(
              child: Text(
                state.errorMessage ?? 'Encounter not found',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              ),
            ),
          );
        }

        final summary = detail.summary;

        return Scaffold(
          backgroundColor: AppColors.backgroundCream,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceWhite,
            elevation: 0,
            leading: const BackButton(color: AppColors.textCharcoal),
            title: Text(
              summary.caseNumber,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textCharcoal,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: TriagePriorityBadge.fromString(summary.priority),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppColors.borderWarm, height: 1),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Hero Card
                _buildPatientHeroCard(detail)
                    .animate()
                    .fadeIn(duration: 250.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 16),

                // Triage Severity & Status Bar
                _buildTriageControls(context, summary)
                    .animate()
                    .fadeIn(duration: 250.ms, delay: 50.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 16),

                // Chief Complaint Card
                _buildChiefComplaintCard(summary)
                    .animate()
                    .fadeIn(duration: 250.ms, delay: 100.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 16),

                // Diagnoses Card
                _buildDiagnosesCard(context, summary)
                    .animate()
                    .fadeIn(duration: 250.ms, delay: 150.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 16),

                // Diagnostic Media & X-Rays Section
                DiagnosticMediaGallery(
                  imageableType: 'clinical_case',
                  imageableId: summary.id,
                  repository: widget.mediaRepository,
                )
                    .animate()
                    .fadeIn(duration: 250.ms, delay: 180.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 20),

                // Embedded SOAP Notes & Addenda Section
                SoapNotesView(
                  notes: detail.progressNotes,
                  defaultVetName: summary.primaryVeterinarianName,
                  onAddSoapNote: ({
                    subjective,
                    objective,
                    assessment,
                    plan,
                    temperatureCelsius,
                    heartRateBpm,
                    respiratoryRateBpm,
                    bodyConditionScore,
                    painScore,
                    vetName,
                  }) {
                    context.read<CaseDetailBloc>().add(
                          CaseSoapNoteAdded(
                            subjective: subjective,
                            objective: objective,
                            assessment: assessment,
                            plan: plan,
                            temperatureCelsius: temperatureCelsius,
                            heartRateBpm: heartRateBpm,
                            respiratoryRateBpm: respiratoryRateBpm,
                            bodyConditionScore: bodyConditionScore,
                            painScore: painScore,
                            veterinarianName: vetName,
                          ),
                        );
                  },
                  onAddAddendum: (text, vetName) {
                    context.read<CaseDetailBloc>().add(
                          CaseAddendumAdded(
                            addendumText: text,
                            veterinarianName: vetName,
                          ),
                        );
                  },
                )
                    .animate()
                    .fadeIn(duration: 250.ms, delay: 200.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientHeroCard(CaseDetailEntity detail) {
    final s = detail.summary;
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
          Row(
            children: [
              AnimalSpeciesAvatar(
                species: s.species,
                radius: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.patientName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textCharcoal,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${s.species}${s.breed != null ? " • ${s.breed}" : ""}${s.ageFormatted != null ? " • ${s.ageFormatted}" : ""}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (s.currentWeightKg != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Weight: ${s.currentWeightKg!.toStringAsFixed(1)} kg',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryEmeraldDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (detail.allergies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.badgeCriticalRose,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.badgeCriticalRoseText),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ALLERGIES: ${detail.allergies.join(", ")}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.badgeCriticalRoseText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          Divider(color: AppColors.borderWarm.withValues(alpha: 0.6)),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${s.clientName} • ${s.clientPhone}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textCharcoal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTriageControls(BuildContext context, CaseSummaryEntity summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Triage Severity Level',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildPriorityPill(
                context: context,
                label: 'Routine',
                priorityKey: 'routine',
                isSelected: summary.isRoutine,
                activeBg: AppColors.badgeStableMint,
                activeText: AppColors.badgeStableMintText,
              ),
              const SizedBox(width: 8),
              _buildPriorityPill(
                context: context,
                label: 'Urgent',
                priorityKey: 'urgent',
                isSelected: summary.isUrgent,
                activeBg: AppColors.badgeObsAmber,
                activeText: AppColors.badgeObsAmberText,
              ),
              const SizedBox(width: 8),
              _buildPriorityPill(
                context: context,
                label: 'Critical',
                priorityKey: 'critical',
                isSelected: summary.isCritical,
                activeBg: AppColors.badgeCriticalRose,
                activeText: AppColors.badgeCriticalRoseText,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: AppColors.borderWarm.withValues(alpha: 0.6)),
          const SizedBox(height: 10),
          Text(
            'Encounter Status',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusPill(context, 'Open', 'open', summary.status == 'open'),
              _buildStatusPill(context, 'In Progress', 'in_progress', summary.status == 'in_progress'),
              _buildStatusPill(context, 'Under Observation', 'under_observation', summary.status == 'under_observation'),
              _buildStatusPill(context, 'Closed', 'closed', summary.status == 'closed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityPill({
    required BuildContext context,
    required String label,
    required String priorityKey,
    required bool isSelected,
    required Color activeBg,
    required Color activeText,
  }) {
    return Expanded(
      child: AnimatedPressable(
        onTap: () {
          context.read<CaseDetailBloc>().add(CasePriorityChanged(priorityKey));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : AppColors.backgroundCream,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeText.withValues(alpha: 0.4) : AppColors.borderWarm,
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeText : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(
    BuildContext context,
    String label,
    String statusKey,
    bool isSelected,
  ) {
    return AnimatedPressable(
      onTap: () {
        context.read<CaseDetailBloc>().add(CaseStatusChanged(statusKey));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryEmeraldLight : AppColors.backgroundCream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryEmeraldDark : AppColors.borderWarm,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primaryEmeraldDark : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildChiefComplaintCard(CaseSummaryEntity summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_rounded, size: 16, color: AppColors.secondaryCoral),
              const SizedBox(width: 6),
              Text(
                'Chief Complaint',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary.chiefComplaint,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textCharcoal,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosesCard(BuildContext context, CaseSummaryEntity summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.biotech_rounded, size: 18, color: AppColors.primaryEmerald),
              const SizedBox(width: 6),
              Text(
                'Diagnoses & Hypotheses',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textCharcoal,
                ),
              ),
              const Spacer(),
              AnimatedPressable(
                onTap: () => _showEditDiagnosesDialog(context, summary),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryEmerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _diagnosisRow('Provisional Diagnosis', summary.provisionalDiagnosis ?? 'None established yet'),
          const SizedBox(height: 8),
          _diagnosisRow('Final Diagnosis', summary.finalDiagnosis ?? 'Pending investigation/response'),
        ],
      ),
    );
  }

  Widget _diagnosisRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.badgeLabel.copyWith(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textCharcoal,
          ),
        ),
      ],
    );
  }

  void _showEditDiagnosesDialog(BuildContext context, CaseSummaryEntity summary) {
    final provController = TextEditingController(text: summary.provisionalDiagnosis);
    final finalController = TextEditingController(text: summary.finalDiagnosis);

    showDialog<void>(
      context: context,
      builder: (dlgContext) => AlertDialog(
        title: const Text('Update Diagnoses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: provController,
              decoration: const InputDecoration(labelText: 'Provisional Diagnosis'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: finalController,
              decoration: const InputDecoration(labelText: 'Final Diagnosis'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<CaseDetailBloc>().add(
                    CaseDiagnosesUpdated(
                      provisionalDiagnosis: provController.text.trim(),
                      finalDiagnosis: finalController.text.trim(),
                    ),
                  );
              Navigator.of(dlgContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
