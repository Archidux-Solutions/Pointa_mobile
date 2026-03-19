import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/widgets/app_async_state.dart';
import 'package:pointa_mobile/core/widgets/app_bottom_nav.dart';
import 'package:pointa_mobile/core/widgets/app_page_bars.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/attendance/domain/exceptions/attendance_exception.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_status.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  var _isSubmitting = false;

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
    } on AttendanceException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
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

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _formatDayLabel(DateTime dateTime) {
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

  List<_AttendanceDayGroup> _buildDailyGroups(
    List<AttendanceRecord> history,
    AttendanceStatus? status,
  ) {
    final grouped = <DateTime, List<AttendanceRecord>>{};

    for (final record in history) {
      final dayKey = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      grouped.putIfAbsent(dayKey, () => <AttendanceRecord>[]).add(record);
    }

    final sortedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final now = DateTime.now();

    return sortedDays.map((day) {
      final records = grouped[day]!
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final checkIns = records
          .where((record) => record.actionType == AttendanceActionType.checkIn)
          .toList();
      final checkOuts = records
          .where((record) => record.actionType == AttendanceActionType.checkOut)
          .toList();

      final arrival = checkIns.isEmpty ? null : checkIns.first;
      final departure = checkOuts.isEmpty ? null : checkOuts.last;
      final siteLabel =
          arrival?.siteLabel ?? departure?.siteLabel ?? 'Siege Ouaga';
      final isCurrentDayOpen =
          _isSameDay(day, now) &&
          (status?.isCheckedIn ?? false) &&
          departure == null;

      return _AttendanceDayGroup(
        label: _formatDayLabel(day),
        siteLabel: siteLabel,
        arrival: arrival,
        departure: departure,
        showPendingDeparture: isCurrentDayOpen,
      );
    }).toList();
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
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(attendanceStatusProvider);
    final historyAsync = ref.watch(attendanceHistoryProvider);
    final pendingSyncAsync = ref.watch(attendancePendingSyncCountProvider);
    final isSyncing = ref.watch(attendanceSyncingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F7),
      appBar: const AppSectionAppBar(title: 'Pointage'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
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
              return _AttendanceHeroCard(
                statusText: status.isCheckedIn ? 'En service' : 'Hors service',
                siteLabel: status.siteLabel,
                radiusMeters: status.radiusMeters,
                actionText: status.isCheckedIn
                    ? 'Pointer le depart'
                    : "Pointer l'arrivee",
                actionIcon: status.isCheckedIn
                    ? Icons.logout_rounded
                    : Icons.login_rounded,
                actionIconColor: status.isCheckedIn
                    ? const Color(0xFFE17386)
                    : const Color(0xFF47BAA5),
                onPressed: _toggleAttendance,
                isLoading: _isSubmitting,
              );
            },
          ),
          const SizedBox(height: 18),
          pendingSyncAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => AppErrorState(
              title: 'Synchronisation indisponible',
              message: 'Impossible de lire les actions en attente.',
              onRetry: () => ref.invalidate(attendancePendingSyncCountProvider),
            ),
            data: (pendingCount) {
              if (pendingCount == 0) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _PendingSyncCard(
                  pendingCount: pendingCount,
                  isSyncing: isSyncing,
                  onPressed: _retrySyncNow,
                ),
              );
            },
          ),
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
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Historique du jour',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D2752),
                  ),
                ),
                const SizedBox(height: 18),
                historyAsync.when(
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

                    final groups = _buildDailyGroups(
                      history,
                      statusAsync.asData?.value,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groups.map((group) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _AttendanceHistoryGroup(
                            group: group,
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
        selectedIndex: 1,
        onSelected: (index) => _handleBottomNavSelection(context, index),
      ),
    );
  }
}

class _AttendanceHeroCard extends StatelessWidget {
  const _AttendanceHeroCard({
    required this.statusText,
    required this.siteLabel,
    required this.radiusMeters,
    required this.actionText,
    required this.actionIcon,
    required this.actionIconColor,
    required this.onPressed,
    required this.isLoading,
  });

  final String statusText;
  final String siteLabel;
  final int? radiusMeters;
  final String actionText;
  final IconData actionIcon;
  final Color actionIconColor;
  final Future<void> Function() onPressed;
  final bool isLoading;

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
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 86,
                      height: 86,
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Statut actuel',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  statusText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF7BE0A5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  'Zone : $siteLabel',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.84,
                                        ),
                                        fontSize: 17,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (radiusMeters != null) ...<Widget>[
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Rayon $radiusMeters m',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.84,
                                        ),
                                        fontSize: 17,
                                      ),
                                ),
                              ],
                            ],
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
                    onTap: isLoading ? null : () => onPressed(),
                    borderRadius: BorderRadius.circular(24),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x11081A42),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 18,
                        ),
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      actionIcon,
                                      color: actionIconColor,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        actionText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: AppColors.primaryDark,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
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

class _PendingSyncCard extends StatelessWidget {
  const _PendingSyncCard({
    required this.pendingCount,
    required this.isSyncing,
    required this.onPressed,
  });

  final int pendingCount;
  final bool isSyncing;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6E3EF)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.sync_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$pendingCount action(s) en attente de synchronisation.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1B2650),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Lancez la reprise pour envoyer les actions au backend.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF7C8199),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: isSyncing ? null : () => onPressed(),
            child: Text(isSyncing ? 'Sync...' : 'Synchroniser'),
          ),
        ],
      ),
    );
  }
}

class _AttendanceHistoryGroup extends StatelessWidget {
  const _AttendanceHistoryGroup({
    required this.group,
    required this.timeFormatter,
  });

  final _AttendanceDayGroup group;
  final String Function(DateTime) timeFormatter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          group.label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            color: const Color(0xFF7C8199),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Container(
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
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            children: <Widget>[
              _AttendanceHistoryRow(
                title: 'Arrivee ${group.siteLabel}',
                subtitle: group.arrival == null
                    ? '--:--'
                    : timeFormatter(group.arrival!.timestamp),
                trailing: group.arrival == null
                    ? '--:--'
                    : timeFormatter(group.arrival!.timestamp),
                icon: Icons.check_rounded,
                iconBackground: const Color(0xFF50BFAF).withValues(alpha: 0.18),
                iconColor: const Color(0xFF3AB4A5),
              ),
              const Divider(height: 20, color: Color(0xFFE7E4EE)),
              _AttendanceHistoryRow(
                title: 'Depart ${group.siteLabel}',
                subtitle: group.departure == null
                    ? (group.showPendingDeparture ? 'En attente' : '--:--')
                    : timeFormatter(group.departure!.timestamp),
                trailing: group.departure == null
                    ? '--:--'
                    : timeFormatter(group.departure!.timestamp),
                icon: Icons.logout_rounded,
                iconBackground: const Color(0xFFE85C6E).withValues(alpha: 0.14),
                iconColor: const Color(0xFFE05B73),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendanceHistoryRow extends StatelessWidget {
  const _AttendanceHistoryRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBackground,
            ),
            child: Icon(icon, color: iconColor, size: 26),
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
                  subtitle,
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
            trailing,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF16234B),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceDayGroup {
  const _AttendanceDayGroup({
    required this.label,
    required this.siteLabel,
    required this.arrival,
    required this.departure,
    required this.showPendingDeparture,
  });

  final String label;
  final String siteLabel;
  final AttendanceRecord? arrival;
  final AttendanceRecord? departure;
  final bool showPendingDeparture;
}
