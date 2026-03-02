import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
import 'package:pointa_mobile/core/widgets/app_async_state.dart';
import 'package:pointa_mobile/core/widgets/app_card.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/attendance/presentation/widgets/attendance_record_tile.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(attendanceHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des presences'),
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: historyAsync.when(
          loading: () =>
              const AppLoadingState(message: 'Chargement de l historique...'),
          error: (_, _) => AppErrorState(
            title: 'Erreur de chargement',
            message:
                'Impossible de recuperer l historique. Reessayez dans quelques instants.',
            onRetry: () => ref.invalidate(attendanceHistoryProvider),
            retryButtonKey: const Key('history_retry_button'),
          ),
          data: (history) {
            if (history.isEmpty) {
              return const AppEmptyState(
                title: 'Aucune presence enregistree',
                message: 'Les actions de pointage apparaitront ici.',
              );
            }

            return ListView.separated(
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final record = history[index];
                return AppCard(child: AttendanceRecordTile(record: record));
              },
            );
          },
        ),
      ),
    );
  }
}
