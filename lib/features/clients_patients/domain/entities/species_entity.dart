import 'package:equatable/equatable.dart';

/// Domain entity representing a biological animal species taxonomy.
class SpeciesEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String? icon;
  final bool isSystemDefault;
  final bool isActive;

  const SpeciesEntity({
    required this.id,
    required this.name,
    required this.code,
    this.icon,
    this.isSystemDefault = false,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        icon,
        isSystemDefault,
        isActive,
      ];
}
