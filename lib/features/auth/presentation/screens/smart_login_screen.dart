import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/clinic_selection_card.dart';

/// Smart Two-Step Login Screen for Veterinarians & Clinic Staff.
///
/// Implements automatic clinic tenant discovery, animated multi-clinic cards,
/// and biometric shift authorization.
class SmartLoginScreen extends StatefulWidget {
  const SmartLoginScreen({super.key});

  @override
  State<SmartLoginScreen> createState() => _SmartLoginScreenState();
}

class _SmartLoginScreenState extends State<SmartLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberBiometrics = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppColors.badgeCriticalRoseText,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header & Branding
                      _buildHeader(),
                      const SizedBox(height: 36),

                      // Interactive Dynamic Flow based on Auth State
                      if (state is AuthLoading)
                        _buildLoading(state.message)
                      else if (state is AuthTenantsDiscovered)
                        _buildTenantSelection(context, state)
                      else if (state is AuthPasswordRequired)
                        _buildPasswordEntry(context, state)
                      else
                        _buildEmailEntry(context, state),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primaryEmerald,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryEmerald.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.pets_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'VetManager',
          style: AppTextStyles.displayLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textCharcoal,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Clinical Shift & Tenancy Authentication',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildEmailEntry(BuildContext context, AuthState state) {
    if (state is AuthUnauthenticated && state.initialEmail != null && _emailController.text.isEmpty) {
      _emailController.text = state.initialEmail!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Step 1 of 2: Discover Clinics',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryEmerald,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            hintText: 'doctor@veterinaryclinic.com',
            labelText: 'Staff Email Address',
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryEmerald),
          ),
        ),
        const SizedBox(height: 24),
        AnimatedPressable(
          onTap: () {
            context.read<AuthBloc>().add(AuthEmailSubmitted(_emailController.text));
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryEmerald,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Discover My Clinics',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTenantSelection(BuildContext context, AuthTenantsDiscovered state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Practice Location',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Found ${state.tenants.length} clinics for ${state.email}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.read<AuthBloc>().add(const AuthResetToEmail()),
              child: Text(
                'Change',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.secondaryCoral,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.tenants.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tenant = state.tenants[index];
            return ClinicSelectionCard(
              tenant: tenant,
              onTap: () {
                context.read<AuthBloc>().add(AuthClinicSelected(tenant));
              },
            ).animate(delay: (index * 80).ms).fadeIn(duration: 300.ms).slideX(begin: 0.08, end: 0);
          },
        ),
      ],
    );
  }

  Widget _buildPasswordEntry(BuildContext context, AuthPasswordRequired state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Clinic Context Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderWarm),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.primaryEmerald, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.tenant.name,
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: () => context.read<AuthBloc>().add(const AuthResetToEmail()),
                child: Text(
                  'Switch',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryCoral,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Account Password',
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryEmerald),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (state.biometricsAvailable)
          Row(
            children: [
              Checkbox(
                value: _rememberBiometrics,
                activeColor: AppColors.primaryEmerald,
                onChanged: (val) {
                  setState(() => _rememberBiometrics = val ?? true);
                },
              ),
              Text(
                'Enable biometric shift unlock on this device',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textCharcoal),
              ),
            ],
          ),
        const SizedBox(height: 20),
        AnimatedPressable(
          onTap: () {
            context.read<AuthBloc>().add(
                  AuthLoginSubmitted(
                    email: state.email,
                    password: _passwordController.text,
                    tenantId: state.tenant.id,
                    enableBiometrics: _rememberBiometrics,
                  ),
                );
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryEmerald,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'Sign In & Start Shift',
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildLoading(String? message) {
    return Column(
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryEmerald),
          strokeWidth: 3,
        ),
        const SizedBox(height: 18),
        Text(
          message ?? 'Communicating with clinic server...',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
