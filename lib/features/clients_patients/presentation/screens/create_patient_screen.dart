import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/errors/clinical_error_formatter.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/entities/species_entity.dart';
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
  late final Stream<List<SpeciesEntity>> _speciesStream = () {
    try {
      return widget.repository.watchSpecies().asBroadcastStream();
    } catch (_) {
      return const Stream<List<SpeciesEntity>>.empty();
    }
  }();

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
        context.l10n.reviewHighlightedFields,
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
          context.l10n.patientUpdatedSuccess,
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
          context.l10n.patientSavedSuccess,
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
          isEditing
              ? context.l10n.editPatientProfile
              : context.l10n.registerPatient,
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
            _buildSectionHeader(
              context.l10n.patientIdentity,
              Icons.pets_rounded,
            ),
            const SizedBox(height: 12),
            _buildCard([
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${context.l10n.patientNameOrTag} *',
                  hintText: context.l10n.patientNameHint,
                ),
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return context.l10n.pleaseEnterPatientName;
                  }
                  if (trimmed.length > 100) {
                    return context.l10n.patientNameTooLong;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Text(
                '${context.l10n.species} *',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<SpeciesEntity>>(
                stream: _speciesStream,
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  final speciesNames = list.isNotEmpty
                      ? list.map((s) => s.name).toList()
                      : _speciesOptions;

                  // Keep _selectedSpecies selectable even if not yet in list
                  final displaySpecies = List<String>.from(speciesNames);
                  if (_selectedSpecies.isNotEmpty &&
                      !displaySpecies.any((s) => s.toLowerCase() == _selectedSpecies.toLowerCase())) {
                    displaySpecies.add(_selectedSpecies);
                  }

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...displaySpecies.map((species) {
                        final isSelected =
                            _selectedSpecies.toLowerCase() == species.toLowerCase();
                        return ChoiceChip(
                          label: Text(context.formatSpecies(species)),
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
                      }),
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 16, color: AppColors.primaryEmerald),
                        label: Text(
                          context.l10n.addSpecies,
                          style: const TextStyle(
                            color: AppColors.primaryEmerald,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: AppColors.backgroundCream,
                        side: const BorderSide(
                          color: AppColors.primaryEmerald,
                        ),
                        onPressed: _showAddSpeciesDialog,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(
                  labelText: context.l10n.breed,
                  hintText: context.l10n.breedHint,
                ),
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.length > 100) {
                    return context.l10n.breedTooLong;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: InputDecoration(
                  labelText: context.l10n.genderAndReproductiveStatus,
                ),
                items: _genderOptions.map((opt) {
                  return DropdownMenuItem(
                    value: opt.$1,
                    child: Text(context.formatGender(opt.$1)),
                  );
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
                      decoration: InputDecoration(
                        labelText: context.l10n.ageYears,
                        hintText: context.l10n.ageHint,
                      ),
                      validator: (val) {
                        final trimmed = val?.trim() ?? '';
                        if (trimmed.isNotEmpty) {
                          final a = int.tryParse(trimmed);
                          if (a == null || a < 0 || a > 150) {
                            return context.l10n.enterValidAge;
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
                      decoration: InputDecoration(
                        labelText: context.l10n.weightKg,
                        hintText: context.l10n.weightHint,
                      ),
                      validator: (val) {
                        final trimmed = val?.trim() ?? '';
                        if (trimmed.isNotEmpty) {
                          final w = double.tryParse(trimmed);
                          if (w == null || w <= 0 || w > 10000) {
                            return context.l10n.enterValidWeight;
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
                title: Text(
                  context.l10n.ageIsEstimated,
                  style: const TextStyle(fontSize: 13),
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primaryEmerald,
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionHeader(
              context.l10n.identificationAndMedical,
              Icons.medical_information_outlined,
            ),
            const SizedBox(height: 12),
            _buildCard([
              TextFormField(
                controller: _microchipController,
                decoration: InputDecoration(
                  labelText: context.l10n.rfidMicrochip,
                  hintText: context.l10n.rfidMicrochipHint,
                ),
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.length > 32) {
                    return context.l10n.microchipTooLong;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _earTagController,
                decoration: InputDecoration(
                  labelText: context.l10n.visualEarTagId,
                  hintText: context.l10n.visualEarTagHint,
                ),
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.length > 64) {
                    return context.l10n.earTagTooLong;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _allergiesController,
                decoration: InputDecoration(
                  labelText: context.l10n.knownDrugAllergies,
                  hintText: context.l10n.knownDrugAllergiesHint,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: context.l10n.clinicalNotesInternal,
                  hintText: context.l10n.clinicalNotesHint,
                ),
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionHeader(
              context.l10n.ownerClientDetails,
              Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            _buildCard([
              TextFormField(
                controller: _ownerNameController,
                decoration: InputDecoration(
                  labelText: context.l10n.clientFullName,
                  hintText: context.l10n.clientNameHint,
                ),
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return context.l10n.pleaseEnterClientName;
                  }
                  if (trimmed.length > 191) {
                    return context.l10n.clientNameTooLong;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _ownerPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText:
                      '${context.l10n.primaryPhone} *',
                  hintText: context.l10n.primaryPhoneHint,
                ),
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return context.l10n.pleaseEnterPhone;
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
                decoration: InputDecoration(
                  labelText:
                      context.l10n.clientAddress,
                  hintText: context.l10n.clientAddressHint,
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
                      isEditing
                          ? context.l10n.saveChanges
                          : context.l10n.savePatientAndSync,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
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

  Future<void> _showAddSpeciesDialog() async {
    final createdName = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => const _AddSpeciesDialog(),
    );

    if (createdName != null && createdName.isNotEmpty) {
      try {
        final species = await widget.repository.createCustomSpecies(createdName);
        if (mounted) {
          setState(() {
            _selectedSpecies = species.name;
          });
          AppSnackbar.showSuccess(context, context.l10n.speciesAddedSuccessfully);
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.showError(
            context,
            ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to create species'),
          );
        }
      }
    }
  }
}

class _AddSpeciesDialog extends StatefulWidget {
  const _AddSpeciesDialog();

  @override
  State<_AddSpeciesDialog> createState() => _AddSpeciesDialogState();
}

class _AddSpeciesDialogState extends State<_AddSpeciesDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.pets_rounded, color: AppColors.primaryEmerald, size: 24),
          const SizedBox(width: 8),
          Text(
            context.l10n.newSpecies,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textCharcoal,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.enterSpeciesName,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: context.l10n.species,
                hintText: context.l10n.speciesNameHint,
              ),
              validator: (val) {
                final trimmed = val?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return context.l10n.enterSpeciesName;
                }
                if (trimmed.length > 50) {
                  return 'Species name is too long';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            context.l10n.cancel,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              Navigator.of(context).pop(_nameController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryEmerald,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}
