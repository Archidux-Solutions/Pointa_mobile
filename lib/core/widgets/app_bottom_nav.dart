import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = <_BottomNavItemData>[
      _BottomNavItemData(label: 'Accueil', icon: Icons.home_rounded),
      _BottomNavItemData(label: 'Pointage', icon: Icons.assignment_rounded),
      _BottomNavItemData(label: 'Historique', icon: Icons.history_rounded),
      _BottomNavItemData(label: 'Recap', icon: Icons.access_time_rounded),
      _BottomNavItemData(label: 'Profil', icon: Icons.person_outline_rounded),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F4F9).withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFE6E3EF)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x120D1B3D),
                blurRadius: 26,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: List<Widget>.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == selectedIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSelected(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE9EEFF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            item.icon,
                            color: isSelected
                                ? const Color(0xFF456BEE)
                                : const Color(0xFF8E93AA),
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF456BEE)
                                : const Color(0xFF747A92),
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItemData {
  const _BottomNavItemData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
