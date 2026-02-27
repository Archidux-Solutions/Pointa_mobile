import 'package:flutter/material.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';

abstract final class AppTypography {
  static TextTheme textTheme() {
    final base = Typography.material2021().black;

    return base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(color: AppColors.onSurface),
      bodySmall: base.bodySmall?.copyWith(color: AppColors.mutedText),
    );
  }
}
