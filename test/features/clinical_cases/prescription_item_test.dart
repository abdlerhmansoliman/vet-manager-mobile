import 'package:flutter_test/flutter_test.dart';
import 'package:vet_manager_mobile/features/clinical_cases/domain/entities/prescription_item.dart';

void main() {
  group('PrescriptionItem Entity Tests', () {
    test('formatForPlan formats complete prescription line with route, freq, and instructions', () {
      const rx = PrescriptionItem(
        medicineName: 'Amoxicillin/Clavulanate',
        doseQuantity: '250',
        unit: 'mg',
        route: 'PO (Oral)',
        frequency: 'BID (Twice daily)',
        instructions: 'with food x 7 days',
      );

      final planLine = rx.formatForPlan();
      expect(planLine, '• Amoxicillin/Clavulanate: 250 mg PO (Oral) BID (Twice daily) (with food x 7 days)');
    });

    test('formatForPlan handles minimal prescription without optional instructions', () {
      const rx = PrescriptionItem(
        medicineName: 'Meloxicam',
        doseQuantity: '1.5',
        unit: 'ml',
        route: 'SQ',
        frequency: 'SID',
      );

      final planLine = rx.formatForPlan();
      expect(planLine, '• Meloxicam: 1.5 ml SQ SID');
    });

    test('toJson and fromJson serialize correctly', () {
      const original = PrescriptionItem(
        medicineName: 'Gabapentin',
        doseQuantity: '100',
        unit: 'mg',
        route: 'PO',
        frequency: 'TID',
        instructions: 'for neuropathic pain',
        productId: 'prod-uuid-123',
      );

      final json = original.toJson();
      final restored = PrescriptionItem.fromJson(json);

      expect(restored, equals(original));
      expect(restored.productId, 'prod-uuid-123');
    });

    test('copyWith creates modified clone', () {
      const original = PrescriptionItem(
        medicineName: 'Ketamine',
        doseQuantity: '0.5',
        unit: 'ml',
      );

      final updated = original.copyWith(doseQuantity: '0.8', unit: 'ml');
      expect(updated.doseQuantity, '0.8');
      expect(updated.medicineName, 'Ketamine');
      expect(updated.unit, 'ml');
    });
  });
}
