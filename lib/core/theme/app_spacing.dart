import 'package:flutter/material.dart';

/// Design System - Spacing Tokens
/// 
/// Système d'espacement basé sur une unité de 4px.
/// Utiliser ces tokens pour padding, margin, gaps.
abstract final class AppSpacing {
  // ============================================================
  // BASE SCALE (multiples de 4)
  // ============================================================
  
  /// 4px - Micro spacing (inline icons, dense lists)
  static const double xxs = 4;
  
  /// 8px - Tight spacing (between related elements)
  static const double xs = 8;
  
  /// 12px - Compact spacing (list items, form fields)
  static const double sm = 12;
  
  /// 16px - Default spacing (standard gaps)
  static const double md = 16;
  
  /// 20px - Comfortable spacing (card padding)
  static const double lg = 20;
  
  /// 24px - Relaxed spacing (section gaps)
  static const double xl = 24;
  
  /// 32px - Large spacing (major sections)
  static const double xxl = 32;
  
  /// 48px - Hero spacing (headers, CTAs)
  static const double xxxl = 48;

  // ============================================================
  // PAGE PADDING PRESETS
  // ============================================================
  
  /// Padding horizontal standard des pages
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 20);
  
  /// Padding complet pour les pages avec scroll
  static const EdgeInsets page = EdgeInsets.fromLTRB(20, 16, 20, 24);
  
  /// Padding pour les pages avec bottom nav (safe area)
  static const EdgeInsets pageWithNav = EdgeInsets.fromLTRB(20, 16, 20, 100);
  
  /// Padding pour le contenu dans les cards
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  
  /// Padding compact pour les cards denses
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(12);

  // ============================================================
  // GAP HELPERS
  // ============================================================
  
  /// SizedBox vertical de 4px
  static const SizedBox verticalXxs = SizedBox(height: xxs);
  
  /// SizedBox vertical de 8px
  static const SizedBox verticalXs = SizedBox(height: xs);
  
  /// SizedBox vertical de 12px
  static const SizedBox verticalSm = SizedBox(height: sm);
  
  /// SizedBox vertical de 16px
  static const SizedBox verticalMd = SizedBox(height: md);
  
  /// SizedBox vertical de 24px
  static const SizedBox verticalXl = SizedBox(height: xl);
  
  /// SizedBox vertical de 32px
  static const SizedBox verticalXxl = SizedBox(height: xxl);
  
  /// SizedBox horizontal de 8px
  static const SizedBox horizontalXs = SizedBox(width: xs);
  
  /// SizedBox horizontal de 12px
  static const SizedBox horizontalSm = SizedBox(width: sm);
  
  /// SizedBox horizontal de 16px
  static const SizedBox horizontalMd = SizedBox(width: md);
}
