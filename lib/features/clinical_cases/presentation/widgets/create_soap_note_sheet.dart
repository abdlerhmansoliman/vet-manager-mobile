import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/blurred_bottom_sheet.dart';

/// Modal bottom sheet for recording a full veterinary SOAP progress note with vitals.
class CreateSoapNoteSheet extends StatefulWidget {
  final String defaultVetName;
  final void Function({
    String? subjective,
    String? objective,
    String? assessment,
    String? plan,
    double? temperatureCelsius,
    int? heartRateBpm,
    int? respiratoryRateBpm,
    int? bodyConditionScore,
    int? painScore,
    String? vetName,
  }) onConfirm;

  const CreateSoapNoteSheet({
    super.key,
    this.defaultVetName = 'Dr. Attending Clinician, DVM',
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    String defaultVetName = 'Dr. Attending Clinician, DVM',
    required void Function({
      String? subjective,
      String? objective,
      String? assessment,
      String? plan,
      double? temperatureCelsius,
      int? heartRateBpm,
      int? respiratoryRateBpm,
      int? bodyConditionScore,
      int? painScore,
      String? vetName,
    }) onConfirm,
  }) {
    return showBlurredBottomSheet(
      context: context,
      builder: (ctx) => CreateSoapNoteSheet(
        defaultVetName: defaultVetName,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<CreateSoapNoteSheet> createState() => _CreateSoapNoteSheetState();
}

class _CreateSoapNoteSheetState extends State<CreateSoapNoteSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _vetNameController;
  late final TextEditingController _subjectiveController;
  late final TextEditingController _objectiveController;
  late final TextEditingController _assessmentController;
  late final TextEditingController _planController;

  late final TextEditingController _tempController;
  late final TextEditingController _hrController;
  late final TextEditingController _rrController;

  int? _bcs = 5;
  int? _painScore = 0;

  @override
  void initState() {
    super.initState();
    _vetNameController = TextEditingController(text: widget.defaultVetName);
    _subjectiveController = TextEditingController();
    _objectiveController = TextEditingController();
    _assessmentController = TextEditingController();
    _planController = TextEditingController();

    _tempController = TextEditingController();
    _hrController = TextEditingController();
    _rrController = TextEditingController();
  }

  @override
  void dispose() {
    _vetNameController.dispose();
    _subjectiveController.dispose();
    _objectiveController.dispose();
    _assessmentController.dispose();
    _planController.dispose();
    _tempController.dispose();
    _hrController.dispose();
    _rrController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final temp = double.tryParse(_tempController.text.trim());
      final hr = int.tryParse(_hrController.text.trim());
      final rr = int.tryParse(_rrController.text.trim());

      widget.onConfirm(
        subjective: _subjectiveController.text.trim().isNotEmpty
            ? _subjectiveController.text.trim()
            : null,
        objective: _objectiveController.text.trim().isNotEmpty
            ? _objectiveController.text.trim()
            : null,
        assessment: _assessmentController.text.trim().isNotEmpty
            ? _assessmentController.text.trim()
            : null,
        plan: _planController.text.trim().isNotEmpty
            ? _planController.text.trim()
            : null,
        temperatureCelsius: temp,
        heartRateBpm: hr,
        respiratoryRateBpm: rr,
        bodyConditionScore: _bcs,
        painScore: _painScore,
        vetName: _vetNameController.text.trim(),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmeraldLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: AppColors.primaryEmeraldDark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Record SOAP Progress Note',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textCharcoal,
                          ),
                        ),
                        Text(
                          'Subjective • Objective • Assessment • Plan',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
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

              // Clinician Name
              Text(
                'Attending Veterinarian',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _vetNameController,
                decoration: _inputDecoration('Dr. Name, DVM'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Clinician name required' : null,
              ),
              const SizedBox(height: 16),

              // (S) Subjective
              _buildSectionHeader('S', 'Subjective', 'Owner observations, demeanor, appetite, vomiting/diarrhea'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _subjectiveController,
                maxLines: 3,
                decoration: _inputDecoration('e.g., Bright and alert, owner notes mild coughing in morning...'),
              ),
              const SizedBox(height: 16),

              // (O) Objective & Vitals
              _buildSectionHeader('O', 'Objective & Vitals', 'Physical examination findings, clinical vitals'),
              const SizedBox(height: 8),

              // Vitals Row: Temp, HR, RR
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Temp (°C)', style: AppTextStyles.badgeLabel.copyWith(color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _tempController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _inputDecoration('38.5'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Heart Rate (bpm)', style: AppTextStyles.badgeLabel.copyWith(color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _hrController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('110'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resp Rate (bpm)', style: AppTextStyles.badgeLabel.copyWith(color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _rrController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('24'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Pain Score & BCS Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pain Score (0-4 CSU)', style: AppTextStyles.badgeLabel.copyWith(color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<int>(
                          initialValue: _painScore,
                          decoration: _inputDecoration('Pain'),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('0 - No pain')),
                            DropdownMenuItem(value: 1, child: Text('1 - Mild')),
                            DropdownMenuItem(value: 2, child: Text('2 - Moderate')),
                            DropdownMenuItem(value: 3, child: Text('3 - Severe')),
                            DropdownMenuItem(value: 4, child: Text('4 - Extreme')),
                          ],
                          onChanged: (v) => setState(() => _painScore = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Body Condition (1-9)', style: AppTextStyles.badgeLabel.copyWith(color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<int>(
                          initialValue: _bcs,
                          decoration: _inputDecoration('BCS'),
                          items: List.generate(
                            9,
                            (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}/9')),
                          ),
                          onChanged: (v) => setState(() => _bcs = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _objectiveController,
                maxLines: 3,
                decoration: _inputDecoration('Physical exam: mucous membranes pink/moist, CRT <2s, palpation soft...'),
              ),
              const SizedBox(height: 16),

              // (A) Assessment
              _buildSectionHeader('A', 'Assessment', 'Diagnostic interpretations, differentials, prognosis'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _assessmentController,
                maxLines: 3,
                decoration: _inputDecoration('e.g., Acute uncomplicated gastroenteritis, dehydration ~5%...'),
              ),
              const SizedBox(height: 16),

              // (P) Plan
              _buildSectionHeader('P', 'Plan', 'Treatment protocols, medications, monitoring, re-check orders'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _planController,
                maxLines: 3,
                decoration: _inputDecoration('e.g., 200ml LRS IV bolus, Maropitant 1mg/kg SQ, NPO for 12 hours...'),
              ),
              const SizedBox(height: 24),

              // Submit Button
              AnimatedPressable(
                onTap: _submit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryEmerald,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Save & Sign SOAP Note',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String letter, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.primaryEmeraldLight,
            shape: BoxShape.circle,

          ),
          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryEmeraldDark,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textCharcoal,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '($subtitle)',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
      filled: true,
      fillColor: AppColors.surfaceWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
    );
  }
}
