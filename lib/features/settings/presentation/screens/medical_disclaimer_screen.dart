import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';

/// Clinical and Veterinary Regulatory Disclaimer Screen.
///
/// Complies with Apple App Store Review Guideline 1.4.1 (Medical Apps)
/// and Google Play Store Health/Medical Content Policies.
class MedicalDisclaimerScreen extends StatelessWidget {
  const MedicalDisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: const Text('Medical & Legal Disclaimer'),
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textCharcoal,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          key: const Key('medical_disclaimer_back_button'),
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Notice Badge
              _buildHeroHeader(),
              const SizedBox(height: 20),

              // Disclaimer Sections
              _buildDisclaimerCard(
                icon: Icons.badge_rounded,
                title: 'Professional Veterinary Use Only',
                content:
                    'VetManager Mobile is designed strictly for licensed veterinarians, credentialed veterinary technicians, and authorized clinical staff. It is an enterprise practice management and medical charting platform and is NOT intended for animal owner self-diagnosis or non-professional clinical administration.',
              ),
              const SizedBox(height: 16),

              _buildDisclaimerCard(
                icon: Icons.psychology_rounded,
                title: 'Auxiliary Decision Support & Independent Judgment',
                content:
                    'All calculators, triage priority indicators, radiograph viewer filters, and clinical templates provided within this application are auxiliary decision-support tools. They DO NOT replace, supersede, or override independent professional veterinary clinical judgment, comprehensive physical examination, or diagnostic laboratory testing.',
              ),
              const SizedBox(height: 16),

              _buildDisclaimerCard(
                icon: Icons.medication_liquid_rounded,
                title: 'Dosage Calculation & Pharmacological Responsibility',
                content:
                    'Before administering any medication, anesthetic agent, fluid therapy, or controlled substance, the attending licensed veterinarian is solely responsible for verifying the patient weight, drug concentration, dosage rate, and potential contraindications. Never rely solely on software calculations for patient therapy.',
              ),
              const SizedBox(height: 16),

              _buildDisclaimerCard(
                icon: Icons.emergency_rounded,
                title: 'Acute & Life-Threatening Emergencies',
                content:
                    'In life-threatening situations, patient stabilization, immediate physical resuscitation, airway maintenance, and critical care protocols take precedence over digital documentation. Complete electronic charting only once the patient is hemodynamically stable.',
              ),
              const SizedBox(height: 16),

              _buildDisclaimerCard(
                icon: Icons.gavel_rounded,
                title: 'Statutory Record Retention & Compliance',
                content:
                    'Clinical progress notes, medical addenda, surgical consents, and pharmacy movement ledgers recorded in VetManager are immutable and append-only to satisfy regional veterinary statutory retention mandates and regulatory board compliance standards.',
              ),
              const SizedBox(height: 28),

              // Bottom Confirmation Button
              ElevatedButton(
                key: const Key('medical_disclaimer_acknowledge_button'),
                onPressed: () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEmerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'I Acknowledge & Understand',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.badgeStableMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: AppColors.primaryEmerald,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clinical Decision Support',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Regulatory & Clinical Safety Notice',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryEmerald,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
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
            children: [
              Icon(icon, size: 20, color: AppColors.primaryEmerald),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textCharcoal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textCharcoal.withValues(alpha: 0.85),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
