import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_theme.dart';
import 'package:pointa_mobile/features/auth/application/auth_controller.dart';
import 'package:pointa_mobile/features/auth/application/auth_state.dart';

class PointaApp extends ConsumerStatefulWidget {
  const PointaApp({super.key});

  @override
  ConsumerState<PointaApp> createState() => _PointaAppState();
}

class _PointaAppState extends ConsumerState<PointaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      ref.read(authControllerProvider.notifier).lockApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Pointa',
      theme: AppTheme.light(),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('fr'), Locale('en')],
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) {
        return Stack(
          children: <Widget>[
            child ?? const SizedBox.shrink(),
            if (authState.isRestoring) const _AppBootstrapOverlay(),
            if (authState.status == AuthStatus.authenticated && authState.isLocked)
              const _AppUnlockOverlay(),
          ],
        );
      },
    );
  }
}

class _AppBootstrapOverlay extends StatelessWidget {
  const _AppBootstrapOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF5F6FB),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Chargement securise de votre session...',
              style: TextStyle(
                color: Color(0xFF303452),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppUnlockOverlay extends ConsumerStatefulWidget {
  const _AppUnlockOverlay();

  @override
  ConsumerState<_AppUnlockOverlay> createState() => _AppUnlockOverlayState();
}

class _AppUnlockOverlayState extends ConsumerState<_AppUnlockOverlay> {
  bool _didAutoPrompt = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didAutoPrompt) {
      return;
    }

    _didAutoPrompt = true;
    Future<void>.microtask(
      () => ref.read(authControllerProvider.notifier).unlockWithDeviceSecurity(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return ColoredBox(
      color: const Color(0xCC111426),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Card(
            elevation: 18,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 44,
                    color: Color(0xFF4E5AE8),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Deverrouiller Pointa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authState.errorMessage ??
                        'Utilisez la securite de votre telephone pour reprendre votre session.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF5E6483),
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: authState.isLoading
                        ? null
                        : () => ref
                              .read(authControllerProvider.notifier)
                              .unlockWithDeviceSecurity(),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Text('Deverrouiller'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : () => ref
                              .read(authControllerProvider.notifier)
                              .requireFreshLogin(),
                    child: const Text('Se reconnecter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
