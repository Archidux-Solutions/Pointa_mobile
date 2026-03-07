import 'package:flutter/material.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';

abstract final class AppTypography {
  static TextTheme textTheme() {
    final base = Typography.material2021().black;

    return base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
        letterSpacing: -0.3,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
        letterSpacing: -0.2,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
        letterSpacing: -0.1,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        color: AppColors.onSurface,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        color: AppColors.mutedText,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}
