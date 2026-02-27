import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.buttonKey,
  });

  final String label;
  final Future<void> Function()? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    if (icon == null) {
      return FilledButton(
        key: buttonKey,
        onPressed: effectiveOnPressed,
        child: _ButtonChild(label: label, isLoading: isLoading),
      );
    }

    return FilledButton.icon(
      key: buttonKey,
      onPressed: effectiveOnPressed,
      icon: isLoading ? const SizedBox.shrink() : Icon(icon),
      label: _ButtonChild(label: label, isLoading: isLoading),
    );
  }
}

class _ButtonChild extends StatelessWidget {
  const _ButtonChild({required this.label, required this.isLoading});

  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return Text(label);
    }

    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}
