import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => AppCard(
            child: Text(
              'Impossible de charger le recapitulatif.',
              style: theme.textTheme.bodyMedium,
            ),
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
                  loading: () => const AppCard(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => AppCard(
                    child: Text(
                      'Historique indisponible.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  data: (history) {
                    if (history.isEmpty) {
                      return AppCard(
                        child: Text(
                          'Aucune donnee de pointage pour etablir un recap detaille.',
                          style: theme.textTheme.bodyMedium,
                        ),
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
