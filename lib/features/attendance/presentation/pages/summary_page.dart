import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/widgets/app_async_state.dart';
import 'package:pointa_mobile/core/widgets/app_bottom_nav.dart';
import 'package:pointa_mobile/core/widgets/app_page_bars.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';

class SummaryPage extends ConsumerStatefulWidget {
  const SummaryPage({super.key});

  @override
  ConsumerState<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends ConsumerState<SummaryPage> {
  static const _dailyTargetMinutes = 8 * 60;
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

  bool _isWeekday(DateTime dateTime) => dateTime.weekday <= DateTime.friday;

  bool _isLateArrival(DateTime timestamp) {
    final threshold = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
      8,
      10,
    );
    return timestamp.isAfter(threshold);
  }

  DateTimeRange _defaultRangeForSummary(List<AttendanceRecord> history) {
    final anchor = history.isEmpty
        ? _dateOnly(DateTime.now())
        : _dateOnly(
            history
                .map((record) => record.timestamp)
                .reduce((left, right) => left.isAfter(right) ? left : right),
          );

    return DateTimeRange(
      start: anchor.subtract(const Duration(days: 6)),
      end: anchor,
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

  String _formatShortWeekday(DateTime dateTime) {
    const weekdays = <String>['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return weekdays[dateTime.weekday - 1];
  }

  String _formatLargeDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours h ${remainingMinutes.toString().padLeft(2, '0')}';
  }

  String _formatCompactDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h${remainingMinutes.toString().padLeft(2, '0')}';
  }

  int _calculateWorkedMinutesForDay(List<AttendanceRecord> records) {
    if (records.isEmpty) {
      return 0;
    }

    final chronological = List<AttendanceRecord>.from(records)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    DateTime? openCheckIn;
    var workedMinutes = 0;

    for (final record in chronological) {
      if (record.actionType == AttendanceActionType.checkIn) {
        openCheckIn = record.timestamp;
        continue;
      }

      if (openCheckIn == null) {
        continue;
      }

      if (record.timestamp.isAfter(openCheckIn)) {
        workedMinutes += record.timestamp.difference(openCheckIn).inMinutes;
      }
      openCheckIn = null;
    }

    return workedMinutes;
  }

  _SummaryInsights _buildInsights(
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

    final groups = <_SummaryDayGroup>[];
    final chartPoints = <_SummaryChartPoint>[];
    var workedMinutes = 0;
    var lateCount = 0;
    var absenceCount = 0;
    var workingDays = 0;

    var day = _dateOnly(range.start);
    final lastDay = _dateOnly(range.end);

    while (!day.isAfter(lastDay)) {
      final records = List<AttendanceRecord>.from(grouped[day] ?? const [])
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final checkIns = records
          .where((record) => record.actionType == AttendanceActionType.checkIn)
          .toList();
      final checkOuts = records
          .where((record) => record.actionType == AttendanceActionType.checkOut)
          .toList();

      final arrival = checkIns.isEmpty ? null : checkIns.first;
      final departure = checkOuts.isEmpty ? null : checkOuts.last;
      final dayWorkedMinutes = _calculateWorkedMinutesForDay(records);
      final isWorkingDay = _isWeekday(day);
      final isLate = arrival != null && _isLateArrival(arrival.timestamp);
      final isAbsent = isWorkingDay && records.isEmpty;

      if (isWorkingDay) {
        workingDays++;
      }

      workedMinutes += dayWorkedMinutes;
      if (isLate) {
        lateCount++;
      }
      if (isAbsent) {
        absenceCount++;
      }

      chartPoints.add(
        _SummaryChartPoint(
          label: _formatShortWeekday(day),
          workedMinutes: dayWorkedMinutes,
          isLate: isLate,
          isAbsent: isAbsent,
        ),
      );

      if (records.isNotEmpty) {
        groups.add(
          _SummaryDayGroup(
            label: _formatDayLabel(day),
            siteLabel:
                arrival?.siteLabel ?? departure?.siteLabel ?? 'Siege Ouaga',
            arrival: arrival,
            departure: departure,
          ),
        );
      }

      day = day.add(const Duration(days: 1));
    }

    final visibleChart = chartPoints.length <= 7
        ? chartPoints
        : chartPoints.sublist(chartPoints.length - 7);

    return _SummaryInsights(
      workedMinutes: workedMinutes,
      expectedMinutes: workingDays * _dailyTargetMinutes,
      lateCount: lateCount,
      absenceCount: absenceCount,
      workingDays: workingDays,
      groups: groups.reversed.toList(),
      chartPoints: visibleChart,
    );
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
    final historyAsync = ref.watch(attendanceHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F7),
      appBar: const AppSectionAppBar(title: 'Recap heures & retards'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
        children: <Widget>[
          historyAsync.when(
            loading: () =>
                const AppLoadingState(message: 'Chargement du recap...'),
            error: (_, _) => AppErrorState(
              title: 'Recap indisponible',
              message: 'Impossible de charger le recap des heures et retards.',
              onRetry: () => ref.invalidate(attendanceHistoryProvider),
              retryButtonKey: const Key('summary_retry_button'),
            ),
            data: (history) {
              final effectiveRange =
                  _selectedRange ?? _defaultRangeForSummary(history);
              final insights = _buildInsights(history, effectiveRange);

              return Column(
                children: <Widget>[
                  _SummaryHeroCard(
                    rangeLabel:
                        'Du ${_formatShortDate(effectiveRange.start)} au ${_formatShortDate(effectiveRange.end)}',
                    workedValue: _formatLargeDuration(insights.workedMinutes),
                    workedCaption:
                        '${_formatCompactDuration(insights.workedMinutes)} / ${_formatCompactDuration(insights.expectedMinutes)}',
                    workedProgress: insights.expectedMinutes == 0
                        ? 0
                        : insights.workedMinutes / insights.expectedMinutes,
                    lateValue: '${insights.lateCount}',
                    lateCaption:
                        '${insights.lateCount} en retard / ${insights.workingDays} jours',
                    lateProgress: insights.workingDays == 0
                        ? 0
                        : insights.lateCount / insights.workingDays,
                    onDateTap: () => _pickDateRange(effectiveRange),
                  ),
                  const SizedBox(height: 22),
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
                    child: insights.groups.isEmpty
                        ? const AppEmptyState(
                            title: 'Aucune donnee sur cette periode',
                            message:
                                'Choisissez une autre plage pour afficher le recap.',
                            asCard: false,
                          )
                        : Column(
                            children: <Widget>[
                              ...insights.groups.map((group) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: _SummaryDayCard(
                                    group: group,
                                    timeFormatter: _formatTime,
                                  ),
                                );
                              }),
                              _SummaryChartCard(
                                points: insights.chartPoints,
                                maxWorkedMinutes: math.max(
                                  _dailyTargetMinutes,
                                  insights.chartPoints.fold<int>(
                                    0,
                                    (maxMinutes, point) => math.max(
                                      maxMinutes,
                                      point.workedMinutes,
                                    ),
                                  ),
                                ),
                                absenceCount: insights.absenceCount,
                              ),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 3,
        onSelected: (index) => _handleBottomNavSelection(context, index),
      ),
    );
  }
}

class _SummaryHeroCard extends StatelessWidget {
  const _SummaryHeroCard({
    required this.rangeLabel,
    required this.workedValue,
    required this.workedCaption,
    required this.workedProgress,
    required this.lateValue,
    required this.lateCaption,
    required this.lateProgress,
    required this.onDateTap,
  });

  final String rangeLabel;
  final String workedValue;
  final String workedCaption;
  final double workedProgress;
  final String lateValue;
  final String lateCaption;
  final double lateProgress;
  final VoidCallback onDateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF5B7CF5), Color(0xFF6E97FF)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x2C4D73F4),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -40,
            right: -28,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Recap de la semaine',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rangeLabel,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 17,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkResponse(
                      key: const Key('summary_date_range_button'),
                      onTap: onDateTap,
                      radius: 26,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: const Color(0xFFE4E4F2)),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  child: IntrinsicHeight(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _SummaryMetricPanel(
                            title: 'Temps travaille',
                            value: workedValue,
                            caption: workedCaption,
                            progress: workedProgress,
                            icon: Icons.schedule_rounded,
                            iconColor: const Color(0xFF4BAEB1),
                            iconBackground: const Color(
                              0xFF4BAEB1,
                            ).withValues(alpha: 0.18),
                            progressColor: const Color(0xFF54B8B9),
                          ),
                        ),
                        VerticalDivider(
                          color: const Color(0xFFE7E4EE).withValues(alpha: 0.9),
                          width: 22,
                          thickness: 1,
                        ),
                        Expanded(
                          child: _SummaryMetricPanel(
                            title: 'Retards',
                            value: lateValue,
                            caption: lateCaption,
                            progress: lateProgress,
                            icon: Icons.rotate_right_rounded,
                            iconColor: const Color(0xFFC9A239),
                            iconBackground: const Color(0xFFF0D890),
                            progressColor: const Color(0xFFE4C25A),
                          ),
                        ),
                      ],
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

class _SummaryMetricPanel extends StatelessWidget {
  const _SummaryMetricPanel({
    required this.title,
    required this.value,
    required this.caption,
    required this.progress,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.progressColor,
  });

  final String title;
  final String value;
  final String caption;
  final double progress;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBackground,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF243154),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF15244E),
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 11,
            backgroundColor: const Color(0xFFE6E7F2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: const Color(0xFF757C96),
          ),
        ),
      ],
    );
  }
}

class _SummaryDayCard extends StatelessWidget {
  const _SummaryDayCard({required this.group, required this.timeFormatter});

  final _SummaryDayGroup group;
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
              _SummaryHistoryRow(
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
              _SummaryHistoryRow(
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

class _SummaryHistoryRow extends StatelessWidget {
  const _SummaryHistoryRow({
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

class _SummaryChartCard extends StatelessWidget {
  const _SummaryChartCard({
    required this.points,
    required this.maxWorkedMinutes,
    required this.absenceCount,
  });

  final List<_SummaryChartPoint> points;
  final int maxWorkedMinutes;
  final int absenceCount;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAFD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9E6EF)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: <Widget>[
              _ChartLegend(
                label: 'Temps travailles',
                color: const Color(0xFF54B8B9),
              ),
              _ChartLegend(label: 'Retards', color: const Color(0xFFE4C25A)),
              _ChartLegend(label: 'Absences', color: const Color(0xFFE0718A)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((point) {
                return Expanded(
                  child: _ChartBarGroup(
                    point: point,
                    maxWorkedMinutes: maxWorkedMinutes,
                  ),
                );
              }).toList(),
            ),
          ),
          if (absenceCount > 0) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              '$absenceCount absence(s) detectee(s) sur la plage selectionnee.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF7A8098),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF535C7B),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _ChartBarGroup extends StatelessWidget {
  const _ChartBarGroup({required this.point, required this.maxWorkedMinutes});

  final _SummaryChartPoint point;
  final int maxWorkedMinutes;

  @override
  Widget build(BuildContext context) {
    final workedHeight = point.workedMinutes == 0
        ? 4.0
        : 12 + (point.workedMinutes / maxWorkedMinutes) * 54;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _ChartBar(height: workedHeight, color: const Color(0xFF54B8B9)),
                const SizedBox(width: 2),
                _ChartBar(
                  height: point.isLate ? 28 : 8,
                  color: point.isLate
                      ? const Color(0xFFE4C25A)
                      : const Color(0xFFE7E4EF),
                ),
                const SizedBox(width: 2),
                _ChartBar(
                  height: point.isAbsent ? 28 : 8,
                  color: point.isAbsent
                      ? const Color(0xFFE0718A)
                      : const Color(0xFFE7E4EF),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          point.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF66708E),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    );
  }
}

class _SummaryInsights {
  const _SummaryInsights({
    required this.workedMinutes,
    required this.expectedMinutes,
    required this.lateCount,
    required this.absenceCount,
    required this.workingDays,
    required this.groups,
    required this.chartPoints,
  });

  final int workedMinutes;
  final int expectedMinutes;
  final int lateCount;
  final int absenceCount;
  final int workingDays;
  final List<_SummaryDayGroup> groups;
  final List<_SummaryChartPoint> chartPoints;
}

class _SummaryDayGroup {
  const _SummaryDayGroup({
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

class _SummaryChartPoint {
  const _SummaryChartPoint({
    required this.label,
    required this.workedMinutes,
    required this.isLate,
    required this.isAbsent,
  });

  final String label;
  final int workedMinutes;
  final bool isLate;
  final bool isAbsent;
}
