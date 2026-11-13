// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مدير العيادة البيطرية';

  @override
  String get triageBoard => 'لوحة فرز الحالات';

  @override
  String get patients => 'سجل المرضى';

  @override
  String get clinicalCases => 'الحالات الطبية';

  @override
  String get pharmacy => 'الصيدلية والمخزون';

  @override
  String get settings => 'الإعدادات';

  @override
  String get createNewCase => 'إنشاء حالة جديدة';

  @override
  String get startNewVisit => 'بدء زيارة جديدة';

  @override
  String get recordSoapExam => 'تسجيل الفحص السريري (SOAP)';

  @override
  String get appendAddendum => 'إضافة ملحق للملف';

  @override
  String get signAndLock => 'توقيع وإقفال الزيارة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get confirm => 'تأكيد';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get close => 'إغلاق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get routine => 'عادية';

  @override
  String get urgent => 'عاجلة';

  @override
  String get critical => 'حرجة / طوارئ';

  @override
  String get criticalPriority => 'حرجة';

  @override
  String get urgentPriority => 'عاجلة';

  @override
  String get routinePriority => 'عادية';

  @override
  String get stable => 'مستقرة';

  @override
  String get observation => 'تحت الملاحظة';

  @override
  String get open => 'مفتوحة';

  @override
  String get closed => 'مغلقة';

  @override
  String get signed => 'موقعة ومقفلة';

  @override
  String get patientName => 'اسم الحيوان';

  @override
  String get species => 'الفصيلة';

  @override
  String get breed => 'السلالة';

  @override
  String get gender => 'النوع';

  @override
  String get age => 'العمر';

  @override
  String get weight => 'الوزن';

  @override
  String get microchip => 'الشريحة الإلكترونية';

  @override
  String get owner => 'المربي / المالك';

  @override
  String get phone => 'الهاتف';

  @override
  String get allergies => 'الحساسية';

  @override
  String get temperature => 'درجة الحرارة';

  @override
  String get heartRate => 'معدل ضربات القلب';

  @override
  String get respiratoryRate => 'معدل التنفس';

  @override
  String get mucousMembrane => 'الأغشية المخاطية';

  @override
  String get subjective => 'الفحص الذاتي (الشكوى والتاريخ المرضي)';

  @override
  String get objective => 'الفحص الموضوعي (الملاحظات السريرية)';

  @override
  String get assessment => 'التقييم والتشخيص';

  @override
  String get plan => 'خطة العلاج والأدوية';

  @override
  String get offlineMode => 'وضع عدم الاتصال';

  @override
  String get syncing => 'جارٍ المزامنة...';

  @override
  String get allChangesSynced => 'تمت مزامنة كافة التغييرات';

  @override
  String get syncFailed => 'فشلت المزامنة';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get medicalDisclaimer => 'إخلاء المسؤولية الطبية والقانونية';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get all => 'الكل';

  @override
  String get search => 'بحث';

  @override
  String get syncNow => 'مزامنة مع السحابة';

  @override
  String get syncingData => 'جارٍ مزامنة الحالات وسجلات المرضى...';

  @override
  String get triageCases => 'الحالات الطبية';

  @override
  String get practitionerProfile => 'الملف المهني للطبيب';

  @override
  String get newPatient => 'مريض جديد';

  @override
  String get patientsDirectory => 'المرضى والعملاء';

  @override
  String get activePatients => 'المرضى النشطون';

  @override
  String get offlineAnimalRegistry => 'سجل الحيوانات أوفلاين أولاً';

  @override
  String get searchPatientsHint => 'ابحث بالاسم، الشريحة، الرقم، السلالة...';

  @override
  String get noPatientsFound => 'لم يتم العثور على مرضى';

  @override
  String get noPatientsFoundDesc =>
      'لا توجد سجلات حيوانات تطابق معايير البحث الحالية.';

  @override
  String get noCasesFound => 'لا توجد حالات';

  @override
  String get noCasesFoundDesc =>
      'لا توجد حالات سريرية مسجلة لهذه الأولوية حالياً.';

  @override
  String get canine => 'كلاب';

  @override
  String get feline => 'قطط';

  @override
  String get equine => 'خيول';

  @override
  String get bovine => 'أبقار';

  @override
  String get ovine => 'أغنام';

  @override
  String get caprine => 'ماعز';

  @override
  String get avian => 'طيور';

  @override
  String get otherSpecies => 'أخرى';

  @override
  String get maleNeutered => 'ذكر (مخصي)';

  @override
  String get maleIntact => 'ذكر (غير مخصي)';

  @override
  String get femaleSpayed => 'أنثى (معقمة)';

  @override
  String get femaleIntact => 'أنثى (غير معقمة)';

  @override
  String get unknownGender => 'غير محدد';

  @override
  String get editPatientProfile => 'تعديل ملف المريض';

  @override
  String get registerPatient => 'تسجيل مريض جديد';

  @override
  String get patientIdentity => 'بيانات وهوية المريض';

  @override
  String get patientNameOrTag => 'اسم الحيوان / رقم الأذن';

  @override
  String get patientNameHint => 'مثال: بيلا أو TAG-104';

  @override
  String get pleaseEnterPatientName => 'يرجى إدخال اسم الحيوان أو رقم الأذن';

  @override
  String get patientNameTooLong => 'لا يمكن أن يتجاوز اسم المريض 100 حرف';

  @override
  String get breedHint => 'مثال: جيرمان شيبرد، هولشتاين، بلدي';

  @override
  String get breedTooLong => 'لا يمكن أن تتجاوز السلالة 100 حرف';

  @override
  String get genderAndReproductiveStatus => 'النوع والحالة التناسلية';

  @override
  String get ageYears => 'العمر (بالسنوات)';

  @override
  String get ageHint => 'مثال: 3';

  @override
  String get enterValidAge => 'أدخل عمراً صحيحاً (0-150)';

  @override
  String get weightKg => 'الوزن (كجم)';

  @override
  String get weightHint => 'مثال: 12.5';

  @override
  String get enterValidWeight => 'أدخل وزناً صحيحاً بالكيلوجرام';

  @override
  String get ageIsEstimated => 'العمر تقديري / تقريبي';

  @override
  String get identificationAndMedical => 'التعريف والبيانات الطبية';

  @override
  String get rfidMicrochip => 'رقم الشريحة الإلكترونية (RFID)';

  @override
  String get rfidMicrochipHint => 'رقم الشريحة المكون من 15 رقماً ISO';

  @override
  String get microchipTooLong => 'لا يمكن أن يتجاوز رقم الشريحة 32 حرفاً';

  @override
  String get visualEarTagId => 'رقم القرط / بطاقة الأذن';

  @override
  String get visualEarTagHint => 'مثال: TAG-402';

  @override
  String get earTagTooLong => 'لا يمكن أن يتجاوز رقم القرط 64 حرفاً';

  @override
  String get knownDrugAllergies => 'الحساسية الدوائية المعروفة';

  @override
  String get knownDrugAllergiesHint =>
      'افصل بينها بفاصلة: بنسلين، مضادات التهاب';

  @override
  String get clinicalNotesInternal => 'ملاحظات سريرية (داخلية)';

  @override
  String get clinicalNotesHint => 'ملاحظات سريرية سرية، سلوك الحيوان...';

  @override
  String get medicalHistory => 'التاريخ المرضي والخلفية السريرية';

  @override
  String get medicalHistoryHint => 'عمليات سابقة، أمراض مزمنة، تطعيمات...';

  @override
  String get ownerClientDetails => 'بيانات المربي / المالك';

  @override
  String get clientFullName => 'اسم المالك / جهة الاتصال *';

  @override
  String get clientNameHint => 'مثال: أحمد محمد';

  @override
  String get pleaseEnterClientName => 'يرجى إدخال اسم المربي';

  @override
  String get clientNameTooLong => 'لا يمكن أن يتجاوز اسم العميل 100 حرف';

  @override
  String get primaryPhone => 'رقم الهاتف الأساسي';

  @override
  String get primaryPhoneHint => 'مثال: 0501234567';

  @override
  String get pleaseEnterPhone => 'يرجى إدخال رقم هاتف التواصل';

  @override
  String get clientAddress => 'العنوان الفعلي / موقع المزرعة';

  @override
  String get clientAddressHint => 'مثال: الحظيرة 4، المزرعة الشمالية';

  @override
  String get savePatientAndSync => 'حفظ المريض ومزامنة البيانات';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get updatePatientProfile => 'حفظ التغييرات';

  @override
  String get reviewHighlightedFields => 'يرجى مراجعة الحقول المحددة قبل الحفظ.';

  @override
  String get patientSavedSuccess => 'تم تسجيل المريض بنجاح!';

  @override
  String get patientUpdatedSuccess => 'تم تحديث بيانات المريض بنجاح!';

  @override
  String get patientDetails => 'تفاصيل المريض';

  @override
  String get demographicsAndOwner => 'البيانات والمالك';

  @override
  String get detailsAndOwner => 'البيانات والمالك';

  @override
  String get vitalStats => 'المؤشرات الحيوية';

  @override
  String get deletePatient => 'حذف المريض';

  @override
  String get deletePatientConfirm =>
      'هل أنت متأكد من رغبتك في حذف هذا المريض؟ سيتم الاحتفاظ بالسجل الطبي محلياً وستتم المزامنة مع الخادم.';

  @override
  String get noCasesRecordedYet => 'لا توجد حالات سريرية مسجلة بعد';

  @override
  String get startEncounter => 'بدء كشف طبي';

  @override
  String get allergiesAlert => 'تنبيه: حساسية عالية الخطورة';

  @override
  String get noKnownAllergies => 'لا توجد حساسية دوائية مسجلة.';

  @override
  String get clientContact => 'معلومات المربي';

  @override
  String get address => 'العنوان';

  @override
  String get historyAndBackground => 'التاريخ المرضي والفحوصات السابقة';

  @override
  String get internalNotes => 'الملاحظات السريرية الداخلية';

  @override
  String get searchCasesHint => 'ابحث في الحالات، الشكاوى، المرضى...';

  @override
  String get activeCases => 'الحالات النشطة';

  @override
  String get caseDetails => 'تفاصيل الحالة الطبية';

  @override
  String get visitsTimeline => 'الجدول الزمني للزيارات';

  @override
  String get chiefComplaint => 'الشكوى الرئيسية';

  @override
  String get provisionalDiagnosis => 'التشخيص المبدئي';

  @override
  String get finalDiagnosis => 'التشخيص النهائي';

  @override
  String get triagePriority => 'أولوية الفرز السريري';

  @override
  String get status => 'الحالة';

  @override
  String get editDiagnoses => 'تعديل التشخيص';

  @override
  String get closeCase => 'إغلاق الحالة';

  @override
  String get reopenCase => 'إعادة فتح الحالة';

  @override
  String get caseClosedNotice => 'تم إغلاق الحالة بنجاح.';

  @override
  String get caseReopenedNotice => 'تم إعادة فتح الحالة.';

  @override
  String get visitDetails => 'تفاصيل الزيارة';

  @override
  String get soapClinicalNotes => 'الملاحظات السريرية (SOAP)';

  @override
  String get administeredMedications => 'الأدوية المعطاة';

  @override
  String get diagnosticMedia => 'الصور والأشعة التشخيصية';

  @override
  String get administerMedication => 'إعطاء جرعة علاجية';

  @override
  String get uploadDiagnosticMedia => 'رفع وسائط تشخيصية';

  @override
  String get noSoapNotesRecorded => 'لم يتم تسجيل فحص SOAP لهذه الزيارة بعد.';

  @override
  String get noMedicationsAdministered => 'لم يتم إعطاء أي أدوية بعد.';

  @override
  String get noMediaAttached => 'لا توجد صور تشخيصية مرفقة بعد.';

  @override
  String get signVisitNotice =>
      'بمجرد التوقيع والإقفال، تصبح نتائج الفحص السريري وثيقة قانونية غير قابلة للتعديل.';

  @override
  String get signInToClinic => 'تسجيل الدخول إلى العيادة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get clinicalSecurityNotice =>
      'نظام بيطري مؤسسي مؤمن. تخضع جميع الإدخالات السريرية لتوثيق رقمي وتشفير كامل.';

  @override
  String get staffDirectory => 'دليل الكادر الطبي والإداري';

  @override
  String get addStaffMember => 'إضافة عضو كادر';

  @override
  String get roleDoctor => 'طبيب بيطري';

  @override
  String get roleTechnician => 'مساعد / فني بيطري';

  @override
  String get roleAdmin => 'مدير العيادة';

  @override
  String get roleReceptionist => 'موظف استقبال';

  @override
  String get manageClinicStaff => 'إدارة كادر العيادة';

  @override
  String get practitionerNotFound => 'لم يتم العثور على الملف المهني';

  @override
  String get practitionerNotFoundDesc =>
      'تعذر تحميل بيانات الاعتماد المطلوبة للكادر.';

  @override
  String get activeStaff => 'كادر نشط';

  @override
  String get suspended => 'موقوف';

  @override
  String get clinicalPractice => 'العيادة الطبية';

  @override
  String get assignedPractice => 'العيادة المحددة';

  @override
  String get switchClinicalPractice => 'تبديل العيادة الطبية';

  @override
  String get onDutyAvailability => 'حالة التواجد في النوبة';

  @override
  String get availableForTriage => 'متاح للاستشارات والفرز السريري';

  @override
  String get unavailableForTriage => 'خارج النوبة / لا يستقبل حالات جديدة';

  @override
  String get clinicalWorkload => 'عبء العمل السريري';

  @override
  String get activeCasesCount => 'الحالات النشطة';

  @override
  String get deaWitness => 'شاهد أدوية خاضعة للرقابة';

  @override
  String get authorized => 'مصرح له';

  @override
  String get notApplicable => 'غير متوفر';

  @override
  String get credentialsAndLicensure => 'الاعتمادات والتراخيص المهنية';

  @override
  String get licenseNumber => 'رقم الترخيص المهني';

  @override
  String get notOnFile => 'غير مسجل';

  @override
  String get deaRegistration => 'رقم تسجيل الرقابة الدوائية (DEA)';

  @override
  String get clinicEmail => 'البريد الإلكتروني للعيادة';

  @override
  String get directPhone => 'الهاتف المباشر';

  @override
  String get biographyAndExperience => 'السيرة المهنية والخبرات';

  @override
  String get clinicalAuthorizations => 'الصلاحيات السريرية';

  @override
  String get prescribeRx => 'وصف الأدوية';

  @override
  String get controlledSubstances => 'أدوية خاضعة للرقابة';

  @override
  String get surgeryClearance => 'إجراء العمليات الجراحية';

  @override
  String get staffManagement => 'إدارة الكادر';

  @override
  String get billingAndInvoicing => 'الفواتير والحسابات';

  @override
  String get ownerDashboard => 'لوحة تحكم المالك';

  @override
  String get legalAndPrivacy => 'الشؤون القانونية والخصوصية';

  @override
  String get medicalAndLegalDisclaimer => 'إخلاء المسؤولية الطبية والقانونية';

  @override
  String get medicalDisclaimerNotice =>
      'إشعار الامتثال التنظيمي البيطري والإرشادي';

  @override
  String get deletePractitionerAccount => 'حذف حساب الطبيب نهائياً';

  @override
  String get deleteAccountNotice => 'حذف بيانات الدخول والسجلات نهائياً';

  @override
  String get manageClinicStaffDirectory => 'إدارة دليل كادر العيادة';

  @override
  String get clinicStaffDirectory => 'دليل كادر العيادة';

  @override
  String get searchStaffHint => 'ابحث بالاسم، الدور، البريد، أو التخصص...';

  @override
  String get allRoles => 'كافة الأدوار';

  @override
  String get allStaff => 'كافة الكادر';

  @override
  String get roleVeterinarian => 'الأطباء البيطريون';

  @override
  String get headVets => 'كبار الأطباء';

  @override
  String get fieldVets => 'أطباء الميدان';

  @override
  String get vetTechs => 'الفنيون البيطريون';

  @override
  String get assistants => 'المساعدون';

  @override
  String get receptionists => 'موظفو الاستقبال';

  @override
  String get roleTech => 'فني';

  @override
  String get roleReceptionistShort => 'استقبال';

  @override
  String get roleAdminShort => 'إدارة';

  @override
  String get roleIntern => 'متدرب';

  @override
  String get noStaffFound => 'لم يتم العثور على أعضاء كادر';

  @override
  String get registerNewStaff => 'تسجيل فرد كادر جديد';

  @override
  String get editStaffMember => 'تعديل بيانات الكادر';

  @override
  String get fullName => 'الاسم بالكامل';

  @override
  String get witnessPin => 'رمز PIN للمصادقة (4 أرقام)';

  @override
  String get jobTitle => 'المسمى الوظيفي';

  @override
  String get specialty => 'التخصص الدقيق';

  @override
  String get saveStaffMember => 'حفظ بيانات الكادر';

  @override
  String get registerStaff => 'تسجيل العضو';

  @override
  String get deleteStaffConfirm =>
      'هل أنت متأكد من رغبتك في حذف هذا العضو من الكادر؟';

  @override
  String get triageSeverityLevel => 'مستوى فرز الحالة';

  @override
  String get encounterStatus => 'حالة الكشف';

  @override
  String get openStatus => 'مفتوحة';

  @override
  String get inProgressStatus => 'قيد المتابعة';

  @override
  String get underObservationStatus => 'تحت الملاحظة';

  @override
  String get closedStatus => 'مغلقة';

  @override
  String get clinicalVisitsAndEncounters => 'الزيارات والكشوفات السريرية';

  @override
  String get noVisitsRecordedYet => 'لا توجد زيارات مسجلة بعد';

  @override
  String get noVisitsRecordedDesc =>
      'اضغط أدناه لبدء أول كشف سريري لتسجيل فحص SOAP والصور التشخيصية والجرعات العلاجية.';

  @override
  String get openInitialConsultation => 'بدء كشف الاستشارة الأولي';

  @override
  String get editChiefComplaint => 'تعديل الشكوى الرئيسية';

  @override
  String get enterChiefComplaintHint => 'أدخل الشكوى الرئيسية...';

  @override
  String get diagnosesAndHypotheses => 'التشخيص والفرضيات السريرية';

  @override
  String get updateDiagnoses => 'تحديث التشخيص';

  @override
  String get noneEstablishedYet => 'لم يتم التحديد بعد';

  @override
  String get pendingInvestigation => 'قيد الفحص المخبري / الاستجابة';

  @override
  String get editVisit => 'تعديل الزيارة';

  @override
  String get editVisitDetails => 'تعديل تفاصيل الزيارة';

  @override
  String get visitTitle => 'عنوان الزيارة';

  @override
  String get visitType => 'نوع الزيارة';

  @override
  String get consultation => 'استشارة أولية';

  @override
  String get followUp => 'متابعة دورية';

  @override
  String get emergency => 'طوارئ';

  @override
  String get surgeryRecheck => 'متابعة بعد الجراحة';

  @override
  String get routineCheckup => 'فحص عام روتيني';

  @override
  String get locked => 'مقفل';

  @override
  String get active => 'نشط';

  @override
  String get activeBadge => 'نشط';

  @override
  String get encounterDate => 'تاريخ الكشف';

  @override
  String get attendingClinician => 'الطبيب المعالج';

  @override
  String get signedAndFinalized => 'تم التوقيع والاعتماد';

  @override
  String get editSoapExam => 'تعديل الفحص السريري (SOAP)';

  @override
  String get administerDose => 'إعطاء جرعة';

  @override
  String get signAndLockVisit => 'توقيع وإقفال سجل الزيارة';

  @override
  String get soapPhysicalExam => 'الفحص السريري الشامل (SOAP)';

  @override
  String get noSoapExamRecordedYet => 'لم يتم تسجيل فحص SOAP بعد';

  @override
  String get noSoapExamDesc =>
      'اضغط على \"تسجيل الفحص السريري\" أعلاه لتدوين العلامات الحيوية والملاحظات والتشخيص وخطة العلاج.';

  @override
  String get immutableAddenda => 'الملاحق السريرية الثابتة';

  @override
  String get noAddendaSigned => 'لا توجد ملاحق مضافة لهذا السجل الموقع.';

  @override
  String get addendaCanBeAppendedOnceSigned =>
      'يمكن إضافة الملاحق فور اعتماد السجل وتوقيعه.';

  @override
  String get startNewVisitEncounter => 'بدء كشف زيارة جديدة';

  @override
  String get encounterType => 'نوع الكشف';

  @override
  String get visitTitleOrPurpose => 'عنوان الزيارة / الغرض';

  @override
  String get beginVisitEncounter => 'بدء الزيارة';

  @override
  String get pleaseEnterVisitTitle => 'يرجى إدخال عنوان الزيارة';

  @override
  String get pleaseEnterVetName => 'يرجى إدخال اسم الطبيب المعالج';

  @override
  String get saveAndSignSoapNote => 'حفظ وتوقيع فحص SOAP';

  @override
  String get prescribeMedication => 'وصف دواء / خطة علاجية';

  @override
  String get selectMedicine => 'اختر الدواء';

  @override
  String get additionalClinicalOrders => 'تعليمات وأوامر سريرية إضافية';

  @override
  String get appendClinicalAddendum => 'إضافة ملحق سريري';

  @override
  String get immutableMedicalRecord => 'سجل طبي غير قابل للتعديل';

  @override
  String get addendaNotice =>
      'الملاحق السريرية للإضافة فقط؛ بمجرد الاعتماد والتوقيع لا يمكن حذفها أو تعديلها قانونياً.';

  @override
  String get signingVeterinarian => 'الطبيب الموقع';

  @override
  String get addendumObservations => 'ملاحظات الملحق السريري';

  @override
  String get certifyAddendum =>
      'أقر بأن هذا الملحق دقيق طبياً ويمثل توثيقاً سريرياً قانونياً.';

  @override
  String get signAndCommitAddendum => 'توقيع واعتماد الملحق';

  @override
  String get administerMedicationImmediate => 'إعطاء دواء';

  @override
  String get immediateDoseAndStock => 'كشف الحالة • جرعة فورية وخصم من المخزون';

  @override
  String get dosageQuantity => 'كمية الجرعة';

  @override
  String get routeOfAdministration => 'طريقة الإعطاء';

  @override
  String get controlledSubstanceWitnessNotice =>
      'دواء خاضع للرقابة: يلزم تأكيد رمز PIN للشاهد المعتمد.';

  @override
  String get confirmAndAdministerDose => 'تأكيد وإعطاء الجرعة';

  @override
  String get professionalVeterinaryOnly => 'للاستخدام البيطري المهني فقط';

  @override
  String get professionalVeterinaryDesc =>
      'تم تصميم تطبيق VetManager حصرياً للأطباء البيطريين المرخصين والفنيين المعتمدين والكادر السريري المصرح له. وهو منصة لإدارة العيادات والتوثيق الطبي ولا يُقصد به الاستخدام الذاتي من قبل المربين أو غير المتخصصين.';

  @override
  String get auxiliaryDecisionSupport =>
      'أدوات دعم القرار والتقدير السريري المستقل';

  @override
  String get auxiliaryDecisionDesc =>
      'تعتبر كافة الحاسبات ومؤشرات الفرز وفلاتر الأشعة والقوالب السريرية في هذا التطبيق أدوات مساعدة لدعم القرار، ولا تحل بأي حال محل الحكم السريري المهني المستقل أو الفحص الطبي الشامل أو التحاليل المخبرية.';

  @override
  String get dosageResponsibility => 'حساب الجرعات والمسؤولية الدوائية';

  @override
  String get dosageResponsibilityDesc =>
      'قبل إعطاء أي دواء أو مخدر أو محاليل أو مواد خاضعة للرقابة، يقع على عاتق الطبيب البيطري المعالج وحده التحقق من وزن المريض وتركيز الدواء ومعدل الجرعة وموانع الاستعمال. لا تعتمد حصراً على الحسابات البرمجية.';

  @override
  String get emergenciesNotice => 'حالات الطوارئ الحرجة والمهددة للحياة';

  @override
  String get emergenciesDesc =>
      'في حالات الطوارئ المهددة للحياة، تحظى الإسعافات وتثبيت حالة المريض والإنعاش بأولوية قصوى على التوثيق الإلكتروني. قم بتسجيل البيانات بعد استقرار العلامات الحيوية للحيوان.';

  @override
  String get recordRetentionCompliance =>
      'حفظ السجلات الطبية والامتثال القانوني';

  @override
  String get recordRetentionDesc =>
      'الملاحظات السريرية والملاحق والموافقات وسجلات حركة الصيدلية في VetManager غير قابلة للتغيير وتقتصر على الإضافة، تلبية للمتطلبات القانونية والتنظيمية لحفظ السجلات البيطرية.';

  @override
  String get iAcknowledgeAndUnderstand => 'أقر وأوافق على ما ورد';

  @override
  String get confirmDeletion => 'تأكيد الحذف';

  @override
  String get confirmDeletionMessage =>
      'هل أنت متأكد تماماً من رغبتك في حذف حساب الطبيب نهائياً؟ سيتم إنهاء كافة الجلسات النشطة فوراً.';

  @override
  String get permanentlyDelete => 'حذف الحساب نهائياً';

  @override
  String get accountDeletedSuccess => 'تم حذف حساب الطبيب بنجاح.';

  @override
  String get deleteAccountWarningTitle => 'إجراء لا يمكن التراجع عنه';

  @override
  String get deleteAccountWarningDesc =>
      'حذف حساب الطبيب سيؤدي لإلغاء وصولك نهائياً وإنهاء جلساتك وحذف بياناتك. السجلات الطبية السريرية المعتمدة ستبقى محفوظة تلبية للمتطلبات القانونية.';

  @override
  String get deleteAccountCheckbox =>
      'أدرك أن هذا الإجراء نهائي ولا يمكن التراجع عنه بأي حال.';

  @override
  String get deleteAccountPasswordPrompt =>
      'أدخل كلمة المرور الحالية لتأكيد الحذف:';
}
