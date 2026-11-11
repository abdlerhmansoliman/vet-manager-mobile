import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animal_species_avatar.dart';
import '../../../../core/widgets/triage_priority_badge.dart';
import '../../../clinical_cases/domain/entities/case_entity.dart';
import '../../../clinical_cases/domain/repositories/case_repository.dart';
import '../../../clinical_cases/presentation/screens/case_detail_screen.dart';
import '../../../media/domain/repositories/media_repository.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patient_repository.dart';
import 'create_patient_screen.dart';
import '../../../../core/widgets/app_snackbar.dart';

/// Comprehensive Patient Clinical Profile & Medical File Screen.
///
/// Designed with the Cheerful Warm Clinical Aesthetic:
/// - Prominent species avatar header with health status pill
/// - High-risk allergy alert badges and behavioral cautions
/// - Multi-case medical history & clinical encounters timeline
/// - Quick clinical encounter generator linked to patient
/// - Direct Edit and Soft-Delete patient actions
class PatientDetailScreen extends StatefulWidget {
  final PatientEntity patient;
  final IPatientRepository? repository;
  final ICaseRepository? caseRepository;
  final IMediaRepository? mediaRepository;

  const PatientDetailScreen({
    super.key,
    required this.patient,
    this.repository,
    this.caseRepository,
    this.mediaRepository,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late PatientEntity _patient;

  IMediaRepository? _resolveMediaRepo() {
    if (widget.mediaRepository != null) return widget.mediaRepository;
    try {
      return RepositoryProvider.of<IMediaRepository>(context);
    } catch (_) {
      return null;
    }
  }
  int _selectedTabIndex = 0; // 0: Demographics & Owner, 1: Clinical Cases

  @override
  void initState() {
    super.initState();
    _patient = widget.patient;
  }

  Future<void> _navigateToEdit() async {
    if (widget.repository == null) {
      AppSnackbar.showWarning(context, 'Patient repository unavailable for editing.');
      return;
    }

    final updated = await Navigator.of(context).push<PatientEntity>(
      MaterialPageRoute(
        builder: (context) => CreatePatientScreen(
          repository: widget.repository!,
          initialPatient: _patient,
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() => _patient = updated);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete ${_patient.nameOrTag}?',
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to remove this patient? The medical history will be preserved offline and the deletion will sync with the clinic server.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textCharcoal),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.badgeCriticalRoseText,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Delete Patient'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        if (widget.repository != null) {
          await widget.repository!.deletePatient(_patient.id);
        }
        if (!mounted) return;
        AppSnackbar.showSuccess(
          context,
          '${_patient.nameOrTag} was removed.',
        );
        Navigator.of(context).maybePop();
      } catch (e) {
        if (!mounted) return;
        AppSnackbar.showError(
          context,
          e,
          fallbackMessage: 'Unable to remove patient. Please try again.',
        );
      }
    }
  }

  Future<void> _handleCreateCase({
    required String complaint,
    required String priority,
    required String caseType,
  }) async {
    if (widget.caseRepository == null) {
      AppSnackbar.showInfo(
        context,
        'Starting encounter for ${_patient.nameOrTag}...',
      );
      return;
    }

    try {
      final now = DateTime.now();
      final caseNum =
          'CAS-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}';

      final newCase = await widget.caseRepository!.openCase(
        patientId: _patient.id,
        caseNumber: caseNum,
        chiefComplaint: complaint,
        priority: priority,
        caseType: caseType,
      );

      if (!mounted) return;
      AppSnackbar.showSuccess(
        context,
        'Case ${newCase.caseNumber} opened!',
      );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => CaseDetailScreen(
            caseId: newCase.id,
            repository: widget.caseRepository,
            mediaRepository: _resolveMediaRepo(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        e,
        fallbackMessage: 'Unable to open encounter. Please try again.',
      );
    }
  }

  void _showStartCaseSheet(BuildContext context) {
    final complaintController = TextEditingController();
    String priority = 'routine';
    String caseType = 'outpatient';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Start Case for ${_patient.nameOrTag}',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textCharcoal,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: complaintController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Chief Complaint *',
                        hintText: 'e.g. Acute vomiting, Limping right forelimb',
                        filled: true,
                        fillColor: AppColors.backgroundCream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderWarm),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Triage Priority',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriorityChip('routine', 'Routine', priority, (val) {
                          setModalState(() => priority = val);
                        }),
                        const SizedBox(width: 8),
                        _buildPriorityChip('urgent', 'Urgent', priority, (val) {
                          setModalState(() => priority = val);
                        }),
                        const SizedBox(width: 8),
                        _buildPriorityChip('critical', 'Critical', priority, (val) {
                          setModalState(() => priority = val);
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Encounter Type',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: caseType,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.backgroundCream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderWarm),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'outpatient', child: Text('Outpatient')),
                        DropdownMenuItem(value: 'inpatient', child: Text('Inpatient')),
                        DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
                        DropdownMenuItem(value: 'surgery', child: Text('Surgery')),
                        DropdownMenuItem(value: 'herd_check', child: Text('Herd Check')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => caseType = val);
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        final complaint = complaintController.text.trim();
                        if (complaint.isEmpty) {
                          AppSnackbar.showWarning(sheetContext, 'Please enter a chief complaint.');
                          return;
                        }

                        Navigator.of(sheetContext).pop();
                        _handleCreateCase(
                          complaint: complaint,
                          priority: priority,
                          caseType: caseType,
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Open Encounter & Begin Triage'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryEmerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriorityChip(
    String value,
    String label,
    String current,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = value == current;
    Color color;
    if (value == 'critical') {
      color = AppColors.badgeCriticalRoseText;
    } else if (value == 'urgent') {
      color = AppColors.badgeObsAmberText;
    } else {
      color = AppColors.primaryEmerald;
    }

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? color : AppColors.textCharcoal,
      ),
      side: BorderSide(color: isSelected ? color : AppColors.borderWarm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textCharcoal),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          _patient.nameOrTag,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textCharcoal,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _patient.status.toLowerCase() == 'active'
                  ? AppColors.badgeStableMint
                  : AppColors.badgeObsAmber,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _patient.status.toLowerCase() == 'active'
                    ? const Color(0xFFA7F3D0)
                    : const Color(0xFFFDE68A),
              ),
            ),
            child: Text(
              _patient.status.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _patient.status.toLowerCase() == 'active'
                    ? AppColors.badgeStableMintText
                    : AppColors.badgeObsAmberText,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textCharcoal),
            onSelected: (val) {
              if (val == 'edit') {
                _navigateToEdit();
              } else if (val == 'delete') {
                _confirmDelete();
              }
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryEmerald),
                    SizedBox(width: 8),
                    Text('Edit Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.badgeCriticalRoseText),
                    SizedBox(width: 8),
                    Text('Delete Patient',
                        style: TextStyle(color: AppColors.badgeCriticalRoseText)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHero(),
            const SizedBox(height: 16),
            if (_patient.allergies.isNotEmpty) ...[
              _buildAllergiesAlert(),
              const SizedBox(height: 16),
            ],
            _buildTabSelector(),
            const SizedBox(height: 16),
            if (_selectedTabIndex == 0) ...[
              _buildDemographicsCard(),
              const SizedBox(height: 16),
              _buildOwnerCard(),
              const SizedBox(height: 16),
              _buildMedicalHistoryCard(),
            ] else ...[
              _buildClinicalCasesSection(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = 0),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0 ? AppColors.primaryEmerald : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Details & Owner',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _selectedTabIndex == 0 ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = 1),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1 ? AppColors.primaryEmerald : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Clinical Cases',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _selectedTabIndex == 1 ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalCasesSection() {
    if (widget.caseRepository == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderWarm),
        ),
        child: Column(
          children: [
            const Icon(Icons.medical_services_outlined, size: 44, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No Clinical Cases Recorded',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Every clinical problem, disease episode, and treatment plan for ${_patient.nameOrTag} is managed as a case. Tap "Create New Case" below to open a case.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<CaseSummaryEntity>>(
      stream: widget.caseRepository!.watchCasesForPatient(_patient.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppColors.primaryEmerald),
            ),
          );
        }

        final cases = snapshot.data ?? [];
        if (cases.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderWarm),
            ),
            child: Column(
              children: [
                const Icon(Icons.medical_services_outlined, size: 44, color: AppColors.primaryEmerald),
                const SizedBox(height: 12),
                Text(
                  'No Clinical Cases Recorded',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'All clinical cases, diagnoses, and medical problems for ${_patient.nameOrTag} will appear here in chronological order.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cases.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final c = cases[index];
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => CaseDetailScreen(
                      caseId: c.id,
                      repository: widget.caseRepository,
                      mediaRepository: _resolveMediaRepo(),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          c.caseNumber,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textCharcoal,
                          ),
                        ),
                        TriagePriorityBadge.fromString(c.priority),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.chiefComplaint,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textCharcoal,
                      ),
                    ),
                    if (c.finalDiagnosis != null || c.provisionalDiagnosis != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryEmeraldLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Diagnosis: ${c.finalDiagnosis ?? c.provisionalDiagnosis}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryEmeraldDark,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Attending: ${c.primaryVeterinarianName ?? "Clinician"}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                        Text(
                          c.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: c.status == 'closed'
                                ? AppColors.textMuted
                                : AppColors.primaryEmerald,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimalSpeciesAvatar(
            species: _patient.species,
            radius: 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _patient.nameOrTag,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmeraldLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _patient.species,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryEmeraldDark,
                        ),
                      ),
                    ),
                    if (_patient.breed != null && _patient.breed!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _patient.breed!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_patient.formattedAge} • ${_patient.formattedGender}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textCharcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildAllergiesAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.badgeCriticalRose,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.badgeCriticalRoseText, size: 20),
              SizedBox(width: 8),
              Text(
                'HIGH-RISK ALLERGY ALERT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors.badgeCriticalRoseText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _patient.allergies.map((allergy) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDA4AF)),
                ),
                child: Text(
                  allergy,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.badgeCriticalRoseText,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildDemographicsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Demographics',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            'Body Weight',
            _patient.currentWeightKg != null
                ? '${_patient.currentWeightKg!.toStringAsFixed(1)} kg'
                : 'Not recorded',
            icon: Icons.scale_rounded,
          ),
          const Divider(height: 18, color: AppColors.borderWarm),
          _buildInfoRow(
            'RFID Microchip',
            _patient.microchipNumber ?? 'No chip implanted',
            icon: Icons.qr_code_2_rounded,
          ),
          if (_patient.earTagId != null && _patient.earTagId!.isNotEmpty) ...[
            const Divider(height: 18, color: AppColors.borderWarm),
            _buildInfoRow(
              'Ear Tag ID',
              _patient.earTagId!,
              icon: Icons.tag_rounded,
            ),
          ],
          if (_patient.coatColorMarkings != null && _patient.coatColorMarkings!.isNotEmpty) ...[
            const Divider(height: 18, color: AppColors.borderWarm),
            _buildInfoRow(
              'Coat / Markings',
              _patient.coatColorMarkings!,
              icon: Icons.palette_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOwnerCard() {
    final client = _patient.client;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Registered Owner',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textCharcoal,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCream,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderWarm),
                ),
                child: Text(
                  client.clientType.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            'Full Name',
            client.name,
            icon: Icons.person_outline_rounded,
          ),
          const Divider(height: 18, color: AppColors.borderWarm),
          _buildInfoRow(
            'Primary Phone',
            client.phonePrimary,
            icon: Icons.phone_outlined,
          ),
          if (client.phoneSecondary != null && client.phoneSecondary!.isNotEmpty) ...[
            const Divider(height: 18, color: AppColors.borderWarm),
            _buildInfoRow(
              'Secondary Phone',
              client.phoneSecondary!,
              icon: Icons.phone_android_rounded,
            ),
          ],
          if (client.physicalAddress != null && client.physicalAddress!.isNotEmpty) ...[
            const Divider(height: 18, color: AppColors.borderWarm),
            _buildInfoRow(
              'Address',
              client.physicalAddress!,
              icon: Icons.location_on_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clinical Background & Cautions',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 12),
          if (_patient.notes != null && _patient.notes!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.badgeObsAmber,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.badgeObsAmberText, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _patient.notes!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.badgeObsAmberText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            _patient.history != null && _patient.history!.isNotEmpty
                ? _patient.history!
                : 'No prior clinical history recorded.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textCharcoal,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryEmerald),
        const SizedBox(width: 10),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textCharcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: const Border(top: BorderSide(color: AppColors.borderWarm)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showStartCaseSheet(context),
              icon: const Icon(Icons.medical_services_outlined, size: 20),
              label: const Text('Create New Case'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
