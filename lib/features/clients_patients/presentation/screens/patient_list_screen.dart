import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../domain/repositories/patient_repository.dart';
import '../bloc/patient_list_bloc.dart';
import '../bloc/patient_list_event.dart';
import '../bloc/patient_list_state.dart';
import '../widgets/patient_card.dart';
import 'create_patient_screen.dart';

/// Main Patient and Client Directory Screen.
class PatientListScreen extends StatefulWidget {
  final IPatientRepository repository;

  const PatientListScreen({
    super.key,
    required this.repository,
  });

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchController = TextEditingController();

  static const _speciesFilters = [
    'All',
    'Canine',
    'Feline',
    'Equine',
    'Bovine',
    'Avian',
    'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientListBloc(repository: widget.repository)
        ..add(const PatientListSubscriptionRequested()),
      child: Scaffold(
        backgroundColor: AppColors.backgroundCream,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              _buildSearchAndFilters(context),
              Expanded(
                child: _buildPatientList(),
              ),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (fabContext) => FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(fabContext).push(
                MaterialPageRoute<void>(
                  builder: (context) => CreatePatientScreen(repository: widget.repository),
                ),
              );
            },
            backgroundColor: AppColors.primaryEmerald,
            foregroundColor: Colors.white,
            elevation: 3,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'New Patient',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patients & Clients',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textCharcoal,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Offline-first animal registry',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderWarm),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: AppColors.primaryEmerald,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return BlocBuilder<PatientListBloc, PatientListState>(
      buildWhen: (prev, curr) =>
          prev.searchQuery != curr.searchQuery ||
          prev.selectedSpecies != curr.selectedSpecies,
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  context.read<PatientListBloc>().add(PatientSearchQueryChanged(query));
                },
                decoration: InputDecoration(
                  hintText: 'Search by patient, chip, ear tag, owner...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                  suffixIcon: state.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            context.read<PatientListBloc>().add(const PatientSearchQueryChanged(''));
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.borderWarm),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.borderWarm),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _speciesFilters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final species = _speciesFilters[index];
                  final isSelected = state.selectedSpecies.toLowerCase() == species.toLowerCase();

                  return ChoiceChip(
                    label: Text(species),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        context
                            .read<PatientListBloc>()
                            .add(PatientSpeciesFilterChanged(species));
                      }
                    },
                    selectedColor: AppColors.primaryEmerald,
                    backgroundColor: AppColors.surfaceWhite,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textCharcoal,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryEmerald : AppColors.borderWarm,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildPatientList() {
    return BlocBuilder<PatientListBloc, PatientListState>(
      builder: (context, state) {
        if (state.status == PatientListStatus.loading && state.patients.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryEmerald),
          );
        }

        if (state.status == PatientListStatus.failure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AppColors.secondaryCoral),
                  const SizedBox(height: 12),
                  Text('Failed to load patients', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    state.errorMessage ?? 'Unknown local SQLite error',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<PatientListBloc>()
                          .add(const PatientListSubscriptionRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryEmerald,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.patients.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderWarm),
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      size: 36,
                      color: AppColors.primaryEmerald,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.searchQuery.isNotEmpty
                        ? 'No patients matching "${state.searchQuery}"'
                        : 'No patients in this clinic yet',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textCharcoal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    state.searchQuery.isNotEmpty
                        ? 'Try searching with a different name, ear tag, or owner phone number.'
                        : 'Tap "+ New Patient" below to register your first patient and client profile.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
          itemCount: state.patients.length,
          itemBuilder: (context, index) {
            return PatientCard(
              patient: state.patients[index],
              index: index,
            );
          },
        );
      },
    );
  }
}
