import 'package:go_router/go_router.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/shell_screen.dart';
import '../screens/vehicle_form_screen.dart';
import '../screens/vehicle_list_screen.dart';
import '../services/auth_session.dart';

/// Central GoRouter configuration for the VMS app.
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: AuthSession.instance,
  redirect: (context, state) {
    final loggedIn = AuthSession.instance.isAuthenticated;
    final loggingIn = state.uri.path == '/login';

    if (!loggedIn && !loggingIn) {
      return '/login';
    }

    if (loggedIn && (loggingIn || state.uri.path == '/')) {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/vehicles',
          builder: (context, state) => const VehicleListScreen(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const VehicleFormScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                return VehicleFormScreen(vehicleId: id);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);