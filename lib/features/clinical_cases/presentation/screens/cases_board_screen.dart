import '../../../../app/router/app_router.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/clinic_switcher_pill.dart';
import '../../../staff_profile/domain/entities/staff_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../domain/entities/case_entity.dart';
import '../../../media/domain/repositories/media_repository.dart';
import '../../domain/repositories/case_repository.dart';
import '../bloc/cases_board_bloc.dart';
import '../bloc/cases_board_event.dart';
import '../bloc/cases_board_state.dart';
import '../widgets/case_card.dart';

/// Clinical Triage Board screen presenting Routine, Urgent, and Critical encounters.
class CasesBoardScreen extends StatelessWidget {
  final ICaseRepository? repository;
  final IMediaRepository? mediaRepository;
  final List<CaseSummaryEntity>? initialCases;
  final VoidCallback? onSync;

  const CasesBoardScreen({
    super.key,
    this.repository,
    this.mediaRepository,
    this.initialCases,
    this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    if (repository == null) {
      return _CasesBoardView(
        initialCases: initialCases,
        mediaRepository: mediaRepository,
        onSync: onSync,
      );
    }

    return BlocProvider<CasesBoardBloc>(
      create: (context) => CasesBoardBloc(repository: repository!)
        ..add(const CasesBoardStarted()),
      child: _CasesBoardView(
        repository: repository,
        mediaRepository: mediaRepository,
        initialCases: initialCases,
        onSync: onSync,
      ),
    );
  }
}

class _CasesBoardView extends StatefulWidget {
  final ICaseRepository? repository;
  final IMediaRepository? mediaRepository;
  final List<CaseSummaryEntity>? initialCases;
  final VoidCallback? onSync;

  const _CasesBoardView({
    this.repository,
    this.mediaRepository,
    this.initialCases,
    this.onSync,
  });

  @override
  State<_CasesBoardView> createState() => _CasesBoardViewState();
}

class _CasesBoardViewState extends State<_CasesBoardView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CasesBoardBloc?>();
    if (bloc != null && bloc.state.status == CasesBoardStatus.initial) {
      bloc.add(const CasesBoardStarted());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<CasesBoardBloc?>()?.add(CasesSearchQueryChanged(query));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CasesBoardBloc, CasesBoardState>(
      builder: (context, state) {
        final cases = state.status == CasesBoardStatus.initial && widget.initialCases != null
            ? widget.initialCases!
            : state.displayedCases;

        final allCount = state.status == CasesBoardStatus.initial && widget.initialCases != null
            ? widget.initialCases!.length
            : state.totalCount;

        final criticalCount = state.status == CasesBoardStatus.initial && widget.initialCases != null
            ? widget.initialCases!.where((c) => c.isCritical).length
            : state.criticalCount;

        final urgentCount = state.status == CasesBoardStatus.initial && widget.initialCases != null
            ? widget.initialCases!.where((c) => c.isUrgent).length
            : state.urgentCount;

        final routineCount = state.status == CasesBoardStatus.initial && widget.initialCases != null
            ? widget.initialCases!.where((c) => c.isRoutine).length
            : state.routineCount;

        final authState = context.watch<AuthBloc?>()?.state;
        String doctorName = 'Dr. Jenkins';
        if (authState is AuthAuthenticated) {
          final rawName = authState.session.user.name;
          doctorName = rawName.startsWith('Dr.') ? rawName : 'Dr. $rawName';
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundCream,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceWhite,
            elevation: 0,
            leading: Navigator.canPop(context)
                ? const BackButton(color: AppColors.textCharcoal)
                : null,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: context.l10n.searchCasesHint,
                      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                      border: InputBorder.none,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.triageBoard,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textCharcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const ClinicSwitcherPill(),
                    ],
                  ),
            actions: [
              IconButton(
                key: const Key('doctor_profile_appbar_action'),
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: AppColors.textCharcoal,
                  size: 22,
                ),
                tooltip: context.l10n.practitionerProfile,
                onPressed: () {
                  final currentAuthState = context.read<AuthBloc?>()?.state;
                  if (currentAuthState is AuthAuthenticated) {
                    final staff = StaffEntity.fromAuthUser(currentAuthState.session.user);
                    context.push(AppRoutes.doctorProfile, extra: staff);
                  } else {
                    context.push(AppRoutes.doctorProfile);
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.sync_rounded,
                  color: AppColors.primaryEmerald,
                  size: 22,
                ),
                tooltip: context.l10n.syncNow,
                onPressed: () {
                  widget.onSync?.call();
                  AppSnackbar.showInfo(
                    context,
                    context.l10n.syncingData,
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.close_rounded : Icons.search_rounded,
                  color: AppColors.textCharcoal,
                ),
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _isSearching = false;
                      _searchController.clear();
                      _onSearchChanged('');
                    } else {
                      _isSearching = true;
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
                tooltip: context.l10n.logOut,
                onPressed: () {
                  context.read<AuthBloc?>()?.add(const AuthLogoutRequested());
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Column(
                children: [
                  // Triage Priority Tabs Row
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterTab(
                            label: context.l10n.all,
                            count: allCount,
                            filterKey: 'all',
                            isActive: state.activePriority == 'all',
                            activeColor: AppColors.primaryEmeraldDark,
                            activeBg: AppColors.primaryEmeraldLight,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterTab(
                            label: context.l10n.criticalPriority,
                            count: criticalCount,
                            filterKey: 'critical',
                            isActive: state.activePriority == 'critical',
                            activeColor: AppColors.badgeCriticalRoseText,
                            activeBg: AppColors.badgeCriticalRose,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterTab(
                            label: context.l10n.urgentPriority,
                            count: urgentCount,
                            filterKey: 'urgent',
                            isActive: state.activePriority == 'urgent',
                            activeColor: AppColors.badgeObsAmberText,
                            activeBg: AppColors.badgeObsAmber,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterTab(
                            label: context.l10n.routinePriority,
                            count: routineCount,
                            filterKey: 'routine',
                            isActive: state.activePriority == 'routine',
                            activeColor: AppColors.badgeStableMintText,
                            activeBg: AppColors.badgeStableMint,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(color: AppColors.borderWarm, height: 1),
                ],
              ),
            ),
          ),
          body: RefreshIndicator(
            color: AppColors.primaryEmerald,
            onRefresh: () async {
              widget.onSync?.call();
              await Future<void>.delayed(const Duration(milliseconds: 600));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildClinicianWelcomeHeader(doctorName),
                  const SizedBox(height: 12),
                  _buildQuickSearchBar(),
                  const SizedBox(height: 14),
                  _buildQuickStatsRibbon(allCount, criticalCount, urgentCount, routineCount),
                  const SizedBox(height: 14),
                  _buildQuickActionBar(context),
                  const SizedBox(height: 18),
                  _buildQueueSectionHeader(allCount),
                  const SizedBox(height: 10),
                  if (cases.isEmpty)
                    _buildEmptyState(state.activePriority)
                  else
                    ...cases.asMap().entries.map((entry) => CaseCard(
                          clinicalCase: entry.value,
                          repository: widget.repository,
                          mediaRepository: widget.mediaRepository,
                          index: entry.key,
                        )),
                  const SizedBox(height: 20),
                  _buildDiagnosticsAlertsSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'cases_board_triage_case_fab',
            onPressed: () => _showOpenCaseModal(context),
            backgroundColor: AppColors.primaryEmerald,
            elevation: 3,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              'Triage Case',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClinicianWelcomeHeader(String doctorName) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMM d').format(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primaryEmerald),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      dateStr,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textCharcoal,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    const TextSpan(text: 'Good morning, '),
                    TextSpan(
                      text: doctorName,
                      style: const TextStyle(color: AppColors.primaryEmerald, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderWarm),
                boxShadow: AppColors.warmAmbientShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryEmerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Oakwood Animal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textCharcoal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderWarm),
                boxShadow: AppColors.warmAmbientShadow,
              ),
              child: const Icon(Icons.person_rounded, size: 22, color: AppColors.primaryEmerald),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: AppColors.warmAmbientShadow,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textCharcoal),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textLight),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune_rounded, size: 18, color: AppColors.textLight),
            onPressed: () {},
          ),
          hintText: 'Search patient, breed, microchip, or owner...',
          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildQuickStatsRibbon(int allCount, int criticalCount, int urgentCount, int routineCount) {
    return SizedBox(
      height: 104,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatCard(
            title: 'Schedule',
            count: allCount,
            subtitle: 'Appointments',
            icon: Icons.event_note_outlined,
            isHighlighted: false,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            title: 'In Clinic',
            count: routineCount + urgentCount,
            subtitle: 'Waiting / Exam',
            icon: Icons.pets_outlined,
            isHighlighted: true,
            highlightColor: AppColors.primaryEmerald,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            title: 'SOAP / Labs',
            count: allCount > 0 ? (allCount / 2).ceil() : 0,
            subtitle: 'Need Review',
            icon: Icons.science_outlined,
            isHighlighted: false,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            title: 'Triage Alert',
            count: criticalCount,
            subtitle: 'Urgent Queue',
            icon: Icons.emergency_outlined,
            isHighlighted: criticalCount > 0,
            highlightColor: AppColors.secondaryCoral,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required String subtitle,
    required IconData icon,
    bool isHighlighted = false,
    Color highlightColor = AppColors.primaryEmerald,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? highlightColor.withValues(alpha: 0.4) : AppColors.borderWarm,
          width: isHighlighted ? 1.5 : 1.0,
        ),
        boxShadow: AppColors.warmAmbientShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isHighlighted ? highlightColor : AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: isHighlighted ? highlightColor : AppColors.textLight),
            ],
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isHighlighted ? highlightColor : AppColors.textCharcoal,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isHighlighted ? highlightColor.withValues(alpha: 0.8) : AppColors.textLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _showOpenCaseModal(context),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text(
                '+ New Check-in',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                AppSnackbar.showInfo(context, 'Quick Vitals available on active encounter');
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surfaceWhite,
                side: const BorderSide(color: AppColors.borderWarm),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.zero,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monitor_heart_outlined, size: 18, color: AppColors.primaryEmerald),
                  SizedBox(height: 2),
                  Text('Vitals', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textCharcoal)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                AppSnackbar.showInfo(context, 'eMAR Barcode scanner ready');
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surfaceWhite,
                side: const BorderSide(color: AppColors.borderWarm),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.zero,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner_rounded, size: 18, color: AppColors.primaryEmerald),
                  SizedBox(height: 2),
                  Text('eMAR Scan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textCharcoal)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQueueSectionHeader(int activeCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              "Today's Patient Queue",
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textCharcoal,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$activeCount active',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textCharcoal,
                ),
              ),
            ),
          ],
        ),
        Text(
          'View All',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primaryEmerald,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticsAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lab Results & Critical Alerts',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textCharcoal,
              ),
            ),
            Text(
              'Diagnostics',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryEmerald,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Normal Lab Result Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderWarm),
            boxShadow: AppColors.warmAmbientShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.badgeStableMint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.badgeStableMintText, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CBC & Chemistry Panel - Max (Canine)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textCharcoal),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        children: [
                          TextSpan(text: 'Marked: '),
                          TextSpan(text: 'Normal', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.badgeStableMintText)),
                          TextSpan(text: ' • Reviewed 15m ago'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.visibility_outlined, size: 20, color: AppColors.textLight),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Urgent Lab Alert Card
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderWarm),
            boxShadow: AppColors.warmAmbientShadow,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: AppColors.secondaryCoral),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryCoralLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.crisis_alert_rounded, color: AppColors.secondaryCoral, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Biochemistry flag: Milo (Feline)',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.secondaryCoral),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Elevated BUN/Creatinine • Needs clinician call',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryCoralLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Review', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondaryCoral)),
                              SizedBox(width: 2),
                              Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.secondaryCoral),
                            ],
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
      ],
    );
  }

  Widget _buildFilterTab({
    required String label,
    required int count,
    required String filterKey,
    required bool isActive,
    required Color activeColor,
    required Color activeBg,
  }) {
    return AnimatedPressable(
      onTap: () {
        context.read<CasesBoardBloc?>()?.add(CasesPriorityFilterChanged(filterKey));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? activeBg : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor.withValues(alpha: 0.4) : AppColors.borderWarm,
            width: isActive ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? activeColor : AppColors.textCharcoal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isActive ? activeColor.withValues(alpha: 0.15) : AppColors.backgroundCream,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isActive ? activeColor : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String priority) {
    final priorityLabel = priority.toLowerCase() == 'all' ? 'active' : priority;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 48,
                color: AppColors.primaryEmerald,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No $priorityLabel cases',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textCharcoal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'All patients in this category have been attended to or discharged.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOpenCaseModal(BuildContext context) {
    final complaintController = TextEditingController();
    final patientIdController = TextEditingController();
    String selectedPriority = 'routine';

    showDialog<void>(
      context: context,
      builder: (dlgContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Triage New Encounter',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textCharcoal,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: patientIdController,
                  decoration: const InputDecoration(
                    labelText: 'Patient ID',
                    hintText: 'Enter patient UUID',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: complaintController,
                  decoration: const InputDecoration(
                    labelText: 'Chief Complaint',
                    hintText: 'e.g. Acute abdominal pain',
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Triage Priority',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textCharcoal,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedPriority,
                  items: const [
                    DropdownMenuItem(value: 'routine', child: Text('Routine')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                    DropdownMenuItem(value: 'critical', child: Text('Critical')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedPriority = v ?? 'routine'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dlgContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final patientId = patientIdController.text.trim();
                final complaint = complaintController.text.trim();
                if (patientId.isEmpty || complaint.isEmpty) return;

                if (widget.repository != null) {
                  final now = DateTime.now();
                  final caseNumber = 'CAS-${now.year}-${now.millisecondsSinceEpoch % 10000}';
                  await widget.repository!.openCase(
                    patientId: patientId,
                    caseNumber: caseNumber,
                    chiefComplaint: complaint,
                    priority: selectedPriority,
                  );
                }
                if (context.mounted) {
                  Navigator.of(dlgContext).pop();
                }
              },
              child: const Text('Open Case'),
            ),
          ],
        ),
      ),
    );
  }
}
