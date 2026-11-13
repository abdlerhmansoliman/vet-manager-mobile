import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/clinic_switcher_bottom_sheet.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/repositories/staff_repository.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import 'staff_management_screen.dart';
import '../../../settings/presentation/screens/delete_account_screen.dart';
import '../../../settings/presentation/screens/medical_disclaimer_screen.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/localization/locale_state.dart';
import '../../../../core/widgets/blurred_bottom_sheet.dart';
import '../../../../core/localization/l10n_extensions.dart';

/// Doctor and Practitioner Profile Screen.
///
/// Displays professional licensure, DEA credentials, active case workload,
/// authorization capabilities, and a real-time On-Duty / Off-Duty availability switch.
class DoctorProfileScreen extends StatefulWidget {
  final String? doctorId;
  final StaffEntity? initialDoctor;
  final IStaffRepository? repository;

  const DoctorProfileScreen({
    super.key,
    this.doctorId,
    this.initialDoctor,
    this.repository,
  });

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  late final StaffBloc _staffBloc;
  bool _isLocalBloc = false;
  late StaffEntity? _currentDoctor;
  bool _isTogglingAvailability = false;

  @override
  void initState() {
    super.initState();
    _currentDoctor = widget.initialDoctor;

    if (widget.repository != null) {
      _staffBloc = StaffBloc(repository: widget.repository!);
      _isLocalBloc = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final docId = widget.doctorId ?? _currentDoctor?.id;
      if (docId != null && widget.initialDoctor == null) {
        _getBloc().add(LoadDoctorProfile(doctorId: docId));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentDoctor == null) {
      try {
        final authBloc = context.read<AuthBloc?>();
        final authState = authBloc?.state;
        if (authState is AuthAuthenticated) {
          final authUser = authState.session.user;
          if (widget.doctorId == null || widget.doctorId == authUser.id) {
            _currentDoctor = StaffEntity.fromAuthUser(authUser);
          }
        }
      } catch (_) {
        // Fallback for isolated widget testing environments
      }
    }
  }

  StaffBloc _getBloc() {
    if (_isLocalBloc) return _staffBloc;
    return context.read<StaffBloc>();
  }

  @override
  void dispose() {
    if (_isLocalBloc) {
      _staffBloc.close();
    }
    super.dispose();
  }

  void _onToggleAvailability(bool newValue) {
    if (_currentDoctor == null || _isTogglingAvailability) return;

    setState(() {
      _isTogglingAvailability = true;
    });

    _getBloc().add(ToggleStaffAvailabilityRequested(
      userId: _currentDoctor!.id,
      isAvailable: newValue,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocalBloc) {
      return BlocProvider<StaffBloc>.value(
        value: _staffBloc,
        child: _buildScaffold(context),
      );
    }
    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {
    return BlocConsumer<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state is StaffOperationSuccess) {
          setState(() {
            _isTogglingAvailability = false;
            if (state.updatedStaff != null &&
                (_currentDoctor == null || state.updatedStaff!.id == _currentDoctor!.id)) {
              _currentDoctor = state.updatedStaff;
            }
          });
          AppSnackbar.showSuccess(context, state.message);
        } else if (state is StaffFailure) {
          setState(() {
            _isTogglingAvailability = false;
          });
          AppSnackbar.showError(context, state.message);
        } else if (state is StaffLoaded && state.selectedDoctor != null) {
          setState(() {
            _currentDoctor = state.selectedDoctor;
          });
        }
      },
      builder: (context, state) {
        final isPendingInitialLoad =
            state is StaffInitial && widget.doctorId != null;
        final isLoading =
            (state is StaffLoading || isPendingInitialLoad) && _currentDoctor == null;
        final doc = _currentDoctor ?? state.selectedDoctor;

        return Scaffold(
          backgroundColor: AppColors.backgroundCream,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceWhite,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textCharcoal),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(
              context.l10n.practitionerProfile,
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.textCharcoal),
            ),
            actions: [
              if (doc != null && doc.capabilities.canManageStaff)
                IconButton(
                  key: const Key('manage_staff_appbar_action'),
                  icon: const Icon(Icons.group_rounded, color: AppColors.primaryEmerald),
                  tooltip: context.l10n.manageClinicStaff,
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => StaffManagementScreen(
                          repository: widget.repository,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryEmerald),
                  ),
                )
              : doc == null
                  ? _buildEmptyState()
                  : _buildProfileContent(doc),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_off_rounded, size: 54, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(context.l10n.practitionerNotFound, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            context.l10n.practitionerNotFoundDesc,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(StaffEntity doc) {
    final isAvailable = doc.isAvailable;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Doctor Header Card
          _buildDoctorHeaderCard(doc)
              .animate()
              .fadeIn(duration: 250.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
          const SizedBox(height: 16),

          // Clinical Practice Tenancy & Multi-Clinic Switcher
          _buildClinicTenancyCard()
              .animate()
              .fadeIn(duration: 280.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
          const SizedBox(height: 16),

          // Real-time Availability Toggle Card
          _buildAvailabilityToggleCard(doc, isAvailable)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
          const SizedBox(height: 16),

          // Active Workload & Case Metrics
          _buildWorkloadMetricsCard(doc)
              .animate()
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
          const SizedBox(height: 16),

          // Clinical Credentials & Licensure
          _buildCredentialsCard(doc)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
          const SizedBox(height: 16),

          // Clinical Capabilities & Authorizations
          _buildCapabilitiesCard(doc)
              .animate()
              .fadeIn(duration: 450.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
          const SizedBox(height: 16),

          // Preferences & Localization
          _buildPreferencesSection()
              .animate()
              .fadeIn(duration: 480.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
          const SizedBox(height: 16),

          // Legal, Disclaimer & Account Privacy
          _buildLegalAndPrivacySection()
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
          const SizedBox(height: 24),

          // Optional Clinic Owner Shortcut
          if (doc.capabilities.canManageStaff)
            ElevatedButton.icon(
              key: const Key('manage_staff_bottom_button'),
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => StaffManagementScreen(
                      repository: widget.repository,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.manage_accounts_rounded, color: Colors.white),
              label: Text(context.l10n.manageClinicStaffDirectory),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDoctorHeaderCard(StaffEntity doc) {
    final initials = doc.name.trim().isNotEmpty
        ? doc.name.trim().split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : 'DR';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primaryEmerald.withValues(alpha: 0.12),
            child: Text(
              initials,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primaryEmerald,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textCharcoal),
                ),
                const SizedBox(height: 4),
                Text(
                  doc.profile?.jobTitle ?? doc.roleLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryEmerald,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (doc.profile?.specialty != null &&
                    doc.profile!.specialty!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    doc.profile!.specialty!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: doc.isActive
                        ? AppColors.badgeStableMint
                        : AppColors.badgeCriticalRose,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    doc.isActive
                        ? context.l10n.activeStaff
                        : context.l10n.suspended,
                    style: AppTextStyles.badgeLabel.copyWith(
                      color: doc.isActive
                          ? AppColors.badgeStableMintText
                          : AppColors.badgeCriticalRoseText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicTenancyCard() {
    final authState = context.watch<AuthBloc?>()?.state;
    final currentTenant = authState is AuthAuthenticated ? authState.session.tenant : null;
    final clinicName = currentTenant?.name ?? context.l10n.assignedPractice;
    final clinicSlug = currentTenant?.slug ?? 'default';

    return Container(
      key: const Key('doctor_profile_clinic_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.domain_rounded,
                  color: AppColors.primaryEmerald,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.clinicalPractice,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textCharcoal,
                      ),
                    ),
                    Text(
                      clinicName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCream,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderWarm),
                ),
                child: Text(
                  clinicSlug,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('switch_clinic_profile_button'),
            onPressed: () => ClinicSwitcherBottomSheet.show(context),
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: Text(context.l10n.switchClinicalPractice),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryEmerald,
              side: const BorderSide(color: AppColors.primaryEmerald),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggleCard(StaffEntity doc, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable ? AppColors.primaryEmerald.withValues(alpha: 0.3) : AppColors.borderWarm,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppColors.badgeStableMint
                  : AppColors.badgeObsAmber,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAvailable ? Icons.medical_services_rounded : Icons.bedtime_rounded,
              color: isAvailable
                  ? AppColors.badgeStableMintText
                  : AppColors.badgeObsAmberText,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.onDutyAvailability,
                  style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  isAvailable
                      ? context.l10n.availableForTriage
                      : context.l10n.unavailableForTriage,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isAvailable ? AppColors.primaryEmerald : AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_isTogglingAvailability)
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryEmerald),
              ),
            )
          else
            Switch.adaptive(
              key: const Key('doctor_availability_switch'),
              value: isAvailable,
              activeTrackColor: AppColors.primaryEmerald,
              onChanged: _onToggleAvailability,
            ),
        ],
      ),
    );
  }

  Widget _buildWorkloadMetricsCard(StaffEntity doc) {
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
          Text(context.l10n.clinicalWorkload, style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.assignment_turned_in_rounded,
                  label: context.l10n.activeCasesCount,
                  value: '${doc.activeCasesCount}',
                  color: AppColors.primaryEmerald,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.shield_rounded,
                  label: context.l10n.deaWitness,
                  value: doc.capabilities.canWitnessControlledSubstances
                      ? context.l10n.authorized
                      : context.l10n.notApplicable,
                  color: doc.capabilities.canWitnessControlledSubstances
                      ? AppColors.primaryEmerald
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textCharcoal,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsCard(StaffEntity doc) {
    final profile = doc.profile;
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
          Text(context.l10n.credentialsAndLicensure, style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
          const SizedBox(height: 14),
          _buildCredentialRow(
            icon: Icons.badge_outlined,
            label: context.l10n.licenseNumber,
            value: profile?.licenseNumber ?? context.l10n.notOnFile,
          ),
          if (profile?.deaNumber != null && profile!.deaNumber!.isNotEmpty) ...[
            const Divider(height: 20, color: AppColors.borderWarm),
            _buildCredentialRow(
              icon: Icons.verified_user_outlined,
              label: context.l10n.deaRegistration,
              value: profile.deaNumber!,
            ),
          ],
          const Divider(height: 20, color: AppColors.borderWarm),
          _buildCredentialRow(
            icon: Icons.email_outlined,
            label: context.l10n.clinicEmail,
            value: doc.email,
          ),
          if (doc.phone != null && doc.phone!.isNotEmpty) ...[
            const Divider(height: 20, color: AppColors.borderWarm),
            _buildCredentialRow(
              icon: Icons.phone_outlined,
              label: context.l10n.directPhone,
              value: doc.phone!,
            ),
          ],
          if (profile?.bio != null && profile!.bio!.trim().isNotEmpty) ...[
            const Divider(height: 20, color: AppColors.borderWarm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.biographyAndExperience,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.bio!,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textCharcoal),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCredentialRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryEmerald),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textCharcoal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCapabilitiesCard(StaffEntity doc) {
    final caps = doc.capabilities;
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
          Text(context.l10n.clinicalAuthorizations, style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAuthChip(context.l10n.prescribeRx, caps.canPrescribeMedication),
              _buildAuthChip(context.l10n.controlledSubstances, caps.canWitnessControlledSubstances),
              _buildAuthChip(context.l10n.surgeryClearance, caps.canPerformSurgery),
              _buildAuthChip(context.l10n.staffManagement, caps.canManageStaff),
              _buildAuthChip(context.l10n.billingAndInvoicing, caps.canManageBilling),
              _buildAuthChip(context.l10n.ownerDashboard, caps.canAccessOwnerDashboard),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthChip(String label, bool isAuthorized) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAuthorized ? AppColors.badgeStableMint : AppColors.backgroundCream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAuthorized ? AppColors.primaryEmerald.withValues(alpha: 0.3) : AppColors.borderWarm,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAuthorized ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            size: 14,
            color: isAuthorized ? AppColors.badgeStableMintText : AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isAuthorized ? AppColors.badgeStableMintText : AppColors.textMuted,
              fontWeight: isAuthorized ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    final l10n = context.l10n;
    LocaleState? localeState;
    try {
      localeState = context.watch<LocaleCubit?>()?.state;
    } catch (_) {}
    final isArabic = localeState?.isArabic ?? (Localizations.maybeLocaleOf(context)?.languageCode == 'ar');
    final currentLangLabel = isArabic ? l10n.arabic : l10n.english;

    return Container(
      key: const Key('doctor_profile_preferences_section'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settings,
            style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 14),
          InkWell(
            key: const Key('change_language_button'),
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showLanguageModal(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      color: AppColors.primaryEmerald,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appLanguage,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textCharcoal,
                          ),
                        ),
                        Text(
                          isArabic ? 'العربية (Arabic - RTL)' : 'English (LTR)',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.badgeStableMint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentLangLabel,
                      style: AppTextStyles.badgeLabel.copyWith(
                        color: AppColors.badgeStableMintText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageModal(BuildContext context) {
    final l10n = context.l10n;
    LocaleCubit? localeCubit;
    try {
      localeCubit = context.read<LocaleCubit?>();
    } catch (_) {}
    final currentCode = localeCubit?.state.locale.languageCode ??
        Localizations.maybeLocaleOf(context)?.languageCode ??
        'en';

    showBlurredBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.selectLanguage,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textCharcoal,
                ),
              ),
              const SizedBox(height: 16),
              // English Option
              InkWell(
                key: const Key('select_language_en'),
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  localeCubit?.setLocale(const Locale('en'));
                  Navigator.of(sheetContext).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: currentCode == 'en'
                        ? AppColors.badgeStableMint
                        : AppColors.backgroundCream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: currentCode == 'en'
                          ? AppColors.primaryEmerald
                          : AppColors.borderWarm,
                      width: currentCode == 'en' ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.english,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textCharcoal,
                              ),
                            ),
                            Text(
                              'Default (LTR)',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (currentCode == 'en')
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryEmerald,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Arabic Option
              InkWell(
                key: const Key('select_language_ar'),
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  localeCubit?.setLocale(const Locale('ar'));
                  Navigator.of(sheetContext).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: currentCode == 'ar'
                        ? AppColors.badgeStableMint
                        : AppColors.backgroundCream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: currentCode == 'ar'
                          ? AppColors.primaryEmerald
                          : AppColors.borderWarm,
                      width: currentCode == 'ar' ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🇸🇦', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.arabic,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textCharcoal,
                              ),
                            ),
                            Text(
                              'Arabic (RTL)',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (currentCode == 'ar')
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryEmerald,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegalAndPrivacySection() {
    return Container(
      key: const Key('doctor_profile_legal_section'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.legalAndPrivacy,
            style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 14),

          // Medical Disclaimer Row
          InkWell(
            key: const Key('view_medical_disclaimer_button'),
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const MedicalDisclaimerScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.health_and_safety_rounded,
                      color: AppColors.primaryEmerald,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.medicalAndLegalDisclaimer,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textCharcoal,
                          ),
                        ),
                        Text(
                          context.l10n.medicalDisclaimerNotice,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 20, color: AppColors.borderWarm),

          // Delete Account Row
          InkWell(
            key: const Key('delete_account_profile_button'),
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const DeleteAccountScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.badgeCriticalRose,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: AppColors.secondaryCoral,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.deletePractitionerAccount,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryCoral,
                          ),
                        ),
                        Text(
                          context.l10n.deleteAccountNotice,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
