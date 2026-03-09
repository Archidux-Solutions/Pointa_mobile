import 'package:flutter/material.dart';

class AppSectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppSectionAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFF3F2F7),
      foregroundColor: const Color(0xFF18234D),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 74,
      titleSpacing: 20,
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF18234D),
        ),
      ),
      actions: actions,
    );
  }
}

class AppHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppHomeAppBar({
    super.key,
    required this.displayName,
    required this.onSignOut,
  });

  final String displayName;
  final Future<void> Function() onSignOut;

  @override
  Size get preferredSize => const Size.fromHeight(96);

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
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFF3F2F7),
      foregroundColor: const Color(0xFF18234D),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 96,
      titleSpacing: 20,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Bonjour,',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF253056),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF17224B),
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: PopupMenuButton<_HeaderMenuAction>(
            tooltip: 'Actions du compte',
            offset: const Offset(0, 62),
            onSelected: (action) {
              if (action == _HeaderMenuAction.signOut) {
                onSignOut();
              }
            },
            itemBuilder: (context) => const <PopupMenuEntry<_HeaderMenuAction>>[
              PopupMenuItem<_HeaderMenuAction>(
                value: _HeaderMenuAction.signOut,
                child: Text('Se deconnecter'),
              ),
            ],
            child: Container(
              width: 58,
              height: 58,
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
        ),
      ],
    );
  }
}

enum _HeaderMenuAction { signOut }
