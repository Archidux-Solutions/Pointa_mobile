import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
import 'package:pointa_mobile/core/widgets/app_async_state.dart';
import 'package:pointa_mobile/core/widgets/app_card.dart';
import 'package:pointa_mobile/core/widgets/app_primary_button.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/auth/application/auth_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(
      authControllerProvider.select((state) => state.session),
    );
    final summaryAsync = ref.watch(attendanceSummaryProvider);
    final pendingSyncAsync = ref.watch(attendancePendingSyncCountProvider);
    final isSyncing = ref.watch(attendanceSyncingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Se deconnecter',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Bienvenue ${session?.displayName ?? ''}',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  session?.email ?? 'Utilisateur non renseigne',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: pendingSyncAsync.when(
              loading: () => const AppLoadingState(
                message: 'Chargement de l etat de synchronisation...',
                asCard: false,
              ),
              error: (_, _) => AppErrorState(
                title: 'Etat sync indisponible',
                message: 'Impossible de lire les actions en attente.',
                asCard: false,
                onRetry: () =>
                    ref.invalidate(attendancePendingSyncCountProvider),
              ),
              data: (pendingCount) {
                if (pendingCount == 0) {
                  return Text(
                    'Synchronisation: a jour.',
                    style: theme.textTheme.bodyMedium,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Synchronisation requise',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$pendingCount action(s) en attente de reprise sync.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppPrimaryButton(
                      label: 'Synchroniser maintenant',
                      icon: Icons.sync,
                      isLoading: isSyncing,
                      onPressed: () async {
                        final synced = await retryPendingAttendanceSync(ref);
                        if (!context.mounted) {
                          return;
                        }
                        final message = synced == 0
                            ? 'Aucune action a synchroniser.'
                            : '$synced action(s) synchronisee(s).';
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: summaryAsync.when(
              loading: () => const AppLoadingState(
                message: 'Chargement des indicateurs...',
                asCard: false,
              ),
              error: (_, _) => AppErrorState(
                title: 'Indicateurs indisponibles',
                message: 'Impossible de charger le resume du jour.',
                asCard: false,
                onRetry: () => ref.invalidate(attendanceSummaryProvider),
              ),
              data: (summary) {
                final hours = summary.workedMinutes ~/ 60;
                final minutes = summary.workedMinutes % 60;
                final worked = '$hours h ${minutes.toString().padLeft(2, '0')}';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Resume du jour', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Temps travaille: $worked',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'Retards: ${summary.lateCount} | Absences: ${summary.absenceCount}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Actions rapides', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                AppPrimaryButton(
                  label: 'Demarrer le flow de pointage',
                  icon: Icons.pin_drop_outlined,
                  onPressed: () async => context.go(AppRoutes.attendance),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.history),
                  icon: const Icon(Icons.history),
                  label: const Text('Voir historique'),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.summary),
                  icon: const Icon(Icons.query_stats),
                  label: const Text('Voir recap'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
