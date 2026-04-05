import 'package:flutter/material.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/theme/app_elevation.dart';
import 'package:pointa_mobile/core/theme/app_radius.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';

/// Variantes visuelles de la carte
enum AppCardVariant {
  /// Carte plate avec bordure légère
  flat,
  
  /// Carte avec ombre légère
  elevated,
  
  /// Carte avec bordure seulement (pas de shadow)
  outlined,
  
  /// Carte sans bordure ni ombre (pour composition)
  ghost,
}

/// Design System - Composant Card Unifié
/// 
/// Conteneur de base pour regrouper du contenu.
/// Remplace les Container inline avec BoxDecoration.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.flat,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.width,
    this.height,
  });

  /// Contenu de la carte
  final Widget child;
  
  /// Style visuel
  final AppCardVariant variant;
  
  /// Padding interne (défaut: 16px)
  final EdgeInsetsGeometry? padding;
  
  /// Margin externe
  final EdgeInsetsGeometry? margin;
  
  /// Callback au tap (rend la carte interactive)
  final VoidCallback? onTap;
  
  /// Couleur de fond custom
  final Color? backgroundColor;
  
  /// Couleur de bordure custom
  final Color? borderColor;
  
  /// Radius custom (défaut: md = 16)
  final BorderRadius? borderRadius;
  
  /// Largeur fixe
  final double? width;
  
  /// Hauteur fixe
  final double? height;

  // ============================================================
  // FACTORY CONSTRUCTORS
  // ============================================================
  
  /// Carte plate standard
  const AppCard.flat({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.width,
    this.height,
  }) : variant = AppCardVariant.flat;
  
  /// Carte avec ombre
  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.width,
    this.height,
  }) : variant = AppCardVariant.elevated;
  
  /// Carte avec bordure visible
  const AppCard.outlined({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.width,
    this.height,
  }) : variant = AppCardVariant.outlined;

  EdgeInsetsGeometry get _defaultPadding => const EdgeInsets.all(AppSpacing.md);

  Color get _backgroundColor {
    return backgroundColor ?? AppColors.surface;
  }

  Border? get _border {
    return switch (variant) {
      AppCardVariant.flat => Border.all(color: borderColor ?? AppColors.neutral200),
      AppCardVariant.elevated => null,
      AppCardVariant.outlined => Border.all(
          color: borderColor ?? AppColors.neutral200,
          width: 1.5,
        ),
      AppCardVariant.ghost => null,
    };
  }

  List<BoxShadow>? get _shadows {
    return switch (variant) {
      AppCardVariant.flat => [AppElevation.subtle],
      AppCardVariant.elevated => AppElevation.cardShadows,
      AppCardVariant.outlined => null,
      AppCardVariant.ghost => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: _backgroundColor,
      borderRadius: borderRadius ?? AppRadius.radiusMd,
      border: _border,
      boxShadow: _shadows,
    );

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: decoration,
      padding: padding ?? _defaultPadding,
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? AppRadius.radiusMd,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Carte Hero avec gradient (pour status, pointage, etc.)
class AppHeroCard extends StatelessWidget {
  const AppHeroCard({
    super.key,
    required this.child,
    this.gradient,
    this.padding,
    this.borderRadius,
    this.withDecorations = true,
  });

  final Widget child;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool withDecorations;

  static const _defaultGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? _defaultGradient,
        borderRadius: borderRadius ?? AppRadius.radiusLg,
        boxShadow: AppElevation.heroShadows,
      ),
      child: Stack(
        children: [
          // Cercles décoratifs optionnels
          if (withDecorations) ...[
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
          ],
          // Contenu
          Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ],
      ),
    );
  }
}
