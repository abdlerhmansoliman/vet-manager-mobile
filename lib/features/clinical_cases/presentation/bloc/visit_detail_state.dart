import 'package:equatable/equatable.dart';
import '../../domain/entities/visit_entity.dart';

enum VisitDetailStatus { initial, loading, success, failure }

class VisitDetailState extends Equatable {
  final VisitDetailStatus status;
  final VisitEntity? visit;
  final String? actionFeedback;
  final String? errorMessage;

  const VisitDetailState({
    this.status = VisitDetailStatus.initial,
    this.visit,
    this.actionFeedback,
    this.errorMessage,
  });

  bool get isLoading => status == VisitDetailStatus.loading;
  bool get isSuccess => status == VisitDetailStatus.success;
  bool get isFailure => status == VisitDetailStatus.failure;

  VisitDetailState copyWith({
    VisitDetailStatus? status,
    VisitEntity? visit,
    String? actionFeedback,
    String? errorMessage,
    bool clearFeedback = false,
    bool clearError = false,
  }) {
    return VisitDetailState(
      status: status ?? this.status,
      visit: visit ?? this.visit,
      actionFeedback: clearFeedback ? null : (actionFeedback ?? this.actionFeedback),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        visit,
        actionFeedback,
        errorMessage,
      ];
}
