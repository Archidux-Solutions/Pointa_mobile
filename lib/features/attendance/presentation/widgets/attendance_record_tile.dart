import 'package:flutter/material.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
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
    final icon = isCheckIn ? Icons.login_rounded : Icons.logout_rounded;
    final label = isCheckIn ? 'Arrivee' : 'Depart';
    final syncSuffix = record.isPendingSync ? ' - Sync en attente' : '';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              icon,
              size: 18,
              color: isCheckIn ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$label - ${record.siteLabel}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(record.timestamp)} a ${_formatTime(record.timestamp)}$syncSuffix',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.mutedText),
        ],
      ),
    );
  }
}
