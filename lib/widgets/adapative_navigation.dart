import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:story_app/utils/extensions.dart';

class AdaptiveNavigation extends StatelessWidget {
  final Widget child;

  const AdaptiveNavigation({super.key, required this.child});

  void _onNavTapped(int index, BuildContext context) {
    final navigationActions = {
      0: () => GoRouter.of(context).go('/stories'),
      1: () => GoRouter.of(context).go('/add_story'),
      2: () => GoRouter.of(context).go('/setting'),
    };
    navigationActions[index]?.call();
  }

  int _getIndex(BuildContext context) {
    final GoRouter route = GoRouter.of(context);
    final String location = route.location;
    if (location.contains('/detail')) {
      return -1;
    }
    if (location.startsWith('/stories')) {
      return 0;
    }
    if (location.startsWith('/add_story')) {
      return 1;
    }
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _getIndex(context) == -1
          ? null
          : NavigationBar(
              selectedIndex: _getIndex(context),
              onDestinationSelected: (index) => _onNavTapped(index, context),
              destinations: List.generate(
                  3,
                  (index) => switch (index) {
                        0 => const NavigationDestination(
                            icon: Icon(Icons.home),
                            selectedIcon: Icon(Icons.home_filled),
                            label: "Home"),
                        1 => Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FloatingActionButton(
                                onPressed: () =>
                                    GoRouter.of(context).go('/add_story'),
                                child: const Icon(Icons.add_outlined),
                              ),
                              Text(
                                "Add Story",
                                style: Theme.of(context).textTheme.labelMedium,
                              )
                            ],
                          ),
                        _ => const NavigationDestination(
                            icon: Icon(Icons.settings_outlined),
                            selectedIcon: Icon(Icons.settings),
                            label: "Setting")
                      }),
            ),
    );
  }
}
