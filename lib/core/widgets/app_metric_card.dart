import 'package:flutter/material.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/theme/app_radius.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';

/// Types de métriques avec couleurs associées
enum AppMetricType {
  /// Métrique neutre (heures travaillées)
  neutral,
  
  /// Métrique positive (présences, ponctualité)
  positive,
  
  /// Métrique d'avertissement (retards)
  warning,
  
  /// Métrique négative (absences)
  negative,
}

/// Design System - Carte de Métrique KPI
/// 
/// Affiche une valeur numérique avec label et icône.
/// Utilisé pour les statistiques sur Home, Summary, etc.
class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.type = AppMetricType.neutral,
    this.subtitle,
    this.onTap,
    this.compact = false,
  });

  /// Valeur principale (ex: "8h32", "2", "95%")
  final String value;
  
  /// Label descriptif (ex: "Heures", "Retards")
  final String label;
  
  /// Icône optionnelle
  final IconData? icon;
  
  /// Type de métrique (affecte les couleurs)
  final AppMetricType type;
  
  /// Sous-titre optionnel (ex: "cette semaine")
  final String? subtitle;
  
  /// Callback au tap
  final VoidCallback? onTap;
  
  /// Version compacte (moins de padding)
  final bool compact;

  Color get _backgroundColor {
    return switch (type) {
      AppMetricType.neutral => AppColors.neutral100,
      AppMetricType.positive => AppColors.successSoft,
      AppMetricType.warning => AppColors.warningSoft,
      AppMetricType.negative => AppColors.dangerSoft,
    };
  }

  Color get _valueColor {
    return switch (type) {
      AppMetricType.neutral => AppColors.neutral900,
      AppMetricType.positive => AppColors.successDark,
      AppMetricType.warning => AppColors.warningDark,
      AppMetricType.negative => AppColors.dangerDark,
    };
  }

  Color get _iconColor {
    return switch (type) {
      AppMetricType.neutral => AppColors.neutral500,
      AppMetricType.positive => AppColors.success,
      AppMetricType.warning => AppColors.warning,
      AppMetricType.negative => AppColors.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: _iconColor),
            SizedBox(height: compact ? 6 : 8),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: compact ? 20 : 24,
              fontWeight: FontWeight.w700,
              color: _valueColor,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          SizedBox(height: compact ? 2 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.neutral400,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Ligne de métriques horizontale (3 items)
class AppMetricRow extends StatelessWidget {
  const AppMetricRow({
    super.key,
    required this.metrics,
    this.spacing = AppSpacing.sm,
  });

  final List<AppMetricCard> metrics;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < metrics.length; i++) ...[
          Expanded(child: metrics[i]),
          if (i < metrics.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}
