import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/theme/app_radius.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
import 'package:pointa_mobile/core/widgets/app_async_state.dart';
import 'package:pointa_mobile/core/widgets/app_bottom_nav.dart';
import 'package:pointa_mobile/core/widgets/app_card.dart';
import 'package:pointa_mobile/core/widgets/app_page_bars.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/auth/application/auth_controller.dart';
import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _formatMetricMinutes(int workedMinutes) {
    final hours = workedMinutes ~/ 60;
    final minutes = workedMinutes % 60;
    return '$hours ${minutes.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDisplayName(UserSession? session) {
    final name = session?.displayName.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return 'Utilisateur Pointa';
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _formatGroupLabel(DateTime dateTime) {
    final now = DateTime.now();
    if (_isSameDay(dateTime, now)) {
      return 'Aujourd hui';
    }

    const weekdays = <String>[
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    const months = <String>[
      'janvier',
      'fevrier',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'aout',
      'septembre',
      'octobre',
      'novembre',
      'decembre',
    ];

    return '${weekdays[dateTime.weekday - 1]} ${dateTime.day} ${months[dateTime.month - 1]}';
  }

  Map<DateTime, List<AttendanceRecord>> _groupHistory(
    List<AttendanceRecord> history,
  ) {
    final groups = <DateTime, List<AttendanceRecord>>{};

    for (final record in history) {
      final dayKey = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      groups.putIfAbsent(dayKey, () => <AttendanceRecord>[]).add(record);
    }

    return groups;
  }

  void _handleBottomNavSelection(BuildContext context, int index) {
    // Nouvelle navigation : Accueil(0), Historique(1), Pointage(2), Recap(3), Profil(4)
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        return;
      case 1:
        context.go(AppRoutes.history);
        return;
      case 2:
        context.go(AppRoutes.attendance);
        return;
      case 3:
        context.go(AppRoutes.summary);
        return;
      case 4:
        context.go(AppRoutes.profile);
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(
      authControllerProvider.select((state) => state.session),
    );
    final statusAsync = ref.watch(attendanceStatusProvider);
    final summaryAsync = ref.watch(attendanceSummaryProvider);
    final historyAsync = ref.watch(attendanceHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppHomeAppBar(
        displayName: _formatDisplayName(session),
        onSignOut: () async {
          await ref.read(authControllerProvider.notifier).signOut();
        },
      ),
      body: ListView(
        padding: AppSpacing.pageWithNav,
        children: [
          // Hero Card - Statut du jour
          statusAsync.when(
            loading: () => const AppLoadingState(
              message: 'Chargement du statut...',
            ),
            error: (_, __) => AppErrorState(
              title: 'Statut indisponible',
              message: 'Impossible de charger le statut du jour.',
              onRetry: () => ref.invalidate(attendanceStatusProvider),
            ),
            data: (status) => _StatusHeroCard(
              isCheckedIn: status.isCheckedIn,
              siteLabel: status.siteLabel,
              onTap: () => context.go(AppRoutes.attendance),
            ),
          ),
          
          AppSpacing.verticalMd,
          
          // Métriques du jour
          summaryAsync.when(
            loading: () => const AppLoadingState(
              message: 'Chargement...',
              compact: true,
            ),
            error: (_, __) => AppErrorState(
              title: 'Erreur',
              message: 'Impossible de charger les indicateurs.',
              compact: true,
              onRetry: () => ref.invalidate(attendanceSummaryProvider),
            ),
            data: (summary) => Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Heures',
                    value: _formatMetricMinutes(summary.workedMinutes),
                    icon: Icons.schedule_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricCard(
                    title: 'Retards',
                    value: summary.lateCount.toString(),
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricCard(
                    title: 'Absences',
                    value: summary.absenceCount.toString(),
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Historique récent
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Derniers pointages',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                AppSpacing.verticalMd,
                historyAsync.when(
                  loading: () => const AppLoadingState(
                    message: 'Chargement...',
                    asCard: false,
                    compact: true,
                  ),
                  error: (_, __) => AppErrorState(
                    title: 'Historique indisponible',
                    message: 'Impossible de charger les derniers pointages.',
                    asCard: false,
                    compact: true,
                    onRetry: () => ref.invalidate(attendanceHistoryProvider),
                  ),
                  data: (history) {
                    if (history.isEmpty) {
                      return const AppEmptyState(
                        title: 'Aucun pointage',
                        message: 'Vos pointages apparaîtront ici.',
                        icon: Icons.schedule_outlined,
                        asCard: false,
                        compact: true,
                      );
                    }

                    final groupedHistory = _groupHistory(history);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groupedHistory.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _HistoryGroup(
                            label: _formatGroupLabel(entry.key),
                            records: entry.value,
                            timeFormatter: _formatTime,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 0,
        onSelected: (index) => _handleBottomNavSelection(context, index),
      ),
    );
  }
}

/// Hero card affichant le statut du jour sur la page Home
class _StatusHeroCard extends StatelessWidget {
  const _StatusHeroCard({
    required this.isCheckedIn,
    required this.siteLabel,
    required this.onTap,
  });

  final bool isCheckedIn;
  final String siteLabel;
  final VoidCallback onTap;

  String get _statusLabel => isCheckedIn ? 'En service' : 'Hors service';
  String get _actionLabel => isCheckedIn ? 'Pointer le départ' : "Pointer l'arrivée";

  @override
  Widget build(BuildContext context) {
    return AppHeroCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              // Cercle de statut
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCheckedIn ? Icons.check_rounded : Icons.schedule_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statut du jour',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCheckedIn ? AppColors.success : AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            siteLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Bouton d'action
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _actionLabel,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de métrique compacte pour la page Home
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // Génère une version soft de la couleur pour le fond
    final softColor = Color.lerp(color, Colors.white, 0.85)!;
    
    return Container(
      height: 100,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
              ],
              Text(
                title,
                style: TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.neutral900,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Groupe d'historique pour un jour
class _HistoryGroup extends StatelessWidget {
  const _HistoryGroup({
    required this.label,
    required this.records,
    required this.timeFormatter,
  });

  final String label;
  final List<AttendanceRecord> records;
  final String Function(DateTime) timeFormatter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...records.map((record) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _HistoryRecordTile(
              record: record,
              timeFormatter: timeFormatter,
            ),
          );
        }),
      ],
    );
  }
}

/// Tuile d'un pointage dans l'historique
class _HistoryRecordTile extends StatelessWidget {
  const _HistoryRecordTile({
    required this.record,
    required this.timeFormatter,
  });

  final AttendanceRecord record;
  final String Function(DateTime) timeFormatter;

  @override
  Widget build(BuildContext context) {
    final isCheckIn = record.actionType == AttendanceActionType.checkIn;
    final title = isCheckIn ? 'Arrivée' : 'Départ';
    final iconColor = isCheckIn ? AppColors.success : AppColors.danger;
    final bgColor = isCheckIn ? AppColors.successSoft : AppColors.dangerSoft;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          // Icône
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(
              isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral900,
                  ),
                ),
                if (record.isPendingSync)
                  Text(
                    'Sync en attente',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.warning,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          // Heure
          Text(
            timeFormatter(record.timestamp),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
