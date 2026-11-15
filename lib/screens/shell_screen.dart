import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

/// The top-level application shell for authenticated users.
///
/// Desktop-first layout displaying a persistent sidebar on the left
/// and the active route's content on the right.
class ShellScreen extends StatelessWidget {
  final Widget child;

  const ShellScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

