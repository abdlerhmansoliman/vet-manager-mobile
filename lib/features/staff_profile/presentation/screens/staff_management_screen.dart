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
import 'doctor_profile_screen.dart';

/// Clinic Owner & Head Vet Staff Management Screen.
///
/// Provides staff directory listing, search, role filtering, registration modal
/// with 4-digit witness PIN assignment, detail editing, activation/suspension,
/// and soft deletion.
class StaffManagementScreen extends StatefulWidget {
  final IStaffRepository? repository;

  const StaffManagementScreen({
    super.key,
    this.repository,
  });

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  late final StaffBloc _staffBloc;
  bool _isLocalBloc = false;
  String _searchQuery = '';
  StaffRole? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    if (widget.repository != null) {
      _staffBloc = StaffBloc(repository: widget.repository!);
      _isLocalBloc = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getBloc().add(const LoadStaffList());
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

  void _onRefresh() {
    _getBloc().add(LoadStaffList(
      roleFilter: _selectedRoleFilter?.value,
    ));
  }

  List<StaffEntity> _filterStaff(List<StaffEntity> all) {
    return all.where((staff) {
      final matchesQuery = _searchQuery.isEmpty ||
          staff.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          staff.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (staff.profile?.jobTitle?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (staff.profile?.specialty?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesRole = _selectedRoleFilter == null || staff.role == _selectedRoleFilter;

      return matchesQuery && matchesRole;
    }).toList();
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
          AppSnackbar.showSuccess(context, state.message);
        } else if (state is StaffFailure && state.fieldErrors.isEmpty) {
          AppSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is StaffLoading && state.staffMembers.isEmpty;
        final isError = state is StaffFailure && state.staffMembers.isEmpty;
        final staffList = _filterStaff(state.staffMembers);

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
              'Clinic Staff Directory',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.textCharcoal),
            ),
            actions: [
              IconButton(
                key: const Key('refresh_staff_button'),
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryEmerald),
                tooltip: 'Refresh',
                onPressed: _onRefresh,
              ),
            ],
          ),
          body: Column(
            children: [
              // Search & Filter Header
              _buildSearchAndFilterHeader(),

              // Body Content
              Expanded(
                child: isError
                    ? _buildErrorBanner(state.message)
                    : isLoading
                        ? _buildLoadingSkeleton()
                        : staffList.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                onRefresh: () async => _onRefresh(),
                                color: AppColors.primaryEmerald,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  itemCount: staffList.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final staff = staffList[index];
                                    return _buildStaffCard(staff, index);
                                  },
                                ),
                              ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('add_staff_fab'),
            onPressed: () => _showStaffFormSheet(context),
            backgroundColor: AppColors.primaryEmerald,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Add Staff Member'),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilterHeader() {
    return Container(
      color: AppColors.surfaceWhite,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          TextField(
            key: const Key('staff_search_field'),
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: 'Search by name, role, email, or specialty...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.backgroundCream,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderWarm),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderWarm),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryEmerald, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRoleFilterChip(label: 'All Staff', role: null),
                const SizedBox(width: 8),
                _buildRoleFilterChip(label: 'Veterinarians', role: StaffRole.doctor),
                const SizedBox(width: 8),
                _buildRoleFilterChip(label: 'Head Vets', role: StaffRole.headVet),
                const SizedBox(width: 8),
                _buildRoleFilterChip(label: 'Field Vets', role: StaffRole.fieldDoctor),
                const SizedBox(width: 8),
                _buildRoleFilterChip(label: 'Vet Techs', role: StaffRole.vetTech),
                const SizedBox(width: 8),
                _buildRoleFilterChip(label: 'Assistants', role: StaffRole.assistant),
                const SizedBox(width: 8),
                _buildRoleFilterChip(label: 'Receptionists', role: StaffRole.receptionist),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChip({required String label, required StaffRole? role}) {
    final isSelected = _selectedRoleFilter == role;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? Colors.white : AppColors.textCharcoal,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      backgroundColor: AppColors.backgroundCream,
      selectedColor: AppColors.primaryEmerald,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primaryEmerald : AppColors.borderWarm,
        ),
      ),
      onSelected: (_) {
        setState(() => _selectedRoleFilter = role);
      },
    );
  }

  Widget _buildStaffCard(StaffEntity staff, int index) {
    final initials = staff.name.trim().isNotEmpty
        ? staff.name.trim().split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : 'ST';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => DoctorProfileScreen(
                  initialDoctor: staff,
                  repository: widget.repository,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: staff.isActive
                      ? AppColors.primaryEmerald.withValues(alpha: 0.12)
                      : AppColors.borderWarm,
                  child: Text(
                    initials,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: staff.isActive
                          ? AppColors.primaryEmerald
                          : AppColors.textMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              staff.name,
                              style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: staff.isActive
                                  ? AppColors.badgeStableMint
                                  : AppColors.badgeCriticalRose,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              staff.isActive ? 'Active' : 'Suspended',
                              style: AppTextStyles.badgeLabel.copyWith(
                                color: staff.isActive
                                    ? AppColors.badgeStableMintText
                                    : AppColors.badgeCriticalRoseText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.roleLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryEmerald,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (staff.profile?.specialty != null &&
                          staff.profile!.specialty!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          staff.profile!.specialty!,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              staff.email,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (staff.role.isDoctor)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: staff.isAvailable
                                    ? AppColors.badgeStableMint.withValues(alpha: 0.5)
                                    : AppColors.badgeObsAmber.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 3,
                                    backgroundColor: staff.isAvailable
                                        ? AppColors.primaryEmerald
                                        : AppColors.badgeObsAmberText,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    staff.isAvailable ? 'On-Duty' : 'Off-Duty',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: staff.isAvailable
                                          ? AppColors.primaryEmerald
                                          : AppColors.badgeObsAmberText,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (staff.capabilities.canWitnessControlledSubstances)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundCream,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderWarm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.shield_rounded,
                                      size: 12, color: AppColors.primaryEmerald),
                                  const SizedBox(width: 4),
                                  Text(
                                    'DEA Witness',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textCharcoal,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  key: Key('staff_menu_${staff.id}'),
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _showStaffFormSheet(context, existingStaff: staff);
                    } else if (val == 'toggle_status') {
                      _confirmToggleStatus(staff);
                    } else if (val == 'delete') {
                      _confirmDelete(staff);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: AppColors.textCharcoal),
                          SizedBox(width: 8),
                          Expanded(child: Text('Edit Staff Details')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_status',
                      child: Row(
                        children: [
                          Icon(
                            staff.isActive
                                ? Icons.pause_circle_outline_rounded
                                : Icons.play_circle_outline_rounded,
                            size: 18,
                            color: staff.isActive
                                ? AppColors.badgeObsAmberText
                                : AppColors.primaryEmerald,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              staff.isActive ? 'Suspend Staff' : 'Activate Staff',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: AppColors.secondaryCoral),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Remove Staff',
                              style: TextStyle(color: AppColors.secondaryCoral),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        height: 96,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderWarm),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryEmerald),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.secondaryCoral),
            const SizedBox(height: 12),
            Text(
              'Unable to load staff directory',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline_rounded, size: 54, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No staff members found', style: AppTextStyles.titleLarge),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or role filters.'
                : 'Add clinic doctors, technicians, or assistants above.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  void _confirmToggleStatus(StaffEntity staff) {
    final willSuspend = staff.isActive;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(willSuspend ? 'Suspend Staff Member?' : 'Activate Staff Member?'),
        content: Text(
          willSuspend
              ? 'Are you sure you want to suspend ${staff.name}? They will not be able to log in or witness controlled substances until reactivated.'
              : 'Reactivate ${staff.name}? They will immediately regain clinical shift access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirm_status_toggle_button'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _getBloc().add(ToggleStaffStatusRequested(
                userId: staff.id,
                isActive: !staff.isActive,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: willSuspend ? AppColors.secondaryCoral : AppColors.primaryEmerald,
              foregroundColor: Colors.white,
            ),
            child: Text(willSuspend ? 'Suspend' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(StaffEntity staff) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Staff Member?'),
        content: Text(
          'Are you sure you want to remove ${staff.name}? This soft-deletes their practitioner profile from the clinic directory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirm_delete_staff_button'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _getBloc().add(DeleteStaffMemberRequested(userId: staff.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryCoral,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showStaffFormSheet(BuildContext context, {StaffEntity? existingStaff}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider<StaffBloc>.value(
          value: _getBloc(),
          child: _StaffFormSheet(
            existingStaff: existingStaff,
          ),
        );
      },
    );
  }
}

/// Modal Form Sheet for Creating or Editing Staff Members.
class _StaffFormSheet extends StatefulWidget {
  final StaffEntity? existingStaff;

  const _StaffFormSheet({this.existingStaff});

  @override
  State<_StaffFormSheet> createState() => _StaffFormSheetState();
}

class _StaffFormSheetState extends State<_StaffFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _pinController;
  late final TextEditingController _phoneController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _specialtyController;
  late final TextEditingController _licenseController;
  late final TextEditingController _bioController;

  late StaffRole _selectedRole;
  bool _isAvailable = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final staff = widget.existingStaff;
    _nameController = TextEditingController(text: staff?.name ?? '');
    _emailController = TextEditingController(text: staff?.email ?? '');
    _passwordController = TextEditingController();
    _pinController = TextEditingController();
    _phoneController = TextEditingController(text: staff?.phone ?? '');
    _jobTitleController =
        TextEditingController(text: staff?.profile?.jobTitle ?? '');
    _specialtyController =
        TextEditingController(text: staff?.profile?.specialty ?? '');
    _licenseController =
        TextEditingController(text: staff?.profile?.licenseNumber ?? '');
    _bioController = TextEditingController(text: staff?.profile?.bio ?? '');

    _selectedRole = staff?.role ?? StaffRole.doctor;
    _isAvailable = staff?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _specialtyController.dispose();
    _licenseController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, bool isSubmitting) {
    if (isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bloc = context.read<StaffBloc>();

    if (widget.existingStaff == null) {
      bloc.add(CreateStaffMemberRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        role: _selectedRole,
        phone: _phoneController.text.trim(),
        pin: _pinController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        specialty: _specialtyController.text.trim(),
        licenseNumber: _licenseController.text.trim(),
        bio: _bioController.text.trim(),
        isAvailable: _isAvailable,
      ));
    } else {
      bloc.add(UpdateStaffMemberRequested(
        userId: widget.existingStaff!.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        role: _selectedRole,
        phone: _phoneController.text.trim(),
        pin: _pinController.text.isNotEmpty ? _pinController.text.trim() : null,
        jobTitle: _jobTitleController.text.trim(),
        specialty: _specialtyController.text.trim(),
        licenseNumber: _licenseController.text.trim(),
        bio: _bioController.text.trim(),
        isAvailable: _isAvailable,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingStaff != null;

    return BlocConsumer<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state is StaffOperationSuccess) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isSubmitting = state is StaffLoading && state.isSubmitting;
        final fieldErrors = state is StaffFailure ? state.fieldErrors : const <String, dynamic>{};

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Sheet Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.borderWarm,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Sheet Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit Staff Member' : 'Register New Staff Member',
                        style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderWarm),

                // Form Scroll Area
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Full Name
                          _buildFieldLabel('Full Name *'),
                          TextFormField(
                            key: const Key('staff_form_name_field'),
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                              hint: 'e.g. Dr. Jane Doe',
                              prefixIcon: Icons.person_outline_rounded,
                              errorText: _extractFieldError(fieldErrors, 'name'),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter staff member full name.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Email Address
                          _buildFieldLabel('Email Address *'),
                          TextFormField(
                            key: const Key('staff_form_email_field'),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              hint: 'e.g. jane.doe@clinic.com',
                              prefixIcon: Icons.email_outlined,
                              errorText: _extractFieldError(fieldErrors, 'email'),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter a valid email address.';
                              }
                              if (!val.contains('@') || !val.contains('.')) {
                                return 'Please enter a valid email address format.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Temporary Password
                          _buildFieldLabel(isEdit ? 'Password (leave blank to keep current)' : 'Password * (min 8 chars)'),
                          TextFormField(
                            key: const Key('staff_form_password_field'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _inputDecoration(
                              hint: isEdit ? '••••••••' : 'Enter temporary password',
                              prefixIcon: Icons.lock_outline_rounded,
                              errorText: _extractFieldError(fieldErrors, 'password'),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            validator: (val) {
                              if (!isEdit && (val == null || val.length < 8)) {
                                return 'Password must be at least 8 characters.';
                              }
                              if (isEdit && val != null && val.isNotEmpty && val.length < 8) {
                                return 'Password must be at least 8 characters.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Staff Role Selector
                          _buildFieldLabel('Clinic Staff Role *'),
                          DropdownButtonFormField<StaffRole>(
                            key: const Key('staff_form_role_dropdown'),
                            initialValue: _selectedRole,
                            decoration: _inputDecoration(
                              hint: 'Select role',
                              prefixIcon: Icons.badge_outlined,
                              errorText: _extractFieldError(fieldErrors, 'role'),
                            ),
                            items: StaffRole.values.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role.label, style: AppTextStyles.bodyMedium),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedRole = val);
                              }
                            },
                          ),
                          const SizedBox(height: 14),

                          // 4-Digit Witness PIN (Dual Authorization)
                          _buildFieldLabel('Witness PIN (4-digit numeric for dual-authorization)'),
                          TextFormField(
                            key: const Key('staff_form_pin_field'),
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: _inputDecoration(
                              hint: 'e.g. 1234',
                              prefixIcon: Icons.pin_outlined,
                              errorText: _extractFieldError(fieldErrors, 'pin'),
                            ),
                            validator: (val) {
                              if (val != null && val.isNotEmpty) {
                                if (val.length != 4 || int.tryParse(val) == null) {
                                  return 'PIN must be exactly 4 numeric digits.';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Phone Number
                          _buildFieldLabel('Phone Number'),
                          TextFormField(
                            key: const Key('staff_form_phone_field'),
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                              hint: 'e.g. +1 555-0192',
                              prefixIcon: Icons.phone_outlined,
                              errorText: _extractFieldError(fieldErrors, 'phone'),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Licensure and Specialty for Clinical Staff
                          if (_selectedRole.isDoctor || _selectedRole.isAssistant) ...[
                            _buildFieldLabel('Job Title'),
                            TextFormField(
                              key: const Key('staff_form_job_title_field'),
                              controller: _jobTitleController,
                              decoration: _inputDecoration(
                                hint: 'e.g. Senior Equine Surgeon',
                                prefixIcon: Icons.work_outline_rounded,
                                errorText: _extractFieldError(fieldErrors, 'job_title'),
                              ),
                            ),
                            const SizedBox(height: 14),

                            _buildFieldLabel('Clinical Specialty'),
                            TextFormField(
                              key: const Key('staff_form_specialty_field'),
                              controller: _specialtyController,
                              decoration: _inputDecoration(
                                hint: 'e.g. Small Animal Orthopedics',
                                prefixIcon: Icons.psychology_outlined,
                                errorText: _extractFieldError(fieldErrors, 'specialty'),
                              ),
                            ),
                            const SizedBox(height: 14),

                            _buildFieldLabel('Veterinary License Number'),
                            TextFormField(
                              key: const Key('staff_form_license_field'),
                              controller: _licenseController,
                              decoration: _inputDecoration(
                                hint: 'e.g. VET-2024-8849',
                                prefixIcon: Icons.verified_outlined,
                                errorText: _extractFieldError(fieldErrors, 'license_number'),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Bio / Notes
                          _buildFieldLabel('Bio & Background'),
                          TextFormField(
                            key: const Key('staff_form_bio_field'),
                            controller: _bioController,
                            maxLines: 2,
                            decoration: _inputDecoration(
                              hint: 'Clinical experience, certifications, schedule preferences...',
                              prefixIcon: Icons.notes_rounded,
                              errorText: _extractFieldError(fieldErrors, 'bio'),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Submit Button with in-flight spinner
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              key: const Key('staff_form_submit_button'),
                              onPressed: isSubmitting
                                  ? null
                                  : () => _submit(context, isSubmitting),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryEmerald,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.primaryEmerald.withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      isEdit ? 'Update Staff Member' : 'Register Staff Member',
                                      style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textCharcoal,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    String? errorText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
      prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
      suffixIcon: suffixIcon,
      errorText: errorText,
      errorMaxLines: 2,
      filled: true,
      fillColor: AppColors.backgroundCream,
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderWarm),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderWarm),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryEmerald, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.secondaryCoral, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    );
  }

  String? _extractFieldError(Map<String, dynamic> errors, String field) {
    if (!errors.containsKey(field)) return null;
    final val = errors[field];
    if (val is List && val.isNotEmpty) {
      return val.first.toString();
    }
    return val?.toString();
  }
}
