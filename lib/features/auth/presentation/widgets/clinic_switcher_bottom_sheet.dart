import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/models/clinic_tenant.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Modal bottom sheet allowing multi-clinic veterinary practitioners to seamlessly
/// switch their active clinic tenancy with password verification and real-time state synchronization.
class ClinicSwitcherBottomSheet extends StatefulWidget {
  const ClinicSwitcherBottomSheet({super.key});

  /// Displays the [ClinicSwitcherBottomSheet] over the active context.
  static Future<void> show(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const ClinicSwitcherBottomSheet(),
      ),
    );
  }

  @override
  State<ClinicSwitcherBottomSheet> createState() => _ClinicSwitcherBottomSheetState();
}

class _ClinicSwitcherBottomSheetState extends State<ClinicSwitcherBottomSheet> {
  String? _selectedTenantIdToSwitch;
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _previousTenantId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _previousTenantId = authState.session.tenant.id;
      if (authState.availableClinics.isEmpty) {
        context.read<AuthBloc>().add(const AuthClinicsRequested());
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onConfirmSwitch(ClinicTenant targetTenant) {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      AppSnackbar.showWarning(context, 'Please enter your password to switch practice.');
      return;
    }

    context.read<AuthBloc>().add(AuthSwitchClinicRequested(
          targetTenant: targetTenant,
          password: password,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.switchingError != null) {
            AppSnackbar.showError(context, state.switchingError!);
          } else if (_previousTenantId != null &&
              _previousTenantId != state.session.tenant.id) {
            AppSnackbar.showSuccess(
              context,
              'Switched active practice to ${state.session.tenant.name}',
            );
            Navigator.of(context).pop();
          }
        }
      },
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final session = state.session;
        final activeTenant = session.tenant;
        final clinics = state.availableClinics.isNotEmpty
            ? state.availableClinics
            : [activeTenant];
        final isSwitching = state.isSwitchingClinic;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.borderWarm,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.domain_rounded,
                        color: AppColors.primaryEmerald,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Multi-Clinic Switcher',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textCharcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dr. ${session.user.name} • ${session.user.email}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: isSwitching ? null : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Text(
                  'SELECT ACTIVE CLINICAL PRACTICE',
                  style: AppTextStyles.badgeLabel.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),

                // Clinic list
                ...clinics.map((clinic) {
                  final isActive = clinic.id == activeTenant.id;
                  final isSelectedForSwitch = _selectedTenantIdToSwitch == clinic.id;

                  return _buildClinicCard(
                    context: context,
                    clinic: clinic,
                    isActive: isActive,
                    isSelectedForSwitch: isSelectedForSwitch,
                    isSwitching: isSwitching,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClinicCard({
    required BuildContext context,
    required ClinicTenant clinic,
    required bool isActive,
    required bool isSelectedForSwitch,
    required bool isSwitching,
  }) {
    return Container(
      key: Key(isActive ? 'active_clinic_card_${clinic.id}' : 'clinic_card_${clinic.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryEmerald.withValues(alpha: 0.04)
            : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primaryEmerald : AppColors.borderWarm,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Clinic icon avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryEmerald.withValues(alpha: 0.15)
                        : AppColors.backgroundCream,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: isActive ? AppColors.primaryEmerald : AppColors.textMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Clinic name & details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinic.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textCharcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundCream,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderWarm),
                            ),
                            child: Text(
                              clinic.slug,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (clinic.plan.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '• ${clinic.plan.toUpperCase()}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Trailing: active badge or switch button
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.badgeStableMint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryEmerald,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Active',
                          style: AppTextStyles.badgeLabel.copyWith(
                            color: AppColors.primaryEmerald,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  OutlinedButton.icon(
                    key: Key('switch_button_${clinic.id}'),
                    onPressed: isSwitching
                        ? null
                        : () {
                            setState(() {
                              if (_selectedTenantIdToSwitch == clinic.id) {
                                _selectedTenantIdToSwitch = null;
                              } else {
                                _selectedTenantIdToSwitch = clinic.id;
                                _passwordController.clear();
                              }
                            });
                          },
                    icon: Icon(
                      isSelectedForSwitch
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.swap_horiz_rounded,
                      size: 16,
                    ),
                    label: Text(isSelectedForSwitch ? 'Cancel' : 'Switch'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryEmerald,
                      side: const BorderSide(color: AppColors.primaryEmerald),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Inline Password Entry when selected
          if (isSelectedForSwitch && !isActive)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(color: AppColors.borderWarm, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    'Authenticate shift switch for ${clinic.name}:',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textCharcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: Key('clinic_switch_password_field_${clinic.id}'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enabled: !isSwitching,
                    decoration: InputDecoration(
                      hintText: 'Enter account password',
                      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryEmerald),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundCream,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.borderWarm),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.borderWarm),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primaryEmerald, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    key: Key('confirm_switch_button_${clinic.id}'),
                    onPressed: isSwitching ? null : () => _onConfirmSwitch(clinic),
                    icon: isSwitching
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.login_rounded, size: 16),
                    label: Text(
                      isSwitching ? 'Switching Practice...' : 'Confirm Practice Switch',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryEmerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms),
        ],
      ),
    );
  }
}
