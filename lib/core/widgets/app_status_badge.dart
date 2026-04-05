import 'package:flutter/material.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/theme/app_radius.dart';

/// Types de statut avec couleurs associées
enum AppStatusType {
  /// Statut neutre (info)
  neutral,
  
  /// Statut actif (en cours)
  active,
  
  /// Statut succès (complété, validé)
  success,
  
  /// Statut warning (en attente, retard)
  warning,
  
  /// Statut erreur (absent, rejeté)
  error,
}

/// Design System - Badge de Statut
/// 
/// Affiche un statut sous forme de pill/tag.
/// Utilisé pour les états de pointage, validation, etc.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.type = AppStatusType.neutral,
    this.icon,
    this.small = false,
  });

  /// Texte du badge
  final String label;
  
  /// Type de statut (affecte les couleurs)
  final AppStatusType type;
  
  /// Icône optionnelle à gauche
  final IconData? icon;
  
  /// Version compacte
  final bool small;

  // Factory constructors pour usage simplifié
  const AppStatusBadge.active({
    super.key,
    required this.label,
    this.icon,
    this.small = false,
  }) : type = AppStatusType.active;

  const AppStatusBadge.success({
    super.key,
    required this.label,
    this.icon,
    this.small = false,
  }) : type = AppStatusType.success;

  const AppStatusBadge.warning({
    super.key,
    required this.label,
    this.icon,
    this.small = false,
  }) : type = AppStatusType.warning;

  const AppStatusBadge.error({
    super.key,
    required this.label,
    this.icon,
    this.small = false,
  }) : type = AppStatusType.error;

  Color get _backgroundColor {
    return switch (type) {
      AppStatusType.neutral => AppColors.neutral100,
      AppStatusType.active => AppColors.primarySoft,
      AppStatusType.success => AppColors.successSoft,
      AppStatusType.warning => AppColors.warningSoft,
      AppStatusType.error => AppColors.dangerSoft,
    };
  }

  Color get _foregroundColor {
    return switch (type) {
      AppStatusType.neutral => AppColors.neutral700,
      AppStatusType.active => AppColors.primary,
      AppStatusType.success => AppColors.successDark,
      AppStatusType.warning => AppColors.warningDark,
      AppStatusType.error => AppColors.dangerDark,
    };
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = small ? 11.0 : 12.0;
    final iconSize = small ? 14.0 : 16.0;
    final verticalPadding = small ? 4.0 : 6.0;
    final horizontalPadding = small ? 8.0 : 10.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: _foregroundColor),
            SizedBox(width: small ? 4 : 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: _foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicateur de statut (petit dot coloré)
class AppStatusDot extends StatelessWidget {
  const AppStatusDot({
    super.key,
    this.type = AppStatusType.neutral,
    this.size = 8,
    this.pulsing = false,
  });

  final AppStatusType type;
  final double size;
  final bool pulsing;

  Color get _color {
    return switch (type) {
      AppStatusType.neutral => AppColors.neutral400,
      AppStatusType.active => AppColors.primary,
      AppStatusType.success => AppColors.success,
      AppStatusType.warning => AppColors.warning,
      AppStatusType.error => AppColors.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color,
      ),
    );

    if (pulsing) {
      return _PulsingDot(color: _color, size: size);
    }

    return dot;
  }
}

/// Dot avec animation de pulsation
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4 * _animation.value),
                blurRadius: widget.size,
                spreadRadius: widget.size * 0.3 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
