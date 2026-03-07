import 'package:flutter/material.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';

class SummaryMetricCard extends StatelessWidget {
  const SummaryMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.chipColor,
    required this.chipLabel,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color chipColor;
  final String chipLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: AppColors.softBlue,
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              chipLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: chipColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
