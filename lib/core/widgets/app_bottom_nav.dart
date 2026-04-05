import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointa_mobile/core/theme/app_colors.dart';
import 'package:pointa_mobile/core/theme/app_durations.dart';
import 'package:pointa_mobile/core/theme/app_elevation.dart';
import 'package:pointa_mobile/core/theme/app_radius.dart';

/// Design System - Bottom Navigation Bar
/// 
/// Barre de navigation principale avec 5 onglets.
/// Le bouton central "Pointage" est visuellement différencié
/// car c'est l'action principale de l'application.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = <_BottomNavItemData>[
    _BottomNavItemData(
      label: 'Accueil',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _BottomNavItemData(
      label: 'Historique',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
    ),
    _BottomNavItemData(
      label: 'Pointage',
      icon: Icons.fingerprint_outlined,
      activeIcon: Icons.fingerprint_rounded,
      isPrimary: true,
    ),
    _BottomNavItemData(
      label: 'Recap',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
    ),
    _BottomNavItemData(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.neutral200),
          boxShadow: [AppElevation.elevated],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: List<Widget>.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = index == selectedIndex;

              // Bouton central différencié (Pointage)
              if (item.isPrimary) {
                return Expanded(
                  child: _PrimaryNavItem(
                    item: item,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onSelected(index);
                    },
                  ),
                );
              }

              return Expanded(
                child: _NavItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onSelected(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Item standard de la navigation
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _BottomNavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AppDurations.fast,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? AppColors.primary : AppColors.neutral400,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.neutral400,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item central "Pointage" avec style différencié
class _PrimaryNavItem extends StatelessWidget {
  const _PrimaryNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _BottomNavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AppDurations.fast,
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: isSelected 
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    )
                  : null,
              color: isSelected ? null : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: isSelected 
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.neutral500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItemData {
  const _BottomNavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isPrimary;
}
