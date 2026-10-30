import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';

/// Modal dialog for authoring an immutable clinical addendum.
class CreateAddendumDialog extends StatefulWidget {
  final String defaultVetName;
  final void Function(String addendumText, String vetName) onConfirm;

  const CreateAddendumDialog({
    super.key,
    this.defaultVetName = 'Dr. Attending Clinician, DVM',
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    String defaultVetName = 'Dr. Attending Clinician, DVM',
    required void Function(String addendumText, String vetName) onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierColor: AppColors.backdropScrim,
      builder: (ctx) => CreateAddendumDialog(
        defaultVetName: defaultVetName,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<CreateAddendumDialog> createState() => _CreateAddendumDialogState();
}

class _CreateAddendumDialogState extends State<CreateAddendumDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addendumController;
  late final TextEditingController _vetNameController;
  bool _certifyChecked = true;

  @override
  void initState() {
    super.initState();
    _addendumController = TextEditingController();
    _vetNameController = TextEditingController(text: widget.defaultVetName);
  }

  @override
  void dispose() {
    _addendumController.dispose();
    _vetNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_certifyChecked) return;
      widget.onConfirm(
        _addendumController.text.trim(),
        _vetNameController.text.trim(),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryCoralLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.note_alt_rounded,
                          color: AppColors.secondaryCoral,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Append Clinical Addendum',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textCharcoal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'IMMUTABLE MEDICAL RECORD',
                              style: AppTextStyles.badgeLabel.copyWith(
                                color: AppColors.badgeObsAmberText,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderWarm),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Addenda are append-only. Once signed and committed, this entry cannot be altered or deleted.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Signing Veterinarian',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textCharcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _vetNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceWhite,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Veterinarian name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Addendum Notes',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textCharcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _addendumController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter clinical observations, emergency interventions, lab updates...',
                      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                      filled: true,
                      fillColor: AppColors.surfaceWhite,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Addendum text cannot be empty' : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Checkbox(
                        value: _certifyChecked,
                        activeColor: AppColors.primaryEmerald,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) => setState(() => _certifyChecked = val ?? false),
                      ),
                      Expanded(
                        child: Text(
                          'I certify this clinical addendum is accurate and signed by me.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textCharcoal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.borderSubtle),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textCharcoal),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: AnimatedPressable(
                          onTap: _certifyChecked ? _submit : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _certifyChecked ? AppColors.primaryEmerald : AppColors.textLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Sign & Append',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
