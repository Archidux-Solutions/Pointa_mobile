import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
import 'package:pointa_mobile/core/widgets/app_async_state.dart';
import 'package:pointa_mobile/core/widgets/app_bottom_nav.dart';
import 'package:pointa_mobile/core/widgets/app_card.dart';
import 'package:pointa_mobile/core/widgets/app_page_bars.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  DateTimeRange? _selectedRange;

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  DateTime _dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  bool _isWithinRange(DateTime value, DateTimeRange range) {
    final date = _dateOnly(value);
    final start = _dateOnly(range.start);
    final end = _dateOnly(range.end);
    return !date.isBefore(start) && !date.isAfter(end);
  }

  DateTimeRange _defaultRangeForHistory(List<AttendanceRecord> history) {
    if (history.isEmpty) {
      final now = DateTime.now();
      return DateTimeRange(start: now, end: now);
    }

    final sorted = history.map((record) => record.timestamp).toList()
      ..sort((a, b) => a.compareTo(b));

    return DateTimeRange(
      start: _dateOnly(sorted.first),
      end: _dateOnly(sorted.last),
    );
  }

  String _formatShortDate(DateTime dateTime) {
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

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  String _formatDayLabel(DateTime dateTime) {
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

  List<_HistoryDayGroup> _groupHistory(
    List<AttendanceRecord> history,
    DateTimeRange range,
  ) {
    final filtered = history
        .where((record) => _isWithinRange(record.timestamp, range))
        .toList();

    final grouped = <DateTime, List<AttendanceRecord>>{};
    for (final record in filtered) {
      final key = _dateOnly(record.timestamp);
      grouped.putIfAbsent(key, () => <AttendanceRecord>[]).add(record);
    }

    final sortedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedDays.map((day) {
      final records = grouped[day]!
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final arrivals = records
          .where((record) => record.actionType == AttendanceActionType.checkIn)
          .toList();
      final departures = records
          .where((record) => record.actionType == AttendanceActionType.checkOut)
          .toList();

      return _HistoryDayGroup(
        label: _formatDayLabel(day),
        siteLabel: records.first.siteLabel,
        arrival: arrivals.isEmpty ? null : arrivals.first,
        departure: departures.isEmpty ? null : departures.last,
      );
    }).toList();
  }

  Future<void> _pickDateRange(DateTimeRange currentRange) async {
    final firstDate = currentRange.start.subtract(const Duration(days: 365));
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final pickedRange = await showDateRangePicker(
      context: context,
      locale: const Locale('fr'),
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: currentRange,
      initialEntryMode: DatePickerEntryMode.calendar,
      helpText: 'Choisir une plage',
      saveText: 'Valider',
      cancelText: 'Annuler',
      confirmText: 'Valider',
      fieldStartHintText: 'Date debut',
      fieldEndHintText: 'Date fin',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange == null) {
      return;
    }

    setState(() {
      _selectedRange = DateTimeRange(
        start: _dateOnly(pickedRange.start),
        end: _dateOnly(pickedRange.end),
      );
    });
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
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(attendanceHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: const AppSectionAppBar(title: 'Historique'),
      body: ListView(
        padding: AppSpacing.pageWithNav,
        children: [
          historyAsync.when(
            loading: () => const AppLoadingState(
              message: 'Chargement de l\'historique...',
            ),
            error: (_, __) => AppErrorState(
              title: 'Erreur de chargement',
              message: 'Impossible de récupérer l\'historique.',
              onRetry: () => ref.invalidate(attendanceHistoryProvider),
              retryButtonKey: const Key('history_retry_button'),
            ),
            data: (history) {
              final effectiveRange =
                  _selectedRange ?? _defaultRangeForHistory(history);
              final groups = _groupHistory(history, effectiveRange);

              return Column(
                children: [
                  // Sélecteur de période
                  _DateRangeCard(
                    label:
                        'Du ${_formatShortDate(effectiveRange.start)} au ${_formatShortDate(effectiveRange.end)}',
                    onTap: () => _pickDateRange(effectiveRange),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(color: AppColors.neutral200),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Liste des pointages
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: groups.isEmpty
                        ? const AppEmptyState(
                            title: 'Aucun pointage',
                            message: 'Choisissez une autre période.',
                            icon: Icons.history_outlined,
                            asCard: false,
                            compact: true,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: groups.map((group) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: _HistoryDayCard(
                                  group: group,
                                  timeFormatter: _formatTime,
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              );
            },
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

class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('history_date_range_button'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE6E3EF)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x09111B33),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF253056),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFF7A87B0),
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryDayCard extends StatelessWidget {
  const _HistoryDayCard({required this.group, required this.timeFormatter});

  final _HistoryDayGroup group;
  final String Function(DateTime) timeFormatter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          group.label,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D2752),
          ),
        ),
        const SizedBox(height: 16),
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
              _HistoryRow(
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
              _HistoryRow(
                title: 'Depart ${group.siteLabel}',
                subtitle: group.departure == null
                    ? 'En attente'
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

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
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

class _HistoryDayGroup {
  const _HistoryDayGroup({
    required this.label,
    required this.siteLabel,
    required this.arrival,
    required this.departure,
  });

  final String label;
  final String siteLabel;
  final AttendanceRecord? arrival;
  final AttendanceRecord? departure;
}
