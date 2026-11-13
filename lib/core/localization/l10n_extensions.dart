import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';

/// Ergonomic localization extension on [BuildContext].
extension AppLocalizationsX on BuildContext {
  /// Look up the nearest [AppLocalizations] instance, or fallback to [AppLocalizationsEn]
  /// if not provided in the widget tree (e.g. in isolated test environments).
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? AppLocalizationsEn();

  /// Formats raw species identifier to a localized human-readable string.
  String formatSpecies(String species) {
    switch (species.trim().toLowerCase()) {
      case 'canine':
      case 'dog':
        return l10n.canine;
      case 'feline':
      case 'cat':
        return l10n.feline;
      case 'equine':
      case 'horse':
        return l10n.equine;
      case 'bovine':
      case 'cow':
      case 'cattle':
        return l10n.bovine;
      case 'ovine':
      case 'sheep':
        return l10n.ovine;
      case 'caprine':
      case 'goat':
        return l10n.caprine;
      case 'avian':
      case 'bird':
        return l10n.avian;
      case 'other':
      default:
        if (species.trim().toLowerCase() == 'other') {
          return l10n.otherSpecies;
        }
        return species;
    }
  }

  /// Formats database gender and reproductive status to localized string.
  String formatGender(String gender) {
    switch (gender.trim().toLowerCase()) {
      case 'neutered_male':
      case 'male_neutered':
        return l10n.maleNeutered;
      case 'intact_male':
      case 'male_intact':
        return l10n.maleIntact;
      case 'spayed_female':
      case 'female_spayed':
        return l10n.femaleSpayed;
      case 'intact_female':
      case 'female_intact':
        return l10n.femaleIntact;
      case 'unknown':
      default:
        return l10n.unknownGender;
    }
  }

  /// Formats triage priority to localized string.
  String formatPriority(String priority) {
    switch (priority.trim().toLowerCase()) {
      case 'critical':
      case 'emergency':
        return l10n.critical;
      case 'urgent':
        return l10n.urgent;
      case 'routine':
      default:
        return l10n.routine;
    }
  }

  /// Formats encounter or visit status to localized string.
  String formatStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'signed':
      case 'locked':
        return l10n.signed;
      case 'closed':
        return l10n.closed;
      case 'observation':
        return l10n.observation;
      case 'stable':
        return l10n.stable;
      case 'open':
      default:
        return l10n.open;
    }
  }

  /// Formats staff role to localized string.
  String formatStaffRole(String role) {
    switch (role.trim().toLowerCase()) {
      case 'doctor':
      case 'veterinarian':
        return l10n.roleDoctor;
      case 'technician':
      case 'tech':
        return l10n.roleTechnician;
      case 'admin':
      case 'administrator':
        return l10n.roleAdmin;
      case 'receptionist':
        return l10n.roleReceptionist;
      default:
        return role;
    }
  }

  /// Formats visit type to localized string.
  String formatVisitType(String visitType) {
    switch (visitType.trim().toLowerCase()) {
      case 'consultation':
        return l10n.consultation;
      case 'follow_up':
      case 'followup':
        return l10n.followUp;
      case 'emergency':
        return l10n.emergency;
      case 'surgery_recheck':
      case 'surgery':
        return l10n.surgeryRecheck;
      case 'routine':
        return l10n.routineCheckup;
      default:
        return visitType;
    }
  }
}


