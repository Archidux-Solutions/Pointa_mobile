import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/features/auth/application/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  var _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    const borderColor = Color(0xFFE2DBFF);

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9791C5),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFFA09ACD), size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.88),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: borderColor.withValues(alpha: 0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFF7E88FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFE36E7E)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFE36E7E), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE7DAFF),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFE6DAFF), Color(0xFFF4F0FF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: <Widget>[
                  Positioned(
                    top: -30,
                    left: -26,
                    right: -26,
                    child: Container(
                      height: 290,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.white.withValues(alpha: 0.6),
                            const Color(0xFFE8E1FF).withValues(alpha: 0.9),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.elliptical(420, 140),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: -90,
                    left: -80,
                    child: _BlurBlob(
                      size: 260,
                      colors: <Color>[Color(0x80FFFFFF), Color(0x26E5D9FF)],
                    ),
                  ),
                  const Positioned(
                    right: -110,
                    top: 260,
                    child: _BlurBlob(
                      size: 280,
                      colors: <Color>[Color(0x55DBD0FF), Color(0x00DBD0FF)],
                    ),
                  ),
                  const Positioned(
                    left: -60,
                    bottom: 120,
                    child: _BlurBlob(
                      size: 200,
                      colors: <Color>[Color(0x40FFFFFF), Color(0x00FFFFFF)],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              splashRadius: 24,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Navigator.of(context).maybePop();
                              },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Color(0xFF7D86F7),
                                size: 34,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const _PointaBrand(),
                          const SizedBox(height: 40),
                          Text(
                            'Connexion',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF5E5A91),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Connectez-vous a votre espace en toute simplicite.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF9993BF),
                              fontSize: 15,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 34),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                TextFormField(
                                  key: const Key('login_email_field'),
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(
                                    color: Color(0xFF5F5A92),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: _inputDecoration(
                                    hintText: 'Adresse e-mail',
                                    prefixIcon: Icons.mail_outline_rounded,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Veuillez saisir un email.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  key: const Key('login_password_field'),
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  style: const TextStyle(
                                    color: Color(0xFF5F5A92),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: _inputDecoration(
                                    hintText: 'Mot de passe',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFFA09ACD),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Veuillez saisir un mot de passe.';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) {
                                    _submit();
                                  },
                                ),
                                const SizedBox(height: 14),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF6D73E7),
                                      padding: EdgeInsets.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      minimumSize: Size.zero,
                                    ),
                                    child: const Text(
                                      'Mot de passe oublie ?',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                if (authState.errorMessage != null) ...<Widget>[
                                  const SizedBox(height: 10),
                                  Text(
                                    authState.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFE36E7E),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                _PrimaryLoginButton(
                                  buttonKey: const Key('login_submit_button'),
                                  label: 'Se connecter',
                                  isLoading: authState.isLoading,
                                  onPressed: _submit,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 34),
                          const _DividerLabel(label: 'ou continuer avec'),
                          const SizedBox(height: 26),
                          const Row(
                            children: <Widget>[
                              Expanded(
                                child: _SocialButton(
                                  label: 'Google',
                                  icon: _GoogleBadge(),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _SocialButton(
                                  label: 'Facebook',
                                  icon: _FacebookBadge(),
                                  isPrimary: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 72),
                          Padding(
                            padding: const EdgeInsets.only(top: 34, bottom: 28),
                            child: Divider(
                              color: const Color(
                                0xFFD9D0F6,
                              ).withValues(alpha: 0.9),
                            ),
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: <Widget>[
                              const Text(
                                'Vous n avez pas de compte ?',
                                style: TextStyle(
                                  color: Color(0xFF8F89B8),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                key: const Key('login_to_register_link'),
                                onTap: () => context.go(AppRoutes.register),
                                child: const Text(
                                  'Creer un compte',
                                  style: TextStyle(
                                    color: Color(0xFF5E67E5),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PointaBrand extends StatelessWidget {
  const _PointaBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0xFF89C1FF), Color(0xFF6568F1)],
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 82,
                  color: Colors.white,
                ),
              ),
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2FF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'PointA',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5C568C),
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}

class _PrimaryLoginButton extends StatelessWidget {
  const _PrimaryLoginButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.buttonKey,
  });

  final String label;
  final Future<void> Function() onPressed;
  final bool isLoading;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: buttonKey,
      height: 62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Color(0xFF7887FF), Color(0xFF6376F6)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x406473F6),
              blurRadius: 26,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: isLoading
                ? null
                : () {
                    onPressed();
                  },
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFD8D0F6).withValues(alpha: 0.8),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9D96C4),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFD8D0F6).withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    this.isPrimary = false,
  });

  final String label;
  final Widget icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final background = isPrimary
        ? const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Color(0xFF7583FF), Color(0xFF6072F4)],
          )
        : const LinearGradient(
            colors: <Color>[Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
          );
    final borderColor = isPrimary
        ? Colors.transparent
        : const Color(0xFFE2DBFF);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: <BoxShadow>[
          if (isPrimary)
            const BoxShadow(
              color: Color(0x2F6473F6),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              icon,
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : const Color(0xFF8580B3),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleBadge extends StatelessWidget {
  const _GoogleBadge();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFFEA775B),
      ),
    );
  }
}

class _FacebookBadge extends StatelessWidget {
  const _FacebookBadge();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'f',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
