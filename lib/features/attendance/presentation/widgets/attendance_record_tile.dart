import 'package:flutter/material.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';

class AttendanceRecordTile extends StatelessWidget {
  const AttendanceRecordTile({super.key, required this.record});

  final AttendanceRecord record;

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day/$month/$year';
  }

  String _formatTime(DateTime dateTime) {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCheckIn = record.actionType == AttendanceActionType.checkIn;
    final icon = isCheckIn ? Icons.login : Icons.logout;
    final label = isCheckIn ? 'Arrivee' : 'Depart';
    final syncSuffix = record.isPendingSync ? ' - Sync en attente' : '';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Icon(icon, size: 18)),
      title: Text('$label - ${record.siteLabel}'),
      subtitle: Text(
        '${_formatDate(record.timestamp)} a ${_formatTime(record.timestamp)}$syncSuffix',
      ),
      trailing: const Padding(
        padding: EdgeInsets.only(left: AppSpacing.sm),
        child: Icon(Icons.chevron_right),
      ),
      titleTextStyle: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      subtitleTextStyle: theme.textTheme.bodySmall,
    );
  }
}
