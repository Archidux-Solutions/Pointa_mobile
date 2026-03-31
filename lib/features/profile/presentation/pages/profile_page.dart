import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/widgets/app_bottom_nav.dart';
import 'package:pointa_mobile/core/widgets/app_page_bars.dart';
import 'package:pointa_mobile/features/auth/application/auth_controller.dart';
import 'package:pointa_mobile/features/auth/domain/exceptions/auth_exception.dart';
import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String _displayName(UserSession? session) {
    final value = session?.displayName.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return 'Membre Pointa';
  }

  String _email(UserSession? session) {
    final value = session?.email.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return 'contact@pointa.app';
  }

  String _phoneNumber(UserSession? session) {
    final value = session?.phoneNumber?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return '+226 70 12 34 56';
  }

  String _employeeCode(UserSession? session) {
    final userId = session?.userId.trim();
    if (userId == null || userId.isEmpty) {
      return 'PT-001';
    }

    final suffix = userId
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase()
        .padLeft(6, '0');
    return 'PT-${suffix.substring(suffix.length - 6)}';
  }

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

  Future<void> _openEditProfileSheet(UserSession? session) async {
    final nameController = TextEditingController(text: _displayName(session));
    final emailController = TextEditingController(text: _email(session));
    final phoneController = TextEditingController(text: _phoneNumber(session));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FB),
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Editer le profil',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2550),
                  ),
                ),
                const SizedBox(height: 18),
                _ProfileField(
                  controller: nameController,
                  label: 'Nom complet',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                _ProfileField(
                  controller: emailController,
                  label: 'Adresse e-mail',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _ProfileField(
                  controller: phoneController,
                  label: 'Telephone',
                  icon: Icons.call_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('profile_save_button'),
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(this.context);

                      try {
                        await ref
                            .read(authControllerProvider.notifier)
                            .updateProfile(
                              displayName: nameController.text,
                              email: emailController.text,
                              phoneNumber: phoneController.text,
                            );
                        if (!mounted) {
                          return;
                        }
                        navigator.pop();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Profil mis a jour.')),
                        );
                      } on AuthException catch (error) {
                        if (!mounted) {
                          return;
                        }
                        messenger.showSnackBar(
                          SnackBar(content: Text(error.message)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A7DF5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openPasswordSheet() async {
    final currentController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FB),
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Changer le mot de passe',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2550),
                  ),
                ),
                const SizedBox(height: 18),
                _ProfileField(
                  controller: currentController,
                  label: 'Mot de passe actuel',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 14),
                _ProfileField(
                  controller: passwordController,
                  label: 'Nouveau mot de passe',
                  icon: Icons.lock_reset_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 14),
                _ProfileField(
                  controller: confirmController,
                  label: 'Confirmer le mot de passe',
                  icon: Icons.verified_user_outlined,
                  obscureText: true,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('profile_password_submit_button'),
                    onPressed: () async {
                      if (passwordController.text.trim().isEmpty ||
                          confirmController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('Renseignez tous les champs.'),
                          ),
                        );
                        return;
                      }

                      if (passwordController.text != confirmController.text) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Les mots de passe ne correspondent pas.',
                            ),
                          ),
                        );
                        return;
                      }

                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(this.context);

                      try {
                        await ref
                            .read(authControllerProvider.notifier)
                            .changePassword(
                              oldPassword: currentController.text,
                              newPassword: passwordController.text,
                            );
                        if (!mounted) {
                          return;
                        }
                        navigator.pop();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Mot de passe mis a jour.'),
                          ),
                        );
                      } on AuthException catch (error) {
                        if (!mounted) {
                          return;
                        }
                        messenger.showSnackBar(
                          SnackBar(content: Text(error.message)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A7DF5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Mettre a jour'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _signOut() async {
    await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(
      authControllerProvider.select((state) => state.session),
    );
    final displayName = _displayName(session);
    final email = _email(session);
    final phoneNumber = _phoneNumber(session);
    final employeeCode = _employeeCode(session);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F7),
      appBar: const AppSectionAppBar(title: 'Profil'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
        children: <Widget>[
          _ProfileHeroCard(
            initials: _initialsFromName(displayName),
            displayName: displayName,
            subtitle: 'Employe Pointa',
            onEdit: () => _openEditProfileSheet(session),
          ),
          const SizedBox(height: 20),
          _ProfileInfoCard(
            children: <Widget>[
              _InfoRow(
                icon: Icons.person_outline_rounded,
                title: displayName,
                subtitle: 'Profil principal',
              ),
              _InfoDivider(),
              _InfoRow(
                icon: Icons.call_outlined,
                title: phoneNumber,
                subtitle: email,
              ),
              _InfoDivider(),
              _InfoRow(
                icon: Icons.badge_outlined,
                title: employeeCode,
                subtitle: 'Siege Ouaga',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ProfileInfoCard(
            children: <Widget>[
              _InfoRow(
                icon: Icons.mail_outline_rounded,
                title: email,
                subtitle: 'Adresse de connexion',
              ),
              _InfoDivider(),
              _InfoRow(
                icon: Icons.verified_outlined,
                title: 'Compte securise',
                subtitle: 'Acces et donnees personnelles',
              ),
              const SizedBox(height: 18),
              _ActionTile(
                key: const Key('profile_change_password_button'),
                icon: Icons.lock_outline_rounded,
                label: 'Changer le mot de passe',
                onTap: _openPasswordSheet,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('profile_sign_out_button'),
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Se deconnecter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5A6D9F),
                    side: const BorderSide(color: Color(0xFFD9DDEA)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 4,
        onSelected: (index) => _handleBottomNavSelection(context, index),
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.initials,
    required this.displayName,
    required this.subtitle,
    required this.onEdit,
  });

  final String initials;
  final String displayName;
  final String subtitle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE6E3EF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A111B33),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        children: <Widget>[
          Container(
            width: 128,
            height: 128,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFFCDE2FF), Color(0xFF8FC0F7)],
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Color(0xFF173563),
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF17224B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF7D829B),
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            key: const Key('profile_edit_button'),
            onPressed: onEdit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE8E8F9),
              foregroundColor: const Color(0xFF314989),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Editer le profil'),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE6E3EF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A111B33),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFE9EAF8),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: const Color(0xFF6475B1), size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C2550),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: const Color(0xFF7B8198),
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

class _InfoDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Divider(
        height: 1,
        color: const Color(0xFFE5E4ED).withValues(alpha: 0.95),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFFBFAFD),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5E4ED)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF6475B1), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E2752),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF98A0BC),
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDDE1EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDDE1EE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF6A84F5)),
        ),
      ),
    );
  }
}
