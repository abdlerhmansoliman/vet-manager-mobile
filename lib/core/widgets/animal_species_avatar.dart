import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Cheerful circular avatar displaying appropriate clinical species iconography.
class AnimalSpeciesAvatar extends StatelessWidget {
  final String species;
  final double radius;

  const AnimalSpeciesAvatar({
    super.key,
    required this.species,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, bgColor, iconColor) = _getSpeciesAssets(species);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderWarm, width: 1.5),
      ),
      child: Center(
        child: Icon(
          icon,
          size: radius * 1.1,
          color: iconColor,
        ),
      ),
    );
  }

  (IconData, Color, Color) _getSpeciesAssets(String speciesName) {
    final normalized = speciesName.toLowerCase().trim();
    if (normalized.contains('canine') || normalized.contains('dog')) {
      return (Icons.pets_rounded, AppColors.primaryEmeraldLight, AppColors.primaryEmeraldDark);
    } else if (normalized.contains('feline') || normalized.contains('cat')) {
      return (Icons.cruelty_free_rounded, const Color(0xFFEDE9FE), const Color(0xFF6D28D9));
    } else if (normalized.contains('equine') || normalized.contains('horse')) {
      return (Icons.bedroom_baby_rounded, AppColors.badgeObsAmber, AppColors.badgeObsAmberText);
    } else if (normalized.contains('bovine') || normalized.contains('cow') || normalized.contains('cattle')) {
      return (Icons.grass_rounded, const Color(0xFFDCFCE7), const Color(0xFF15803D));
    } else if (normalized.contains('avian') || normalized.contains('bird')) {
      return (Icons.flutter_dash_rounded, const Color(0xFFE0F2FE), const Color(0xFF0369A1));
    } else {
      return (Icons.favorite_rounded, AppColors.secondaryCoralLight, AppColors.secondaryCoral);
    }
  }
}
