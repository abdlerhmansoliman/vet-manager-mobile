import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/blurred_bottom_sheet.dart';
import '../../domain/entities/prescription_item.dart';
import '../../domain/entities/veterinary_formulary.dart';

/// Modal bottom sheet for recording a full veterinary SOAP progress note with vitals,
/// structured medication selection, and unit dosing.
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
    List<PrescriptionItem>? prescriptions,
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
      List<PrescriptionItem>? prescriptions,
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

  // Structured Prescriptions & Medication Selection
  final List<PrescriptionItem> _prescriptions = [];
  final TextEditingController _medicineSearchController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  TextEditingController? _autocompleteTextController;

  String _selectedUnit = 'ml';
  String _selectedRoute = 'PO (Oral)';
  String _selectedFrequency = 'BID (Twice daily)';
  String? _prescriptionError;

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
    _medicineSearchController.dispose();
    _doseController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _addPrescription() {
    final medName = _medicineSearchController.text.trim();
    final dose = _doseController.text.trim();

    if (medName.isEmpty) {
      setState(() {
        _prescriptionError = 'Please select or enter a medicine name';
      });
      return;
    }
    if (dose.isEmpty) {
      setState(() {
        _prescriptionError = 'Please enter dose quantity';
      });
      return;
    }

    setState(() {
      _prescriptionError = null;
      _prescriptions.add(
        PrescriptionItem(
          medicineName: medName,
          doseQuantity: dose,
          unit: _selectedUnit,
          route: _selectedRoute,
          frequency: _selectedFrequency,
          instructions: _instructionsController.text.trim().isNotEmpty
              ? _instructionsController.text.trim()
              : null,
        ),
      );

      // Reset entry inputs
      _autocompleteTextController?.clear();
      _medicineSearchController.clear();
      _doseController.clear();
      _instructionsController.clear();
    });
  }

  void _removePrescription(int index) {
    setState(() {
      _prescriptions.removeAt(index);
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final temp = double.tryParse(_tempController.text.trim());
      final hr = int.tryParse(_hrController.text.trim());
      final rr = int.tryParse(_rrController.text.trim());

      // Combine structured prescriptions with general plan notes
      String? combinedPlan;
      final generalPlan = _planController.text.trim();

      if (_prescriptions.isNotEmpty) {
        final buffer = StringBuffer('Rx Prescriptions:\n');
        for (final rx in _prescriptions) {
          buffer.writeln(rx.formatForPlan());
        }
        if (generalPlan.isNotEmpty) {
          buffer.write('\nOrders & Clinical Instructions:\n$generalPlan');
        }
        combinedPlan = buffer.toString().trim();
      } else if (generalPlan.isNotEmpty) {
        combinedPlan = generalPlan;
      }

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
        plan: combinedPlan,
        temperatureCelsius: temp,
        heartRateBpm: hr,
        respiratoryRateBpm: rr,
        bodyConditionScore: _bcs,
        painScore: _painScore,
        vetName: _vetNameController.text.trim(),
        prescriptions: _prescriptions.isNotEmpty ? List.unmodifiable(_prescriptions) : null,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
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

              // (P) Plan Header
              _buildSectionHeader('P', 'Plan', 'Treatment protocols, medications, monitoring, re-check orders'),
              const SizedBox(height: 10),

              // Structured Prescription & Medicine Selector Card
              _buildPrescriptionBuilderCard(),
              const SizedBox(height: 12),

              // List of Added Prescriptions
              if (_prescriptions.isNotEmpty) ...[
                _buildPrescriptionsList(),
                const SizedBox(height: 12),
              ],

              // Additional Clinical Orders & Notes
              Text(
                'Additional Clinical Orders & Instructions',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _planController,
                maxLines: 2,
                decoration: _inputDecoration('e.g., 200ml LRS IV bolus, NPO for 12 hours, recheck renal panel in 48h...'),
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

  /// Builds the interactive medication prescription builder card
  Widget _buildPrescriptionBuilderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryEmeraldLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: AppColors.primaryEmeraldDark,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Prescribe Medication / Treatment',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Medicine Name with Autocomplete suggestions
          Text(
            'Select Medicine',
            style: AppTextStyles.badgeLabel.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Autocomplete<VeterinaryMedicationRef>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              final query = textEditingValue.text.trim().toLowerCase();
              if (query.isEmpty) {
                return VeterinaryFormulary.commonMedications.take(6);
              }
              return VeterinaryFormulary.commonMedications.where(
                (med) =>
                    med.name.toLowerCase().contains(query) ||
                    med.category.toLowerCase().contains(query),
              );
            },
            displayStringForOption: (option) => option.name,
            onSelected: (option) {
              _medicineSearchController.text = option.name;
              setState(() {
                _selectedUnit = option.defaultUnit;
                _selectedRoute = option.defaultRoute;
                _selectedFrequency = option.defaultFrequency;
              });
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              _autocompleteTextController = controller;
              // Keep external controller in sync
              controller.addListener(() {
                _medicineSearchController.text = controller.text;
              });
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: _inputDecoration('Search or enter medication name (e.g. Meloxicam)...')
                    .copyWith(
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Dose Quantity & Unit Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dose Quantity
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dose / Qty', style: AppTextStyles.badgeLabel.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _doseController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration('e.g. 2.5 or 250'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Measurement Unit Dropdown
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unit', style: AppTextStyles.badgeLabel.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      decoration: _inputDecoration('Unit'),
                      items: VeterinaryFormulary.standardUnits.map((u) {
                        return DropdownMenuItem<String>(
                          value: u,
                          child: Text(u, style: const TextStyle(fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedUnit = v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Route & Frequency Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Route', style: AppTextStyles.badgeLabel.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRoute,
                      decoration: _inputDecoration('Route'),
                      isExpanded: true,
                      items: VeterinaryFormulary.standardRoutes.map((r) {
                        return DropdownMenuItem<String>(
                          value: r,
                          child: Text(
                            r,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedRoute = v);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Frequency
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Frequency', style: AppTextStyles.badgeLabel.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedFrequency,
                      decoration: _inputDecoration('Frequency'),
                      isExpanded: true,
                      items: VeterinaryFormulary.standardFrequencies.map((f) {
                        return DropdownMenuItem<String>(
                          value: f,
                          child: Text(
                            f,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedFrequency = v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Duration / Instructions
          Text(
            'Special Instructions / Duration (Optional)',
            style: AppTextStyles.badgeLabel.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _instructionsController,
            decoration: _inputDecoration('e.g., with meals x 7 days, taper over 14 days'),
          ),

          if (_prescriptionError != null) ...[
            const SizedBox(height: 6),
            Text(
              _prescriptionError!,
              style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],

          const SizedBox(height: 12),

          // Add Medication Button
          AnimatedPressable(
            onTap: _addPrescription,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryEmeraldLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryEmerald),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 18, color: AppColors.primaryEmeraldDark),
                  SizedBox(width: 6),
                  Text(
                    '+ Add Medication to Plan',
                    style: TextStyle(
                      color: AppColors.primaryEmeraldDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the list of added prescriptions
  Widget _buildPrescriptionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Prescriptions to Record',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textCharcoal,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.badgeStableMint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_prescriptions.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryEmeraldDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ..._prescriptions.asMap().entries.map((entry) {
          final index = entry.key;
          final rx = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryEmeraldLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.vaccines_rounded,
                    size: 16,
                    color: AppColors.primaryEmeraldDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rx.medicineName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textCharcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${rx.doseQuantity} ${rx.unit} • ${rx.route} • ${rx.frequency}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryEmeraldDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (rx.instructions != null && rx.instructions!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          rx.instructions!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline_rounded,
                    color: AppColors.secondaryCoral,
                    size: 20,
                  ),
                  tooltip: 'Remove',
                  onPressed: () => _removePrescription(index),
                ),
              ],
            ),
          );
        }),
      ],
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
