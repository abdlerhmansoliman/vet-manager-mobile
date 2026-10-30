import 'package:equatable/equatable.dart';
import '../../domain/entities/case_entity.dart';

enum CaseDetailStatus { initial, loading, success, failure }

class CaseDetailState extends Equatable {
  final CaseDetailStatus status;
  final CaseDetailEntity? caseDetail;
  final String? errorMessage;
  final String? actionFeedback;

  const CaseDetailState({
    this.status = CaseDetailStatus.initial,
    this.caseDetail,
    this.errorMessage,
    this.actionFeedback,
  });

  CaseDetailState copyWith({
    CaseDetailStatus? status,
    CaseDetailEntity? caseDetail,
    String? errorMessage,
    String? actionFeedback,
  }) {
    return CaseDetailState(
      status: status ?? this.status,
      caseDetail: caseDetail ?? this.caseDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      actionFeedback: actionFeedback ?? this.actionFeedback,
    );
  }

  @override
  List<Object?> get props => [
        status,
        caseDetail,
        errorMessage,
        actionFeedback,
      ];
}
