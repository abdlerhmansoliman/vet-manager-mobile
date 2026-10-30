import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/animated_pressable.dart';
import '../../domain/entities/case_entity.dart';
import '../../domain/repositories/case_repository.dart';
import '../bloc/cases_board_bloc.dart';
import '../bloc/cases_board_event.dart';
import '../bloc/cases_board_state.dart';
import '../widgets/case_card.dart';

/// Clinical Triage Board screen presenting Routine, Urgent, and Critical encounters.
class CasesBoardScreen extends StatelessWidget {
  final ICaseRepository? repository;
  final List<CaseSummaryEntity>? initialCases;
  final VoidCallback? onSync;

  const CasesBoardScreen({
    super.key,
    this.repository,
    this.initialCases,
    this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    if (repository == null) {
      return _CasesBoardView(initialCases: initialCases, onSync: onSync);
    }

    return BlocProvider<CasesBoardBloc>(
      create: (context) => CasesBoardBloc(repository: repository!)
        ..add(const CasesBoardStarted()),
      child: _CasesBoardView(
        repository: repository,
        initialCases: initialCases,
        onSync: onSync,
      ),
    );
  }
}

class _CasesBoardView extends StatefulWidget {
  final ICaseRepository? repository;
  final List<CaseSummaryEntity>? initialCases;
  final VoidCallback? onSync;

  const _CasesBoardView({
    this.repository,
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
                      hintText: 'Search cases, complaints, patients...',
                      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                      border: InputBorder.none,
                    ),
                  )
                : Text(
                    'Triage Board',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textCharcoal,
                    ),
                  ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.sync_rounded,
                  color: AppColors.primaryEmerald,
                  size: 22,
                ),
                tooltip: 'Sync with Cloud',
                onPressed: () {
                  widget.onSync?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Syncing cases and patient records...'),
                      duration: Duration(seconds: 1),
                    ),
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
                tooltip: 'Sign Out',
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
                            label: 'All',
                            count: allCount,
                            filterKey: 'all',
                            isActive: state.activePriority == 'all',
                            activeColor: AppColors.primaryEmeraldDark,
                            activeBg: AppColors.primaryEmeraldLight,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterTab(
                            label: 'Critical',
                            count: criticalCount,
                            filterKey: 'critical',
                            isActive: state.activePriority == 'critical',
                            activeColor: AppColors.badgeCriticalRoseText,
                            activeBg: AppColors.badgeCriticalRose,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterTab(
                            label: 'Urgent',
                            count: urgentCount,
                            filterKey: 'urgent',
                            isActive: state.activePriority == 'urgent',
                            activeColor: AppColors.badgeObsAmberText,
                            activeBg: AppColors.badgeObsAmber,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterTab(
                            label: 'Routine',
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
            child: state.status == CasesBoardStatus.loading && cases.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryEmerald),
                  )
                : cases.isEmpty
                    ? CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildEmptyState(state.activePriority),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: cases.length,
                        itemBuilder: (context, index) {
                          return CaseCard(
                            clinicalCase: cases[index],
                            repository: widget.repository,
                            index: index,
                          );
                        },
                      ),
          ),
          floatingActionButton: FloatingActionButton.extended(
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
