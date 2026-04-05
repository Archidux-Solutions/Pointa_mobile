import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/theme/app_radius.dart';
import 'package:pointa_mobile/core/theme/app_spacing.dart';
import 'package:pointa_mobile/core/widgets/app_async_state.dart';
import 'package:pointa_mobile/core/widgets/app_bottom_nav.dart';
import 'package:pointa_mobile/core/widgets/app_card.dart';
import 'package:pointa_mobile/core/widgets/app_feedback_overlay.dart';
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
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    
    try {
      final record = await ref
          .read(attendanceRepositoryProvider)
          .toggleAttendance();
      refreshAttendanceReadModels(ref);

      if (!mounted) return;

      // Feedback premium avec overlay animé
      final isCheckIn = record.actionType == AttendanceActionType.checkIn;
      final time = _formatTime(record.timestamp);
      
      await AppAttendanceSuccessOverlay.show(
        context,
        isCheckIn: isCheckIn,
        time: time,
        location: record.siteLabel,
      );
      
    } on AttendanceException catch (error) {
      if (!mounted) return;
      
      await AppFeedbackOverlay.error(
        context,
        title: 'Erreur de pointage',
        message: error.message,
      );
    } catch (_) {
      if (!mounted) return;
      
      await AppFeedbackOverlay.error(
        context,
        title: 'Erreur',
        message: 'Action impossible, réessayez.',
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
    final statusAsync = ref.watch(attendanceStatusProvider);
    final historyAsync = ref.watch(attendanceHistoryProvider);
    final pendingSyncAsync = ref.watch(attendancePendingSyncCountProvider);
    final isSyncing = ref.watch(attendanceSyncingProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: const AppSectionAppBar(title: 'Pointage'),
      body: ListView(
        padding: AppSpacing.pageWithNav,
        children: [
          // Hero Card - Statut et action principale
          statusAsync.when(
            loading: () => const AppLoadingState(
              message: 'Chargement du statut...',
            ),
            error: (_, __) => AppErrorState(
              title: 'Statut indisponible',
              message: 'Impossible de charger le statut de pointage.',
              onRetry: () => ref.invalidate(attendanceStatusProvider),
            ),
            data: (status) => _AttendanceHeroCard(
              isCheckedIn: status.isCheckedIn,
              siteLabel: status.siteLabel,
              radiusMeters: status.radiusMeters,
              onPressed: _toggleAttendance,
              isLoading: _isSubmitting,
            ),
          ),
          
          AppSpacing.verticalMd,
          
          // Carte de synchronisation en attente
          pendingSyncAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (pendingCount) {
              if (pendingCount == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _PendingSyncCard(
                  pendingCount: pendingCount,
                  isSyncing: isSyncing,
                  onPressed: _retrySyncNow,
                ),
              );
            },
          ),
          
          // Historique du jour
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historique du jour',
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
                    message: 'Impossible de charger les dernières actions.',
                    asCard: false,
                    compact: true,
                    onRetry: () => ref.invalidate(attendanceHistoryProvider),
                  ),
                  data: (history) {
                    if (history.isEmpty) {
                      return const AppEmptyState(
                        title: 'Aucune action',
                        message: 'Vos pointages apparaîtront ici.',
                        icon: Icons.schedule_outlined,
                        asCard: false,
                        compact: true,
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
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
        selectedIndex: 2, // Pointage est maintenant au centre (index 2)
        onSelected: (index) => _handleBottomNavSelection(context, index),
      ),
    );
  }
}

/// Hero Card de pointage avec statut et bouton d'action
class _AttendanceHeroCard extends StatefulWidget {
  const _AttendanceHeroCard({
    required this.isCheckedIn,
    required this.siteLabel,
    required this.radiusMeters,
    required this.onPressed,
    required this.isLoading,
  });

  final bool isCheckedIn;
  final String siteLabel;
  final int? radiusMeters;
  final Future<void> Function() onPressed;
  final bool isLoading;

  @override
  State<_AttendanceHeroCard> createState() => _AttendanceHeroCardState();
}

class _AttendanceHeroCardState extends State<_AttendanceHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Animation de pulsation subtile pour le cercle de statut
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _statusText => widget.isCheckedIn ? 'En service' : 'Hors service';
  String get _actionText => widget.isCheckedIn ? 'Pointer le départ' : "Pointer l'arrivée";
  IconData get _actionIcon => widget.isCheckedIn ? Icons.logout_rounded : Icons.login_rounded;
  Color get _actionIconColor => widget.isCheckedIn ? AppColors.danger : AppColors.success;
  Color get _statusDotColor => widget.isCheckedIn ? AppColors.success : AppColors.neutral400;

  @override
  Widget build(BuildContext context) {
    return AppHeroCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              // Cercle de statut animé
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isCheckedIn ? _pulseAnimation.value : 1.0,
                    child: Container(
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
                        widget.isCheckedIn ? Icons.check_rounded : Icons.schedule_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
              
              AppSpacing.horizontalMd,
              
              // Infos statut
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Dot de statut
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _statusDotColor,
                            boxShadow: widget.isCheckedIn
                                ? [
                                    BoxShadow(
                                      color: AppColors.success.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Zone et rayon
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.siteLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (widget.radiusMeters != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            '${widget.radiusMeters}m',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
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
          
          const SizedBox(height: AppSpacing.lg),
          
          // Bouton d'action principal
          _AttendanceActionButton(
            label: _actionText,
            icon: _actionIcon,
            iconColor: _actionIconColor,
            isLoading: widget.isLoading,
            onPressed: widget.onPressed,
          ),
        ],
      ),
    );
  }
}

/// Bouton d'action de pointage (dans le hero card)
class _AttendanceActionButton extends StatefulWidget {
  const _AttendanceActionButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isLoading;
  final Future<void> Function() onPressed;

  @override
  State<_AttendanceActionButton> createState() => _AttendanceActionButtonState();
}

class _AttendanceActionButtonState extends State<_AttendanceActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isLoading) return;
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isLoading) return;
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Carte indiquant les actions en attente de synchronisation
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
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Icône sync
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.sync_rounded,
              color: AppColors.warning,
              size: 22,
            ),
          ),
          AppSpacing.horizontalSm,
          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pendingCount action(s) en attente',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Synchronisez pour envoyer au serveur',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          // Bouton sync
          TextButton(
            onPressed: isSyncing ? null : () => onPressed(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSyncing)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.warning,
                    ),
                  )
                else
                  const Icon(Icons.sync_rounded, size: 18),
                const SizedBox(width: 6),
                Text(isSyncing ? 'Sync...' : 'Sync'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Groupe d'historique pour un jour
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
      children: [
        // Label du jour
        Text(
          group.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Card avec arrivée et départ
        Container(
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.neutral200),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              // Arrivée
              _AttendanceHistoryRow(
                label: 'Arrivée',
                time: group.arrival != null
                    ? timeFormatter(group.arrival!.timestamp)
                    : '--:--',
                isCheckIn: true,
                isPending: false,
              ),
              
              const Divider(height: 1, color: AppColors.neutral200),
              
              // Départ
              _AttendanceHistoryRow(
                label: 'Départ',
                time: group.departure != null
                    ? timeFormatter(group.departure!.timestamp)
                    : '--:--',
                isCheckIn: false,
                isPending: group.showPendingDeparture,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Ligne d'historique (arrivée ou départ)
class _AttendanceHistoryRow extends StatelessWidget {
  const _AttendanceHistoryRow({
    required this.label,
    required this.time,
    required this.isCheckIn,
    required this.isPending,
  });

  final String label;
  final String time;
  final bool isCheckIn;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final iconColor = isCheckIn ? AppColors.success : AppColors.danger;
    final bgColor = isCheckIn ? AppColors.successSoft : AppColors.dangerSoft;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Icône
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(
              isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
              color: iconColor,
              size: 20,
            ),
          ),
          AppSpacing.horizontalSm,
          
          // Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral900,
                  ),
                ),
                if (isPending)
                  const Text(
                    'En cours...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          
          // Heure
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: time == '--:--' ? AppColors.neutral300 : AppColors.neutral900,
              letterSpacing: -0.5,
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
