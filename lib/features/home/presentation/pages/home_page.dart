import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
import 'package:pointa_mobile/core/widgets/app_async_state.dart';
import 'package:pointa_mobile/core/widgets/app_bottom_nav.dart';
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
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        return;
      case 1:
        context.go(AppRoutes.attendance);
        return;
      case 2:
        context.go(AppRoutes.history);
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
      backgroundColor: const Color(0xFFF3F2F7),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
          children: <Widget>[
            _HomeHeader(
              displayName: _formatDisplayName(session),
              onSignOut: () async {
                await ref.read(authControllerProvider.notifier).signOut();
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            statusAsync.when(
              loading: () => const AppLoadingState(
                message: 'Chargement du statut du jour...',
              ),
              error: (_, _) => AppErrorState(
                title: 'Statut indisponible',
                message: 'Impossible de charger le statut du jour.',
                onRetry: () => ref.invalidate(attendanceStatusProvider),
              ),
              data: (status) {
                return _StatusHeroCard(
                  title: 'Statut du jour',
                  statusLabel: status.isCheckedIn
                      ? 'En service'
                      : 'Hors service',
                  siteLabel: 'Siege Ouaga',
                  actionLabel: status.isCheckedIn
                      ? 'Pointer le depart'
                      : "Pointer l'arrivee",
                  onTap: () => context.go(AppRoutes.attendance),
                );
              },
            ),
            const SizedBox(height: 18),
            summaryAsync.when(
              loading: () => const AppLoadingState(
                message: 'Chargement des indicateurs...',
              ),
              error: (_, _) => AppErrorState(
                title: 'Indicateurs indisponibles',
                message: 'Impossible de charger les indicateurs du jour.',
                onRetry: () => ref.invalidate(attendanceSummaryProvider),
              ),
              data: (summary) {
                return Row(
                  children: <Widget>[
                    Expanded(
                      child: _MetricCard(
                        title: 'Heures',
                        value: _formatMetricMinutes(summary.workedMinutes),
                        icon: Icons.schedule_rounded,
                        startColor: const Color(0xFF43C1C2),
                        endColor: const Color(0xFF2B9CAD),
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        title: 'Retards',
                        value: summary.lateCount.toString(),
                        startColor: const Color(0xFFF1E2BF),
                        endColor: const Color(0xFFE9D7B3),
                        textColor: const Color(0xFF243154),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        title: 'Absences',
                        value: summary.absenceCount.toString(),
                        startColor: const Color(0xFFF6D987),
                        endColor: const Color(0xFFF0CC67),
                        textColor: const Color(0xFF243154),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.98),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFE6E3EF)),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x0A111B33),
                    blurRadius: 26,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Derniers pointages',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1D2752),
                    ),
                  ),
                  const SizedBox(height: 20),
                  historyAsync.when(
                    loading: () => const AppLoadingState(
                      message: 'Chargement des derniers pointages...',
                      asCard: false,
                    ),
                    error: (_, _) => AppErrorState(
                      title: 'Historique indisponible',
                      message: 'Impossible de charger les derniers pointages.',
                      asCard: false,
                      onRetry: () => ref.invalidate(attendanceHistoryProvider),
                    ),
                    data: (history) {
                      if (history.isEmpty) {
                        return const AppEmptyState(
                          title: 'Aucun pointage disponible',
                          message: 'Vos prochaines actions apparaitront ici.',
                          asCard: false,
                        );
                      }

                      final groupedHistory = _groupHistory(history);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: groupedHistory.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
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
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 0,
        onSelected: (index) => _handleBottomNavSelection(context, index),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.displayName, required this.onSignOut});

  final String displayName;
  final Future<void> Function() onSignOut;

  String _initialsFromName(String name) {
    final tokens = name
        .split(' ')
        .where((token) => token.trim().isNotEmpty)
        .take(2)
        .toList();

    if (tokens.isEmpty) {
      return 'P';
    }

    return tokens
        .map((token) => token.trim().substring(0, 1).toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Bonjour,',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF253056),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF17224B),
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<_HeaderMenuAction>(
          tooltip: 'Actions du compte',
          offset: const Offset(0, 62),
          onSelected: (action) async {
            if (action == _HeaderMenuAction.signOut) {
              await onSignOut();
            }
          },
          itemBuilder: (context) => const <PopupMenuEntry<_HeaderMenuAction>>[
            PopupMenuItem<_HeaderMenuAction>(
              value: _HeaderMenuAction.signOut,
              child: Text('Se deconnecter'),
            ),
          ],
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF9FD5FF), Color(0xFF6DB6F7)],
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x1D5D81C5),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _initialsFromName(displayName),
                style: const TextStyle(
                  color: Color(0xFF12305B),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum _HeaderMenuAction { signOut }

class _StatusHeroCard extends StatelessWidget {
  const _StatusHeroCard({
    required this.title,
    required this.statusLabel,
    required this.siteLabel,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String statusLabel;
  final String siteLabel;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF4065F0), Color(0xFF5A8CFF)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x304F77F4),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -26,
            right: -36,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 24,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            statusLabel,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            siteLabel,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  fontSize: 15,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(26),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x11081A42),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                actionLabel,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.startColor,
    required this.endColor,
    required this.textColor,
    this.icon,
  });

  final String title;
  final String value;
  final Color startColor;
  final Color endColor;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0E111B33),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (icon != null)
            Row(
              children: <Widget>[
                Icon(icon, color: textColor.withValues(alpha: 0.92), size: 26),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

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
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            color: const Color(0xFF7C8199),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        ...records.map((record) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
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

class _HistoryRecordTile extends StatelessWidget {
  const _HistoryRecordTile({required this.record, required this.timeFormatter});

  final AttendanceRecord record;
  final String Function(DateTime) timeFormatter;

  @override
  Widget build(BuildContext context) {
    final isCheckIn = record.actionType == AttendanceActionType.checkIn;
    final title = isCheckIn
        ? 'Arrivee ${record.siteLabel}'
        : 'Depart ${record.siteLabel}';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAFD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9E6EF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x09111B33),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCheckIn
                  ? const Color(0xFF50BFAF).withValues(alpha: 0.18)
                  : const Color(0xFFE85C6E).withValues(alpha: 0.14),
            ),
            child: Icon(
              isCheckIn ? Icons.check_rounded : Icons.logout_rounded,
              color: isCheckIn
                  ? const Color(0xFF3AB4A5)
                  : const Color(0xFFE05B73),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1C2550),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.isPendingSync
                      ? '${timeFormatter(record.timestamp)} • Sync en attente'
                      : timeFormatter(record.timestamp),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF7E859D),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            timeFormatter(record.timestamp),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF16234B),
            ),
          ),
        ],
      ),
    );
  }
}
