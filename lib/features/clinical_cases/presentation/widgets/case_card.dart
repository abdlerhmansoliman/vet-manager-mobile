import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animal_species_avatar.dart';
import '../../../../core/widgets/triage_priority_badge.dart';
import '../../../media/domain/repositories/media_repository.dart';
import '../../domain/entities/case_entity.dart';
import '../../domain/repositories/case_repository.dart';
import '../screens/case_detail_screen.dart';

/// Clinical case encounter card featuring seamless [OpenContainer] Material motion transform.
class CaseCard extends StatelessWidget {
  final CaseSummaryEntity clinicalCase;
  final ICaseRepository? repository;
  final IMediaRepository? mediaRepository;
  final int index;

  const CaseCard({
    super.key,
    required this.clinicalCase,
    this.repository,
    this.mediaRepository,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final staggerMs = (index * 40).clamp(0, 400);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OpenContainer(
        closedElevation: 0,
        openElevation: 0,
        closedColor: Colors.transparent,
        openColor: AppColors.backgroundCream,
        transitionDuration: const Duration(milliseconds: 350),
        transitionType: ContainerTransitionType.fadeThrough,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        closedBuilder: (context, openContainer) {
          return InkWell(
            onTap: openContainer,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: clinicalCase.isCritical
                      ? AppColors.secondaryCoral.withValues(alpha: 0.6)
                      : AppColors.borderWarm,
                  width: clinicalCase.isCritical ? 1.5 : 1.0,
                ),
                boxShadow: AppColors.warmAmbientShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Patient Avatar + Name & Triage Tag + Time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimalSpeciesAvatar(
                        species: clinicalCase.species,
                        radius: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    clinicalCase.patientName,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppColors.textCharcoal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TriagePriorityBadge.fromString(clinicalCase.priority),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${clinicalCase.species}${clinicalCase.breed != null ? " • ${clinicalCase.breed}" : ""}${clinicalCase.ageFormatted != null ? " • ${clinicalCase.ageFormatted}" : ""}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatClockTime(clinicalCase.admittedAt),
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: clinicalCase.isCritical
                                  ? AppColors.secondaryCoral
                                  : AppColors.textCharcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatAdmissionTime(clinicalCase.admittedAt),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textLight,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Reason / Chief Complaint Bar with Open Action
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: clinicalCase.isCritical
                          ? AppColors.secondaryCoralLight.withValues(alpha: 0.5)
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: clinicalCase.isCritical
                            ? AppColors.secondaryCoral.withValues(alpha: 0.3)
                            : AppColors.borderWarm,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          clinicalCase.isCritical
                              ? Icons.warning_amber_rounded
                              : Icons.medical_information_outlined,
                          size: 16,
                          color: clinicalCase.isCritical
                              ? AppColors.secondaryCoral
                              : AppColors.primaryEmerald,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                              children: [
                                const TextSpan(text: 'Reason: '),
                                TextSpan(
                                  text: clinicalCase.chiefComplaint,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: clinicalCase.isCritical
                                        ? AppColors.secondaryCoral
                                        : AppColors.textCharcoal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: clinicalCase.isCritical
                                ? AppColors.secondaryCoral
                                : AppColors.primaryEmerald,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                clinicalCase.isCritical ? 'Triage' : 'Open Visit',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bottom Sub-strip: Owner & Case Number
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          clinicalCase.clientName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        clinicalCase.caseNumber,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        openBuilder: (context, closeContainer) {
          IMediaRepository? effectiveMediaRepo = mediaRepository;
          if (effectiveMediaRepo == null) {
            try {
              effectiveMediaRepo = RepositoryProvider.of<IMediaRepository>(context);
            } catch (_) {}
          }
          ICaseRepository? effectiveCaseRepo = repository;
          if (effectiveCaseRepo == null) {
            try {
              effectiveCaseRepo = RepositoryProvider.of<ICaseRepository>(context);
            } catch (_) {}
          }
          return CaseDetailScreen(
            caseId: clinicalCase.id,
            repository: effectiveCaseRepo,
            mediaRepository: effectiveMediaRepo,
          );
        },
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms, delay: staggerMs.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad);
  }

  String _formatAdmissionTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${dt.day}/${dt.month}';
    }
  }

  String _formatClockTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
