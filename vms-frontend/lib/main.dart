import 'package:flutter/material.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'services/auth_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore a saved token (if still valid) before the router first runs.
  await AuthSession.instance.load();
  runApp(const VmsApp());
}

/// Root widget for the Stark Group Vehicle Management System frontend.
class VmsApp extends StatelessWidget {
  const VmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Stark Group VMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}