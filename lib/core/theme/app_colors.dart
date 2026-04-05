import 'package:flutter/material.dart';

/// Design System - Color Tokens
/// 
/// Palette unifiée pour Pointa Mobile.
/// Utiliser ces tokens partout, jamais de couleurs hardcodées.
abstract final class AppColors {
  // ============================================================
  // PRIMARY SPECTRUM - Bleu Pointa
  // ============================================================
  
  /// Couleur principale de la marque
  static const Color primary = Color(0xFF2563EB);
  
  /// Variante claire pour hover/accent
  static const Color primaryLight = Color(0xFF3B82F6);
  
  /// Variante foncée pour pressed/active
  static const Color primaryDark = Color(0xFF1D4ED8);
  
  /// Background très léger teinté primary
  static const Color primarySoft = Color(0xFFEFF6FF);
  
  /// Cards et éléments avec accent primary
  static const Color primaryMuted = Color(0xFFDBEAFE);

  // ============================================================
  // SEMANTIC COLORS - États et feedback
  // ============================================================
  
  /// Succès, validation, check-in confirmé
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);
  static const Color successSoft = Color(0xFFD1FAE5);
  
  /// Avertissement, retard, attention requise
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFEF3C7);
  
  /// Erreur, danger, absence, hors zone
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerDark = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFEE2E2);

  // ============================================================
  // NEUTRAL SCALE - Textes, backgrounds, borders
  // ============================================================
  
  /// Background principal de l'app
  static const Color neutral50 = Color(0xFFF8FAFC);
  
  /// Background cards secondaires
  static const Color neutral100 = Color(0xFFF1F5F9);
  
  /// Borders, dividers
  static const Color neutral200 = Color(0xFFE2E8F0);
  
  /// Borders hover
  static const Color neutral300 = Color(0xFFCBD5E1);
  
  /// Placeholder text, icônes désactivées
  static const Color neutral400 = Color(0xFF94A3B8);
  
  /// Muted text, labels secondaires
  static const Color neutral500 = Color(0xFF64748B);
  
  /// Body text standard
  static const Color neutral700 = Color(0xFF334155);
  
  /// Headlines, texte important
  static const Color neutral900 = Color(0xFF0F172A);

  // ============================================================
  // SURFACE & ELEVATION
  // ============================================================
  
  /// Surface blanche pure (cards, modals)
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Surface légèrement élevée
  static const Color surfaceElevated = Color(0xFFFAFBFC);
  
  /// Overlay pour modals (4% black)
  static const Color overlay = Color(0x0A000000);
  
  /// Scrim pour bottom sheets (40% black)
  static const Color scrim = Color(0x66000000);

  // ============================================================
  // LEGACY ALIASES (pour compatibilité pendant migration)
  // ============================================================
  
  @Deprecated('Utiliser neutral50 à la place')
  static const Color background = neutral50;
  
  @Deprecated('Utiliser neutral900 à la place')
  static const Color onSurface = neutral900;
  
  @Deprecated('Utiliser neutral500 à la place')
  static const Color mutedText = neutral500;
  
  @Deprecated('Utiliser neutral200 à la place')
  static const Color border = neutral200;
  
  @Deprecated('Utiliser primarySoft à la place')
  static const Color softBlue = primarySoft;
  
  @Deprecated('Utiliser primaryLight à la place')
  static const Color secondary = primaryLight;
}
