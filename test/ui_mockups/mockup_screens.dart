import 'package:flutter/material.dart';

abstract final class PreviewColors {
  static const bg = Color(0xFFF3F7FF);
  static const card = Colors.white;
  static const line = Color(0xFFE2E9FB);
  static const text = Color(0xFF18223F);
  static const muted = Color(0xFF7784A8);
  static const blue = Color(0xFF2F67F6);
  static const blueDark = Color(0xFF2149CC);
  static const blueSoft = Color(0xFFEAF1FF);
  static const green = Color(0xFF22BE79);
  static const greenSoft = Color(0xFFDCF8EA);
  static const yellow = Color(0xFFF2C84A);
  static const yellowSoft = Color(0xFFFFF4D6);
  static const red = Color(0xFFE45B6E);
  static const redSoft = Color(0xFFFFE6EB);
}

ThemeData previewTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: PreviewColors.bg,
    textTheme: Typography.material2021().black.copyWith(
      headlineSmall: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: PreviewColors.text,
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: PreviewColors.text,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: PreviewColors.text,
      ),
      bodyMedium: const TextStyle(fontSize: 14, color: PreviewColors.text),
      bodySmall: const TextStyle(fontSize: 12, color: PreviewColors.muted),
    ),
  );
}

class PreviewFrame extends StatelessWidget {
  const PreviewFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: previewTheme(),
      home: RepaintBoundary(
        key: const Key('preview-root'),
        child: SizedBox(
          width: 430,
          height: 932,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: PreviewColors.bg),
            child: child,
          ),
        ),
      ),
    );
  }
}

class LoginPreview extends StatelessWidget {
  const LoginPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 292,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PreviewColors.blue, PreviewColors.blueDark],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 54, 22, 28),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Pointa',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Connectez-vous pour consulter vos presences, vos horaires et votre statut du jour.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, 8),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connexion',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Accedez a votre espace employe avec une interface propre et rapide.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: PreviewColors.muted,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const InputBox(
                            label: 'Email professionnel',
                            value: 'nom@entreprise.com',
                          ),
                          const SizedBox(height: 14),
                          const InputBox(
                            label: 'Mot de passe',
                            value: '••••••••',
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Text(
                                'Se souvenir de moi',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Spacer(),
                              const Text(
                                'Mot de passe oublie ?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: PreviewColors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const PrimaryButton(label: 'Se connecter'),
                          const SizedBox(height: 18),
                          Row(
                            children: const [
                              Expanded(child: Divider(color: PreviewColors.line)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'ou',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: PreviewColors.muted,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: PreviewColors.line)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const GhostButton(label: 'Continuer avec Google'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardPreview extends StatelessWidget {
  const DashboardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Tableau de bord',
      trailingAvatar: true,
      bottomIndex: 0,
      children: [
        const GradientHero(
          badgeLabel: 'Au bureau',
          title: 'Pret a pointer votre journee',
          subtitle:
              'Visualisez votre statut, vos heures et vos retards en un coup d oeil.',
          button: PrimaryButton(label: 'Pointer maintenant', isGreen: true),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: KpiBox(
                label: 'Heures',
                value: '08 h 58',
                start: Color(0xFF30CB8A),
                end: Color(0xFF20A76F),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: KpiBox(
                label: 'Retards',
                value: '01',
                start: Color(0xFF5B8FFE),
                end: Color(0xFF4478E6),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: KpiBox(
                label: 'Absences',
                value: '00',
                start: Color(0xFFFFD95D),
                end: Color(0xFFF2BF38),
                darkText: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Statut du jour'),
              SizedBox(height: 14),
              SoftRow(
                icon: Icons.pin_drop_rounded,
                iconColor: PreviewColors.green,
                title: 'Arrivee enregistree',
                subtitle: '08:12 - Siege Ouaga',
                trailingWidget: StatusPill(
                  label: 'A jour',
                  background: PreviewColors.greenSoft,
                  foreground: Color(0xFF14965E),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const AppCard(
          child: Column(
            children: [
              SectionHeader(title: 'Actions rapides'),
              SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: QuickAction(
                      label: 'Pointer',
                      icon: Icons.touch_app_rounded,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: QuickAction(
                      label: 'Historique',
                      icon: Icons.history_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: QuickAction(
                      label: 'Recap',
                      icon: Icons.query_stats_rounded,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: QuickAction(
                      label: 'Profil',
                      icon: Icons.person_outline_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PointagePreview extends StatelessWidget {
  const PointagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Pointage',
      showBack: true,
      bottomIndex: 1,
      children: const [
        PointageHeroCard(),
        SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              SectionHeader(title: 'Planning de travail'),
              SizedBox(height: 14),
              SoftRow(
                icon: Icons.schedule_rounded,
                iconColor: PreviewColors.blue,
                title: 'Horaire general',
                subtitle: '08:00 - 17:00',
                trailingText: 'Actif',
              ),
              SizedBox(height: 12),
              SoftRow(
                icon: Icons.location_on_outlined,
                iconColor: PreviewColors.blue,
                title: 'Geofence',
                subtitle: 'Siege Ouaga - Rayon 60m',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HistoryPreview extends StatelessWidget {
  const HistoryPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Historique',
      showBack: true,
      trailingAvatar: true,
      bottomIndex: 2,
      children: const [
        GradientHero(
          title: 'Historique des presences',
          subtitle: 'Retrouvez vos pointages recents et leurs statuts sur la periode.',
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: ToolbarChip(label: '01 Mar - 31 Mar')),
            SizedBox(width: 10),
            Expanded(child: ToolbarChip(label: 'Tous les sites')),
            SizedBox(width: 10),
            Expanded(child: ToolbarChip(label: 'Filtrer')),
          ],
        ),
        SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              SectionHeader(title: 'Dernieres actions'),
              SizedBox(height: 14),
              SoftRow(
                icon: Icons.login_rounded,
                iconColor: PreviewColors.green,
                title: 'Arrivee - Siege Ouaga',
                subtitle: '06/03/2026 a 08:12',
                trailingWidget: StatusPill(
                  label: 'A l heure',
                  background: PreviewColors.greenSoft,
                  foreground: Color(0xFF14965E),
                ),
              ),
              SizedBox(height: 12),
              SoftRow(
                icon: Icons.logout_rounded,
                iconColor: PreviewColors.red,
                title: 'Depart - Siege Ouaga',
                subtitle: '05/03/2026 a 17:04',
                trailingWidget: StatusPill(
                  label: 'Complet',
                  background: PreviewColors.greenSoft,
                  foreground: Color(0xFF14965E),
                ),
              ),
              SizedBox(height: 12),
              SoftRow(
                icon: Icons.login_rounded,
                iconColor: PreviewColors.green,
                title: 'Arrivee - Siege Ouaga',
                subtitle: '04/03/2026 a 08:19',
                trailingWidget: StatusPill(
                  label: 'Retard',
                  background: PreviewColors.yellowSoft,
                  foreground: Color(0xFFAF840F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RecapPreview extends StatelessWidget {
  const RecapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Recap',
      showBack: true,
      trailingAvatar: true,
      bottomIndex: 3,
      children: const [
        GradientHero(
          title: 'Attendance',
          subtitle: 'Suivi mensuel des heures, des retards et des absences.',
        ),
        SizedBox(height: 16),
        TabsBar(),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: ToolbarChip(label: 'Janvier 2026')),
            SizedBox(width: 10),
            Expanded(child: ToolbarChip(label: 'Resume mensuel')),
          ],
        ),
        SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusPill(
                    label: '21 jours',
                    background: PreviewColors.greenSoft,
                    foreground: Color(0xFF14965E),
                  ),
                  StatusPill(
                    label: '3 absences',
                    background: PreviewColors.redSoft,
                    foreground: Color(0xFFCF4559),
                  ),
                  StatusPill(
                    label: '45 min',
                    background: PreviewColors.yellowSoft,
                    foreground: Color(0xFFAF840F),
                  ),
                ],
              ),
              SizedBox(height: 18),
              CalendarGrid(),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfilePreview extends StatelessWidget {
  const ProfilePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Profil',
      showBack: true,
      bottomIndex: 4,
      children: const [
        ProfileCard(),
        SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              SectionHeader(title: 'Informations'),
              SizedBox(height: 14),
              InfoRow(
                icon: Icons.badge_outlined,
                title: 'Matricule',
                value: 'EMP-2026-1847',
              ),
              InfoRow(
                icon: Icons.mail_outline_rounded,
                title: 'Email',
                value: 'abdoul.sinon@pointa.app',
              ),
              InfoRow(
                icon: Icons.apartment_outlined,
                title: 'Departement',
                value: 'Operations',
              ),
              InfoRow(
                icon: Icons.phone_outlined,
                title: 'Telephone',
                value: '+226 00 00 00 00',
              ),
              InfoRow(
                icon: Icons.location_on_outlined,
                title: 'Site principal',
                value: 'Siege Ouaga',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScreenShell extends StatelessWidget {
  const ScreenShell({
    super.key,
    required this.title,
    this.showBack = false,
    this.trailingAvatar = false,
    required this.children,
    this.bottomIndex,
  });

  final String title;
  final bool showBack;
  final bool trailingAvatar;
  final List<Widget> children;
  final int? bottomIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 104),
            child: Column(
              children: [
                Row(
                  children: [
                    if (showBack) ...[
                      const SquareIcon(icon: Icons.arrow_back_rounded),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    if (trailingAvatar) const AvatarBadge(),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: children,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (bottomIndex != null)
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: BottomNav(activeIndex: bottomIndex!),
          ),
      ],
    );
  }
}

class GradientHero extends StatelessWidget {
  const GradientHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeLabel,
    this.button,
  });

  final String title;
  final String subtitle;
  final String? badgeLabel;
  final Widget? button;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PreviewColors.blue, PreviewColors.blueDark],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332F67F6),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badgeLabel != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badgeLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
              height: 1.5,
            ),
          ),
          if (button != null) ...[
            const SizedBox(height: 18),
            button!,
          ],
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: PreviewColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: PreviewColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12283C6D),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.isGreen = false,
  });

  final String label;
  final bool isGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGreen
              ? const [Color(0xFF31CB8A), Color(0xFF20A76F)]
              : const [PreviewColors.blue, PreviewColors.blueDark],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (isGreen ? PreviewColors.green : PreviewColors.blue)
                .withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: PreviewColors.blueSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PreviewColors.line),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: PreviewColors.text,
          ),
        ),
      ),
    );
  }
}

class InputBox extends StatelessWidget {
  const InputBox({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PreviewColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9FD2FF), Color(0xFF7CA9FF)],
        ),
      ),
      child: const Center(
        child: Text(
          'A',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class SquareIcon extends StatelessWidget {
  const SquareIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PreviewColors.line),
      ),
      child: Icon(icon, size: 20, color: PreviewColors.text),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class KpiBox extends StatelessWidget {
  const KpiBox({
    super.key,
    required this.label,
    required this.value,
    required this.start,
    required this.end,
    this.darkText = false,
  });

  final String label;
  final String value;
  final Color start;
  final Color end;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    final textColor = darkText ? const Color(0xFF433400) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class SoftRow extends StatelessWidget {
  const SoftRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailingText,
    this.trailingWidget,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? trailingText;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PreviewColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PreviewColors.line),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (trailingWidget != null)
            trailingWidget!
          else if (trailingText != null)
            Text(
              trailingText!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: PreviewColors.green,
              ),
            ),
        ],
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  const QuickAction({super.key, required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PreviewColors.blueSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PreviewColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: PreviewColors.blue),
          ),
          const Spacer(),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ToolbarChip extends StatelessWidget {
  const ToolbarChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PreviewColors.line),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: PreviewColors.text,
          ),
        ),
      ),
    );
  }
}

class TabsBar extends StatelessWidget {
  const TabsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PreviewColors.line),
      ),
      child: const Row(
        children: [
          Expanded(child: TabItem(label: 'Resume', active: true)),
          SizedBox(width: 8),
          Expanded(child: TabItem(label: 'Calendrier')),
        ],
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  const TabItem({super.key, required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: active ? PreviewColors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        boxShadow: active
            ? const [
                BoxShadow(
                  color: Color(0x242F67F6),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : PreviewColors.muted,
          ),
        ),
      ),
    );
  }
}

class PointageHeroCard extends StatelessWidget {
  const PointageHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [PreviewColors.blue, PreviewColors.blueDark],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presence du jour',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Controle rapide de votre arrivee et de votre depart.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.84),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Text(
                  '08:12:00',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Vendredi 6 mars 2026',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                Container(
                  width: 126,
                  height: 126,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4AE29D), Color(0xFF24BF79)],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.touch_app_rounded, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'Pointer\nle depart',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(
                      child: MiniInfo(
                        title: 'Arrivee',
                        value: '08:12',
                        subtitle: 'Siege Ouaga',
                        color: PreviewColors.green,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: MiniInfo(
                        title: 'Depart prevu',
                        value: '17:00',
                        subtitle: 'En cours',
                        color: PreviewColors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MiniInfo extends StatelessWidget {
  const MiniInfo({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = ['DIM', 'LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM'];
    final values = [
      ('01', '08:00', false),
      ('02', '08:04', false),
      ('03', '08:00', false),
      ('04', '08:15', false),
      ('05', '08:00', false),
      ('06', '08:12', true),
      ('07', '00:00', false),
      ('08', '08:00', false),
      ('09', '08:00', false),
      ('10', '08:17', false),
      ('11', '08:00', false),
      ('12', '08:00', false),
      ('13', '08:06', false),
      ('14', '00:00', false),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels
              .map(
                (label) => SizedBox(
                  width: 44,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: PreviewColors.muted,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((value) {
            return Container(
              width: 48,
              height: 58,
              decoration: BoxDecoration(
                color: value.$3 ? const Color(0xFFEEF3FF) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: value.$3
                      ? const Color(0xFFCFE0FF)
                      : PreviewColors.line,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.$1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: PreviewColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value.$2,
                    style: const TextStyle(
                      fontSize: 10,
                      color: PreviewColors.muted,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFBDE1FF), Color(0xFF7FAAFF)],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Abdoul Sinon',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Agent operations',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          const SizedBox(
            width: 154,
            child: GhostButton(label: 'Modifier le profil'),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: PreviewColors.line),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: PreviewColors.blueSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: PreviewColors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final items = ['Accueil', 'Presence', 'Historique', 'Recap', 'Profil'];
    return Container(
      height: 72,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PreviewColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14283C6D),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final active = index == activeIndex;
          return Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: active ? PreviewColors.blueSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  items[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: active ? PreviewColors.blue : PreviewColors.muted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
