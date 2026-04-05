import 'package:flutter/material.dart';

/// Design System - Border Radius Tokens
/// 
/// Échelle simplifiée à 4 niveaux pour la cohérence.
/// Éviter de créer de nouveaux radius, utiliser ces tokens.
abstract final class AppRadius {
  // ============================================================
  // BASE SCALE
  // ============================================================
  
  /// 8px - Petits éléments (chips, badges, inputs compacts)
  static const double xs = 8;
  
  /// 12px - Éléments standards (inputs, boutons, list items)
  static const double sm = 12;
  
  /// 16px - Cards, bottom sheets
  static const double md = 16;
  
  /// 24px - Hero cards, modals, grandes surfaces
  static const double lg = 24;
  
  /// 999px - Pills, avatars, éléments circulaires
  static const double full = 999;

  // ============================================================
  // BORDER RADIUS PRESETS (pour BoxDecoration)
  // ============================================================
  
  /// BorderRadius 8px
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));
  
  /// BorderRadius 12px
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  
  /// BorderRadius 16px
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  
  /// BorderRadius 24px
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  
  /// BorderRadius circulaire
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));

  // ============================================================
  // TOP ONLY (pour bottom sheets, modals)
  // ============================================================
  
  /// BorderRadius 16px en haut seulement
  static const BorderRadius topMd = BorderRadius.vertical(
    top: Radius.circular(md),
  );
  
  /// BorderRadius 24px en haut seulement
  static const BorderRadius topLg = BorderRadius.vertical(
    top: Radius.circular(lg),
  );
}
