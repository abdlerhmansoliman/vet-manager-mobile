// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VetManager';

  @override
  String get triageBoard => 'Triage Board';

  @override
  String get patients => 'Patients';

  @override
  String get clinicalCases => 'Clinical Cases';

  @override
  String get pharmacy => 'Pharmacy';

  @override
  String get settings => 'Settings';

  @override
  String get createNewCase => 'Create New Case';

  @override
  String get startNewVisit => 'Start New Visit';

  @override
  String get recordSoapExam => 'Record SOAP Exam';

  @override
  String get appendAddendum => 'Append Addendum';

  @override
  String get signAndLock => 'Sign & Lock Visit';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get appLanguage => 'App Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get routine => 'Routine';

  @override
  String get urgent => 'Urgent';

  @override
  String get critical => 'Critical / Emergency';

  @override
  String get criticalPriority => 'Critical';

  @override
  String get urgentPriority => 'Urgent';

  @override
  String get routinePriority => 'Routine';

  @override
  String get stable => 'Stable';

  @override
  String get observation => 'Observation';

  @override
  String get open => 'Open';

  @override
  String get closed => 'Closed';

  @override
  String get signed => 'Signed & Locked';

  @override
  String get patientName => 'Patient Name';

  @override
  String get species => 'Species';

  @override
  String get breed => 'Breed';

  @override
  String get gender => 'Gender';

  @override
  String get age => 'Age';

  @override
  String get weight => 'Weight';

  @override
  String get microchip => 'Microchip';

  @override
  String get owner => 'Owner';

  @override
  String get phone => 'Phone';

  @override
  String get allergies => 'Allergies';

  @override
  String get temperature => 'Temperature';

  @override
  String get heartRate => 'Heart Rate';

  @override
  String get respiratoryRate => 'Respiratory Rate';

  @override
  String get mucousMembrane => 'Mucous Membrane';

  @override
  String get subjective => 'Subjective (History & Complaints)';

  @override
  String get objective => 'Objective (Clinical Findings)';

  @override
  String get assessment => 'Assessment (Diagnosis)';

  @override
  String get plan => 'Plan (Treatment & Prescriptions)';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get syncing => 'Syncing...';

  @override
  String get allChangesSynced => 'All changes synced';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get logOut => 'Log Out';

  @override
  String get medicalDisclaimer => 'Medical & Legal Disclaimer';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get all => 'All';

  @override
  String get search => 'Search';

  @override
  String get syncNow => 'Sync with Cloud';

  @override
  String get syncingData => 'Syncing cases and patient records...';

  @override
  String get triageCases => 'Triage Cases';

  @override
  String get practitionerProfile => 'Practitioner Profile';

  @override
  String get newPatient => 'New Patient';

  @override
  String get patientsDirectory => 'Patients & Clients';

  @override
  String get activePatients => 'Active Patients';

  @override
  String get offlineAnimalRegistry => 'Offline-first animal registry';

  @override
  String get searchPatientsHint => 'Search by patient, chip, ear tag, owner...';

  @override
  String get noPatientsFound => 'No patients found';

  @override
  String get noPatientsFoundDesc =>
      'No animal patients match your search criteria.';

  @override
  String get noCasesFound => 'No cases found';

  @override
  String get noCasesFoundDesc =>
      'No clinical cases found for this triage priority.';

  @override
  String get canine => 'Canine';

  @override
  String get feline => 'Feline';

  @override
  String get equine => 'Equine';

  @override
  String get bovine => 'Bovine';

  @override
  String get ovine => 'Ovine';

  @override
  String get caprine => 'Caprine';

  @override
  String get avian => 'Avian';

  @override
  String get otherSpecies => 'Other';

  @override
  String get maleNeutered => 'Male (Neutered)';

  @override
  String get maleIntact => 'Male (Intact)';

  @override
  String get femaleSpayed => 'Female (Spayed)';

  @override
  String get femaleIntact => 'Female (Intact)';

  @override
  String get unknownGender => 'Unknown';

  @override
  String get editPatientProfile => 'Edit Patient Profile';

  @override
  String get registerPatient => 'Register Patient';

  @override
  String get patientIdentity => 'Patient Identity';

  @override
  String get patientNameOrTag => 'Patient Name / Ear Tag';

  @override
  String get patientNameHint => 'e.g. Bella or EAR-104';

  @override
  String get pleaseEnterPatientName => 'Please enter patient name or ear tag';

  @override
  String get patientNameTooLong => 'Patient name cannot exceed 100 characters';

  @override
  String get breedHint => 'e.g. Golden Retriever, Holstein, Mixed';

  @override
  String get breedTooLong => 'Breed cannot exceed 100 characters';

  @override
  String get genderAndReproductiveStatus => 'Gender & Reproductive Status';

  @override
  String get ageYears => 'Age (Years)';

  @override
  String get ageHint => 'e.g. 3';

  @override
  String get enterValidAge => 'Enter valid age (0-150)';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get weightHint => 'e.g. 12.5';

  @override
  String get enterValidWeight => 'Enter valid weight in kg';

  @override
  String get ageIsEstimated => 'Age is estimated / approximate';

  @override
  String get identificationAndMedical => 'Identification & Medical';

  @override
  String get rfidMicrochip => 'RFID Microchip Implant #';

  @override
  String get rfidMicrochipHint => '15-digit ISO 11784/11785';

  @override
  String get microchipTooLong => 'Microchip ID cannot exceed 32 characters';

  @override
  String get visualEarTagId => 'Visual Livestock Ear Tag ID';

  @override
  String get visualEarTagHint => 'e.g. TAG-402';

  @override
  String get earTagTooLong => 'Ear tag ID cannot exceed 64 characters';

  @override
  String get knownDrugAllergies => 'Known Drug Allergies';

  @override
  String get knownDrugAllergiesHint =>
      'Separate with comma: Penicillin, NSAIDs';

  @override
  String get clinicalNotesInternal => 'Clinical Notes (Internal)';

  @override
  String get clinicalNotesHint =>
      'Confidential patient observations, temperament...';

  @override
  String get medicalHistory => 'Medical History & Clinical Background';

  @override
  String get medicalHistoryHint =>
      'Prior surgeries, chronic conditions, immunizations...';

  @override
  String get ownerClientDetails => 'Owner / Client Details';

  @override
  String get clientFullName => 'Owner / Contact Name *';

  @override
  String get clientNameHint => 'e.g. John Miller';

  @override
  String get pleaseEnterClientName => 'Please enter client name';

  @override
  String get clientNameTooLong => 'Client name cannot exceed 100 characters';

  @override
  String get primaryPhone => 'Primary Phone';

  @override
  String get primaryPhoneHint => 'e.g. +1 555-0199';

  @override
  String get pleaseEnterPhone => 'Please enter contact phone';

  @override
  String get clientAddress => 'Physical Address / Farm Location';

  @override
  String get clientAddressHint => 'e.g. Barn 4, North Pasture';

  @override
  String get savePatientAndSync => 'Save Patient & Enqueue Sync';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get updatePatientProfile => 'Save Changes';

  @override
  String get reviewHighlightedFields =>
      'Please review the highlighted fields before saving.';

  @override
  String get patientSavedSuccess => 'Patient registered successfully!';

  @override
  String get patientUpdatedSuccess => 'Patient profile updated successfully!';

  @override
  String get patientDetails => 'Patient Details';

  @override
  String get demographicsAndOwner => 'Demographics & Owner';

  @override
  String get detailsAndOwner => 'Details & Owner';

  @override
  String get vitalStats => 'Vital Statistics';

  @override
  String get deletePatient => 'Delete Patient';

  @override
  String get deletePatientConfirm =>
      'Are you sure you want to remove this patient? The medical history will be preserved offline and the deletion will sync with the clinic server.';

  @override
  String get noCasesRecordedYet => 'No clinical cases recorded yet';

  @override
  String get startEncounter => 'Start Encounter';

  @override
  String get allergiesAlert => 'High-Risk Allergies';

  @override
  String get noKnownAllergies => 'No known drug allergies reported.';

  @override
  String get clientContact => 'Client Contact';

  @override
  String get address => 'Address';

  @override
  String get historyAndBackground => 'History & Clinical Background';

  @override
  String get internalNotes => 'Internal Clinical Notes';

  @override
  String get searchCasesHint => 'Search cases, complaints, patients...';

  @override
  String get activeCases => 'Active Cases';

  @override
  String get caseDetails => 'Case Details';

  @override
  String get visitsTimeline => 'Visits Timeline';

  @override
  String get chiefComplaint => 'Chief Complaint';

  @override
  String get provisionalDiagnosis => 'Provisional Diagnosis';

  @override
  String get finalDiagnosis => 'Final Diagnosis';

  @override
  String get triagePriority => 'Triage Priority';

  @override
  String get status => 'Status';

  @override
  String get editDiagnoses => 'Edit Diagnoses';

  @override
  String get closeCase => 'Close Case';

  @override
  String get reopenCase => 'Reopen Case';

  @override
  String get caseClosedNotice => 'Case marked as closed.';

  @override
  String get caseReopenedNotice => 'Case reopened.';

  @override
  String get visitDetails => 'Visit Details';

  @override
  String get soapClinicalNotes => 'SOAP Clinical Notes';

  @override
  String get administeredMedications => 'Administered Medications';

  @override
  String get diagnosticMedia => 'Diagnostic Media';

  @override
  String get administerMedication => 'Administer Medication';

  @override
  String get uploadDiagnosticMedia => 'Upload Diagnostic Media';

  @override
  String get noSoapNotesRecorded =>
      'No SOAP notes recorded for this visit yet.';

  @override
  String get noMedicationsAdministered => 'No medications administered yet.';

  @override
  String get noMediaAttached => 'No diagnostic images attached yet.';

  @override
  String get signVisitNotice =>
      'Once signed and locked, clinical exam findings cannot be altered.';

  @override
  String get signInToClinic => 'Sign In to Your Clinic';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get signIn => 'Sign In';

  @override
  String get clinicalSecurityNotice =>
      'Secured enterprise veterinary system. All clinical entries are cryptographically stamped.';

  @override
  String get staffDirectory => 'Staff Directory';

  @override
  String get addStaffMember => 'Add Staff Member';

  @override
  String get roleDoctor => 'Doctor / Veterinarian';

  @override
  String get roleTechnician => 'Veterinary Technician';

  @override
  String get roleAdmin => 'Clinic Administrator';

  @override
  String get roleReceptionist => 'Receptionist';

  @override
  String get manageClinicStaff => 'Manage Clinic Staff';

  @override
  String get practitionerNotFound => 'Practitioner profile not found';

  @override
  String get practitionerNotFoundDesc =>
      'The requested staff credentials could not be loaded.';

  @override
  String get activeStaff => 'Active Staff';

  @override
  String get suspended => 'Suspended';

  @override
  String get clinicalPractice => 'Clinical Practice';

  @override
  String get assignedPractice => 'Assigned Practice';

  @override
  String get switchClinicalPractice => 'Switch Clinical Practice';

  @override
  String get onDutyAvailability => 'On-Duty Availability';

  @override
  String get availableForTriage => 'Available for consultations & triage';

  @override
  String get unavailableForTriage => 'Off-duty / Not accepting new cases';

  @override
  String get clinicalWorkload => 'Clinical Workload';

  @override
  String get activeCasesCount => 'Active Cases';

  @override
  String get deaWitness => 'DEA Witness';

  @override
  String get authorized => 'Authorized';

  @override
  String get notApplicable => 'N/A';

  @override
  String get credentialsAndLicensure => 'Credentials & Licensure';

  @override
  String get licenseNumber => 'License Number';

  @override
  String get notOnFile => 'Not on file';

  @override
  String get deaRegistration => 'DEA Registration';

  @override
  String get clinicEmail => 'Clinic Email';

  @override
  String get directPhone => 'Direct Phone';

  @override
  String get biographyAndExperience => 'Biography & Experience';

  @override
  String get clinicalAuthorizations => 'Clinical Authorizations';

  @override
  String get prescribeRx => 'Prescribe Rx';

  @override
  String get controlledSubstances => 'Controlled Substances';

  @override
  String get surgeryClearance => 'Surgery Clearance';

  @override
  String get staffManagement => 'Staff Management';

  @override
  String get billingAndInvoicing => 'Billing & Invoicing';

  @override
  String get ownerDashboard => 'Owner Dashboard';

  @override
  String get legalAndPrivacy => 'Legal & Account Privacy';

  @override
  String get medicalAndLegalDisclaimer => 'Medical & Legal Disclaimer';

  @override
  String get medicalDisclaimerNotice =>
      'Guideline 1.4.1 & Veterinary Regulatory Notice';

  @override
  String get deletePractitionerAccount => 'Delete Practitioner Account';

  @override
  String get deleteAccountNotice =>
      'Permanently remove login credentials and data';

  @override
  String get manageClinicStaffDirectory => 'Manage Clinic Staff Directory';

  @override
  String get clinicStaffDirectory => 'Clinic Staff Directory';

  @override
  String get searchStaffHint => 'Search by name, role, email, or specialty...';

  @override
  String get allRoles => 'All Roles';

  @override
  String get allStaff => 'All Staff';

  @override
  String get roleVeterinarian => 'Veterinarians';

  @override
  String get headVets => 'Head Vets';

  @override
  String get fieldVets => 'Field Vets';

  @override
  String get vetTechs => 'Vet Techs';

  @override
  String get assistants => 'Assistants';

  @override
  String get receptionists => 'Receptionists';

  @override
  String get roleTech => 'Tech';

  @override
  String get roleReceptionistShort => 'Receptionist';

  @override
  String get roleAdminShort => 'Admin';

  @override
  String get roleIntern => 'Intern';

  @override
  String get noStaffFound => 'No staff members found';

  @override
  String get registerNewStaff => 'Register New Staff Member';

  @override
  String get editStaffMember => 'Edit Staff Member';

  @override
  String get fullName => 'Full Name';

  @override
  String get witnessPin => 'Witness PIN (4-Digits)';

  @override
  String get jobTitle => 'Job Title';

  @override
  String get specialty => 'Specialty';

  @override
  String get saveStaffMember => 'Save Staff Member';

  @override
  String get registerStaff => 'Register Staff';

  @override
  String get deleteStaffConfirm =>
      'Are you sure you want to delete this staff member?';

  @override
  String get triageSeverityLevel => 'Triage Severity Level';

  @override
  String get encounterStatus => 'Encounter Status';

  @override
  String get openStatus => 'Open';

  @override
  String get inProgressStatus => 'In Progress';

  @override
  String get underObservationStatus => 'Under Observation';

  @override
  String get closedStatus => 'Closed';

  @override
  String get clinicalVisitsAndEncounters => 'Clinical Visits & Encounters';

  @override
  String get noVisitsRecordedYet => 'No Visits Recorded Yet';

  @override
  String get noVisitsRecordedDesc =>
      'Tap below to open the first clinical visit encounter for recording SOAP examination findings, diagnostic images, medication doses, and addenda.';

  @override
  String get openInitialConsultation => 'Open Initial Consultation Visit';

  @override
  String get editChiefComplaint => 'Edit Chief Complaint';

  @override
  String get enterChiefComplaintHint => 'Enter chief complaint...';

  @override
  String get diagnosesAndHypotheses => 'Diagnoses & Hypotheses';

  @override
  String get updateDiagnoses => 'Update Diagnoses';

  @override
  String get noneEstablishedYet => 'None established yet';

  @override
  String get pendingInvestigation => 'Pending investigation/response';

  @override
  String get editVisit => 'Edit Visit';

  @override
  String get editVisitDetails => 'Edit Visit Details';

  @override
  String get visitTitle => 'Visit Title';

  @override
  String get visitType => 'Visit Type';

  @override
  String get consultation => 'Consultation';

  @override
  String get followUp => 'Follow-up';

  @override
  String get emergency => 'Emergency';

  @override
  String get surgeryRecheck => 'Surgery Re-check';

  @override
  String get routineCheckup => 'Routine Checkup';

  @override
  String get locked => 'LOCKED';

  @override
  String get active => 'Active';

  @override
  String get activeBadge => 'ACTIVE';

  @override
  String get encounterDate => 'Encounter Date';

  @override
  String get attendingClinician => 'Attending';

  @override
  String get signedAndFinalized => 'Signed & Finalized';

  @override
  String get editSoapExam => 'Edit SOAP Exam';

  @override
  String get administerDose => 'Administer Dose';

  @override
  String get signAndLockVisit => 'Sign & Lock Visit Record';

  @override
  String get soapPhysicalExam => 'SOAP Physical Examination';

  @override
  String get noSoapExamRecordedYet => 'No SOAP Exam Recorded Yet';

  @override
  String get noSoapExamDesc =>
      'Tap \"Record SOAP Exam\" above to document vitals, subjective observations, assessment, and treatment plan.';

  @override
  String get immutableAddenda => 'Immutable Addenda';

  @override
  String get noAddendaSigned => 'No addendums appended to this signed record.';

  @override
  String get addendaCanBeAppendedOnceSigned =>
      'Addendums can be appended once the encounter is signed.';

  @override
  String get startNewVisitEncounter => 'Start New Visit Encounter';

  @override
  String get encounterType => 'Encounter Type';

  @override
  String get visitTitleOrPurpose => 'Visit Title / Purpose';

  @override
  String get beginVisitEncounter => 'Begin Visit Encounter';

  @override
  String get pleaseEnterVisitTitle => 'Please enter a visit title';

  @override
  String get pleaseEnterVetName => 'Please enter attending clinician name';

  @override
  String get saveAndSignSoapNote => 'Save & Sign SOAP Note';

  @override
  String get prescribeMedication => 'Prescribe Medication / Treatment';

  @override
  String get selectMedicine => 'Select Medicine';

  @override
  String get additionalClinicalOrders =>
      'Additional Clinical Orders & Instructions';

  @override
  String get appendClinicalAddendum => 'Append Clinical Addendum';

  @override
  String get immutableMedicalRecord => 'IMMUTABLE MEDICAL RECORD';

  @override
  String get addendaNotice =>
      'Addenda are append-only. Once signed and committed, this entry cannot be altered or deleted.';

  @override
  String get signingVeterinarian => 'Signing Veterinarian';

  @override
  String get addendumObservations => 'Addendum Clinical Observations & Notes';

  @override
  String get certifyAddendum =>
      'I certify that this addendum is medically accurate and represents legal clinical documentation.';

  @override
  String get signAndCommitAddendum => 'Sign & Commit Addendum';

  @override
  String get administerMedicationImmediate => 'Administer Medication';

  @override
  String get immediateDoseAndStock =>
      'Case Encounter • Immediate Dose & Stock Deduction';

  @override
  String get dosageQuantity => 'Dosage Quantity';

  @override
  String get routeOfAdministration => 'Route of Administration';

  @override
  String get controlledSubstanceWitnessNotice =>
      'Controlled Substance: DEA witness PIN confirmation will be required.';

  @override
  String get confirmAndAdministerDose => 'Confirm & Administer Dose';

  @override
  String get professionalVeterinaryOnly => 'Professional Veterinary Use Only';

  @override
  String get professionalVeterinaryDesc =>
      'VetManager Mobile is designed strictly for licensed veterinarians, credentialed veterinary technicians, and authorized clinical staff. It is an enterprise practice management and medical charting platform and is NOT intended for animal owner self-diagnosis or non-professional clinical administration.';

  @override
  String get auxiliaryDecisionSupport =>
      'Auxiliary Decision Support & Independent Judgment';

  @override
  String get auxiliaryDecisionDesc =>
      'All calculators, triage priority indicators, radiograph viewer filters, and clinical templates provided within this application are auxiliary decision-support tools. They DO NOT replace, supersede, or override independent professional veterinary clinical judgment, comprehensive physical examination, or diagnostic laboratory testing.';

  @override
  String get dosageResponsibility =>
      'Dosage Calculation & Pharmacological Responsibility';

  @override
  String get dosageResponsibilityDesc =>
      'Before administering any medication, anesthetic agent, fluid therapy, or controlled substance, the attending licensed veterinarian is solely responsible for verifying the patient weight, drug concentration, dosage rate, and potential contraindications. Never rely solely on software calculations for patient therapy.';

  @override
  String get emergenciesNotice => 'Acute & Life-Threatening Emergencies';

  @override
  String get emergenciesDesc =>
      'In life-threatening situations, patient stabilization, immediate physical resuscitation, airway maintenance, and critical care protocols take precedence over digital documentation. Complete electronic charting only once the patient is hemodynamically stable.';

  @override
  String get recordRetentionCompliance =>
      'Statutory Record Retention & Compliance';

  @override
  String get recordRetentionDesc =>
      'Clinical progress notes, medical addenda, surgical consents, and pharmacy movement ledgers recorded in VetManager are immutable and append-only to satisfy regional veterinary statutory retention mandates and regulatory board compliance standards.';

  @override
  String get iAcknowledgeAndUnderstand => 'I Acknowledge & Understand';

  @override
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String get confirmDeletionMessage =>
      'Are you absolutely sure you want to permanently delete your practitioner account? All active sessions will be terminated immediately.';

  @override
  String get permanentlyDelete => 'Permanently Delete';

  @override
  String get accountDeletedSuccess =>
      'Your practitioner account has been deleted successfully.';

  @override
  String get deleteAccountWarningTitle => 'Irreversible Action';

  @override
  String get deleteAccountWarningDesc =>
      'Deleting your practitioner account will permanently revoke your access, invalidate all active sessions, and remove your credentials. Clinical medical records you authored will remain archived according to statutory compliance requirements.';

  @override
  String get deleteAccountCheckbox =>
      'I understand that this action is permanent and cannot be undone.';

  @override
  String get deleteAccountPasswordPrompt =>
      'Enter your current password to authorize deletion:';

  @override
  String get camel => 'Camel';

  @override
  String get addSpecies => 'Add Species';

  @override
  String get newSpecies => 'New Species';

  @override
  String get enterSpeciesName => 'Enter Species Name';

  @override
  String get speciesNameHint => 'e.g. Camel, Falcon, Rabbit...';

  @override
  String get speciesAddedSuccessfully => 'Species added successfully';
}
