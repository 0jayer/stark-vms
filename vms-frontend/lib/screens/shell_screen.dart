import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../widgets/sidebar.dart';

/// The top-level application shell for authenticated users.
/// Desktop-first layout with persistent sidebar and responsive main content area.
class ShellScreen extends StatelessWidget {
  final Widget child;

  const ShellScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Sidebar(),
          Expanded(
            child: SafeArea(
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
