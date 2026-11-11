import 'package:flutter_test/flutter_test.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/veterinary_formulary.dart';

void main() {
  group('VeterinaryFormulary Tests', () {
    test('contains comprehensive standard measurement units', () {
      expect(VeterinaryFormulary.standardUnits, containsAll(['ml', 'mg', 'tablet', 'capsule', 'drop', 'vial', 'bolus', 'IU']));
    });

    test('contains comprehensive standard administration routes', () {
      expect(VeterinaryFormulary.standardRoutes, contains('PO (Oral)'));
      expect(VeterinaryFormulary.standardRoutes, contains('SQ (Subcutaneous)'));
      expect(VeterinaryFormulary.standardRoutes, contains('IV (Intravenous)'));
      expect(VeterinaryFormulary.standardRoutes, contains('IM (Intramuscular)'));
    });

    test('commonMedications list includes antibiotics, NSAIDs, antiemetics, and controlled drugs', () {
      expect(VeterinaryFormulary.commonMedications.isNotEmpty, isTrue);

      final clavamox = VeterinaryFormulary.findByName('Clavamox');
      expect(clavamox, isNotNull);
      expect(clavamox!.defaultUnit, 'mg');
      expect(clavamox.category, 'Antibiotic');

      final metacam = VeterinaryFormulary.findByName('Meloxicam');
      expect(metacam, isNotNull);
      expect(metacam!.defaultUnit, 'ml');

      final ketamine = VeterinaryFormulary.findByName('Ketamine');
      expect(ketamine, isNotNull);
      expect(ketamine!.isControlled, isTrue);
      expect(ketamine.defaultUnit, 'ml');
    });

    test('findByName returns null for unknown medication', () {
      final unknown = VeterinaryFormulary.findByName('NonExistentDrug12345');
      expect(unknown, isNull);
    });
  });
}
