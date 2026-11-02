import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patient_repository.dart';

/// Form screen allowing clinicians to register a new animal patient or edit an existing profile.
class CreatePatientScreen extends StatefulWidget {
  final IPatientRepository repository;
  final PatientEntity? initialPatient;
  final VoidCallback? onSync;

  const CreatePatientScreen({
    super.key,
    required this.repository,
    this.initialPatient,
    this.onSync,
  });

  @override
  State<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

typedef PatientFormScreen = CreatePatientScreen;

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final _formKey = GlobalKey<FormState>();

  // Patient controllers
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _microchipController = TextEditingController();
  final _earTagController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _historyController = TextEditingController();
  final _notesController = TextEditingController();

  // Client controllers
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerAddressController = TextEditingController();

  String _selectedSpecies = 'Canine';
  String _selectedGender = 'neutered_male';
  bool _isApproximateAge = false;
  bool _isSubmitting = false;

  static const _speciesOptions = [
    'Canine',
    'Feline',
    'Equine',
    'Bovine',
    'Ovine',
    'Caprine',
    'Avian',
    'Other',
  ];

  static const _genderOptions = [
    ('neutered_male', 'Male (Neutered)'),
    ('intact_male', 'Male (Intact)'),
    ('spayed_female', 'Female (Spayed)'),
    ('intact_female', 'Female (Intact)'),
    ('unknown', 'Unknown'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPatient != null) {
      final p = widget.initialPatient!;
      _nameController.text = p.nameOrTag;
      _breedController.text = p.breed ?? '';
      _ageController.text = p.age?.toString() ?? '';
      _weightController.text = p.currentWeightKg != null ? p.currentWeightKg!.toStringAsFixed(1) : '';
      _microchipController.text = p.microchipNumber ?? '';
      _earTagController.text = p.earTagId ?? '';
      _allergiesController.text = p.allergies.join(', ');
      _historyController.text = p.history ?? '';
      _notesController.text = p.notes ?? '';
      _selectedSpecies = p.species;
      final g = p.gender;
      if (g == 'male_neutered') {
        _selectedGender = 'neutered_male';
      } else if (g == 'male_intact') {
        _selectedGender = 'intact_male';
      } else if (g == 'female_spayed') {
        _selectedGender = 'spayed_female';
      } else if (g == 'female_intact') {
        _selectedGender = 'intact_female';
      } else {
        _selectedGender = g;
      }
      _isApproximateAge = p.isApproximateAge;

      _ownerNameController.text = p.client.name;
      _ownerPhoneController.text = p.client.phonePrimary;
      _ownerAddressController.text = p.client.physicalAddress ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    _earTagController.dispose();
    _allergiesController.dispose();
    _historyController.dispose();
    _notesController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerAddressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.showWarning(
        context,
        'Please review the highlighted fields before saving.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final rawAllergies = _allergiesController.text.trim();
      final allergiesList = rawAllergies.isNotEmpty
          ? rawAllergies
              .split(',')
              .map((a) => a.trim())
              .where((a) => a.isNotEmpty)
              .toList()
          : <String>[];

      final age = int.tryParse(_ageController.text.trim());
      final weight = double.tryParse(_weightController.text.trim());

      if (widget.initialPatient != null) {
        final updated = await widget.repository.updatePatient(
          patientId: widget.initialPatient!.id,
          nameOrTag: _nameController.text.trim(),
          species: _selectedSpecies,
          breed: _breedController.text.trim().isNotEmpty
              ? _breedController.text.trim()
              : null,
          gender: _selectedGender,
          age: age,
          isApproximateAge: _isApproximateAge,
          microchipNumber: _microchipController.text.trim().isNotEmpty
              ? _microchipController.text.trim()
              : null,
          earTagId: _earTagController.text.trim().isNotEmpty
              ? _earTagController.text.trim()
              : null,
          currentWeightKg: weight,
          allergies: allergiesList,
          history: _historyController.text.trim().isNotEmpty
              ? _historyController.text.trim()
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          clientName: _ownerNameController.text.trim().isNotEmpty
              ? _ownerNameController.text.trim()
              : null,
          clientPhonePrimary: _ownerPhoneController.text.trim().isNotEmpty
              ? _ownerPhoneController.text.trim()
              : null,
          clientAddress: _ownerAddressController.text.trim().isNotEmpty
              ? _ownerAddressController.text.trim()
              : null,
        );

        widget.onSync?.call();
        if (!mounted) return;
        AppSnackbar.showSuccess(
          context,
          'Updated ${_nameController.text.trim()} successfully!',
        );
        Navigator.of(context).pop(updated);
      } else {
        await widget.repository.registerPatient(
          nameOrTag: _nameController.text.trim(),
          species: _selectedSpecies,
          breed: _breedController.text.trim().isNotEmpty
              ? _breedController.text.trim()
              : null,
          gender: _selectedGender,
          age: age,
          isApproximateAge: _isApproximateAge,
          microchipNumber: _microchipController.text.trim().isNotEmpty
              ? _microchipController.text.trim()
              : null,
          earTagId: _earTagController.text.trim().isNotEmpty
              ? _earTagController.text.trim()
              : null,
          currentWeightKg: weight,
          allergies: allergiesList,
          history: _historyController.text.trim().isNotEmpty
              ? _historyController.text.trim()
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          clientName: _ownerNameController.text.trim(),
          clientPhonePrimary: _ownerPhoneController.text.trim(),
          clientAddress: _ownerAddressController.text.trim().isNotEmpty
              ? _ownerAddressController.text.trim()
              : null,
        );

        widget.onSync?.call();
        if (!mounted) return;
        AppSnackbar.showSuccess(
          context,
          'Registered ${_nameController.text.trim()} successfully!',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppSnackbar.showError(
        context,
        e,
        fallbackMessage: 'Unable to save patient record. Please check the details and try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialPatient != null;
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEditing ? 'Edit Patient Profile' : 'Register Patient',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textCharcoal,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildSectionHeader('Patient Identity', Icons.pets_rounded),
            const SizedBox(height: 12),
            _buildCard([
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name / Ear Tag *',
                  hintText: 'e.g. Bella or EAR-104',
                ),
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Please enter patient name or ear tag';
                  }
                  if (trimmed.length > 100) {
                    return 'Patient name cannot exceed 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              const Text(
                'Species *',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _speciesOptions.map((species) {
                  final isSelected = _selectedSpecies == species;
                  return ChoiceChip(
                    label: Text(species),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedSpecies = species);
                    },
                    selectedColor: AppColors.primaryEmeraldLight,
                    backgroundColor: AppColors.backgroundCream,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primaryEmeraldDark
                          : AppColors.textCharcoal,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryEmerald
                          : AppColors.borderWarm,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  hintText: 'e.g. Golden Retriever, Holstein, Mixed',
                ),
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.length > 100) {
                    return 'Breed cannot exceed 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender & Reproductive Status',
                ),
                items: _genderOptions.map((opt) {
                  return DropdownMenuItem(value: opt.$1, child: Text(opt.$2));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGender = val);
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age (Years)',
                        hintText: 'e.g. 3',
                      ),
                      validator: (val) {
                        final trimmed = val?.trim() ?? '';
                        if (trimmed.isNotEmpty) {
                          final a = int.tryParse(trimmed);
                          if (a == null || a < 0 || a > 150) {
                            return 'Enter valid age (0-150)';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        hintText: 'e.g. 12.5',
                      ),
                      validator: (val) {
                        final trimmed = val?.trim() ?? '';
                        if (trimmed.isNotEmpty) {
                          final w = double.tryParse(trimmed);
                          if (w == null || w <= 0 || w > 10000) {
                            return 'Enter valid weight in kg';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                value: _isApproximateAge,
                onChanged: (v) => setState(() => _isApproximateAge = v ?? false),
                title: const Text('Age is estimated / approximate',
                    style: TextStyle(fontSize: 13)),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primaryEmerald,
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionHeader('Identification & Medical', Icons.medical_information_outlined),
            const SizedBox(height: 12),
            _buildCard([
              TextFormField(
                controller: _microchipController,
                decoration: const InputDecoration(
                  labelText: 'RFID Microchip Implant #',
                  hintText: '15-digit ISO 11784/11785',
                ),
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.length > 32) {
                    return 'Microchip ID cannot exceed 32 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _earTagController,
                decoration: const InputDecoration(
                  labelText: 'Visual Livestock Ear Tag ID',
                  hintText: 'e.g. TAG-402',
                ),
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.length > 64) {
                    return 'Ear tag ID cannot exceed 64 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(
                  labelText: 'Known Drug Allergies',
                  hintText: 'Separate with comma: Penicillin, NSAIDs',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Behavioral Cautions / Clinical Notes',
                  hintText: 'e.g. Muzzle required, highly anxious',
                ),
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionHeader('Registered Owner / Farm', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _buildCard([
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Owner / Contact Name *',
                  hintText: 'e.g. Sarah Connor',
                ),
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Please enter owner name';
                  }
                  if (trimmed.length > 191) {
                    return 'Owner name cannot exceed 191 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _ownerPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Primary Phone Number *',
                  hintText: 'e.g. +1-555-0199',
                ),
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Please enter primary phone number';
                  }
                  if (trimmed.length < 3) {
                    return 'Phone number must be at least 3 digits / characters';
                  }
                  if (trimmed.length > 32) {
                    return 'Phone number cannot exceed 32 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _ownerAddressController,
                decoration: const InputDecoration(
                  labelText: 'Physical Address',
                  hintText: 'Farm location or residential address',
                ),
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.length > 255) {
                    return 'Address cannot exceed 255 characters';
                  }
                  return null;
                },
              ),
            ]),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isEditing ? 'Save Changes' : 'Save Patient & Enqueue Sync',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryEmerald),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textCharcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Material(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderWarm),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
