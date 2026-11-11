import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/blurred_bottom_sheet.dart';
import '../../domain/entities/prescription_item.dart';
import '../../domain/entities/veterinary_formulary.dart';

/// Modal bottom sheet for administering and logging immediate clinical doses to a case.
class AdministerMedicationSheet extends StatefulWidget {
  final String defaultVetName;
  final void Function({
    required PrescriptionItem prescription,
    required String veterinarianName,
    String? clinicalNotes,
  }) onConfirm;

  const AdministerMedicationSheet({
    super.key,
    this.defaultVetName = 'Dr. Attending Clinician, DVM',
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    String defaultVetName = 'Dr. Attending Clinician, DVM',
    required void Function({
      required PrescriptionItem prescription,
      required String veterinarianName,
      String? clinicalNotes,
    }) onConfirm,
  }) {
    return showBlurredBottomSheet(
      context: context,
      builder: (ctx) => AdministerMedicationSheet(
        defaultVetName: defaultVetName,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<AdministerMedicationSheet> createState() => _AdministerMedicationSheetState();
}

class _AdministerMedicationSheetState extends State<AdministerMedicationSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _vetNameController;
  late final TextEditingController _medicineController;
  late final TextEditingController _doseController;
  late final TextEditingController _notesController;

  String _selectedUnit = 'ml';
  String _selectedRoute = 'SQ (Subcutaneous)';
  bool _isControlled = false;

  @override
  void initState() {
    super.initState();
    _vetNameController = TextEditingController(text: widget.defaultVetName);
    _medicineController = TextEditingController();
    _doseController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _vetNameController.dispose();
    _medicineController.dispose();
    _doseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _incrementDose(double amount) {
    final current = double.tryParse(_doseController.text.trim()) ?? 0.0;
    final updated = (current + amount);
    // Format to 1 or 2 decimal places cleanly
    _doseController.text = updated % 1 == 0 ? updated.toInt().toString() : updated.toStringAsFixed(1);
    setState(() {});
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final item = PrescriptionItem(
        medicineName: _medicineController.text.trim(),
        doseQuantity: _doseController.text.trim(),
        unit: _selectedUnit,
        route: _selectedRoute,
        frequency: 'Stat (Administered)',
        instructions: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      widget.onConfirm(
        prescription: item,
        veterinarianName: _vetNameController.text.trim(),
        clinicalNotes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
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
                      Icons.vaccines_rounded,
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
                          'Administer Medication',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textCharcoal,
                          ),
                        ),
                        Text(
                          'Case Encounter • Immediate Dose & Stock Deduction',
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

              // Attending Clinician
              Text(
                'Administering Veterinarian',
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
              const SizedBox(height: 14),

              // Medicine Name with Autocomplete
              Text(
                'Medicine / Pharmaceutical Product',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textCharcoal,
                ),
              ),
              const SizedBox(height: 6),
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
                  _medicineController.text = option.name;
                  setState(() {
                    _selectedUnit = option.defaultUnit;
                    _selectedRoute = option.defaultRoute;
                    _isControlled = option.isControlled;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  controller.addListener(() {
                    _medicineController.text = controller.text;
                  });
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: _inputDecoration('Search or enter medication name (e.g. Meloxicam, Ketamine)...')
                        .copyWith(
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Medication name required' : null,
                  );
                },
              ),

              // Controlled Substance Warning
              if (_isControlled) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.badgeObsAmber,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 20, color: Colors.amber.shade900),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Controlled Substance: Dual-authorization & immutable DEA ledger audit will be recorded.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // Dose & Unit Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dose
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dose Quantity', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _doseController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _inputDecoration('e.g. 2.5 or 50'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Dose required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Unit Dropdown
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unit', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          decoration: _inputDecoration('Unit'),
                          items: VeterinaryFormulary.standardUnits.map((u) {
                            return DropdownMenuItem<String>(
                              value: u,
                              child: Text(u, style: const TextStyle(fontWeight: FontWeight.w700)),
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
              const SizedBox(height: 8),

              // Quick Stepper Chips (+0.5, +1, +5, +10)
              Row(
                children: [
                  Text('Quick Step:', style: AppTextStyles.badgeLabel.copyWith(color: AppColors.textMuted)),
                  const SizedBox(width: 6),
                  _buildQuickStepChip('+0.5', 0.5),
                  const SizedBox(width: 6),
                  _buildQuickStepChip('+1.0', 1.0),
                  const SizedBox(width: 6),
                  _buildQuickStepChip('+5.0', 5.0),
                  const SizedBox(width: 6),
                  _buildQuickStepChip('+10', 10.0),
                ],
              ),
              const SizedBox(height: 14),

              // Route Dropdown
              Text('Administration Route', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedRoute,
                decoration: _inputDecoration('Route'),
                isExpanded: true,
                items: VeterinaryFormulary.standardRoutes.map((r) {
                  return DropdownMenuItem<String>(
                    value: r,
                    child: Text(r),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedRoute = v);
                },
              ),
              const SizedBox(height: 14),

              // Clinical Notes
              Text('Clinical Indications / Notes (Optional)', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: _inputDecoration('e.g., Pre-anesthetic induction, IV catheter flush, wound irrigation...'),
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
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Confirm & Administer Dose',
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

  Widget _buildQuickStepChip(String label, double value) {
    return InkWell(
      onTap: () => _incrementDose(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryEmeraldDark,
          ),
        ),
      ),
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
