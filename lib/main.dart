import 'package:flutter/material.dart';
import 'app/router.dart';
import 'app/theme.dart';

void main() {
  runApp(const VmsApp());
}

/// Root widget for the Vehicle Management System frontend.
class VmsApp extends StatelessWidget {
  const VmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vehicle Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
