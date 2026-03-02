import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
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
            child: summaryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Text(
                'Indicateurs indisponibles.',
                style: theme.textTheme.bodyMedium,
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
                  onPressed: () {},
                  icon: const Icon(Icons.history),
                  label: const Text('Historique (prochaine etape)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
