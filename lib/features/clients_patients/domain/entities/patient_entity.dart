import 'package:equatable/equatable.dart';

/// Lightweight Client/Owner entity attached to a Patient.
class ClientSummaryEntity extends Equatable {
  final String id;
  final String tenantId;
  final String clientType;
  final String name;
  final String? contactPerson;
  final String phonePrimary;
  final String? phoneSecondary;
  final String? physicalAddress;
  final String? notes;

  const ClientSummaryEntity({
    required this.id,
    required this.tenantId,
    required this.clientType,
    required this.name,
    this.contactPerson,
    required this.phonePrimary,
    this.phoneSecondary,
    this.physicalAddress,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        clientType,
        name,
        contactPerson,
        phonePrimary,
        phoneSecondary,
        physicalAddress,
        notes,
      ];
}

/// Domain entity representing a veterinary patient combined with owner summary.
class PatientEntity extends Equatable {
  final String id;
  final String tenantId;
  final String clientId;
  final String nameOrTag;
  final String species;
  final String? breed;
  final String gender;
  final int? age;
  final DateTime? dateOfBirth;
  final bool isApproximateAge;
  final String? microchipNumber;
  final String? earTagId;
  final String? coatColorMarkings;
  final double? currentWeightKg;
  final DateTime? weightRecordedAt;
  final String? history;
  final String? notes;
  final String status;
  final List<String> allergies;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final ClientSummaryEntity client;

  const PatientEntity({
    required this.id,
    required this.tenantId,
    required this.clientId,
    required this.nameOrTag,
    required this.species,
    this.breed,
    required this.gender,
    this.age,
    this.dateOfBirth,
    this.isApproximateAge = false,
    this.microchipNumber,
    this.earTagId,
    this.coatColorMarkings,
    this.currentWeightKg,
    this.weightRecordedAt,
    this.history,
    this.notes,
    this.status = 'active',
    this.allergies = const [],
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
    required this.client,
  });

  /// Human-readable age representation.
  String get formattedAge {
    if (age != null) {
      final prefix = isApproximateAge ? 'Approx. ' : '';
      return '$prefix$age ${age == 1 ? "yr" : "yrs"}';
    }
    if (dateOfBirth != null) {
      final now = DateTime.now();
      final diffDays = now.difference(dateOfBirth!).inDays;
      if (diffDays < 30) {
        return '$diffDays days';
      } else if (diffDays < 365) {
        final months = (diffDays / 30).floor();
        return '$months ${months == 1 ? "mo" : "mos"}';
      } else {
        final years = (diffDays / 365).floor();
        final prefix = isApproximateAge ? 'Approx. ' : '';
        return '$prefix$years ${years == 1 ? "yr" : "yrs"}';
      }
    }
    return 'Age unknown';
  }

  /// Clinical representation of gender and reproductive status.
  String get formattedGender {
    switch (gender.toLowerCase()) {
      case 'male_neutered':
        return 'Male (Neutered)';
      case 'male_intact':
        return 'Male (Intact)';
      case 'female_spayed':
        return 'Female (Spayed)';
      case 'female_intact':
        return 'Female (Intact)';
      default:
        return 'Unknown';
    }
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        clientId,
        nameOrTag,
        species,
        breed,
        gender,
        age,
        dateOfBirth,
        isApproximateAge,
        microchipNumber,
        earTagId,
        coatColorMarkings,
        currentWeightKg,
        weightRecordedAt,
        history,
        notes,
        status,
        allergies,
        createdAt,
        updatedAt,
        syncStatus,
        client,
      ];
}
