import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Screen displayed when an authenticated clinician re-opens the app during shift.
class BiometricUnlockScreen extends StatelessWidget {
  final String? doctorName;
  final String? clinicName;

  const BiometricUnlockScreen({
    super.key,
    this.doctorName,
    this.clinicName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Doctor Avatar
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primaryEmerald.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryEmerald, width: 2),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryEmerald,
                    size: 48,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 20),

                Text(
                  doctorName ?? 'Veterinarian On Duty',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  clinicName ?? 'VetManager Clinical Workspace',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 48),

                // Biometric Scan Touch Target
                AnimatedPressable(
                  onTap: () {
                    context.read<AuthBloc>().add(const AuthBiometricUnlockAttempted());
                  },
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryEmerald, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryEmerald.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      color: AppColors.primaryEmerald,
                      size: 46,
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 1.0, end: 1.06, duration: 1200.ms, curve: Curves.easeInOut),

                const SizedBox(height: 24),
                Text(
                  'Touch fingerprint sensor or scan FaceID',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                ),
                const SizedBox(height: 48),

                // Fallback to Full Sign-In
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                  child: Text(
                    'Sign in with password or switch account',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.secondaryCoral,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
