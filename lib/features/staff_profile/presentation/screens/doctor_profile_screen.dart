import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/repositories/staff_repository.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import 'staff_management_screen.dart';

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
      final docId = widget.doctorId ?? widget.initialDoctor?.id;
      if (docId != null && widget.initialDoctor == null) {
        _getBloc().add(LoadDoctorProfile(doctorId: docId));
      }
    });
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
        final isLoading =
            (state is StaffLoading || state is StaffInitial) && _currentDoctor == null;
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
              'Practitioner Profile',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.textCharcoal),
            ),
            actions: [
              if (doc != null && doc.capabilities.canManageStaff)
                IconButton(
                  key: const Key('manage_staff_appbar_action'),
                  icon: const Icon(Icons.group_rounded, color: AppColors.primaryEmerald),
                  tooltip: 'Manage Clinic Staff',
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
          Text('Practitioner profile not found', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'The requested staff credentials could not be loaded.',
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
              label: const Text('Manage Clinic Staff Directory'),
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
                    doc.isActive ? 'Active Staff' : 'Suspended',
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
                  'On-Duty Availability',
                  style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  isAvailable
                      ? 'Available for consultations & triage'
                      : 'Off-duty / Not accepting new cases',
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
          Text('Clinical Workload', style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.assignment_turned_in_rounded,
                  label: 'Active Cases',
                  value: '${doc.activeCasesCount}',
                  color: AppColors.primaryEmerald,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.shield_rounded,
                  label: 'DEA Witness',
                  value: doc.capabilities.canWitnessControlledSubstances ? 'Authorized' : 'N/A',
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
          Text('Credentials & Licensure', style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
          const SizedBox(height: 14),
          _buildCredentialRow(
            icon: Icons.badge_outlined,
            label: 'License Number',
            value: profile?.licenseNumber ?? 'Not on file',
          ),
          if (profile?.deaNumber != null && profile!.deaNumber!.isNotEmpty) ...[
            const Divider(height: 20, color: AppColors.borderWarm),
            _buildCredentialRow(
              icon: Icons.verified_user_outlined,
              label: 'DEA Registration',
              value: profile.deaNumber!,
            ),
          ],
          const Divider(height: 20, color: AppColors.borderWarm),
          _buildCredentialRow(
            icon: Icons.email_outlined,
            label: 'Clinic Email',
            value: doc.email,
          ),
          if (doc.phone != null && doc.phone!.isNotEmpty) ...[
            const Divider(height: 20, color: AppColors.borderWarm),
            _buildCredentialRow(
              icon: Icons.phone_outlined,
              label: 'Direct Phone',
              value: doc.phone!,
            ),
          ],
          if (profile?.bio != null && profile!.bio!.trim().isNotEmpty) ...[
            const Divider(height: 20, color: AppColors.borderWarm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biography & Experience',
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
          Text('Clinical Authorizations', style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAuthChip('Prescribe Rx', caps.canPrescribeMedication),
              _buildAuthChip('Controlled Substances', caps.canWitnessControlledSubstances),
              _buildAuthChip('Surgery Clearance', caps.canPerformSurgery),
              _buildAuthChip('Staff Management', caps.canManageStaff),
              _buildAuthChip('Billing & Invoicing', caps.canManageBilling),
              _buildAuthChip('Owner Dashboard', caps.canAccessOwnerDashboard),
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
}
