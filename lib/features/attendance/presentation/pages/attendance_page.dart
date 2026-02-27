import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
import 'package:pointa_mobile/core/widgets/app_card.dart';
import 'package:pointa_mobile/core/widgets/app_primary_button.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool _isCheckedIn = false;
  DateTime? _lastActionAt;

  void _toggleAttendance() {
    setState(() {
      _isCheckedIn = !_isCheckedIn;
      _lastActionAt = DateTime.now();
    });

    final action = _isCheckedIn ? 'arrivee enregistree' : 'depart enregistre';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Pointage mock: $action')));
  }

  String _formatTime(DateTime dateTime) {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusText = _isCheckedIn ? 'En service' : 'Hors service';
    final actionText = _isCheckedIn ? 'Pointer depart' : 'Pointer arrivee';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pointage'),
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Etat actuel: $statusText',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Zone GPS (mock): Siege Ouaga - Rayon 60m',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _lastActionAt == null
                      ? 'Aucun pointage aujourd hui.'
                      : 'Derniere action a ${_formatTime(_lastActionAt!)}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                AppPrimaryButton(
                  label: actionText,
                  onPressed: () async => _toggleAttendance(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Text(
              'Mode mock actif: ce flow est testable sans endpoint backend.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
