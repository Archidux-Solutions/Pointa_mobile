import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
import 'package:pointa_mobile/core/widgets/app_async_state.dart';
import 'package:pointa_mobile/core/widgets/app_card.dart';
import 'package:pointa_mobile/core/widgets/app_primary_button.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  bool _isSubmitting = false;

  Future<void> _toggleAttendance() async {
    if (_isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final record = await ref
          .read(attendanceRepositoryProvider)
          .toggleAttendance();
      refreshAttendanceReadModels(ref);

      if (!mounted) {
        return;
      }

      final action = record.actionType == AttendanceActionType.checkIn
          ? 'arrivee enregistree'
          : 'depart enregistre';
      final message = record.isPendingSync
          ? 'Pointage local enregistre (sync en attente).'
          : 'Pointage reussi: $action';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action impossible, reessayez.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _retrySyncNow() async {
    if (ref.read(attendanceSyncingProvider)) {
      return;
    }

    final synced = await retryPendingAttendanceSync(ref);
    if (!mounted) {
      return;
    }

    if (synced == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune action a synchroniser.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$synced action(s) synchronisee(s).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusAsync = ref.watch(attendanceStatusProvider);
    final historyAsync = ref.watch(attendanceHistoryProvider);
    final pendingSyncAsync = ref.watch(attendancePendingSyncCountProvider);
    final isSyncing = ref.watch(attendanceSyncingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pointage'),
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          statusAsync.when(
            loading: () => const AppLoadingState(
              message: 'Chargement du statut de pointage...',
            ),
            error: (_, _) => AppErrorState(
              title: 'Statut indisponible',
              message: 'Impossible de charger le statut de pointage.',
              onRetry: () => ref.invalidate(attendanceStatusProvider),
            ),
            data: (status) {
              final statusText = status.isCheckedIn
                  ? 'En service'
                  : 'Hors service';
              final actionText = status.isCheckedIn
                  ? 'Pointer depart'
                  : 'Pointer arrivee';

              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Etat actuel: $statusText',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Zone GPS (mock): Siege Ouaga - Rayon 60m',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      status.lastActionAt == null
                          ? 'Aucun pointage aujourd hui.'
                          : 'Derniere action a ${_formatTime(status.lastActionAt!)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppPrimaryButton(
                      label: actionText,
                      isLoading: _isSubmitting,
                      onPressed: _toggleAttendance,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: pendingSyncAsync.when(
              loading: () => const AppLoadingState(
                message: 'Chargement de l etat de synchronisation...',
                asCard: false,
              ),
              error: (_, _) => AppErrorState(
                title: 'Synchronisation indisponible',
                message: 'Impossible de lire les actions en attente.',
                asCard: false,
                onRetry: () =>
                    ref.invalidate(attendancePendingSyncCountProvider),
              ),
              data: (pendingCount) {
                if (pendingCount == 0) {
                  return Text(
                    'Synchronisation: aucune action en attente.',
                    style: theme.textTheme.bodyMedium,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$pendingCount action(s) en attente de synchronisation.',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Les actions ont ete enregistrees localement. Lancez la reprise pour les envoyer au backend.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppPrimaryButton(
                      label: 'Synchroniser maintenant',
                      icon: Icons.sync,
                      isLoading: isSyncing,
                      onPressed: _retrySyncNow,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: historyAsync.when(
              loading: () => const AppLoadingState(
                message: 'Chargement des dernieres actions...',
                asCard: false,
              ),
              error: (_, _) => AppErrorState(
                title: 'Historique indisponible',
                message: 'Impossible de charger les dernieres actions.',
                asCard: false,
                onRetry: () => ref.invalidate(attendanceHistoryProvider),
              ),
              data: (history) {
                if (history.isEmpty) {
                  return const AppEmptyState(
                    title: 'Aucune action de pointage',
                    message: 'Les prochaines actions apparaitront ici.',
                    asCard: false,
                  );
                }

                final topRecords = history.take(3).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Dernieres actions',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...topRecords.map((record) {
                      final label =
                          record.actionType == AttendanceActionType.checkIn
                          ? 'Arrivee'
                          : 'Depart';
                      final syncSuffix = record.isPendingSync
                          ? ' (sync en attente)'
                          : '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          '$label - ${record.siteLabel}$syncSuffix - ${_formatTime(record.timestamp)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
