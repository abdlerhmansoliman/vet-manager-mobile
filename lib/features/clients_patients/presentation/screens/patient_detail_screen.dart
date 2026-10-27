import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animal_species_avatar.dart';
import '../../domain/entities/patient_entity.dart';

/// Comprehensive Patient Clinical Profile Screen.
///
/// Designed with the Cheerful Warm Clinical Aesthetic:
/// - Prominent species avatar header with health status pill
/// - High-risk allergy alert badges and behavioral cautions
/// - Owner contact card with quick-dial support
/// - Quick clinical encounter action triggers
class PatientDetailScreen extends StatelessWidget {
  final PatientEntity patient;

  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textCharcoal),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          patient.nameOrTag,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textCharcoal,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: patient.status.toLowerCase() == 'active'
                  ? AppColors.badgeStableMint
                  : AppColors.badgeObsAmber,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: patient.status.toLowerCase() == 'active'
                    ? const Color(0xFFA7F3D0)
                    : const Color(0xFFFDE68A),
              ),
            ),
            child: Text(
              patient.status.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: patient.status.toLowerCase() == 'active'
                    ? AppColors.badgeStableMintText
                    : AppColors.badgeObsAmberText,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHero(),
            const SizedBox(height: 16),
            if (patient.allergies.isNotEmpty) ...[
              _buildAllergiesAlert(),
              const SizedBox(height: 16),
            ],
            _buildDemographicsCard(),
            const SizedBox(height: 16),
            _buildOwnerCard(),
            const SizedBox(height: 16),
            _buildMedicalHistoryCard(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildProfileHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimalSpeciesAvatar(
            species: patient.species,
            radius: 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.nameOrTag,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmeraldLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        patient.species,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryEmeraldDark,
                        ),
                      ),
                    ),
                    if (patient.breed != null && patient.breed!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          patient.breed!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${patient.formattedAge} • ${patient.formattedGender}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textCharcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildAllergiesAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.badgeCriticalRose,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.badgeCriticalRoseText, size: 20),
              SizedBox(width: 8),
              Text(
                'HIGH-RISK ALLERGY ALERT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors.badgeCriticalRoseText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: patient.allergies.map((allergy) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDA4AF)),
                ),
                child: Text(
                  allergy,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.badgeCriticalRoseText,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildDemographicsCard() {
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
            'Patient Demographics',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            'Body Weight',
            patient.currentWeightKg != null
                ? '${patient.currentWeightKg!.toStringAsFixed(1)} kg'
                : 'Not recorded',
            icon: Icons.scale_rounded,
          ),
          const Divider(height: 18, color: AppColors.borderWarm),
          _buildInfoRow(
            'RFID Microchip',
            patient.microchipNumber ?? 'No chip implanted',
            icon: Icons.qr_code_2_rounded,
          ),
          if (patient.earTagId != null && patient.earTagId!.isNotEmpty) ...[
            const Divider(height: 18, color: AppColors.borderWarm),
            _buildInfoRow(
              'Ear Tag ID',
              patient.earTagId!,
              icon: Icons.tag_rounded,
            ),
          ],
          if (patient.coatColorMarkings != null && patient.coatColorMarkings!.isNotEmpty) ...[
            const Divider(height: 18, color: AppColors.borderWarm),
            _buildInfoRow(
              'Coat / Markings',
              patient.coatColorMarkings!,
              icon: Icons.palette_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOwnerCard() {
    final client = patient.client;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Registered Owner',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textCharcoal,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCream,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderWarm),
                ),
                child: Text(
                  client.clientType.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            'Full Name',
            client.name,
            icon: Icons.person_outline_rounded,
          ),
          const Divider(height: 18, color: AppColors.borderWarm),
          _buildInfoRow(
            'Primary Phone',
            client.phonePrimary,
            icon: Icons.phone_outlined,
          ),
          if (client.phoneSecondary != null && client.phoneSecondary!.isNotEmpty) ...[
            const Divider(height: 18, color: AppColors.borderWarm),
            _buildInfoRow(
              'Secondary Phone',
              client.phoneSecondary!,
              icon: Icons.phone_android_rounded,
            ),
          ],
          if (client.physicalAddress != null && client.physicalAddress!.isNotEmpty) ...[
            const Divider(height: 18, color: AppColors.borderWarm),
            _buildInfoRow(
              'Address',
              client.physicalAddress!,
              icon: Icons.location_on_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryCard() {
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
            'Clinical Background & Cautions',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textCharcoal,
            ),
          ),
          const SizedBox(height: 12),
          if (patient.notes != null && patient.notes!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.badgeObsAmber,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.badgeObsAmberText, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      patient.notes!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.badgeObsAmberText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            patient.history != null && patient.history!.isNotEmpty
                ? patient.history!
                : 'No prior clinical history recorded.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textCharcoal,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryEmerald),
        const SizedBox(width: 10),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textCharcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: const Border(top: BorderSide(color: AppColors.borderWarm)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Starting encounter for ${patient.nameOrTag}...'),
                    backgroundColor: AppColors.primaryEmerald,
                  ),
                );
              },
              icon: const Icon(Icons.medical_services_outlined, size: 20),
              label: const Text('Start Case'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
