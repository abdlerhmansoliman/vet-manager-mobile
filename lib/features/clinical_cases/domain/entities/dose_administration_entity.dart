import 'package:equatable/equatable.dart';

/// Domain entity representing a medication dose administered during a clinical visit.
class DoseAdministrationEntity extends Equatable {
  final String id;
  final String tenantId;
  final String visitId;
  final String caseId;
  final String patientId;
  final String medicineName;
  final String doseQuantity;
  final String unit;
  final String route;
  final String? clinicalNotes;
  final String veterinarianId;
  final String veterinarianName;
  final DateTime administeredAt;
  final DateTime createdAt;
  final String syncStatus;

  const DoseAdministrationEntity({
    required this.id,
    this.tenantId = 'default',
    required this.visitId,
    required this.caseId,
    required this.patientId,
    required this.medicineName,
    required this.doseQuantity,
    required this.unit,
    required this.route,
    this.clinicalNotes,
    required this.veterinarianId,
    required this.veterinarianName,
    required this.administeredAt,
    required this.createdAt,
    this.syncStatus = 'synced',
  });

  String get summaryLabel => '$doseQuantity $unit $medicineName ($route)';

  @override
  List<Object?> get props => [
        id,
        tenantId,
        visitId,
        caseId,
        patientId,
        medicineName,
        doseQuantity,
        unit,
        route,
        clinicalNotes,
        veterinarianId,
        veterinarianName,
        administeredAt,
        createdAt,
        syncStatus,
      ];
}
