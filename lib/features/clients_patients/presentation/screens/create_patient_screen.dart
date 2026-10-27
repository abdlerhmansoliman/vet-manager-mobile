import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../domain/repositories/patient_repository.dart';

/// Form screen allowing clinicians to register a new animal patient and their owner.
class CreatePatientScreen extends StatefulWidget {
  final IPatientRepository repository;

  const CreatePatientScreen({
    super.key,
    required this.repository,
  });

  @override
  State<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

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
  String _selectedGender = 'male_neutered';
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
    ('male_neutered', 'Male (Neutered)'),
    ('male_intact', 'Male (Intact)'),
    ('female_spayed', 'Female (Spayed)'),
    ('female_intact', 'Female (Intact)'),
    ('unknown', 'Unknown'),
  ];

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
    if (!_formKey.currentState!.validate()) return;

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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registered ${_nameController.text.trim()} successfully!'),
          backgroundColor: AppColors.primaryEmerald,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error registering patient: $e'),
          backgroundColor: AppColors.secondaryCoral,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textCharcoal),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Register Patient',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textCharcoal,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
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
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter patient name or ear tag';
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
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _earTagController,
                decoration: const InputDecoration(
                  labelText: 'Visual Livestock Ear Tag ID',
                  hintText: 'e.g. TAG-402',
                ),
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
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter owner name';
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
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter primary phone number';
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
                  : const Text(
                      'Save Patient & Enqueue Sync',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
