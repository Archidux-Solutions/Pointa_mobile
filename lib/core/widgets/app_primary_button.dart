import 'package:flutter/material.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/theme/app_radius.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.buttonKey,
    this.isSuccess = false,
  });

  final String label;
  final Future<void> Function()? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Key? buttonKey;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final colors = isSuccess
        ? const <Color>[Color(0xFF2FCC8C), Color(0xFF1CA86E)]
        : const <Color>[AppColors.primary, AppColors.primaryDark];
    final disabledColors = <Color>[
      AppColors.primary.withValues(alpha: 0.5),
      AppColors.primaryDark.withValues(alpha: 0.5),
    ];

    return SizedBox(
      key: buttonKey,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: effectiveOnPressed == null ? disabledColors : colors,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colors.first.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: effectiveOnPressed,
            child: Center(
              child: _ButtonChild(
                label: label,
                isLoading: isLoading,
                icon: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonChild extends StatelessWidget {
  const _ButtonChild({
    required this.label,
    required this.isLoading,
    required this.icon,
  });

  final String label;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      if (icon == null) {
        return Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
      }
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}
