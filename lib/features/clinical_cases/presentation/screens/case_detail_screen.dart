import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/localization/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animal_species_avatar.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/triage_priority_badge.dart';
import '../../domain/entities/case_entity.dart';
import '../../domain/entities/visit_entity.dart';
import '../../domain/repositories/case_repository.dart';
import '../bloc/case_detail_bloc.dart';
import '../bloc/case_detail_event.dart';
import '../bloc/case_detail_state.dart';
import '../widgets/visit_card.dart';
import '../widgets/start_visit_sheet.dart';
import 'visit_detail_screen.dart';
import '../../../media/domain/repositories/media_repository.dart';

/// Comprehensive clinical encounter detail screen featuring hierarchical visits,
/// instant triage severity switching, and diagnoses.
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
    IMediaRepository? effectiveMediaRepo = mediaRepository;
    if (effectiveMediaRepo == null) {
      try {
        effectiveMediaRepo = RepositoryProvider.of<IMediaRepository>(context);
      } catch (_) {}
    }

    ICaseRepository? effectiveCaseRepo = repository;
    if (effectiveCaseRepo == null) {
      try {
        effectiveCaseRepo = RepositoryProvider.of<ICaseRepository>(context);
      } catch (_) {}
    }

    if (effectiveCaseRepo == null) {
      // In testing or when repository is already provided up the tree
      return _CaseDetailView(
        caseId: caseId,
        repository: null,
        initialDetail: initialDetail,
        mediaRepository: effectiveMediaRepo,
      );
    }

    final nonNullCaseRepo = effectiveCaseRepo;
    return BlocProvider<CaseDetailBloc>(
      create: (context) => CaseDetailBloc(repository: nonNullCaseRepo)
        ..add(CaseDetailLoaded(caseId)),
      child: _CaseDetailView(
        caseId: caseId,
        repository: nonNullCaseRepo,
        initialDetail: initialDetail,
        mediaRepository: effectiveMediaRepo,
      ),
    );
  }
}

class _CaseDetailView extends StatefulWidget {
  final String caseId;
  final ICaseRepository? repository;
  final CaseDetailEntity? initialDetail;
  final IMediaRepository? mediaRepository;

  const _CaseDetailView({
    required this.caseId,
    this.repository,
    this.initialDetail,
    this.mediaRepository,
  });

  @override
  State<_CaseDetailView> createState() => _CaseDetailViewState();
}

class _CaseDetailViewState extends State<_CaseDetailView> {
  ICaseRepository? _resolveCaseRepo(BuildContext context) {
    if (widget.repository != null) return widget.repository;
    try {
      return RepositoryProvider.of<ICaseRepository>(context);
    } catch (_) {
      return null;
    }
  }


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
                _buildChiefComplaintCard(context, summary)
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

                // Hierarchical Visits & Clinical Encounters Section
                _buildVisitsSection(context, detail)
                    .animate()
                    .fadeIn(duration: 250.ms, delay: 180.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisitsSection(BuildContext context, CaseDetailEntity detail) {
    final visits = detail.visits;
    final repo = _resolveCaseRepo(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: AppColors.primaryEmeraldDark,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.clinicalVisitsAndEncounters,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
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
                '${visits.length}',
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

        // Prominent Primary Action Button: "Start New Visit" (shown when visits already exist)
        if (visits.isNotEmpty) ...[
          AnimatedPressable(
            onTap: () => _handleStartNewVisit(context, detail, repo),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.primaryEmerald,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.startNewVisit,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Visits List or Empty State
        if (visits.isEmpty)
          _buildEmptyVisitsState(context, detail, repo)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final visit = visits[index];
              return VisitCard(
                visit: visit,
                animationIndex: index,
                onTap: () => _navigateToVisit(context, visit, repo),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyVisitsState(
    BuildContext context,
    CaseDetailEntity detail,
    ICaseRepository? repo,
  ) {
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
              Icons.meeting_room_outlined,
              size: 32,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.noVisitsRecordedYet,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.noVisitsRecordedDesc,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _handleOpenInitialConsultation(context, detail, repo),
            icon: const Icon(Icons.add, size: 18),
            label: Text(context.l10n.openInitialConsultation),
          ),
        ],
      ),
    );
  }

  Future<void> _handleOpenInitialConsultation(
    BuildContext context,
    CaseDetailEntity detail,
    ICaseRepository? repo,
  ) async {
    if (repo == null) return;
    try {
      final newVisit = await repo.startVisit(
        caseId: detail.summary.id,
        patientId: detail.summary.patientId,
        veterinarianId: detail.summary.primaryVeterinarianId,
        veterinarianName: detail.summary.primaryVeterinarianName ?? 'Dr. Attending Clinician, DVM',
        title: 'Initial Consultation',
        visitType: 'consultation',
      );
      if (context.mounted) {
        AppSnackbar.showSuccess(context, 'Initial Consultation opened');
        _navigateToVisit(context, newVisit, repo);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(context, 'Failed to open initial visit.');
      }
    }
  }

  void _handleStartNewVisit(
    BuildContext context,
    CaseDetailEntity detail,
    ICaseRepository? repo,
  ) {
    StartVisitSheet.show(
      context: context,
      defaultVetName: detail.summary.primaryVeterinarianName ?? 'Dr. Attending Clinician, DVM',
      onConfirm: ({
        required title,
        required visitType,
        required veterinarianName,
      }) async {
        if (repo == null) return;
        try {
          final newVisit = await repo.startVisit(
            caseId: detail.summary.id,
            patientId: detail.summary.patientId,
            veterinarianId: detail.summary.primaryVeterinarianId,
            veterinarianName: veterinarianName,
            title: title,
            visitType: visitType,
          );
          if (context.mounted) {
            AppSnackbar.showSuccess(context, 'Visit encounter started: $title');
            _navigateToVisit(context, newVisit, repo);
          }
        } catch (e) {
          if (context.mounted) {
            AppSnackbar.showError(context, 'Failed to start visit. Please try again.');
          }
        }
      },
    );
  }

  void _navigateToVisit(
    BuildContext context,
    VisitEntity visit,
    ICaseRepository? repo,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => VisitDetailScreen(
          caseId: widget.caseId,
          visitId: visit.id,
          caseRepository: repo,
          initialVisit: visit,
        ),
      ),
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
            context.l10n.triageSeverityLevel,
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
                label: context.l10n.routinePriority,
                priorityKey: 'routine',
                isSelected: summary.isRoutine,
                activeBg: AppColors.badgeStableMint,
                activeText: AppColors.badgeStableMintText,
              ),
              const SizedBox(width: 8),
              _buildPriorityPill(
                context: context,
                label: context.l10n.urgentPriority,
                priorityKey: 'urgent',
                isSelected: summary.isUrgent,
                activeBg: AppColors.badgeObsAmber,
                activeText: AppColors.badgeObsAmberText,
              ),
              const SizedBox(width: 8),
              _buildPriorityPill(
                context: context,
                label: context.l10n.criticalPriority,
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
            context.l10n.encounterStatus,
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
              _buildStatusPill(context, context.l10n.openStatus, 'open', summary.status == 'open'),
              _buildStatusPill(context, context.l10n.inProgressStatus, 'in_progress', summary.status == 'in_progress'),
              _buildStatusPill(context, context.l10n.underObservationStatus, 'under_observation', summary.status == 'under_observation'),
              _buildStatusPill(context, context.l10n.closedStatus, 'closed', summary.status == 'closed'),
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

  Widget _buildChiefComplaintCard(BuildContext context, CaseSummaryEntity summary) {
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
                context.l10n.chiefComplaint,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textCharcoal,
                ),
              ),
              const Spacer(),
              AnimatedPressable(
                key: const Key('edit_chief_complaint_button'),
                onTap: () => _showEditChiefComplaintDialog(context, summary),
                child: Text(
                  context.l10n.edit,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryEmerald,
                  ),
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

  void _showEditChiefComplaintDialog(BuildContext context, CaseSummaryEntity summary) {
    final controller = TextEditingController(text: summary.chiefComplaint);
    showDialog<void>(
      context: context,
      builder: (dlgContext) => AlertDialog(
        backgroundColor: AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.l10n.editChiefComplaint,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textCharcoal,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: context.l10n.enterChiefComplaintHint,
            filled: true,
            fillColor: AppColors.backgroundCream,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderWarm),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgContext).pop(),
            child: Text(context.l10n.cancel, style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                context.read<CaseDetailBloc>().add(CaseChiefComplaintUpdated(text));
                Navigator.of(dlgContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(context.l10n.save),
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
                context.l10n.diagnosesAndHypotheses,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textCharcoal,
                ),
              ),
              const Spacer(),
              AnimatedPressable(
                key: const Key('edit_diagnoses_button'),
                onTap: () => _showEditDiagnosesDialog(context, summary),
                child: Text(
                  context.l10n.edit,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryEmerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _diagnosisRow(
            context.l10n.provisionalDiagnosis,
            summary.provisionalDiagnosis ?? context.l10n.noneEstablishedYet,
          ),
          const SizedBox(height: 8),
          _diagnosisRow(
            context.l10n.finalDiagnosis,
            summary.finalDiagnosis ?? context.l10n.pendingInvestigation,
          ),
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
        title: Text(context.l10n.updateDiagnoses),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: provController,
              decoration: InputDecoration(
                labelText: context.l10n.provisionalDiagnosis,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: finalController,
              decoration: InputDecoration(
                labelText: context.l10n.finalDiagnosis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgContext).pop(),
            child: Text(context.l10n.cancel),
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
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }
}
