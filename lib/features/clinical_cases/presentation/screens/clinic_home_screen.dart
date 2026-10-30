import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../sync/sync_manager.dart';
import '../../../clients_patients/domain/repositories/patient_repository.dart';
import '../../../clients_patients/presentation/screens/patient_list_screen.dart';
import '../../domain/repositories/case_repository.dart';
import 'cases_board_screen.dart';

/// Unified Clinic Workspace screen providing bottom navigation between
/// the Clinical Triage Board and the Patients & Clients Directory.
class ClinicHomeScreen extends StatefulWidget {
  final ICaseRepository? caseRepository;
  final IPatientRepository? patientRepository;
  final SyncManager? syncManager;
  final int initialIndex;

  const ClinicHomeScreen({
    super.key,
    this.caseRepository,
    this.patientRepository,
    this.syncManager,
    this.initialIndex = 0,
  });

  @override
  State<ClinicHomeScreen> createState() => _ClinicHomeScreenState();
}

class _ClinicHomeScreenState extends State<ClinicHomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Automatically trigger cloud delta sync on workspace ingress
    widget.syncManager?.syncNow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          CasesBoardScreen(
            repository: widget.caseRepository,
            onSync: () => widget.syncManager?.syncNow(),
          ),
          if (widget.patientRepository != null)
            PatientListScreen(
              repository: widget.patientRepository!,
              onSync: () => widget.syncManager?.syncNow(),
            )
          else
            const Scaffold(
              backgroundColor: AppColors.backgroundCream,
              body: Center(
                child: Text('Patient directory is loading...'),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border(
            top: BorderSide(color: AppColors.borderWarm, width: 1),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppColors.primaryEmerald.withValues(alpha: 0.15),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryEmerald,
                  fontWeight: FontWeight.w700,
                );
              }
              return AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              );
            }),
          ),
          child: NavigationBar(
            height: 64,
            backgroundColor: AppColors.surfaceWhite,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined, color: AppColors.textMuted),
                selectedIcon: Icon(Icons.assignment_rounded, color: AppColors.primaryEmerald),
                label: 'Triage Cases',
              ),
              NavigationDestination(
                icon: Icon(Icons.pets_outlined, color: AppColors.textMuted),
                selectedIcon: Icon(Icons.pets_rounded, color: AppColors.primaryEmerald),
                label: 'Patients',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
