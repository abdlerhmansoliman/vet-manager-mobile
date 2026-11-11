import 'package:equatable/equatable.dart';

/// Represents a structured prescription / medication order in a clinical case or SOAP note.
class PrescriptionItem extends Equatable {
  final String medicineName;
  final String doseQuantity;
  final String unit;
  final String route;
  final String frequency;
  final String? instructions;
  final String? productId;

  const PrescriptionItem({
    required this.medicineName,
    required this.doseQuantity,
    required this.unit,
    this.route = 'PO',
    this.frequency = 'BID',
    this.instructions,
    this.productId,
  });

  /// Formats the prescription into standard clinical medical record notation.
  /// Example: "• Meloxicam: 1.5 ml SQ SID (with food)"
  String formatForPlan() {
    final buffer = StringBuffer('• $medicineName: $doseQuantity $unit');
    if (route.isNotEmpty) {
      buffer.write(' $route');
    }
    if (frequency.isNotEmpty) {
      buffer.write(' $frequency');
    }
    if (instructions != null && instructions!.trim().isNotEmpty) {
      buffer.write(' (${instructions!.trim()})');
    }
    return buffer.toString();
  }

  PrescriptionItem copyWith({
    String? medicineName,
    String? doseQuantity,
    String? unit,
    String? route,
    String? frequency,
    String? instructions,
    String? productId,
  }) {
    return PrescriptionItem(
      medicineName: medicineName ?? this.medicineName,
      doseQuantity: doseQuantity ?? this.doseQuantity,
      unit: unit ?? this.unit,
      route: route ?? this.route,
      frequency: frequency ?? this.frequency,
      instructions: instructions ?? this.instructions,
      productId: productId ?? this.productId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_name': medicineName,
      'dose_quantity': doseQuantity,
      'unit': unit,
      'route': route,
      'frequency': frequency,
      'instructions': instructions,
      'product_id': productId,
    };
  }

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      medicineName: json['medicine_name']?.toString() ?? '',
      doseQuantity: json['dose_quantity']?.toString() ?? '',
      unit: json['unit']?.toString() ?? 'ml',
      route: json['route']?.toString() ?? 'PO',
      frequency: json['frequency']?.toString() ?? 'BID',
      instructions: json['instructions']?.toString(),
      productId: json['product_id']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        medicineName,
        doseQuantity,
        unit,
        route,
        frequency,
        instructions,
        productId,
      ];
}
