import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../domain/entities/visit_entity.dart';

/// Interactive clinical card representing a specific Visit / Encounter within a Case,
/// styled with Stitch Warm Clinical Bento aesthetics.
class VisitCard extends StatelessWidget {
  final VisitEntity visit;
  final VoidCallback onTap;
  final int animationIndex;

  const VisitCard({
    super.key,
    required this.visit,
    required this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final hasVitals = visit.soapNote != null &&
        (visit.soapNote!.temperatureCelsius != null ||
            visit.soapNote!.heartRateBpm != null ||
            visit.soapNote!.respiratoryRateBpm != null);
    final soapSnippet = visit.soapNote != null
        ? ((visit.soapNote!.assessment != null && visit.soapNote!.assessment!.trim().isNotEmpty)
            ? visit.soapNote!.assessment!.trim()
            : (visit.soapNote!.subjective != null && visit.soapNote!.subjective!.trim().isNotEmpty)
                ? visit.soapNote!.subjective!.trim()
                : null)
        : null;

    return AnimatedPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: visit.isLocked
                ? AppColors.primaryEmerald.withValues(alpha: 0.3)
                : AppColors.borderWarm,
            width: visit.isLocked ? 1.4 : 1.0,
          ),
          boxShadow: AppColors.warmAmbientShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Status badge, encounter ID, and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusBadge(),
                    const SizedBox(width: 8),
                    Text(
                      '#${visit.id.length > 8 ? visit.id.substring(0, 8) : visit.id}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatDate(visit.visitDate),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: visit.isOpen ? AppColors.primaryEmerald : AppColors.textMuted,
                    fontWeight: visit.isOpen ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Visit Title
            Text(
              visit.title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textCharcoal,
                fontSize: 16,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),

            // Attending Clinician & Encounter Type
            Row(
              children: [
                const Icon(
                  Icons.medical_services_outlined,
                  size: 15,
                  color: AppColors.primaryEmerald,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${visit.veterinarianName} • ${_formatVisitType(visit.visitType)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Recorded Vitals Bento Rail
            if (hasVitals) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderWarm.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (visit.soapNote!.temperatureCelsius != null)
                      _buildVitalItem(
                        label: 'TEMP',
                        value: '${visit.soapNote!.temperatureCelsius!.toStringAsFixed(1)}°C',
                        status: 'Normal',
                      ),
                    if (visit.soapNote!.heartRateBpm != null)
                      _buildVitalItem(
                        label: 'HEART RATE',
                        value: '${visit.soapNote!.heartRateBpm} bpm',
                        status: 'Steady',
                      ),
                    if (visit.soapNote!.respiratoryRateBpm != null)
                      _buildVitalItem(
                        label: 'RESP RATE',
                        value: '${visit.soapNote!.respiratoryRateBpm} rpm',
                        status: 'Recorded',
                      ),
                  ],
                ),
              ),
            ],

            // SOAP Note Assessment / Subjective Preview
            if (soapSnippet != null && soapSnippet.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCream,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderWarm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.description_outlined,
                              size: 13,
                              color: AppColors.primaryEmerald,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'SOAP CLINICAL PREVIEW',
                              style: AppTextStyles.badgeLabel.copyWith(
                                color: AppColors.primaryEmeraldDark,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          visit.isLocked ? 'Locked' : 'Draft',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"$soapSnippet"',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textCharcoal,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],

            // Administered Meds Tag Strip
            if (visit.doseAdministrations.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: visit.doseAdministrations.take(3).map((dose) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderWarm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.medication_outlined,
                          size: 12,
                          color: AppColors.primaryEmerald,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${dose.medicineName} ${dose.doseQuantity}${dose.unit}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textCharcoal,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            // Bottom CTA row
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderWarm.withValues(alpha: 0.6))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    visit.isLocked ? 'Documented & Signed' : 'Encounter in Progress',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        visit.isLocked ? 'View Full SOAP Record' : 'Continue Charting',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primaryEmerald,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primaryEmerald,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms, delay: (animationIndex * 50).ms)
        .slideY(begin: 0.06, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildVitalItem({
    required String label,
    required String value,
    required String status,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.badgeLabel.copyWith(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textCharcoal,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          status,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryEmeraldDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    if (visit.isLocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: AppColors.badgeStableMint,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded, size: 10, color: Color(0xFF065F46)),
            const SizedBox(width: 3),
            Text(
              'SIGNED & LOCKED',
              style: AppTextStyles.badgeLabel.copyWith(
                color: const Color(0xFF065F46),
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: AppColors.badgeObsAmber,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.badgeObsAmberText,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'ACTIVE ENCOUNTER',
            style: AppTextStyles.badgeLabel.copyWith(
              color: AppColors.badgeObsAmberText,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatVisitType(String type) {
    switch (type.toLowerCase()) {
      case 'follow_up':
        return 'Follow-up';
      case 'emergency':
        return 'Emergency';
      case 'surgery':
        return 'Surgery';
      case 'consultation':
      default:
        return 'Consultation';
    }
  }
}
