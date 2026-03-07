import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointa_mobile/app/router/app_router.dart';
import 'package:pointa_mobile/core/theme/app_theme.dart';

class PointaApp extends ConsumerWidget {
  const PointaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    );
  }
}
