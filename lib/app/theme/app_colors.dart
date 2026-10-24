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
