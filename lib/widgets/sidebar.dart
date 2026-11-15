import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/router.dart';

/// The navigation sidebar for the application shell.
///
/// Uses [NavigationRail] in extended mode for a desktop-friendly layout.
/// Shows navigation destinations and a sign-out button at the bottom.
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentPath = GoRouterState.of(context).uri.path;

    // Determine which nav item is selected based on the current route.
    int selectedIndex = 0;
    if (currentPath.startsWith('/vehicles')) {
      selectedIndex = 0;
    }

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/vehicles');
        }
      },
      extended: true,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(Icons.directions_car, color: colorScheme.primary, size: 32),
            const SizedBox(width: 12),
            Text(
              'VMS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextButton.icon(
              onPressed: () {
                isLoggedIn = false;
                context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.directions_car_outlined),
          selectedIcon: Icon(Icons.directions_car),
          label: Text('Vehicles'),
        ),
      ],
    );
  }
}

