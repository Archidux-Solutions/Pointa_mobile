import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pointa_mobile/features/attendance/presentation/pages/attendance_page.dart';
import 'package:pointa_mobile/features/attendance/presentation/pages/history_page.dart';
import 'package:pointa_mobile/features/attendance/presentation/pages/summary_page.dart';
import 'package:pointa_mobile/features/auth/application/auth_controller.dart';
import 'package:pointa_mobile/features/auth/application/auth_state.dart';
import 'package:pointa_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:pointa_mobile/features/home/presentation/pages/home_page.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const attendance = '/attendance';
  static const history = '/attendance/history';
  static const summary = '/attendance/summary';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(
    authControllerProvider.select((state) => state.status),
  );

  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: <GoRoute>[
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.attendance,
        builder: (context, state) => const AttendancePage(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.summary,
        builder: (context, state) => const SummaryPage(),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authStatus == AuthStatus.authenticated;
      final isAtLogin = state.matchedLocation == AppRoutes.login;

      if (!isAuthenticated && !isAtLogin) {
        return AppRoutes.login;
      }
      if (isAuthenticated && isAtLogin) {
        return AppRoutes.home;
      }
      return null;
    },
  );
});
