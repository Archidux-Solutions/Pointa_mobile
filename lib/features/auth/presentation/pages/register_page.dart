import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/features/auth/application/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  var _obscurePassword = true;
  var _obscureConfirmPassword = true;
  var _acceptedTerms = false;
  var _showTermsError = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      setState(() {
        _showTermsError = true;
      });
      return;
    }

    setState(() {
      _showTermsError = false;
    });

    await ref
        .read(authControllerProvider.notifier)
        .register(
          fullName: _fullNameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    required bool compact,
    Widget? suffixIcon,
  }) {
    const borderColor = Color(0xFFE2DBFF);
    final radius = compact ? 20.0 : 22.0;
    final verticalPadding = compact ? 15.0 : 18.0;
    final hintFontSize = compact ? 14.0 : 15.0;
    final iconSize = compact ? 20.0 : 22.0;

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: const Color(0xFF9791C5),
        fontSize: hintFontSize,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFFA09ACD),
        size: iconSize,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.88),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: verticalPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: borderColor.withValues(alpha: 0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Color(0xFF7E88FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Color(0xFFE36E7E)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Color(0xFFE36E7E), width: 1.4),
      ),
    );
  }

  void _toggleTerms() {
    setState(() {
      _acceptedTerms = !_acceptedTerms;
      _showTermsError = false;
    });
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
              final compact = constraints.maxHeight < 780;
              final semiCompact = constraints.maxHeight < 900;
              final heroHeight = compact
                  ? 206.0
                  : (semiCompact ? 226.0 : 246.0);
              final brandLogoSize = compact ? 64.0 : 74.0;
              final brandTextSize = compact ? 28.0 : 31.0;
              final titleSize = compact ? 24.0 : 28.0;
              final introGap = compact ? 10.0 : 14.0;
              final sectionGap = compact ? 20.0 : 26.0;
              final fieldGap = compact ? 10.0 : 14.0;
              final footerGap = compact ? 16.0 : 20.0;

              return Stack(
                children: <Widget>[
                  Positioned(
                    top: -30,
                    left: -26,
                    right: -26,
                    child: Container(
                      height: heroHeight,
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
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _PointaBrand(
                            logoSize: brandLogoSize,
                            textSize: brandTextSize,
                          ),
                          SizedBox(height: sectionGap),
                          Text(
                            'Creer un compte',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF5E5A91),
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: introGap),
                          Text(
                            'Creez votre compte pour un pointage simplifie.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF9993BF),
                              fontSize: compact ? 14 : 15,
                              height: 1.55,
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                TextFormField(
                                  key: const Key('register_full_name_field'),
                                  controller: _fullNameController,
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(
                                    color: Color(0xFF5F5A92),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: _inputDecoration(
                                    compact: compact,
                                    hintText: 'Nom complet',
                                    prefixIcon: Icons.person_outline_rounded,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Veuillez saisir votre nom complet.';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: fieldGap),
                                TextFormField(
                                  key: const Key('register_phone_field'),
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(
                                    color: Color(0xFF5F5A92),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: _inputDecoration(
                                    compact: compact,
                                    hintText: 'Numero de telephone',
                                    prefixIcon: Icons.call_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Veuillez saisir un numero.';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: fieldGap),
                                TextFormField(
                                  key: const Key('register_email_field'),
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(
                                    color: Color(0xFF5F5A92),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: _inputDecoration(
                                    compact: compact,
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
                                SizedBox(height: fieldGap),
                                TextFormField(
                                  key: const Key('register_password_field'),
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(
                                    color: Color(0xFF5F5A92),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: _inputDecoration(
                                    compact: compact,
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
                                    if (value.trim().length < 6) {
                                      return 'Le mot de passe doit contenir au moins 6 caracteres.';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: fieldGap),
                                TextFormField(
                                  key: const Key(
                                    'register_confirm_password_field',
                                  ),
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  style: const TextStyle(
                                    color: Color(0xFF5F5A92),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: _inputDecoration(
                                    compact: compact,
                                    hintText: 'Confirmer le mot de passe',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFFA09ACD),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Veuillez confirmer le mot de passe.';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Les mots de passe ne correspondent pas.';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _submit(),
                                ),
                                SizedBox(height: compact ? 14 : 16),
                                GestureDetector(
                                  key: const Key('register_terms_checkbox'),
                                  onTap: _toggleTerms,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      _TermsCheckbox(isChecked: _acceptedTerms),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            style: const TextStyle(
                                              color: Color(0xFF8F89B8),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              height: 1.5,
                                            ),
                                            children: const <InlineSpan>[
                                              TextSpan(
                                                text:
                                                    'En vous inscrivant, vous acceptez nos ',
                                              ),
                                              TextSpan(
                                                text:
                                                    'Conditions d utilisation',
                                                style: TextStyle(
                                                  color: Color(0xFF5E67E5),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              TextSpan(text: ' et notre '),
                                              TextSpan(
                                                text:
                                                    'Politique de confidentialite.',
                                                style: TextStyle(
                                                  color: Color(0xFF5E67E5),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_showTermsError) ...<Widget>[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Veuillez accepter les conditions pour continuer.',
                                    style: TextStyle(
                                      color: Color(0xFFE36E7E),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                if (authState.errorMessage != null) ...<Widget>[
                                  const SizedBox(height: 8),
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
                                SizedBox(height: compact ? 16 : 20),
                                _PrimaryRegisterButton(
                                  buttonKey: const Key(
                                    'register_submit_button',
                                  ),
                                  label: 'S inscrire',
                                  isLoading: authState.isLoading,
                                  height: compact ? 54 : 58,
                                  onPressed: _submit,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: compact ? 16 : 18),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: <Widget>[
                              const Text(
                                'Vous avez deja un compte ?',
                                style: TextStyle(
                                  color: Color(0xFF8F89B8),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                key: const Key('register_to_login_link'),
                                onTap: () => context.go(AppRoutes.login),
                                child: const Text(
                                  'Se connecter',
                                  style: TextStyle(
                                    color: Color(0xFF5E67E5),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: footerGap),
                          const _DividerLabel(label: 'ou continuer avec'),
                          SizedBox(height: compact ? 16 : 20),
                          Row(
                            children: <Widget>[
                              const Expanded(
                                child: _SocialButton(
                                  label: 'Google',
                                  icon: _GoogleBadge(),
                                  verticalPadding: 13,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: _SocialButton(
                                  label: 'Facebook',
                                  icon: _FacebookBadge(),
                                  isPrimary: true,
                                  verticalPadding: 13,
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
  const _PointaBrand({required this.logoSize, required this.textSize});

  final double logoSize;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: logoSize,
          height: logoSize,
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
                child: Icon(
                  Icons.location_on_rounded,
                  size: logoSize - 6,
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
        Text(
          'PointA',
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5C568C),
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isChecked
            ? const Color(0xFFEEF0FF)
            : Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isChecked ? const Color(0xFF6A75EE) : const Color(0xFFD9D1F6),
          width: 1.4,
        ),
      ),
      child: isChecked
          ? const Icon(Icons.check_rounded, size: 22, color: Color(0xFF6572EE))
          : null,
    );
  }
}

class _PrimaryRegisterButton extends StatelessWidget {
  const _PrimaryRegisterButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.height,
    this.buttonKey,
  });

  final String label;
  final Future<void> Function() onPressed;
  final bool isLoading;
  final double height;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: buttonKey,
      height: height,
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
            onTap: isLoading ? null : () => onPressed(),
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
                        fontSize: 17,
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
    required this.verticalPadding,
    this.isPrimary = false,
  });

  final String label;
  final Widget icon;
  final double verticalPadding;
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
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: verticalPadding,
          ),
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
