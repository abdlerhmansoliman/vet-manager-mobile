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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: clinicalCase.isCritical
                      ? AppColors.badgeCriticalRoseText.withValues(alpha: 0.3)
                      : AppColors.borderWarm,
                  width: clinicalCase.isCritical ? 1.3 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Case Code + Priority Badge
                  Row(
                    children: [
                      Text(
                        clinicalCase.caseNumber,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textCharcoal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (clinicalCase.syncStatus != 'synced')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.badgeObsAmber,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'OFFLINE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.badgeObsAmberText,
                            ),
                          ),
                        ),
                      const Spacer(),
                      TriagePriorityBadge.fromString(clinicalCase.priority),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Middle Row: Patient Avatar + Name + Species • Breed • Age
                  Row(
                    children: [
                      AnimalSpeciesAvatar(
                        species: clinicalCase.species,
                        radius: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clinicalCase.patientName,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textCharcoal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
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
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Chief Complaint Snippet
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCream,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderWarm),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.medical_information_outlined,
                          size: 14,
                          color: AppColors.secondaryCoral,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            clinicalCase.chiefComplaint,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textCharcoal,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bottom Row: Owner Name + Time + Status Chip
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textMuted),
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
                        _formatAdmissionTime(clinicalCase.admittedAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryEmeraldLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          clinicalCase.status.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryEmeraldDark,
                          ),
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
}
