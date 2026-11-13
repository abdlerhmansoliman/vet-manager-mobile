import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/visit_entity.dart';
import '../../domain/repositories/case_repository.dart';
import '../bloc/visit_detail_bloc.dart';
import '../bloc/visit_detail_event.dart';
import '../bloc/visit_detail_state.dart';
import '../../../media/domain/repositories/media_repository.dart';
import '../../../media/presentation/widgets/diagnostic_media_gallery.dart';
import '../widgets/administer_medication_sheet.dart';
import '../widgets/create_addendum_dialog.dart';
import '../widgets/create_soap_note_sheet.dart';
import '../widgets/dose_administration_card.dart';
import '../widgets/immutable_addendum_card.dart';
import '../widgets/soap_progress_card.dart';
import '../../../../core/localization/l10n_extensions.dart';

/// Clinical Encounter Hub displaying medical data strictly scoped to a specific Visit.
class VisitDetailScreen extends StatelessWidget {
  final String caseId;
  final String visitId;
  final ICaseRepository? caseRepository;
  final VisitEntity? initialVisit;

  const VisitDetailScreen({
    super.key,
    required this.caseId,
    required this.visitId,
    this.caseRepository,
    this.initialVisit,
  });

  @override
  Widget build(BuildContext context) {
    ICaseRepository? effectiveRepo = caseRepository;
    if (effectiveRepo == null) {
      try {
        effectiveRepo = RepositoryProvider.of<ICaseRepository>(context);
      } catch (_) {}
    }

    if (effectiveRepo == null) {
      return _VisitDetailView(
        caseId: caseId,
        visitId: visitId,
        initialVisit: initialVisit,
      );
    }

    return BlocProvider<VisitDetailBloc>(
      create: (context) => VisitDetailBloc(repository: effectiveRepo!)
        ..add(VisitDetailLoaded(visitId)),
      child: _VisitDetailView(
        caseId: caseId,
        visitId: visitId,
        initialVisit: initialVisit,
      ),
    );
  }
}

class _VisitDetailView extends StatefulWidget {
  final String caseId;
  final String visitId;
  final VisitEntity? initialVisit;

  const _VisitDetailView({
    required this.caseId,
    required this.visitId,
    this.initialVisit,
  });

  @override
  State<_VisitDetailView> createState() => _VisitDetailViewState();
}

class _VisitDetailViewState extends State<_VisitDetailView> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<VisitDetailBloc?>();
    if (bloc != null && bloc.state.status == VisitDetailStatus.initial) {
      bloc.add(VisitDetailLoaded(widget.visitId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VisitDetailBloc, VisitDetailState>(
      listener: (context, state) {
        if (state.actionFeedback != null) {
          AppSnackbar.showSuccess(context, state.actionFeedback!);
        }
        if (state.errorMessage != null) {
          AppSnackbar.showError(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        final visit = state.visit ?? widget.initialVisit;

        if (visit == null && state.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundCream,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryEmerald),
            ),
          );
        }

        if (visit == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundCream,
            appBar: AppBar(
              backgroundColor: AppColors.surfaceWhite,
              leading: const BackButton(color: AppColors.textCharcoal),
            ),
            body: Center(
              child: Text(
                state.errorMessage ?? 'Encounter visit not found',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundCream,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceWhite,
            elevation: 0,
            leading: const BackButton(color: AppColors.textCharcoal),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textCharcoal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  context.formatVisitType(visit.visitType),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            actions: [
              if (!visit.isLocked)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primaryEmerald),
                  tooltip: context.l10n.editVisit,
                  onPressed: () => _showEditVisitDialog(context, visit),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: _buildStatusBadge(visit),
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
                // Visit Metadata Hero Banner
                _buildVisitMetadataCard(visit)
                    .animate()
                    .fadeIn(duration: 250.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 16),

                // Scoped Action Buttons
                _buildActionButtons(context, visit)
                    .animate()
                    .fadeIn(duration: 250.ms, delay: 50.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 20),

                // SOAP Progress Note Section
                _buildSoapSection(context, visit)
                    .animate()
                    .fadeIn(duration: 250.ms, delay: 100.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 20),

                // Visit Diagnostic Media & Radiographs Section
                _buildVisitMediaSection(context, visit)
                    .animate()
                    .fadeIn(duration: 250.ms, delay: 120.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 20),

                // Administered Medications Section
                _buildMedicationsSection(context, visit)
                    .animate()
                    .fadeIn(duration: 250.ms, delay: 150.ms)
                    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 20),

                // Immutable Medical Addendums Section
                _buildAddendaSection(context, visit)
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

  Widget _buildStatusBadge(VisitEntity visit) {
    if (visit.isLocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
        decoration: BoxDecoration(
          color: AppColors.badgeStableMint,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded, size: 11, color: Color(0xFF065F46)),
            const SizedBox(width: 4),
            Text(
              context.l10n.locked,
              style: AppTextStyles.badgeLabel.copyWith(
                color: const Color(0xFF065F46),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: AppColors.badgeObsAmber,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pending_actions_rounded, size: 11, color: AppColors.badgeObsAmberText),
          const SizedBox(width: 4),
          Text(
            context.l10n.activeBadge,
            style: AppTextStyles.badgeLabel.copyWith(
              color: AppColors.badgeObsAmberText,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitMetadataCard(VisitEntity visit) {
    return Container(
      width: double.infinity,
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: visit.isLocked
                      ? AppColors.primaryEmeraldLight
                      : AppColors.badgeObsAmber,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  visit.isLocked ? Icons.verified_rounded : Icons.pending_actions_rounded,
                  color: visit.isLocked ? AppColors.primaryEmeraldDark : AppColors.badgeObsAmberText,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${context.l10n.encounterDate}: ${_formatDate(visit.visitDate)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.borderWarm.withValues(alpha: 0.6)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${context.l10n.attendingClinician}: ${visit.veterinarianName}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textCharcoal,
                ),
              ),
              const Spacer(),
              if (visit.isLocked) ...[
                const Icon(Icons.lock_clock_rounded, size: 13, color: Color(0xFF065F46)),
                const SizedBox(width: 4),
                Text(
                  context.l10n.signedAndFinalized,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF065F46),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisitMediaSection(BuildContext context, VisitEntity visit) {
    IMediaRepository? mediaRepo;
    try {
      mediaRepo = RepositoryProvider.of<IMediaRepository>(context);
    } catch (_) {}

    return DiagnosticMediaGallery(
      imageableType: 'visit',
      imageableId: visit.id,
      parentCaseId: visit.caseId,
      repository: mediaRepo,
    );
  }

  Widget _buildActionButtons(BuildContext context, VisitEntity visit) {
    final isOpen = visit.isOpen;

    return Column(
      children: [
        Row(
          children: [
            // "Record SOAP Exam" button (visible & primary when OPEN, hidden when SIGNED)
            if (isOpen)
              Expanded(
                child: AnimatedPressable(
                  onTap: () {
                    CreateSoapNoteSheet.show(
                      context: context,
                      defaultVetName: visit.veterinarianName,
                      onConfirm: ({
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
                        prescriptions,
                      }) {
                        context.read<VisitDetailBloc>().add(
                              VisitSoapRecorded(
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
                                autoSign: true, // Signing SOAP locks the encounter
                              ),
                            );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryEmerald.withValues(alpha: 0.22),
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
                          visit.hasSoap
                              ? context.l10n.editSoapExam
                              : context.l10n.recordSoapExam,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              // "Append Addendum" button (visible & prominent when SIGNED / CLOSED)
              Expanded(
                child: AnimatedPressable(
                  onTap: () {
                    CreateAddendumDialog.show(
                      context: context,
                      defaultVetName: visit.veterinarianName,
                      onConfirm: (text, vetName) {
                        context.read<VisitDetailBloc>().add(
                              VisitAddendumAppended(
                                addendumText: text,
                                veterinarianName: vetName,
                              ),
                            );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.secondaryCoral, width: 1.3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryCoral.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.note_add_outlined, size: 16, color: AppColors.secondaryCoral),
                        const SizedBox(width: 6),
                        Text(
                          context.l10n.appendAddendum,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.secondaryCoral,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(width: 10),

            // "Administer Medication / Dose" button
            Expanded(
              child: AnimatedPressable(
                onTap: () {
                  AdministerMedicationSheet.show(
                    context: context,
                    defaultVetName: visit.veterinarianName,
                    onConfirm: ({
                      required prescription,
                      required veterinarianName,
                      clinicalNotes,
                    }) {
                      context.read<VisitDetailBloc>().add(
                            VisitMedicationAdministered(
                              prescription: prescription,
                              veterinarianName: veterinarianName,
                              clinicalNotes: clinicalNotes,
                            ),
                          );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryEmerald, width: 1.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.vaccines_rounded, size: 16, color: AppColors.primaryEmerald),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.administerDose,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primaryEmerald,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // If open and SOAP already drafted, show explicit "Sign & Lock Visit" action
        if (isOpen && visit.hasSoap) ...[
          const SizedBox(height: 10),
          AnimatedPressable(
            onTap: () {
              context.read<VisitDetailBloc>().add(
                    VisitSigned(visit.veterinarianName),
                  );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF059669), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 15, color: Color(0xFF059669)),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.signAndLockVisit,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: const Color(0xFF059669),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSoapSection(BuildContext context, VisitEntity visit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.assignment_outlined, size: 18, color: AppColors.primaryEmeraldDark),
            const SizedBox(width: 6),
            Text(
              context.l10n.soapPhysicalExam,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textCharcoal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (visit.soapNote != null)
          SoapProgressCard(
            note: visit.soapNote!,
            isSigned: visit.isLocked,
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderWarm),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundCream,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_add,
                    size: 28,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.noSoapExamRecordedYet,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textCharcoal,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.noSoapExamDesc,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMedicationsSection(BuildContext context, VisitEntity visit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.vaccines_outlined, size: 18, color: AppColors.primaryEmeraldDark),
            const SizedBox(width: 6),
            Text(
              context.l10n.administeredMedications,
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
                '${visit.doseAdministrations.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryEmeraldDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (visit.doseAdministrations.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderWarm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  context.l10n.noMedicationsAdministered,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visit.doseAdministrations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return DoseAdministrationCard(
                dose: visit.doseAdministrations[index],
                animationIndex: index,
              );
            },
          ),
      ],
    );
  }

  Widget _buildAddendaSection(BuildContext context, VisitEntity visit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.note_alt_outlined, size: 18, color: AppColors.badgeObsAmberText),
            const SizedBox(width: 6),
            Text(
              context.l10n.immutableAddenda,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textCharcoal,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.badgeObsAmber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${visit.addenda.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.badgeObsAmberText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (visit.addenda.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderWarm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_clock_outlined, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    visit.isLocked
                        ? context.l10n.noAddendaSigned
                        : context.l10n.addendaCanBeAppendedOnceSigned,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visit.addenda.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return ImmutableAddendumCard(
                note: visit.addenda[index],
                animationIndex: index,
              );
            },
          ),
      ],
    );
  }

  void _showEditVisitDialog(BuildContext context, VisitEntity visit) {
    final titleController = TextEditingController(text: visit.title);
    String selectedType = visit.visitType;
    final validTypes = ['consultation', 'follow_up', 'emergency', 'surgery_recheck', 'routine'];
    if (!validTypes.contains(selectedType)) {
      selectedType = 'consultation';
    }

    showDialog<void>(
      context: context,
      builder: (dlgContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            context.l10n.editVisitDetails,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textCharcoal,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.visitTitle,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. Initial Consultation',
                  filled: true,
                  fillColor: AppColors.backgroundCream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderWarm),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.visitType,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.backgroundCream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderWarm),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'consultation', child: Text(context.l10n.consultation)),
                  DropdownMenuItem(value: 'follow_up', child: Text(context.l10n.followUp)),
                  DropdownMenuItem(value: 'emergency', child: Text(context.l10n.emergency)),
                  DropdownMenuItem(value: 'surgery_recheck', child: Text(context.l10n.surgeryRecheck)),
                  DropdownMenuItem(value: 'routine', child: Text(context.l10n.routineCheckup)),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedType = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dlgContext).pop(),
              child: Text(context.l10n.cancel, style: const TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final newTitle = titleController.text.trim();
                if (newTitle.isNotEmpty) {
                  context.read<VisitDetailBloc>().add(
                    VisitDetailsUpdated(
                      title: newTitle,
                      visitType: selectedType,
                    ),
                  );
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
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
