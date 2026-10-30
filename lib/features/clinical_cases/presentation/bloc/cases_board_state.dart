import 'package:equatable/equatable.dart';
import '../../domain/entities/case_entity.dart';

enum CasesBoardStatus { initial, loading, success, failure }

class CasesBoardState extends Equatable {
  final CasesBoardStatus status;
  final List<CaseSummaryEntity> cases;
  final String activePriority; // 'all', 'routine', 'urgent', 'critical'
  final String searchQuery;
  final String? errorMessage;

  const CasesBoardState({
    this.status = CasesBoardStatus.initial,
    this.cases = const [],
    this.activePriority = 'all',
    this.searchQuery = '',
    this.errorMessage,
  });

  int get criticalCount => cases.where((c) => c.isCritical).length;
  int get urgentCount => cases.where((c) => c.isUrgent).length;
  int get routineCount => cases.where((c) => c.isRoutine).length;
  int get totalCount => cases.length;

  List<CaseSummaryEntity> get displayedCases {
    if (activePriority.toLowerCase() == 'all') {
      return cases;
    }
    if (activePriority.toLowerCase() == 'critical') {
      return cases.where((c) => c.isCritical).toList();
    }
    return cases
        .where((c) => c.priority.toLowerCase() == activePriority.toLowerCase())
        .toList();
  }

  CasesBoardState copyWith({
    CasesBoardStatus? status,
    List<CaseSummaryEntity>? cases,
    String? activePriority,
    String? searchQuery,
    String? errorMessage,
  }) {
    return CasesBoardState(
      status: status ?? this.status,
      cases: cases ?? this.cases,
      activePriority: activePriority ?? this.activePriority,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        cases,
        activePriority,
        searchQuery,
        errorMessage,
      ];
}
