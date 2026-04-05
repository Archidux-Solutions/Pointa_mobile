import 'package:flutter/material.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/theme/app_radius.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
import 'package:pointa_mobile/core/widgets/app_button.dart';
import 'package:pointa_mobile/core/widgets/app_card.dart';

/// Design System - État de chargement
/// 
/// Affiche un indicateur de chargement avec message optionnel.
class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.message,
    this.asCard = true,
    this.compact = false,
  });

  final String? message;
  final bool asCard;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: compact ? 24 : 32,
          height: compact ? 24 : 32,
          child: CircularProgressIndicator(
            strokeWidth: compact ? 2.5 : 3,
            color: AppColors.primary,
          ),
        ),
        if (message != null) ...[
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 13 : 14,
              color: AppColors.neutral500,
            ),
          ),
        ],
      ],
    );

    if (asCard) {
      return AppCard(
        padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

/// Design System - État d'erreur
/// 
/// Affiche un message d'erreur avec bouton retry optionnel.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.asCard = true,
    this.retryButtonKey,
    this.compact = false,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool asCard;
  final Key? retryButtonKey;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icône d'erreur
        Container(
          width: compact ? 48 : 56,
          height: compact ? 48 : 56,
          decoration: BoxDecoration(
            color: AppColors.dangerSoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            Icons.error_outline_rounded,
            color: AppColors.danger,
            size: compact ? 24 : 28,
          ),
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
        
        // Titre
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 15 : 16,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        
        // Message
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 13 : 14,
            color: AppColors.neutral500,
            height: 1.4,
          ),
        ),
        
        // Bouton retry
        if (onRetry != null) ...[
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          AppButton.secondary(
            key: retryButtonKey,
            label: 'Réessayer',
            leadingIcon: Icons.refresh_rounded,
            onPressed: onRetry,
            size: compact ? AppButtonSize.sm : AppButtonSize.md,
            isFullWidth: false,
          ),
        ],
      ],
    );

    if (asCard) {
      return AppCard(
        padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
        child: content,
      );
    }

    return content;
  }
}

/// Design System - État vide
/// 
/// Affiche un message quand il n'y a pas de données.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.asCard = true,
    this.action,
    this.actionLabel,
    this.compact = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final bool asCard;
  final VoidCallback? action;
  final String? actionLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icône
        Container(
          width: compact ? 48 : 56,
          height: compact ? 48 : 56,
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            icon,
            color: AppColors.neutral400,
            size: compact ? 24 : 28,
          ),
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
        
        // Titre
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 15 : 16,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        
        // Message
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 13 : 14,
            color: AppColors.neutral500,
            height: 1.4,
          ),
        ),
        
        // Action optionnelle
        if (action != null && actionLabel != null) ...[
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          AppButton.ghost(
            label: actionLabel!,
            onPressed: action,
            size: compact ? AppButtonSize.sm : AppButtonSize.md,
          ),
        ],
      ],
    );

    if (asCard) {
      return AppCard(
        padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
        child: content,
      );
    }

    return content;
  }
}

/// Widget helper pour afficher l'état approprié selon AsyncValue
class AppAsyncBuilder<T> extends StatelessWidget {
  const AppAsyncBuilder({
    super.key,
    required this.data,
    required this.loading,
    required this.error,
    required this.builder,
    this.asCard = true,
  });

  final T? data;
  final bool loading;
  final String? error;
  final Widget Function(T data) builder;
  final bool asCard;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return AppLoadingState(asCard: asCard);
    }
    
    if (error != null) {
      return AppErrorState(
        title: 'Erreur',
        message: error!,
        asCard: asCard,
      );
    }
    
    if (data != null) {
      return builder(data as T);
    }
    
    return AppEmptyState(
      title: 'Aucune donnée',
      message: 'Les données ne sont pas disponibles.',
      asCard: asCard,
    );
  }
}
