import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/theme/app_durations.dart';
import 'package:pointa_mobile/core/theme/app_radius.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';

/// Types de feedback avec styles associés
enum AppFeedbackType {
  success,
  error,
  warning,
  info,
}

/// Design System - Overlay de Feedback
/// 
/// Affiche un feedback visuel en overlay après une action importante.
/// Utilisé principalement pour le succès/erreur de pointage.
class AppFeedbackOverlay extends StatefulWidget {
  const AppFeedbackOverlay({
    super.key,
    required this.type,
    required this.title,
    this.message,
    this.icon,
    this.autoDismiss = true,
    this.dismissDuration = AppDurations.successOverlayDelay,
    this.onDismissed,
  });

  final AppFeedbackType type;
  final String title;
  final String? message;
  final IconData? icon;
  final bool autoDismiss;
  final Duration dismissDuration;
  final VoidCallback? onDismissed;

  /// Affiche l'overlay en fullscreen modal
  static Future<void> show(
    BuildContext context, {
    required AppFeedbackType type,
    required String title,
    String? message,
    IconData? icon,
    bool autoDismiss = true,
    Duration dismissDuration = AppDurations.successOverlayDelay,
    VoidCallback? onDismissed,
  }) async {
    HapticFeedback.mediumImpact();
    
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: AppDurations.medium,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppFeedbackOverlay(
          type: type,
          title: title,
          message: message,
          icon: icon,
          autoDismiss: autoDismiss,
          dismissDuration: dismissDuration,
          onDismissed: () {
            Navigator.of(context).pop();
            onDismissed?.call();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Raccourci pour feedback de succès
  static Future<void> success(
    BuildContext context, {
    required String title,
    String? message,
  }) {
    return show(
      context,
      type: AppFeedbackType.success,
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
    );
  }

  /// Raccourci pour feedback d'erreur
  static Future<void> error(
    BuildContext context, {
    required String title,
    String? message,
  }) {
    return show(
      context,
      type: AppFeedbackType.error,
      title: title,
      message: message,
      icon: Icons.error_rounded,
    );
  }

  @override
  State<AppFeedbackOverlay> createState() => _AppFeedbackOverlayState();
}

class _AppFeedbackOverlayState extends State<AppFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconController;
  late final Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    
    _iconController = AnimationController(
      vsync: this,
      duration: AppDurations.elaborate,
    );
    
    _iconAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    
    // Démarrer l'animation de l'icône
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _iconController.forward();
    });
    
    // Auto-dismiss après délai
    if (widget.autoDismiss) {
      Future.delayed(widget.dismissDuration, () {
        if (mounted) widget.onDismissed?.call();
      });
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    return switch (widget.type) {
      AppFeedbackType.success => AppColors.success,
      AppFeedbackType.error => AppColors.danger,
      AppFeedbackType.warning => AppColors.warning,
      AppFeedbackType.info => AppColors.primary,
    };
  }

  Color get _softColor {
    return switch (widget.type) {
      AppFeedbackType.success => AppColors.successSoft,
      AppFeedbackType.error => AppColors.dangerSoft,
      AppFeedbackType.warning => AppColors.warningSoft,
      AppFeedbackType.info => AppColors.primarySoft,
    };
  }

  IconData get _defaultIcon {
    return switch (widget.type) {
      AppFeedbackType.success => Icons.check_circle_rounded,
      AppFeedbackType.error => Icons.error_rounded,
      AppFeedbackType.warning => Icons.warning_rounded,
      AppFeedbackType.info => Icons.info_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.xxl),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: _backgroundColor.withOpacity(0.3),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cercle avec icône animée
              AnimatedBuilder(
                animation: _iconAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _iconAnimation.value,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _softColor,
                        border: Border.all(
                          color: _backgroundColor.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        widget.icon ?? _defaultIcon,
                        size: 44,
                        color: _backgroundColor,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Titre
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                  letterSpacing: -0.3,
                ),
              ),
              
              // Message optionnel
              if (widget.message != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral500,
                    height: 1.4,
                  ),
                ),
              ],
              
              // Bouton dismiss si pas auto
              if (!widget.autoDismiss) ...[
                const SizedBox(height: AppSpacing.xl),
                TextButton(
                  onPressed: widget.onDismissed,
                  child: const Text('Continuer'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Overlay de succès spécifique pour le pointage
class AppAttendanceSuccessOverlay extends StatelessWidget {
  const AppAttendanceSuccessOverlay({
    super.key,
    required this.isCheckIn,
    required this.time,
    this.location,
  });

  final bool isCheckIn;
  final String time;
  final String? location;

  static Future<void> show(
    BuildContext context, {
    required bool isCheckIn,
    required String time,
    String? location,
  }) {
    return AppFeedbackOverlay.show(
      context,
      type: AppFeedbackType.success,
      title: isCheckIn ? 'Arrivée enregistrée' : 'Départ enregistré',
      message: '$time${location != null ? ' • $location' : ''}',
      icon: isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ce widget est surtout utilisé via la méthode statique show()
    return const SizedBox.shrink();
  }
}
