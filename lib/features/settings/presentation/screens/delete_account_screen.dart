import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/errors/clinical_error_formatter.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// Self-Service Account Deletion Screen.
///
/// Complies with Apple App Store Review Guideline 5.1.1(v) (Account Deletion Requirement)
/// and Google Play Store User Data Deletion Policies.
class DeleteAccountScreen extends StatefulWidget {
  final IAuthRepository? authRepository;
  final AuthBloc? authBloc;

  const DeleteAccountScreen({
    super.key,
    this.authRepository,
    this.authBloc,
  });

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _confirmedAcknowledgement = false;
  bool _isDeleting = false;
  String? _inlineError;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  IAuthRepository _getAuthRepository() {
    if (widget.authRepository != null) return widget.authRepository!;
    try {
      final repo = context.read<IAuthRepository?>();
      if (repo != null) return repo;
    } catch (_) {}
    return AuthRepository();
  }

  AuthBloc? _getAuthBloc() {
    if (widget.authBloc != null) return widget.authBloc;
    try {
      return context.read<AuthBloc?>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleDeleteAccount() async {
    if (!_confirmedAcknowledgement) {
      setState(() {
        _inlineError = 'Please check the box to confirm you understand the consequences.';
      });
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Show dual-confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.secondaryCoral, size: 24),
            SizedBox(width: 8),
            Text('Confirm Deletion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you absolutely sure you want to permanently delete your practitioner account? All active sessions will be terminated immediately.',
          style: TextStyle(fontSize: 14, color: AppColors.textCharcoal),
        ),
        actions: [
          TextButton(
            key: const Key('cancel_deletion_dialog_button'),
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            key: const Key('confirm_deletion_dialog_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Permanently Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
      _inlineError = null;
    });

    try {
      final repository = _getAuthRepository();
      await repository.deleteAccount(password: _passwordController.text.trim());

      if (!mounted) return;

      AppSnackbar.showSuccess(
        context,
        'Your practitioner account has been deleted successfully.',
      );

      final bloc = _getAuthBloc();
      bloc?.add(const AuthLogoutRequested());

      // Navigate to login
      if (mounted) {
        try {
          context.go(AppRoutes.login);
        } catch (_) {
          try {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          } catch (_) {
            Navigator.of(context).maybePop();
          }
        }
      }
    } catch (e) {
      if (!mounted) return;

      final formattedError = ClinicalErrorFormatter.format(
        e,
        fallbackMessage: 'Unable to delete account. Please verify your password.',
      );

      setState(() {
        _isDeleting = false;
        _inlineError = formattedError;
      });

      AppSnackbar.showError(context, formattedError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Delete Account'),
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textCharcoal,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          key: const Key('delete_account_back_button'),
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isDeleting ? null : () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Red Danger Header Warning
                _buildDangerWarningBanner(),
                const SizedBox(height: 20),

                // Legal Audit Notice Card
                _buildLegalAuditNoticeCard(),
                const SizedBox(height: 20),

                // Consequences Checklist Card
                _buildConsequencesCard(),
                const SizedBox(height: 24),

                // Confirmation Checkbox
                _buildAcknowledgementCheckbox(),
                const SizedBox(height: 16),

                // Password Confirmation Field
                _buildPasswordField(),
                const SizedBox(height: 12),

                // Inline Error Display
                if (_inlineError != null) ...[
                  Container(
                    key: const Key('delete_account_inline_error'),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.badgeCriticalRose,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.secondaryCoral.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: AppColors.badgeCriticalRoseText,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _inlineError!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.badgeCriticalRoseText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                ElevatedButton(
                  key: const Key('confirm_delete_account_button'),
                  onPressed: (_isDeleting || !_confirmedAcknowledgement)
                      ? null
                      : _handleDeleteAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryCoral,
                    disabledBackgroundColor: AppColors.secondaryCoral.withValues(alpha: 0.35),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isDeleting
                      ? const SizedBox(
                          key: Key('delete_account_loading_indicator'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Permanently Delete My Account',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(height: 12),

                OutlinedButton(
                  key: const Key('cancel_delete_account_button'),
                  onPressed: _isDeleting ? null : () => Navigator.of(context).maybePop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textCharcoal,
                    side: const BorderSide(color: AppColors.borderWarm),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Keep My Account',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textCharcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDangerWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.badgeCriticalRose,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondaryCoral.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: AppColors.secondaryCoral,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permanent & Irreversible Action',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.badgeCriticalRoseText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Deleting your account permanently terminates your practitioner profile and revokes access to this clinic management system.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.badgeCriticalRoseText.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalAuditNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.gavel_rounded,
            size: 20,
            color: AppColors.primaryEmerald,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Audit Record Preservation',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textCharcoal,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Under veterinary statutory regulations and medical record retention laws, existing clinical progress notes, diagnostic media, and drug administration logs previously signed by you remain preserved in the clinic audit ledger.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsequencesCard() {
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
            'What happens when your account is deleted:',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletItem('Immediate revocation of all active login tokens and mobile sessions.'),
          _buildBulletItem('Your staff profile is removed from active triage scheduling and on-duty lists.'),
          _buildBulletItem('You will not be able to log back in without an invitation from the clinic owner.'),
          _buildBulletItem('Any local un-synced clinical drafts on this device will be securely wiped.'),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.secondaryCoral, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textCharcoal,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcknowledgementCheckbox() {
    return InkWell(
      key: const Key('confirm_deletion_checkbox_tap_target'),
      onTap: _isDeleting
          ? null
          : () {
              setState(() {
                _confirmedAcknowledgement = !_confirmedAcknowledgement;
                if (_confirmedAcknowledgement) _inlineError = null;
              });
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _confirmedAcknowledgement
                ? AppColors.secondaryCoral
                : AppColors.borderWarm,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              key: const Key('confirm_deletion_checkbox'),
              value: _confirmedAcknowledgement,
              activeColor: AppColors.secondaryCoral,
              onChanged: _isDeleting
                  ? null
                  : (value) {
                      setState(() {
                        _confirmedAcknowledgement = value ?? false;
                        if (_confirmedAcknowledgement) _inlineError = null;
                      });
                    },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'I understand that deleting my account is permanent and cannot be undone.',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textCharcoal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      key: const Key('delete_account_password_field'),
      controller: _passwordController,
      obscureText: _obscurePassword,
      enabled: !_isDeleting,
      decoration: InputDecoration(
        labelText: 'Confirm Your Password',
        hintText: 'Enter your account password',
        filled: true,
        fillColor: AppColors.surfaceWhite,
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted),
        suffixIcon: IconButton(
          key: const Key('delete_account_toggle_password_visibility'),
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textMuted,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderWarm),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderWarm),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.secondaryCoral, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.secondaryCoral),
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Please enter your password to authorize deletion.';
        }
        return null;
      },
    );
  }
}
