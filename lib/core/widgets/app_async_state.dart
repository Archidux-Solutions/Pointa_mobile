import 'package:flutter/material.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
import 'package:pointa_mobile/core/widgets/app_card.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key, this.message, this.asCard = true});

  final String? message;
  final bool asCard;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const CircularProgressIndicator(),
        if (message != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(message!, textAlign: TextAlign.center),
        ],
      ],
    );

    if (asCard) {
      return AppCard(child: Center(child: content));
    }

    return Center(child: content);
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.asCard = true,
    this.retryButtonKey,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool asCard;
  final Key? retryButtonKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(message, style: theme.textTheme.bodyMedium),
        if (onRetry != null) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            key: retryButtonKey,
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reessayer'),
          ),
        ],
      ],
    );

    if (asCard) {
      return AppCard(child: content);
    }

    return content;
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.asCard = true,
  });

  final String title;
  final String message;
  final IconData icon;
  final bool asCard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(message, style: theme.textTheme.bodyMedium),
      ],
    );

    if (asCard) {
      return AppCard(child: content);
    }

    return content;
  }
}
