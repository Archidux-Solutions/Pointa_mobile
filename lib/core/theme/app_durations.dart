/// Design System - Animation Duration Tokens
/// 
/// Durées standardisées pour toutes les animations.
/// Cohérence du rythme et de la fluidité perçue.
abstract final class AppDurations {
  // ============================================================
  // BASE DURATIONS
  // ============================================================
  
  /// 100ms - Micro-interactions (ripple, tap feedback)
  static const Duration instant = Duration(milliseconds: 100);
  
  /// 150ms - Transitions rapides (hover, focus)
  static const Duration fast = Duration(milliseconds: 150);
  
  /// 200ms - Transitions standard (fade, scale léger)
  static const Duration normal = Duration(milliseconds: 200);
  
  /// 300ms - Transitions moyennes (slide, expand)
  static const Duration medium = Duration(milliseconds: 300);
  
  /// 400ms - Transitions complexes (page transitions)
  static const Duration slow = Duration(milliseconds: 400);
  
  /// 600ms - Animations élaborées (success feedback)
  static const Duration elaborate = Duration(milliseconds: 600);
  
  /// 800ms - Animations longues (onboarding, celebration)
  static const Duration long = Duration(milliseconds: 800);

  // ============================================================
  // SEMANTIC DURATIONS
  // ============================================================
  
  /// Durée du feedback de tap sur bouton
  static const Duration buttonTap = fast;
  
  /// Durée de transition entre pages
  static const Duration pageTransition = medium;
  
  /// Durée d'apparition des cards (stagger)
  static const Duration cardAppear = normal;
  
  /// Durée de l'animation de succès pointage
  static const Duration attendanceSuccess = elaborate;
  
  /// Durée d'affichage du toast/snackbar
  static const Duration snackbarDisplay = Duration(seconds: 3);
  
  /// Durée de l'animation de chargement (pulse)
  static const Duration loadingPulse = Duration(milliseconds: 1500);
  
  /// Délai avant auto-dismiss du success overlay
  static const Duration successOverlayDelay = Duration(milliseconds: 1800);

  // ============================================================
  // STAGGER DELAYS (pour animations séquentielles)
  // ============================================================
  
  /// Délai entre chaque élément d'une liste animée
  static const Duration staggerDelay = Duration(milliseconds: 50);
  
  /// Délai initial avant le début du stagger
  static const Duration staggerInitial = Duration(milliseconds: 100);
}
