import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
import 'package:pointa_mobile/core/widgets/app_async_state.dart';
import 'package:pointa_mobile/core/widgets/app_card.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/attendance/presentation/widgets/summary_metric_card.dart';

class SummaryPage extends ConsumerWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(attendanceSummaryProvider);
    final historyAsync = ref.watch(attendanceHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recap heures et retards'),
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: summaryAsync.when(
          loading: () =>
              const AppLoadingState(message: 'Chargement du recapitulatif...'),
          error: (_, _) => AppErrorState(
            title: 'Recapitulatif indisponible',
            message: 'Impossible de charger le recapitulatif.',
            onRetry: () => ref.invalidate(attendanceSummaryProvider),
          ),
          data: (summary) {
            final hours = summary.workedMinutes ~/ 60;
            final minutes = summary.workedMinutes % 60;
            final worked = '$hours h ${minutes.toString().padLeft(2, '0')}';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SummaryMetricCard(
                  title: 'Temps travaille',
                  value: worked,
                  icon: Icons.schedule,
                ),
                const SizedBox(height: AppSpacing.sm),
                SummaryMetricCard(
                  title: 'Retards',
                  value: summary.lateCount.toString(),
                  icon: Icons.timer_off_outlined,
                ),
                const SizedBox(height: AppSpacing.sm),
                SummaryMetricCard(
                  title: 'Absences',
                  value: summary.absenceCount.toString(),
                  icon: Icons.event_busy_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
                historyAsync.when(
                  loading: () => const AppLoadingState(
                    message: 'Chargement de l historique...',
                  ),
                  error: (_, _) => AppErrorState(
                    title: 'Historique indisponible',
                    message: 'Impossible de recuperer les donnees detaillees.',
                    onRetry: () => ref.invalidate(attendanceHistoryProvider),
                  ),
                  data: (history) {
                    if (history.isEmpty) {
                      return const AppEmptyState(
                        title: 'Aucune donnee de pointage',
                        message:
                            'Le recap detaille apparaitra apres les premieres actions.',
                      );
                    }
                    return AppCard(
                      child: Text(
                        'Recap base sur ${history.length} action(s) de pointage.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
