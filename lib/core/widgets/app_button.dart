import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/theme/app_durations.dart';
import 'package:pointa_mobile/core/theme/app_elevation.dart';
import 'package:pointa_mobile/core/theme/app_radius.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';

/// Variantes de style du bouton
enum AppButtonVariant {
  /// Bouton principal avec background coloré
  primary,
  
  /// Bouton secondaire avec bordure
  secondary,
  
  /// Bouton tertiaire sans background ni bordure
  ghost,
  
  /// Bouton de danger (suppression, déconnexion)
  danger,
  
  /// Bouton succès (validation, confirmation)
  success,
}

/// Tailles disponibles pour le bouton
enum AppButtonSize {
  /// Petit bouton (40px height)
  sm,
  
  /// Bouton standard (52px height)
  md,
  
  /// Grand bouton (60px height)
  lg,
}

/// Design System - Composant Button Unifié
/// 
/// Remplace tous les boutons inline de l'app.
/// Supporte plusieurs variantes, tailles, icônes et états.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.withHaptic = true,
    this.withShadow = false,
  });
  
  /// Texte du bouton
  final String label;
  
  /// Callback au tap (null = disabled)
  final VoidCallback? onPressed;
  
  /// Variante visuelle
  final AppButtonVariant variant;
  
  /// Taille du bouton
  final AppButtonSize size;
  
  /// Icône à gauche du label
  final IconData? leadingIcon;
  
  /// Icône à droite du label
  final IconData? trailingIcon;
  
  /// Affiche un loader et désactive le bouton
  final bool isLoading;
  
  /// Prend toute la largeur disponible
  final bool isFullWidth;
  
  /// Active le feedback haptique au tap
  final bool withHaptic;
  
  /// Affiche une ombre colorée (pour CTA principal)
  final bool withShadow;

  // ============================================================
  // FACTORY CONSTRUCTORS pour usage simplifié
  // ============================================================
  
  /// Bouton primaire (CTA principal)
  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.withHaptic = true,
    this.withShadow = true,
  }) : variant = AppButtonVariant.primary;
  
  /// Bouton secondaire (action alternative)
  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.withHaptic = true,
  }) : variant = AppButtonVariant.secondary,
       withShadow = false;
  
  /// Bouton ghost (action tertiaire)
  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.withHaptic = false,
  }) : variant = AppButtonVariant.ghost,
       withShadow = false;
  
  /// Bouton danger (suppression, etc.)
  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.withHaptic = true,
  }) : variant = AppButtonVariant.danger,
       withShadow = false;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.buttonTap,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  double get _height {
    return switch (widget.size) {
      AppButtonSize.sm => 40,
      AppButtonSize.md => 52,
      AppButtonSize.lg => 60,
    };
  }

  double get _fontSize {
    return switch (widget.size) {
      AppButtonSize.sm => 13,
      AppButtonSize.md => 15,
      AppButtonSize.lg => 16,
    };
  }

  double get _iconSize {
    return switch (widget.size) {
      AppButtonSize.sm => 18,
      AppButtonSize.md => 20,
      AppButtonSize.lg => 22,
    };
  }

  EdgeInsets get _padding {
    return switch (widget.size) {
      AppButtonSize.sm => const EdgeInsets.symmetric(horizontal: 16),
      AppButtonSize.md => const EdgeInsets.symmetric(horizontal: 24),
      AppButtonSize.lg => const EdgeInsets.symmetric(horizontal: 32),
    };
  }

  Color get _backgroundColor {
    if (!_isEnabled) return AppColors.neutral200;
    
    return switch (widget.variant) {
      AppButtonVariant.primary => AppColors.primary,
      AppButtonVariant.secondary => Colors.transparent,
      AppButtonVariant.ghost => Colors.transparent,
      AppButtonVariant.danger => AppColors.danger,
      AppButtonVariant.success => AppColors.success,
    };
  }

  Color get _foregroundColor {
    if (!_isEnabled) return AppColors.neutral400;
    
    return switch (widget.variant) {
      AppButtonVariant.primary => Colors.white,
      AppButtonVariant.secondary => AppColors.neutral700,
      AppButtonVariant.ghost => AppColors.primary,
      AppButtonVariant.danger => Colors.white,
      AppButtonVariant.success => Colors.white,
    };
  }

  Border? get _border {
    if (widget.variant == AppButtonVariant.secondary) {
      return Border.all(
        color: _isEnabled ? AppColors.neutral200 : AppColors.neutral100,
        width: 1.5,
      );
    }
    return null;
  }

  List<BoxShadow>? get _shadows {
    if (!widget.withShadow || !_isEnabled) return null;
    
    return switch (widget.variant) {
      AppButtonVariant.primary => AppElevation.primaryButtonShadows,
      AppButtonVariant.success => AppElevation.successButtonShadows,
      AppButtonVariant.danger => [AppElevation.dangerGlow],
      _ => null,
    };
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isEnabled) return;
    _controller.forward();
    if (widget.withHaptic) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isEnabled) return;
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (!_isEnabled) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          height: _height,
          padding: _padding,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: _border,
            boxShadow: _shadows,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: _iconSize,
                    height: _iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(_foregroundColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.leadingIcon != null) ...[
                        Icon(
                          widget.leadingIcon,
                          size: _iconSize,
                          color: _foregroundColor,
                        ),
                        SizedBox(width: AppSpacing.xs),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontWeight: FontWeight.w600,
                          color: _foregroundColor,
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (widget.trailingIcon != null) ...[
                        SizedBox(width: AppSpacing.xs),
                        Icon(
                          widget.trailingIcon,
                          size: _iconSize,
                          color: _foregroundColor,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );

    if (widget.isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

/// Bouton icône seul (sans label)
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44,
    this.iconSize = 22,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  });
  
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor ?? 
                   (onPressed != null 
                       ? AppColors.neutral700 
                       : AppColors.neutral400),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
