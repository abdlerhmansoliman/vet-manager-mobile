import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/text_styles.dart';
import '../errors/clinical_error_formatter.dart';

/// Centralized SnackBar presentation utility adhering to the
/// Cheerful Warm Clinical Aesthetic.
class AppSnackbar {
  AppSnackbar._();

  /// Displays an error or exception message in a clean, clinical, non-technical format.
  static void showError(
    BuildContext context,
    Object? error, {
    String? fallbackMessage,
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = ClinicalErrorFormatter.format(error, fallbackMessage: fallbackMessage);
    _showSnackBar(
      context: context,
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: AppColors.secondaryCoral,
      textColor: Colors.white,
      duration: duration,
    );
  }

  /// Displays a success feedback banner.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context: context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: AppColors.primaryEmerald,
      textColor: Colors.white,
      duration: duration,
    );
  }

  /// Displays a warning / reminder notice.
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context: context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: AppColors.badgeObsAmber,
      textColor: AppColors.badgeObsAmberText,
      iconColor: AppColors.badgeObsAmberText,
      duration: duration,
    );
  }

  /// Displays an informative notice (e.g. offline sync status).
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackBar(
      context: context,
      message: message,
      icon: Icons.cloud_off_rounded,
      backgroundColor: AppColors.primaryEmeraldDark,
      textColor: Colors.white,
      duration: duration,
    );
  }

  static void _showSnackBar({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    Color? iconColor,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor ?? textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
      ),
    );
  }
}
