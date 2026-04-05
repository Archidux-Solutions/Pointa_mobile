import 'package:flutter/material.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';

/// Design System - Elevation & Shadow Tokens
/// 
/// Système d'ombres cohérent pour créer la hiérarchie visuelle.
/// Ombres subtiles et modernes, pas de drop shadows lourds.
abstract final class AppElevation {
  // ============================================================
  // NEUTRAL SHADOWS (pour surfaces générales)
  // ============================================================
  
  /// Ombre très subtile (éléments au repos)
  static const BoxShadow subtle = BoxShadow(
    color: Color(0x08000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  
  /// Ombre standard pour cards
  static const BoxShadow card = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
  
  /// Ombre pour éléments élevés (dropdowns, tooltips)
  static const BoxShadow elevated = BoxShadow(
    color: Color(0x10000000),
    blurRadius: 24,
    offset: Offset(0, 8),
  );
  
  /// Ombre pour hero cards et éléments proéminents
  static const BoxShadow hero = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 32,
    offset: Offset(0, 12),
  );
  
  /// Ombre pour modals et overlays
  static const BoxShadow modal = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 48,
    offset: Offset(0, 16),
  );

  // ============================================================
  // COLORED SHADOWS (pour CTAs et accents)
  // ============================================================
  
  /// Glow bleu pour boutons primaires
  static BoxShadow get primaryGlow => BoxShadow(
    color: AppColors.primary.withOpacity(0.25),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
  
  /// Glow vert pour boutons succès
  static BoxShadow get successGlow => BoxShadow(
    color: AppColors.success.withOpacity(0.25),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
  
  /// Glow rouge pour boutons danger
  static BoxShadow get dangerGlow => BoxShadow(
    color: AppColors.danger.withOpacity(0.20),
    blurRadius: 16,
    offset: const Offset(0, 6),
  );

  // ============================================================
  // SHADOW LISTS (pour BoxDecoration)
  // ============================================================
  
  /// Liste d'ombres pour cards standard
  static const List<BoxShadow> cardShadows = [card];
  
  /// Liste d'ombres pour hero cards
  static const List<BoxShadow> heroShadows = [hero];
  
  /// Liste d'ombres pour éléments élevés
  static const List<BoxShadow> elevatedShadows = [elevated];
  
  /// Liste d'ombres pour modals
  static const List<BoxShadow> modalShadows = [modal];
  
  /// Ombres pour bouton primaire (avec glow)
  static List<BoxShadow> get primaryButtonShadows => [primaryGlow];
  
  /// Ombres pour bouton succès (avec glow)
  static List<BoxShadow> get successButtonShadows => [successGlow];
}
