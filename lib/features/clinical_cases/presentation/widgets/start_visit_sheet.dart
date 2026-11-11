import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../../../core/widgets/blurred_bottom_sheet.dart';

/// Modal bottom sheet for beginning a new clinical visit encounter for a case.
class StartVisitSheet extends StatefulWidget {
  final String defaultVetName;
  final void Function({
    required String title,
    required String visitType,
    required String veterinarianName,
  }) onConfirm;

  const StartVisitSheet({
    super.key,
    this.defaultVetName = 'Dr. Attending Clinician, DVM',
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    String defaultVetName = 'Dr. Attending Clinician, DVM',
    required void Function({
      required String title,
      required String visitType,
      required String veterinarianName,
    }) onConfirm,
  }) {
    return showBlurredBottomSheet(
      context: context,
      builder: (ctx) => StartVisitSheet(
        defaultVetName: defaultVetName,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<StartVisitSheet> createState() => _StartVisitSheetState();
}

class _StartVisitSheetState extends State<StartVisitSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _vetNameController;

  String _selectedType = 'follow_up';

  final List<Map<String, String>> _visitTypes = [
    {'type': 'consultation', 'label': 'Consultation'},
    {'type': 'follow_up', 'label': 'Follow-up Visit'},
    {'type': 'emergency', 'label': 'Emergency'},
    {'type': 'routine', 'label': 'Routine Check'},
    {'type': 'surgery_recheck', 'label': 'Surgery Recheck'},
  ];

  @override
  void initState() {
    super.initState();
    _vetNameController = TextEditingController(text: widget.defaultVetName);
    _titleController = TextEditingController(text: _generateDefaultTitle('follow_up'));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _vetNameController.dispose();
    super.dispose();
  }

  String _generateDefaultTitle(String type) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${months[now.month - 1]} ${now.day}, ${now.year}';
    final typeMap = {
      'consultation': 'Initial Consultation',
      'follow_up': 'Follow-up Visit',
      'emergency': 'Emergency Encounter',
      'routine': 'Routine Wellness Check',
      'surgery_recheck': 'Post-Op Surgery Recheck',
    };
    return '${typeMap[type] ?? 'Clinical Encounter'} - $dateStr';
  }

  void _onTypeSelected(String type) {
    setState(() {
      _selectedType = type;
      _titleController.text = _generateDefaultTitle(type);
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onConfirm(
        title: _titleController.text.trim(),
        visitType: _selectedType,
        veterinarianName: _vetNameController.text.trim(),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderWarm,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmeraldLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_task_rounded,
                      color: AppColors.primaryEmeraldDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Start New Visit Encounter',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textCharcoal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Encounter Type Selector
              Text(
                'Encounter Type',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textCharcoal,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _visitTypes.map((item) {
                  final isSelected = _selectedType == item['type'];
                  return ChoiceChip(
                    label: Text(item['label']!),
                    selected: isSelected,
                    onSelected: (_) => _onTypeSelected(item['type']!),
                    selectedColor: AppColors.primaryEmerald,
                    backgroundColor: AppColors.backgroundCream,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textCharcoal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryEmerald : AppColors.borderWarm,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Title input
              Text(
                'Visit Title / Purpose',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'e.g. Follow-up Visit - Nov 11, 2026',
                  filled: true,
                  fillColor: AppColors.backgroundCream,
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a visit title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Attending Clinician input
              Text(
                'Attending Clinician',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _vetNameController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'e.g. Dr. Attending Clinician, DVM',
                  filled: true,
                  fillColor: AppColors.backgroundCream,
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter attending clinician name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),

              // Action button
              AnimatedPressable(
                onTap: _submit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryEmerald,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Begin Visit Encounter',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
