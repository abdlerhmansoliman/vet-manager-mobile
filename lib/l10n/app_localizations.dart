import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'VetManager'**
  String get appTitle;

  /// No description provided for @triageBoard.
  ///
  /// In en, this message translates to:
  /// **'Triage Board'**
  String get triageBoard;

  /// No description provided for @patients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patients;

  /// No description provided for @clinicalCases.
  ///
  /// In en, this message translates to:
  /// **'Clinical Cases'**
  String get clinicalCases;

  /// No description provided for @pharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get pharmacy;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @createNewCase.
  ///
  /// In en, this message translates to:
  /// **'Create New Case'**
  String get createNewCase;

  /// No description provided for @startNewVisit.
  ///
  /// In en, this message translates to:
  /// **'Start New Visit'**
  String get startNewVisit;

  /// No description provided for @recordSoapExam.
  ///
  /// In en, this message translates to:
  /// **'Record SOAP Exam'**
  String get recordSoapExam;

  /// No description provided for @appendAddendum.
  ///
  /// In en, this message translates to:
  /// **'Append Addendum'**
  String get appendAddendum;

  /// No description provided for @signAndLock.
  ///
  /// In en, this message translates to:
  /// **'Sign & Lock Visit'**
  String get signAndLock;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @routine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routine;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical / Emergency'**
  String get critical;

  /// No description provided for @criticalPriority.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get criticalPriority;

  /// No description provided for @urgentPriority.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgentPriority;

  /// No description provided for @routinePriority.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routinePriority;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// No description provided for @observation.
  ///
  /// In en, this message translates to:
  /// **'Observation'**
  String get observation;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @signed.
  ///
  /// In en, this message translates to:
  /// **'Signed & Locked'**
  String get signed;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient Name'**
  String get patientName;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @microchip.
  ///
  /// In en, this message translates to:
  /// **'Microchip'**
  String get microchip;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @respiratoryRate.
  ///
  /// In en, this message translates to:
  /// **'Respiratory Rate'**
  String get respiratoryRate;

  /// No description provided for @mucousMembrane.
  ///
  /// In en, this message translates to:
  /// **'Mucous Membrane'**
  String get mucousMembrane;

  /// No description provided for @subjective.
  ///
  /// In en, this message translates to:
  /// **'Subjective (History & Complaints)'**
  String get subjective;

  /// No description provided for @objective.
  ///
  /// In en, this message translates to:
  /// **'Objective (Clinical Findings)'**
  String get objective;

  /// No description provided for @assessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment (Diagnosis)'**
  String get assessment;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan (Treatment & Prescriptions)'**
  String get plan;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @allChangesSynced.
  ///
  /// In en, this message translates to:
  /// **'All changes synced'**
  String get allChangesSynced;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Medical & Legal Disclaimer'**
  String get medicalDisclaimer;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync with Cloud'**
  String get syncNow;

  /// No description provided for @syncingData.
  ///
  /// In en, this message translates to:
  /// **'Syncing cases and patient records...'**
  String get syncingData;

  /// No description provided for @triageCases.
  ///
  /// In en, this message translates to:
  /// **'Triage Cases'**
  String get triageCases;

  /// No description provided for @practitionerProfile.
  ///
  /// In en, this message translates to:
  /// **'Practitioner Profile'**
  String get practitionerProfile;

  /// No description provided for @newPatient.
  ///
  /// In en, this message translates to:
  /// **'New Patient'**
  String get newPatient;

  /// No description provided for @patientsDirectory.
  ///
  /// In en, this message translates to:
  /// **'Patients & Clients'**
  String get patientsDirectory;

  /// No description provided for @activePatients.
  ///
  /// In en, this message translates to:
  /// **'Active Patients'**
  String get activePatients;

  /// No description provided for @offlineAnimalRegistry.
  ///
  /// In en, this message translates to:
  /// **'Offline-first animal registry'**
  String get offlineAnimalRegistry;

  /// No description provided for @searchPatientsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by patient, chip, ear tag, owner...'**
  String get searchPatientsHint;

  /// No description provided for @noPatientsFound.
  ///
  /// In en, this message translates to:
  /// **'No patients found'**
  String get noPatientsFound;

  /// No description provided for @noPatientsFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'No animal patients match your search criteria.'**
  String get noPatientsFoundDesc;

  /// No description provided for @noCasesFound.
  ///
  /// In en, this message translates to:
  /// **'No cases found'**
  String get noCasesFound;

  /// No description provided for @noCasesFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'No clinical cases found for this triage priority.'**
  String get noCasesFoundDesc;

  /// No description provided for @canine.
  ///
  /// In en, this message translates to:
  /// **'Canine'**
  String get canine;

  /// No description provided for @feline.
  ///
  /// In en, this message translates to:
  /// **'Feline'**
  String get feline;

  /// No description provided for @equine.
  ///
  /// In en, this message translates to:
  /// **'Equine'**
  String get equine;

  /// No description provided for @bovine.
  ///
  /// In en, this message translates to:
  /// **'Bovine'**
  String get bovine;

  /// No description provided for @ovine.
  ///
  /// In en, this message translates to:
  /// **'Ovine'**
  String get ovine;

  /// No description provided for @caprine.
  ///
  /// In en, this message translates to:
  /// **'Caprine'**
  String get caprine;

  /// No description provided for @avian.
  ///
  /// In en, this message translates to:
  /// **'Avian'**
  String get avian;

  /// No description provided for @otherSpecies.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherSpecies;

  /// No description provided for @maleNeutered.
  ///
  /// In en, this message translates to:
  /// **'Male (Neutered)'**
  String get maleNeutered;

  /// No description provided for @maleIntact.
  ///
  /// In en, this message translates to:
  /// **'Male (Intact)'**
  String get maleIntact;

  /// No description provided for @femaleSpayed.
  ///
  /// In en, this message translates to:
  /// **'Female (Spayed)'**
  String get femaleSpayed;

  /// No description provided for @femaleIntact.
  ///
  /// In en, this message translates to:
  /// **'Female (Intact)'**
  String get femaleIntact;

  /// No description provided for @unknownGender.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownGender;

  /// No description provided for @editPatientProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Patient Profile'**
  String get editPatientProfile;

  /// No description provided for @registerPatient.
  ///
  /// In en, this message translates to:
  /// **'Register Patient'**
  String get registerPatient;

  /// No description provided for @patientIdentity.
  ///
  /// In en, this message translates to:
  /// **'Patient Identity'**
  String get patientIdentity;

  /// No description provided for @patientNameOrTag.
  ///
  /// In en, this message translates to:
  /// **'Patient Name / Ear Tag'**
  String get patientNameOrTag;

  /// No description provided for @patientNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bella or EAR-104'**
  String get patientNameHint;

  /// No description provided for @pleaseEnterPatientName.
  ///
  /// In en, this message translates to:
  /// **'Please enter patient name or ear tag'**
  String get pleaseEnterPatientName;

  /// No description provided for @patientNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Patient name cannot exceed 100 characters'**
  String get patientNameTooLong;

  /// No description provided for @breedHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Golden Retriever, Holstein, Mixed'**
  String get breedHint;

  /// No description provided for @breedTooLong.
  ///
  /// In en, this message translates to:
  /// **'Breed cannot exceed 100 characters'**
  String get breedTooLong;

  /// No description provided for @genderAndReproductiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Gender & Reproductive Status'**
  String get genderAndReproductiveStatus;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'Age (Years)'**
  String get ageYears;

  /// No description provided for @ageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3'**
  String get ageHint;

  /// No description provided for @enterValidAge.
  ///
  /// In en, this message translates to:
  /// **'Enter valid age (0-150)'**
  String get enterValidAge;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @weightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12.5'**
  String get weightHint;

  /// No description provided for @enterValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter valid weight in kg'**
  String get enterValidWeight;

  /// No description provided for @ageIsEstimated.
  ///
  /// In en, this message translates to:
  /// **'Age is estimated / approximate'**
  String get ageIsEstimated;

  /// No description provided for @identificationAndMedical.
  ///
  /// In en, this message translates to:
  /// **'Identification & Medical'**
  String get identificationAndMedical;

  /// No description provided for @rfidMicrochip.
  ///
  /// In en, this message translates to:
  /// **'RFID Microchip Implant #'**
  String get rfidMicrochip;

  /// No description provided for @rfidMicrochipHint.
  ///
  /// In en, this message translates to:
  /// **'15-digit ISO 11784/11785'**
  String get rfidMicrochipHint;

  /// No description provided for @microchipTooLong.
  ///
  /// In en, this message translates to:
  /// **'Microchip ID cannot exceed 32 characters'**
  String get microchipTooLong;

  /// No description provided for @visualEarTagId.
  ///
  /// In en, this message translates to:
  /// **'Visual Livestock Ear Tag ID'**
  String get visualEarTagId;

  /// No description provided for @visualEarTagHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. TAG-402'**
  String get visualEarTagHint;

  /// No description provided for @earTagTooLong.
  ///
  /// In en, this message translates to:
  /// **'Ear tag ID cannot exceed 64 characters'**
  String get earTagTooLong;

  /// No description provided for @knownDrugAllergies.
  ///
  /// In en, this message translates to:
  /// **'Known Drug Allergies'**
  String get knownDrugAllergies;

  /// No description provided for @knownDrugAllergiesHint.
  ///
  /// In en, this message translates to:
  /// **'Separate with comma: Penicillin, NSAIDs'**
  String get knownDrugAllergiesHint;

  /// No description provided for @clinicalNotesInternal.
  ///
  /// In en, this message translates to:
  /// **'Clinical Notes (Internal)'**
  String get clinicalNotesInternal;

  /// No description provided for @clinicalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Confidential patient observations, temperament...'**
  String get clinicalNotesHint;

  /// No description provided for @medicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History & Clinical Background'**
  String get medicalHistory;

  /// No description provided for @medicalHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Prior surgeries, chronic conditions, immunizations...'**
  String get medicalHistoryHint;

  /// No description provided for @ownerClientDetails.
  ///
  /// In en, this message translates to:
  /// **'Owner / Client Details'**
  String get ownerClientDetails;

  /// No description provided for @clientFullName.
  ///
  /// In en, this message translates to:
  /// **'Owner / Contact Name *'**
  String get clientFullName;

  /// No description provided for @clientNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. John Miller'**
  String get clientNameHint;

  /// No description provided for @pleaseEnterClientName.
  ///
  /// In en, this message translates to:
  /// **'Please enter client name'**
  String get pleaseEnterClientName;

  /// No description provided for @clientNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Client name cannot exceed 100 characters'**
  String get clientNameTooLong;

  /// No description provided for @primaryPhone.
  ///
  /// In en, this message translates to:
  /// **'Primary Phone'**
  String get primaryPhone;

  /// No description provided for @primaryPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. +1 555-0199'**
  String get primaryPhoneHint;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter contact phone'**
  String get pleaseEnterPhone;

  /// No description provided for @clientAddress.
  ///
  /// In en, this message translates to:
  /// **'Physical Address / Farm Location'**
  String get clientAddress;

  /// No description provided for @clientAddressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Barn 4, North Pasture'**
  String get clientAddressHint;

  /// No description provided for @savePatientAndSync.
  ///
  /// In en, this message translates to:
  /// **'Save Patient & Enqueue Sync'**
  String get savePatientAndSync;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @updatePatientProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get updatePatientProfile;

  /// No description provided for @reviewHighlightedFields.
  ///
  /// In en, this message translates to:
  /// **'Please review the highlighted fields before saving.'**
  String get reviewHighlightedFields;

  /// No description provided for @patientSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Patient registered successfully!'**
  String get patientSavedSuccess;

  /// No description provided for @patientUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Patient profile updated successfully!'**
  String get patientUpdatedSuccess;

  /// No description provided for @patientDetails.
  ///
  /// In en, this message translates to:
  /// **'Patient Details'**
  String get patientDetails;

  /// No description provided for @demographicsAndOwner.
  ///
  /// In en, this message translates to:
  /// **'Demographics & Owner'**
  String get demographicsAndOwner;

  /// No description provided for @detailsAndOwner.
  ///
  /// In en, this message translates to:
  /// **'Details & Owner'**
  String get detailsAndOwner;

  /// No description provided for @vitalStats.
  ///
  /// In en, this message translates to:
  /// **'Vital Statistics'**
  String get vitalStats;

  /// No description provided for @deletePatient.
  ///
  /// In en, this message translates to:
  /// **'Delete Patient'**
  String get deletePatient;

  /// No description provided for @deletePatientConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this patient? The medical history will be preserved offline and the deletion will sync with the clinic server.'**
  String get deletePatientConfirm;

  /// No description provided for @noCasesRecordedYet.
  ///
  /// In en, this message translates to:
  /// **'No clinical cases recorded yet'**
  String get noCasesRecordedYet;

  /// No description provided for @startEncounter.
  ///
  /// In en, this message translates to:
  /// **'Start Encounter'**
  String get startEncounter;

  /// No description provided for @allergiesAlert.
  ///
  /// In en, this message translates to:
  /// **'High-Risk Allergies'**
  String get allergiesAlert;

  /// No description provided for @noKnownAllergies.
  ///
  /// In en, this message translates to:
  /// **'No known drug allergies reported.'**
  String get noKnownAllergies;

  /// No description provided for @clientContact.
  ///
  /// In en, this message translates to:
  /// **'Client Contact'**
  String get clientContact;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @historyAndBackground.
  ///
  /// In en, this message translates to:
  /// **'History & Clinical Background'**
  String get historyAndBackground;

  /// No description provided for @internalNotes.
  ///
  /// In en, this message translates to:
  /// **'Internal Clinical Notes'**
  String get internalNotes;

  /// No description provided for @searchCasesHint.
  ///
  /// In en, this message translates to:
  /// **'Search cases, complaints, patients...'**
  String get searchCasesHint;

  /// No description provided for @activeCases.
  ///
  /// In en, this message translates to:
  /// **'Active Cases'**
  String get activeCases;

  /// No description provided for @caseDetails.
  ///
  /// In en, this message translates to:
  /// **'Case Details'**
  String get caseDetails;

  /// No description provided for @visitsTimeline.
  ///
  /// In en, this message translates to:
  /// **'Visits Timeline'**
  String get visitsTimeline;

  /// No description provided for @chiefComplaint.
  ///
  /// In en, this message translates to:
  /// **'Chief Complaint'**
  String get chiefComplaint;

  /// No description provided for @provisionalDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Provisional Diagnosis'**
  String get provisionalDiagnosis;

  /// No description provided for @finalDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Final Diagnosis'**
  String get finalDiagnosis;

  /// No description provided for @triagePriority.
  ///
  /// In en, this message translates to:
  /// **'Triage Priority'**
  String get triagePriority;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @editDiagnoses.
  ///
  /// In en, this message translates to:
  /// **'Edit Diagnoses'**
  String get editDiagnoses;

  /// No description provided for @closeCase.
  ///
  /// In en, this message translates to:
  /// **'Close Case'**
  String get closeCase;

  /// No description provided for @reopenCase.
  ///
  /// In en, this message translates to:
  /// **'Reopen Case'**
  String get reopenCase;

  /// No description provided for @caseClosedNotice.
  ///
  /// In en, this message translates to:
  /// **'Case marked as closed.'**
  String get caseClosedNotice;

  /// No description provided for @caseReopenedNotice.
  ///
  /// In en, this message translates to:
  /// **'Case reopened.'**
  String get caseReopenedNotice;

  /// No description provided for @visitDetails.
  ///
  /// In en, this message translates to:
  /// **'Visit Details'**
  String get visitDetails;

  /// No description provided for @soapClinicalNotes.
  ///
  /// In en, this message translates to:
  /// **'SOAP Clinical Notes'**
  String get soapClinicalNotes;

  /// No description provided for @administeredMedications.
  ///
  /// In en, this message translates to:
  /// **'Administered Medications'**
  String get administeredMedications;

  /// No description provided for @diagnosticMedia.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic Media'**
  String get diagnosticMedia;

  /// No description provided for @administerMedication.
  ///
  /// In en, this message translates to:
  /// **'Administer Medication'**
  String get administerMedication;

  /// No description provided for @uploadDiagnosticMedia.
  ///
  /// In en, this message translates to:
  /// **'Upload Diagnostic Media'**
  String get uploadDiagnosticMedia;

  /// No description provided for @noSoapNotesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No SOAP notes recorded for this visit yet.'**
  String get noSoapNotesRecorded;

  /// No description provided for @noMedicationsAdministered.
  ///
  /// In en, this message translates to:
  /// **'No medications administered yet.'**
  String get noMedicationsAdministered;

  /// No description provided for @noMediaAttached.
  ///
  /// In en, this message translates to:
  /// **'No diagnostic images attached yet.'**
  String get noMediaAttached;

  /// No description provided for @signVisitNotice.
  ///
  /// In en, this message translates to:
  /// **'Once signed and locked, clinical exam findings cannot be altered.'**
  String get signVisitNotice;

  /// No description provided for @signInToClinic.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Your Clinic'**
  String get signInToClinic;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @clinicalSecurityNotice.
  ///
  /// In en, this message translates to:
  /// **'Secured enterprise veterinary system. All clinical entries are cryptographically stamped.'**
  String get clinicalSecurityNotice;

  /// No description provided for @staffDirectory.
  ///
  /// In en, this message translates to:
  /// **'Staff Directory'**
  String get staffDirectory;

  /// No description provided for @addStaffMember.
  ///
  /// In en, this message translates to:
  /// **'Add Staff Member'**
  String get addStaffMember;

  /// No description provided for @roleDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor / Veterinarian'**
  String get roleDoctor;

  /// No description provided for @roleTechnician.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Technician'**
  String get roleTechnician;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Clinic Administrator'**
  String get roleAdmin;

  /// No description provided for @roleReceptionist.
  ///
  /// In en, this message translates to:
  /// **'Receptionist'**
  String get roleReceptionist;

  /// No description provided for @manageClinicStaff.
  ///
  /// In en, this message translates to:
  /// **'Manage Clinic Staff'**
  String get manageClinicStaff;

  /// No description provided for @practitionerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Practitioner profile not found'**
  String get practitionerNotFound;

  /// No description provided for @practitionerNotFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'The requested staff credentials could not be loaded.'**
  String get practitionerNotFoundDesc;

  /// No description provided for @activeStaff.
  ///
  /// In en, this message translates to:
  /// **'Active Staff'**
  String get activeStaff;

  /// No description provided for @suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspended;

  /// No description provided for @clinicalPractice.
  ///
  /// In en, this message translates to:
  /// **'Clinical Practice'**
  String get clinicalPractice;

  /// No description provided for @assignedPractice.
  ///
  /// In en, this message translates to:
  /// **'Assigned Practice'**
  String get assignedPractice;

  /// No description provided for @switchClinicalPractice.
  ///
  /// In en, this message translates to:
  /// **'Switch Clinical Practice'**
  String get switchClinicalPractice;

  /// No description provided for @onDutyAvailability.
  ///
  /// In en, this message translates to:
  /// **'On-Duty Availability'**
  String get onDutyAvailability;

  /// No description provided for @availableForTriage.
  ///
  /// In en, this message translates to:
  /// **'Available for consultations & triage'**
  String get availableForTriage;

  /// No description provided for @unavailableForTriage.
  ///
  /// In en, this message translates to:
  /// **'Off-duty / Not accepting new cases'**
  String get unavailableForTriage;

  /// No description provided for @clinicalWorkload.
  ///
  /// In en, this message translates to:
  /// **'Clinical Workload'**
  String get clinicalWorkload;

  /// No description provided for @activeCasesCount.
  ///
  /// In en, this message translates to:
  /// **'Active Cases'**
  String get activeCasesCount;

  /// No description provided for @deaWitness.
  ///
  /// In en, this message translates to:
  /// **'DEA Witness'**
  String get deaWitness;

  /// No description provided for @authorized.
  ///
  /// In en, this message translates to:
  /// **'Authorized'**
  String get authorized;

  /// No description provided for @notApplicable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notApplicable;

  /// No description provided for @credentialsAndLicensure.
  ///
  /// In en, this message translates to:
  /// **'Credentials & Licensure'**
  String get credentialsAndLicensure;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get licenseNumber;

  /// No description provided for @notOnFile.
  ///
  /// In en, this message translates to:
  /// **'Not on file'**
  String get notOnFile;

  /// No description provided for @deaRegistration.
  ///
  /// In en, this message translates to:
  /// **'DEA Registration'**
  String get deaRegistration;

  /// No description provided for @clinicEmail.
  ///
  /// In en, this message translates to:
  /// **'Clinic Email'**
  String get clinicEmail;

  /// No description provided for @directPhone.
  ///
  /// In en, this message translates to:
  /// **'Direct Phone'**
  String get directPhone;

  /// No description provided for @biographyAndExperience.
  ///
  /// In en, this message translates to:
  /// **'Biography & Experience'**
  String get biographyAndExperience;

  /// No description provided for @clinicalAuthorizations.
  ///
  /// In en, this message translates to:
  /// **'Clinical Authorizations'**
  String get clinicalAuthorizations;

  /// No description provided for @prescribeRx.
  ///
  /// In en, this message translates to:
  /// **'Prescribe Rx'**
  String get prescribeRx;

  /// No description provided for @controlledSubstances.
  ///
  /// In en, this message translates to:
  /// **'Controlled Substances'**
  String get controlledSubstances;

  /// No description provided for @surgeryClearance.
  ///
  /// In en, this message translates to:
  /// **'Surgery Clearance'**
  String get surgeryClearance;

  /// No description provided for @staffManagement.
  ///
  /// In en, this message translates to:
  /// **'Staff Management'**
  String get staffManagement;

  /// No description provided for @billingAndInvoicing.
  ///
  /// In en, this message translates to:
  /// **'Billing & Invoicing'**
  String get billingAndInvoicing;

  /// No description provided for @ownerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Owner Dashboard'**
  String get ownerDashboard;

  /// No description provided for @legalAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Legal & Account Privacy'**
  String get legalAndPrivacy;

  /// No description provided for @medicalAndLegalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Medical & Legal Disclaimer'**
  String get medicalAndLegalDisclaimer;

  /// No description provided for @medicalDisclaimerNotice.
  ///
  /// In en, this message translates to:
  /// **'Guideline 1.4.1 & Veterinary Regulatory Notice'**
  String get medicalDisclaimerNotice;

  /// No description provided for @deletePractitionerAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Practitioner Account'**
  String get deletePractitionerAccount;

  /// No description provided for @deleteAccountNotice.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove login credentials and data'**
  String get deleteAccountNotice;

  /// No description provided for @manageClinicStaffDirectory.
  ///
  /// In en, this message translates to:
  /// **'Manage Clinic Staff Directory'**
  String get manageClinicStaffDirectory;

  /// No description provided for @clinicStaffDirectory.
  ///
  /// In en, this message translates to:
  /// **'Clinic Staff Directory'**
  String get clinicStaffDirectory;

  /// No description provided for @searchStaffHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, role, email, or specialty...'**
  String get searchStaffHint;

  /// No description provided for @allRoles.
  ///
  /// In en, this message translates to:
  /// **'All Roles'**
  String get allRoles;

  /// No description provided for @allStaff.
  ///
  /// In en, this message translates to:
  /// **'All Staff'**
  String get allStaff;

  /// No description provided for @roleVeterinarian.
  ///
  /// In en, this message translates to:
  /// **'Veterinarians'**
  String get roleVeterinarian;

  /// No description provided for @headVets.
  ///
  /// In en, this message translates to:
  /// **'Head Vets'**
  String get headVets;

  /// No description provided for @fieldVets.
  ///
  /// In en, this message translates to:
  /// **'Field Vets'**
  String get fieldVets;

  /// No description provided for @vetTechs.
  ///
  /// In en, this message translates to:
  /// **'Vet Techs'**
  String get vetTechs;

  /// No description provided for @assistants.
  ///
  /// In en, this message translates to:
  /// **'Assistants'**
  String get assistants;

  /// No description provided for @receptionists.
  ///
  /// In en, this message translates to:
  /// **'Receptionists'**
  String get receptionists;

  /// No description provided for @roleTech.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get roleTech;

  /// No description provided for @roleReceptionistShort.
  ///
  /// In en, this message translates to:
  /// **'Receptionist'**
  String get roleReceptionistShort;

  /// No description provided for @roleAdminShort.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdminShort;

  /// No description provided for @roleIntern.
  ///
  /// In en, this message translates to:
  /// **'Intern'**
  String get roleIntern;

  /// No description provided for @noStaffFound.
  ///
  /// In en, this message translates to:
  /// **'No staff members found'**
  String get noStaffFound;

  /// No description provided for @registerNewStaff.
  ///
  /// In en, this message translates to:
  /// **'Register New Staff Member'**
  String get registerNewStaff;

  /// No description provided for @editStaffMember.
  ///
  /// In en, this message translates to:
  /// **'Edit Staff Member'**
  String get editStaffMember;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @witnessPin.
  ///
  /// In en, this message translates to:
  /// **'Witness PIN (4-Digits)'**
  String get witnessPin;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @saveStaffMember.
  ///
  /// In en, this message translates to:
  /// **'Save Staff Member'**
  String get saveStaffMember;

  /// No description provided for @registerStaff.
  ///
  /// In en, this message translates to:
  /// **'Register Staff'**
  String get registerStaff;

  /// No description provided for @deleteStaffConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this staff member?'**
  String get deleteStaffConfirm;

  /// No description provided for @triageSeverityLevel.
  ///
  /// In en, this message translates to:
  /// **'Triage Severity Level'**
  String get triageSeverityLevel;

  /// No description provided for @encounterStatus.
  ///
  /// In en, this message translates to:
  /// **'Encounter Status'**
  String get encounterStatus;

  /// No description provided for @openStatus.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openStatus;

  /// No description provided for @inProgressStatus.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressStatus;

  /// No description provided for @underObservationStatus.
  ///
  /// In en, this message translates to:
  /// **'Under Observation'**
  String get underObservationStatus;

  /// No description provided for @closedStatus.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedStatus;

  /// No description provided for @clinicalVisitsAndEncounters.
  ///
  /// In en, this message translates to:
  /// **'Clinical Visits & Encounters'**
  String get clinicalVisitsAndEncounters;

  /// No description provided for @noVisitsRecordedYet.
  ///
  /// In en, this message translates to:
  /// **'No Visits Recorded Yet'**
  String get noVisitsRecordedYet;

  /// No description provided for @noVisitsRecordedDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap below to open the first clinical visit encounter for recording SOAP examination findings, diagnostic images, medication doses, and addenda.'**
  String get noVisitsRecordedDesc;

  /// No description provided for @openInitialConsultation.
  ///
  /// In en, this message translates to:
  /// **'Open Initial Consultation Visit'**
  String get openInitialConsultation;

  /// No description provided for @editChiefComplaint.
  ///
  /// In en, this message translates to:
  /// **'Edit Chief Complaint'**
  String get editChiefComplaint;

  /// No description provided for @enterChiefComplaintHint.
  ///
  /// In en, this message translates to:
  /// **'Enter chief complaint...'**
  String get enterChiefComplaintHint;

  /// No description provided for @diagnosesAndHypotheses.
  ///
  /// In en, this message translates to:
  /// **'Diagnoses & Hypotheses'**
  String get diagnosesAndHypotheses;

  /// No description provided for @updateDiagnoses.
  ///
  /// In en, this message translates to:
  /// **'Update Diagnoses'**
  String get updateDiagnoses;

  /// No description provided for @noneEstablishedYet.
  ///
  /// In en, this message translates to:
  /// **'None established yet'**
  String get noneEstablishedYet;

  /// No description provided for @pendingInvestigation.
  ///
  /// In en, this message translates to:
  /// **'Pending investigation/response'**
  String get pendingInvestigation;

  /// No description provided for @editVisit.
  ///
  /// In en, this message translates to:
  /// **'Edit Visit'**
  String get editVisit;

  /// No description provided for @editVisitDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Visit Details'**
  String get editVisitDetails;

  /// No description provided for @visitTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit Title'**
  String get visitTitle;

  /// No description provided for @visitType.
  ///
  /// In en, this message translates to:
  /// **'Visit Type'**
  String get visitType;

  /// No description provided for @consultation.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get consultation;

  /// No description provided for @followUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get followUp;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @surgeryRecheck.
  ///
  /// In en, this message translates to:
  /// **'Surgery Re-check'**
  String get surgeryRecheck;

  /// No description provided for @routineCheckup.
  ///
  /// In en, this message translates to:
  /// **'Routine Checkup'**
  String get routineCheckup;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get locked;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @activeBadge.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeBadge;

  /// No description provided for @encounterDate.
  ///
  /// In en, this message translates to:
  /// **'Encounter Date'**
  String get encounterDate;

  /// No description provided for @attendingClinician.
  ///
  /// In en, this message translates to:
  /// **'Attending'**
  String get attendingClinician;

  /// No description provided for @signedAndFinalized.
  ///
  /// In en, this message translates to:
  /// **'Signed & Finalized'**
  String get signedAndFinalized;

  /// No description provided for @editSoapExam.
  ///
  /// In en, this message translates to:
  /// **'Edit SOAP Exam'**
  String get editSoapExam;

  /// No description provided for @administerDose.
  ///
  /// In en, this message translates to:
  /// **'Administer Dose'**
  String get administerDose;

  /// No description provided for @signAndLockVisit.
  ///
  /// In en, this message translates to:
  /// **'Sign & Lock Visit Record'**
  String get signAndLockVisit;

  /// No description provided for @soapPhysicalExam.
  ///
  /// In en, this message translates to:
  /// **'SOAP Physical Examination'**
  String get soapPhysicalExam;

  /// No description provided for @noSoapExamRecordedYet.
  ///
  /// In en, this message translates to:
  /// **'No SOAP Exam Recorded Yet'**
  String get noSoapExamRecordedYet;

  /// No description provided for @noSoapExamDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Record SOAP Exam\" above to document vitals, subjective observations, assessment, and treatment plan.'**
  String get noSoapExamDesc;

  /// No description provided for @immutableAddenda.
  ///
  /// In en, this message translates to:
  /// **'Immutable Addenda'**
  String get immutableAddenda;

  /// No description provided for @noAddendaSigned.
  ///
  /// In en, this message translates to:
  /// **'No addendums appended to this signed record.'**
  String get noAddendaSigned;

  /// No description provided for @addendaCanBeAppendedOnceSigned.
  ///
  /// In en, this message translates to:
  /// **'Addendums can be appended once the encounter is signed.'**
  String get addendaCanBeAppendedOnceSigned;

  /// No description provided for @startNewVisitEncounter.
  ///
  /// In en, this message translates to:
  /// **'Start New Visit Encounter'**
  String get startNewVisitEncounter;

  /// No description provided for @encounterType.
  ///
  /// In en, this message translates to:
  /// **'Encounter Type'**
  String get encounterType;

  /// No description provided for @visitTitleOrPurpose.
  ///
  /// In en, this message translates to:
  /// **'Visit Title / Purpose'**
  String get visitTitleOrPurpose;

  /// No description provided for @beginVisitEncounter.
  ///
  /// In en, this message translates to:
  /// **'Begin Visit Encounter'**
  String get beginVisitEncounter;

  /// No description provided for @pleaseEnterVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a visit title'**
  String get pleaseEnterVisitTitle;

  /// No description provided for @pleaseEnterVetName.
  ///
  /// In en, this message translates to:
  /// **'Please enter attending clinician name'**
  String get pleaseEnterVetName;

  /// No description provided for @saveAndSignSoapNote.
  ///
  /// In en, this message translates to:
  /// **'Save & Sign SOAP Note'**
  String get saveAndSignSoapNote;

  /// No description provided for @prescribeMedication.
  ///
  /// In en, this message translates to:
  /// **'Prescribe Medication / Treatment'**
  String get prescribeMedication;

  /// No description provided for @selectMedicine.
  ///
  /// In en, this message translates to:
  /// **'Select Medicine'**
  String get selectMedicine;

  /// No description provided for @additionalClinicalOrders.
  ///
  /// In en, this message translates to:
  /// **'Additional Clinical Orders & Instructions'**
  String get additionalClinicalOrders;

  /// No description provided for @appendClinicalAddendum.
  ///
  /// In en, this message translates to:
  /// **'Append Clinical Addendum'**
  String get appendClinicalAddendum;

  /// No description provided for @immutableMedicalRecord.
  ///
  /// In en, this message translates to:
  /// **'IMMUTABLE MEDICAL RECORD'**
  String get immutableMedicalRecord;

  /// No description provided for @addendaNotice.
  ///
  /// In en, this message translates to:
  /// **'Addenda are append-only. Once signed and committed, this entry cannot be altered or deleted.'**
  String get addendaNotice;

  /// No description provided for @signingVeterinarian.
  ///
  /// In en, this message translates to:
  /// **'Signing Veterinarian'**
  String get signingVeterinarian;

  /// No description provided for @addendumObservations.
  ///
  /// In en, this message translates to:
  /// **'Addendum Clinical Observations & Notes'**
  String get addendumObservations;

  /// No description provided for @certifyAddendum.
  ///
  /// In en, this message translates to:
  /// **'I certify that this addendum is medically accurate and represents legal clinical documentation.'**
  String get certifyAddendum;

  /// No description provided for @signAndCommitAddendum.
  ///
  /// In en, this message translates to:
  /// **'Sign & Commit Addendum'**
  String get signAndCommitAddendum;

  /// No description provided for @administerMedicationImmediate.
  ///
  /// In en, this message translates to:
  /// **'Administer Medication'**
  String get administerMedicationImmediate;

  /// No description provided for @immediateDoseAndStock.
  ///
  /// In en, this message translates to:
  /// **'Case Encounter • Immediate Dose & Stock Deduction'**
  String get immediateDoseAndStock;

  /// No description provided for @dosageQuantity.
  ///
  /// In en, this message translates to:
  /// **'Dosage Quantity'**
  String get dosageQuantity;

  /// No description provided for @routeOfAdministration.
  ///
  /// In en, this message translates to:
  /// **'Route of Administration'**
  String get routeOfAdministration;

  /// No description provided for @controlledSubstanceWitnessNotice.
  ///
  /// In en, this message translates to:
  /// **'Controlled Substance: DEA witness PIN confirmation will be required.'**
  String get controlledSubstanceWitnessNotice;

  /// No description provided for @confirmAndAdministerDose.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Administer Dose'**
  String get confirmAndAdministerDose;

  /// No description provided for @professionalVeterinaryOnly.
  ///
  /// In en, this message translates to:
  /// **'Professional Veterinary Use Only'**
  String get professionalVeterinaryOnly;

  /// No description provided for @professionalVeterinaryDesc.
  ///
  /// In en, this message translates to:
  /// **'VetManager Mobile is designed strictly for licensed veterinarians, credentialed veterinary technicians, and authorized clinical staff. It is an enterprise practice management and medical charting platform and is NOT intended for animal owner self-diagnosis or non-professional clinical administration.'**
  String get professionalVeterinaryDesc;

  /// No description provided for @auxiliaryDecisionSupport.
  ///
  /// In en, this message translates to:
  /// **'Auxiliary Decision Support & Independent Judgment'**
  String get auxiliaryDecisionSupport;

  /// No description provided for @auxiliaryDecisionDesc.
  ///
  /// In en, this message translates to:
  /// **'All calculators, triage priority indicators, radiograph viewer filters, and clinical templates provided within this application are auxiliary decision-support tools. They DO NOT replace, supersede, or override independent professional veterinary clinical judgment, comprehensive physical examination, or diagnostic laboratory testing.'**
  String get auxiliaryDecisionDesc;

  /// No description provided for @dosageResponsibility.
  ///
  /// In en, this message translates to:
  /// **'Dosage Calculation & Pharmacological Responsibility'**
  String get dosageResponsibility;

  /// No description provided for @dosageResponsibilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Before administering any medication, anesthetic agent, fluid therapy, or controlled substance, the attending licensed veterinarian is solely responsible for verifying the patient weight, drug concentration, dosage rate, and potential contraindications. Never rely solely on software calculations for patient therapy.'**
  String get dosageResponsibilityDesc;

  /// No description provided for @emergenciesNotice.
  ///
  /// In en, this message translates to:
  /// **'Acute & Life-Threatening Emergencies'**
  String get emergenciesNotice;

  /// No description provided for @emergenciesDesc.
  ///
  /// In en, this message translates to:
  /// **'In life-threatening situations, patient stabilization, immediate physical resuscitation, airway maintenance, and critical care protocols take precedence over digital documentation. Complete electronic charting only once the patient is hemodynamically stable.'**
  String get emergenciesDesc;

  /// No description provided for @recordRetentionCompliance.
  ///
  /// In en, this message translates to:
  /// **'Statutory Record Retention & Compliance'**
  String get recordRetentionCompliance;

  /// No description provided for @recordRetentionDesc.
  ///
  /// In en, this message translates to:
  /// **'Clinical progress notes, medical addenda, surgical consents, and pharmacy movement ledgers recorded in VetManager are immutable and append-only to satisfy regional veterinary statutory retention mandates and regulatory board compliance standards.'**
  String get recordRetentionDesc;

  /// No description provided for @iAcknowledgeAndUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I Acknowledge & Understand'**
  String get iAcknowledgeAndUnderstand;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @confirmDeletionMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to permanently delete your practitioner account? All active sessions will be terminated immediately.'**
  String get confirmDeletionMessage;

  /// No description provided for @permanentlyDelete.
  ///
  /// In en, this message translates to:
  /// **'Permanently Delete'**
  String get permanentlyDelete;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your practitioner account has been deleted successfully.'**
  String get accountDeletedSuccess;

  /// No description provided for @deleteAccountWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Irreversible Action'**
  String get deleteAccountWarningTitle;

  /// No description provided for @deleteAccountWarningDesc.
  ///
  /// In en, this message translates to:
  /// **'Deleting your practitioner account will permanently revoke your access, invalidate all active sessions, and remove your credentials. Clinical medical records you authored will remain archived according to statutory compliance requirements.'**
  String get deleteAccountWarningDesc;

  /// No description provided for @deleteAccountCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I understand that this action is permanent and cannot be undone.'**
  String get deleteAccountCheckbox;

  /// No description provided for @deleteAccountPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password to authorize deletion:'**
  String get deleteAccountPasswordPrompt;

  /// No description provided for @camel.
  ///
  /// In en, this message translates to:
  /// **'Camel'**
  String get camel;

  /// No description provided for @addSpecies.
  ///
  /// In en, this message translates to:
  /// **'Add Species'**
  String get addSpecies;

  /// No description provided for @newSpecies.
  ///
  /// In en, this message translates to:
  /// **'New Species'**
  String get newSpecies;

  /// No description provided for @enterSpeciesName.
  ///
  /// In en, this message translates to:
  /// **'Enter Species Name'**
  String get enterSpeciesName;

  /// No description provided for @speciesNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Camel, Falcon, Rabbit...'**
  String get speciesNameHint;

  /// No description provided for @speciesAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Species added successfully'**
  String get speciesAddedSuccessfully;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
