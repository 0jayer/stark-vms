import 'package:go_router/go_router.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/shell_screen.dart';
import '../screens/vehicle_form_screen.dart';
import '../screens/vehicle_list_screen.dart';

/// In-memory mock authentication flag for demonstration.
/// Set to true upon successful login.
bool isLoggedIn = false;

/// Central GoRouter configuration for the VMS app.
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final loggingIn = state.uri.path == '/login';

    if (!isLoggedIn && !loggingIn) {
      return '/login';
    }

    if (isLoggedIn && (loggingIn || state.uri.path == '/')) {
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
