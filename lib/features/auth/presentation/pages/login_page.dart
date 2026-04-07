import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointa_mobile/features/auth/application/auth_controller.dart';
import 'package:pointa_mobile/features/auth/domain/exceptions/auth_exception.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  var _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .signIn(
          phone: _phoneController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _openForgotPasswordSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ForgotPasswordSheet(initialPhone: _phoneController.text);
      },
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
    final verticalPadding = compact ? 16.0 : 18.0;
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
              final compact = constraints.maxHeight < 760;
              final semiCompact = constraints.maxHeight < 860;
              final heroHeight = compact
                  ? 220.0
                  : (semiCompact ? 242.0 : 262.0);
              final brandLogoSize = compact ? 70.0 : 80.0;
              final brandTextSize = compact ? 30.0 : 32.0;
              final titleSize = compact ? 25.0 : 28.0;
              final introGap = compact ? 12.0 : 16.0;
              final sectionGap = compact ? 24.0 : 30.0;
              final fieldGap = compact ? 12.0 : 14.0;
              final buttonGap = compact ? 18.0 : 22.0;

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
                            'Connexion',
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
                            'Connectez-vous a votre espace en toute simplicite.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF9993BF),
                              fontSize: compact ? 14 : 15,
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                TextFormField(
                                  key: const Key('login_phone_field'),
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
                                  key: const Key('login_password_field'),
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
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
                                    return null;
                                  },
                                  onFieldSubmitted: (_) {
                                    _submit();
                                  },
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    key: const Key(
                                      'login_forgot_password_button',
                                    ),
                                    onPressed: _openForgotPasswordSheet,
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
                                        fontSize: 14,
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
                                SizedBox(height: buttonGap),
                                _PrimaryLoginButton(
                                  buttonKey: const Key('login_submit_button'),
                                  label: 'Se connecter',
                                  isLoading: authState.isLoading,
                                  height: compact ? 54 : 58,
                                  onPressed: _submit,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
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

class _ForgotPasswordSheet extends ConsumerStatefulWidget {
  const _ForgotPasswordSheet({required this.initialPhone});

  final String initialPhone;

  @override
  ConsumerState<_ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends ConsumerState<_ForgotPasswordSheet> {
  late final TextEditingController _phoneController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _resetToken;
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _isResetStep => _resetToken != null;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone.trim());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _requestResetToken() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _errorMessage = 'Renseignez votre numero de telephone.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await ref
          .read(authControllerProvider.notifier)
          .requestPasswordReset(phone: phone);

      if (!mounted) {
        return;
      }

      setState(() {
        _resetToken = token;
        _isLoading = false;
      });
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitNewPassword() async {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Renseignez tous les champs.';
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _errorMessage = 'Le mot de passe doit contenir au moins 6 caracteres.';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas.';
      });
      return;
    }

    final token = _resetToken;
    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'Token de reinitialisation introuvable.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .resetPassword(token: token, newPassword: newPassword);

      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Mot de passe reinitialise. Vous pouvez vous connecter.',
          ),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _isResetStep
                  ? 'Reinitialiser le mot de passe'
                  : 'Mot de passe oublie',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A2550),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isResetStep
                  ? 'Definissez un nouveau mot de passe pour votre compte.'
                  : 'Saisissez votre numero pour lancer la reinitialisation.',
              style: const TextStyle(
                color: Color(0xFF8F89B8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            if (!_isResetStep) ...<Widget>[
              _ForgotField(
                key: const Key('forgot_phone_field'),
                controller: _phoneController,
                label: 'Numero de telephone',
                icon: Icons.call_outlined,
                keyboardType: TextInputType.phone,
              ),
            ] else ...<Widget>[
              _ForgotField(
                key: const Key('forgot_new_password_field'),
                controller: _passwordController,
                label: 'Nouveau mot de passe',
                icon: Icons.lock_reset_rounded,
                obscureText: _obscurePassword,
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
              const SizedBox(height: 14),
              _ForgotField(
                key: const Key('forgot_confirm_password_field'),
                controller: _confirmController,
                label: 'Confirmer le mot de passe',
                icon: Icons.verified_user_outlined,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
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
            ],
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFE36E7E),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[Color(0xFF7887FF), Color(0xFF6376F6)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const Key('forgot_submit_button'),
                    borderRadius: BorderRadius.circular(24),
                    onTap: _isLoading
                        ? null
                        : () {
                            if (_isResetStep) {
                              _submitNewPassword();
                            } else {
                              _requestResetToken();
                            }
                          },
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isResetStep ? 'Mettre a jour' : 'Continuer',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotField extends StatelessWidget {
  const _ForgotField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        color: Color(0xFF5F5A92),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(
          color: Color(0xFF9791C5),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFA09ACD), size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE2DBFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: const Color(0xFFE2DBFF).withValues(alpha: 0.9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFF7E88FF), width: 1.5),
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

class _PrimaryLoginButton extends StatelessWidget {
  const _PrimaryLoginButton({
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
            key: buttonKey,
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
