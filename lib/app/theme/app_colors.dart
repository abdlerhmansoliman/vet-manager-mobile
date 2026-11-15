import 'package:flutter/material.dart';

/// Semantic Color Palette for VetManager Mobile Application.
///
/// Follows the Warm & Cheerful clinical design system, avoiding sterile
/// clinical whites while maintaining WCAG AAA contrast accessibility.
abstract final class AppColors {
  // --- Core Warm & Cheerful Palette ---
  /// Warm Cream Background (#FAF8F5) - Soft, inviting canvas
  static const Color backgroundCream = Color(0xFFFAF8F5);

  /// Pure Surface Container (#FFFFFF)
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  /// Fresh Emerald / Teal Primary (#0D9488) - Clinical authority & calmness
  static const Color primaryEmerald = Color(0xFF0D9488);

  /// Deep Emerald for active states and high-contrast text (#0F766E)
  static const Color primaryEmeraldDark = Color(0xFF0F766E);

  /// Light Emerald container / chip fill (#CCFBF1)
  static const Color primaryEmeraldLight = Color(0xFFCCFBF1);

  /// Warm Coral Secondary Accent (#FF7E67) - Friendly CTA & urgent badges
  static const Color secondaryCoral = Color(0xFFFF7E67);

  /// Soft Coral tint for subtle highlights (#FFE8E4)
  static const Color secondaryCoralLight = Color(0xFFFFE8E4);

  // --- Pastel Status Badges ---
  /// Stable Mint (#D1FAE5) - Normal vitals, discharged, sealed stock
  static const Color badgeStableMint = Color(0xFFD1FAE5);
  static const Color badgeStableMintText = Color(0xFF065F46);

  /// Observation Amber (#FEF3C7) - Inpatient monitoring, pending tests, open vials
  static const Color badgeObsAmber = Color(0xFFFEF3C7);
  static const Color badgeObsAmberText = Color(0xFF92400E);

  /// Critical Rose (#FFE4E6) - Emergency triage, critical status, drug waste
  static const Color badgeCriticalRose = Color(0xFFFFE4E6);
  static const Color badgeCriticalRoseText = Color(0xFF9F1239);

  // --- Typography & Neutral Slate ---
  /// High-contrast Charcoal (#1E293B) for body & headlines
  static const Color textCharcoal = Color(0xFF1E293B);

  /// Muted Slate (#64748B) for secondary labels and timestamps
  static const Color textMuted = Color(0xFF64748B);

  /// Light Slate (#94A3B8) for placeholder hints and disabled states
  static const Color textLight = Color(0xFF94A3B8);

  // --- Tonal Surface Containers (from Warm Clinical DESIGN.md) ---
  /// Surface Container Lowest (#FFFFFF) - Pure white card surface
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  /// Surface Container Low (#F5F3F0) - Soft ambient background for chips & inner sections
  static const Color surfaceContainerLow = Color(0xFFF5F3F0);

  /// Surface Container (#EFEEEB) - Standard grouped container surface
  static const Color surfaceContainer = Color(0xFFEFEEEB);

  /// Surface Container High (#EAE8E5) - Structural separator container
  static const Color surfaceContainerHigh = Color(0xFFEAE8E5);

  /// Surface Container Highest (#E4E2DF) - Highest contrast surface tier
  static const Color surfaceContainerHighest = Color(0xFFE4E2DF);

  /// Ambient warm card shadow: 0 4px 16px -2px rgba(120, 113, 108, 0.08)
  static const List<BoxShadow> warmAmbientShadow = [
    BoxShadow(
      color: Color(0x1478716C),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x0A78716C),
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: -1,
    ),
  ];

  // --- Borders, Dividers & Overlays ---
  /// Subtle Warm Border (#F1EDE4)
  static const Color borderWarm = Color(0xFFF1EDE4);

  /// Neutral Outline Border (#E2E8F0)
  static const Color borderSubtle = Color(0xFFE2E8F0);

  /// Backdrop Blur Dim Tint (Black with 25% opacity)
  static const Color backdropScrim = Color(0x40000000);

  // --- Dark Mode Inversions ---
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B);    // Slate 800
  static const Color darkBorder = Color(0xFF334155);     // Slate 700
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextMuted = Color(0xFF94A3B8);
}
