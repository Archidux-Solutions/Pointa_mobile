import 'package:flutter/material.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';

/// Design System - Typography Tokens
/// 
/// Hiérarchie typographique complète pour Pointa Mobile.
/// Basée sur une échelle cohérente avec des usages clairs.
abstract final class AppTypography {
  // Police système par défaut (SF Pro sur iOS, Roboto sur Android)
  // Pour une police custom, décommenter et configurer dans pubspec.yaml
  // static const String _fontFamily = 'Inter';
  
  /// Génère le TextTheme complet pour l'application
  static TextTheme textTheme() {
    return const TextTheme(
      // ============================================================
      // DISPLAY - Grandes valeurs numériques (KPIs, timer)
      // ============================================================
      
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.1,
        color: AppColors.neutral900,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.15,
        color: AppColors.neutral900,
      ),
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: AppColors.neutral900,
      ),

      // ============================================================
      // HEADLINES - Titres d'écrans et sections majeures
      // ============================================================
      
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: AppColors.neutral900,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.25,
        color: AppColors.neutral900,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: AppColors.neutral900,
      ),

      // ============================================================
      // TITLES - Titres de cards, rows, éléments de liste
      // ============================================================
      
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: AppColors.neutral900,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.35,
        color: AppColors.neutral700,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: AppColors.neutral700,
      ),

      // ============================================================
      // BODY - Contenu textuel principal
      // ============================================================
      
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: AppColors.neutral700,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.45,
        color: AppColors.neutral500,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.4,
        color: AppColors.neutral500,
      ),

      // ============================================================
      // LABELS - Boutons, badges, tags, captions
      // ============================================================
      
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
        color: AppColors.neutral900,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.35,
        color: AppColors.neutral700,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.3,
        color: AppColors.neutral500,
      ),
    );
  }
}
