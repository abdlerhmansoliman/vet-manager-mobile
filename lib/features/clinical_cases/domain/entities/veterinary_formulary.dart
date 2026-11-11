/// Curated veterinary pharmaceutical reference and clinical dosing options.
class VeterinaryMedicationRef {
  final String name;
  final String category;
  final String defaultUnit;
  final String defaultRoute;
  final String defaultFrequency;
  final bool isControlled;

  const VeterinaryMedicationRef({
    required this.name,
    required this.category,
    this.defaultUnit = 'ml',
    this.defaultRoute = 'PO',
    this.defaultFrequency = 'BID',
    this.isControlled = false,
  });
}

class VeterinaryFormulary {
  static const List<String> standardUnits = [
    'ml',
    'mg',
    'tablet',
    'capsule',
    'drop',
    'vial',
    'bolus',
    'IU',
    'g',
    'mcg',
  ];

  static const List<String> standardRoutes = [
    'PO (Oral)',
    'SQ (Subcutaneous)',
    'IV (Intravenous)',
    'IM (Intramuscular)',
    'Topical',
    'Ophthalmic (Eye)',
    'Otic (Ear)',
    'Inhalation',
  ];

  static const List<String> standardFrequencies = [
    'SID (Once daily)',
    'BID (Twice daily)',
    'TID (Three times daily)',
    'QID (Four times daily)',
    'q8h (Every 8h)',
    'q12h (Every 12h)',
    'q24h (Every 24h)',
    'PRN (As needed)',
    'Stat (Immediately)',
  ];

  static const List<VeterinaryMedicationRef> commonMedications = [
    // Antibiotics & Antimicrobials
    VeterinaryMedicationRef(
      name: 'Amoxicillin/Clavulanate (Clavamox)',
      category: 'Antibiotic',
      defaultUnit: 'mg',
      defaultRoute: 'PO (Oral)',
      defaultFrequency: 'BID (Twice daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Enrofloxacin (Baytril)',
      category: 'Antibiotic',
      defaultUnit: 'ml',
      defaultRoute: 'SQ (Subcutaneous)',
      defaultFrequency: 'SID (Once daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Metronidazole',
      category: 'Antibiotic / Antiprotozoal',
      defaultUnit: 'mg',
      defaultRoute: 'PO (Oral)',
      defaultFrequency: 'BID (Twice daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Doxycycline',
      category: 'Antibiotic',
      defaultUnit: 'mg',
      defaultRoute: 'PO (Oral)',
      defaultFrequency: 'BID (Twice daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Cefazolin',
      category: 'Antibiotic',
      defaultUnit: 'mg',
      defaultRoute: 'IV (Intravenous)',
      defaultFrequency: 'TID (Three times daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Cephalexin',
      category: 'Antibiotic',
      defaultUnit: 'mg',
      defaultRoute: 'PO (Oral)',
      defaultFrequency: 'BID (Twice daily)',
    ),

    // NSAIDs & Analgesics
    VeterinaryMedicationRef(
      name: 'Meloxicam (Metacam 1.5mg/ml)',
      category: 'NSAID / Analgesic',
      defaultUnit: 'ml',
      defaultRoute: 'SQ (Subcutaneous)',
      defaultFrequency: 'SID (Once daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Carprofen (Rimadyl)',
      category: 'NSAID / Analgesic',
      defaultUnit: 'mg',
      defaultRoute: 'PO (Oral)',
      defaultFrequency: 'BID (Twice daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Gabapentin',
      category: 'Neuropathic Pain / Sedative',
      defaultUnit: 'mg',
      defaultRoute: 'PO (Oral)',
      defaultFrequency: 'BID (Twice daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Tramadol',
      category: 'Analgesic',
      defaultUnit: 'mg',
      defaultRoute: 'PO (Oral)',
      defaultFrequency: 'BID (Twice daily)',
    ),

    // Antiemetics & Gastroprotectants
    VeterinaryMedicationRef(
      name: 'Maropitant (Cerenia 10mg/ml)',
      category: 'Antiemetic',
      defaultUnit: 'ml',
      defaultRoute: 'SQ (Subcutaneous)',
      defaultFrequency: 'SID (Once daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Famotidine',
      category: 'H2 Blocker / GI Protectant',
      defaultUnit: 'mg',
      defaultRoute: 'PO (Oral)',
      defaultFrequency: 'BID (Twice daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Omeprazole',
      category: 'Proton Pump Inhibitor',
      defaultUnit: 'mg',
      defaultRoute: 'PO (Oral)',
      defaultFrequency: 'SID (Once daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Ondansetron',
      category: 'Antiemetic',
      defaultUnit: 'ml',
      defaultRoute: 'IV (Intravenous)',
      defaultFrequency: 'BID (Twice daily)',
    ),

    // Corticosteroids
    VeterinaryMedicationRef(
      name: 'Prednisolone',
      category: 'Corticosteroid',
      defaultUnit: 'mg',
      defaultRoute: 'PO (Oral)',
      defaultFrequency: 'SID (Once daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Dexamethasone',
      category: 'Corticosteroid',
      defaultUnit: 'ml',
      defaultRoute: 'IV (Intravenous)',
      defaultFrequency: 'Stat (Immediately)',
    ),

    // Cardiovascular & Emergency
    VeterinaryMedicationRef(
      name: 'Furosemide (Salix 50mg/ml)',
      category: 'Loop Diuretic',
      defaultUnit: 'ml',
      defaultRoute: 'IV (Intravenous)',
      defaultFrequency: 'BID (Twice daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Pimobendan (Vetmedin)',
      category: 'Inodilator',
      defaultUnit: 'mg',
      defaultRoute: 'PO (Oral)',
      defaultFrequency: 'BID (Twice daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Atropine (0.54mg/ml)',
      category: 'Anticholinergic / Emergency',
      defaultUnit: 'ml',
      defaultRoute: 'IV (Intravenous)',
      defaultFrequency: 'Stat (Immediately)',
    ),
    VeterinaryMedicationRef(
      name: 'Epinephrine (1:1000)',
      category: 'Adrenergic / Emergency',
      defaultUnit: 'ml',
      defaultRoute: 'IV (Intravenous)',
      defaultFrequency: 'Stat (Immediately)',
    ),

    // Fluid Therapy
    VeterinaryMedicationRef(
      name: "Lactated Ringer's Solution (LRS)",
      category: 'IV Fluid Solution',
      defaultUnit: 'ml',
      defaultRoute: 'IV (Intravenous)',
      defaultFrequency: 'Stat (Immediately)',
    ),
    VeterinaryMedicationRef(
      name: '0.9% Normal Saline',
      category: 'IV Fluid Solution',
      defaultUnit: 'ml',
      defaultRoute: 'IV (Intravenous)',
      defaultFrequency: 'Stat (Immediately)',
    ),

    // Allergy & Dermatology
    VeterinaryMedicationRef(
      name: 'Apoquel (Oclacitinib)',
      category: 'JAK Inhibitor / Antipruritic',
      defaultUnit: 'tablet',
      defaultRoute: 'PO (Oral)',
      defaultFrequency: 'BID (Twice daily)',
    ),
    VeterinaryMedicationRef(
      name: 'Cytopoint (Lokivetmab)',
      category: 'Monoclonal Antibody',
      defaultUnit: 'vial',
      defaultRoute: 'SQ (Subcutaneous)',
      defaultFrequency: 'Stat (Immediately)',
    ),

    // Controlled Substances (DEA Schedules)
    VeterinaryMedicationRef(
      name: 'Ketamine (100mg/ml)',
      category: 'Dissociative Anesthetic (C-III)',
      defaultUnit: 'ml',
      defaultRoute: 'IV (Intravenous)',
      defaultFrequency: 'Stat (Immediately)',
      isControlled: true,
    ),
    VeterinaryMedicationRef(
      name: 'Butorphanol (10mg/ml)',
      category: 'Opioid Analgesic (C-IV)',
      defaultUnit: 'ml',
      defaultRoute: 'SQ (Subcutaneous)',
      defaultFrequency: 'PRN (As needed)',
      isControlled: true,
    ),
    VeterinaryMedicationRef(
      name: 'Diazepam (5mg/ml)',
      category: 'Benzodiazepine / Anticonvulsant (C-IV)',
      defaultUnit: 'ml',
      defaultRoute: 'IV (Intravenous)',
      defaultFrequency: 'Stat (Immediately)',
      isControlled: true,
    ),
    VeterinaryMedicationRef(
      name: 'Midazolam (5mg/ml)',
      category: 'Benzodiazepine (C-IV)',
      defaultUnit: 'ml',
      defaultRoute: 'IM (Intramuscular)',
      defaultFrequency: 'Stat (Immediately)',
      isControlled: true,
    ),
  ];

  /// Finds a matching medication or returns null.
  static VeterinaryMedicationRef? findByName(String name) {
    final query = name.trim().toLowerCase();
    for (final med in commonMedications) {
      if (med.name.toLowerCase().contains(query)) {
        return med;
      }
    }
    return null;
  }
}
