import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/storage/secure_storage_service.dart';
import 'database/app_database.dart';
import 'features/clients_patients/data/repositories/patient_repository_impl.dart';
import 'features/clinical_cases/data/repositories/case_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-Edge System Navigation for Android 15 & iOS
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final db = AppDatabase();
  final storageService = SecureStorageService();
  final patientRepo = PatientRepositoryImpl(
    dao: db.clientPatientDao,
    storageService: storageService,
  );
  final caseRepo = CaseRepositoryImpl(
    dao: db.clinicalCaseDao,
    storageService: storageService,
  );

  runApp(VetManagerApp(
    patientRepository: patientRepo,
    caseRepository: caseRepo,
  ));
}
