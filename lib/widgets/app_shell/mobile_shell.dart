import 'package:flutter/material.dart';

import '../native_glass_floating_button.dart';
import '../native_glass_tab_bar.dart';
import 'app_destination.dart';

class MobileShell extends StatelessWidget {
  final List<AppDestination> destinations;
  final int selectedIndex;
  final int assignmentsIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  const MobileShell({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.assignmentsIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: child,
      floatingActionButton: selectedIndex == assignmentsIndex
          ? NativeGlassFloatingButton(
              onPressed: () {},
              icon: Icons.add,
              sfSymbol: 'plus',
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NativeGlassTabBar(
        selectedIndex: selectedIndex,
        items: destinations.map((item) => item.toNativeTabBarItem()).toList(),
        onSelected: onDestinationSelected,
      ),
    );
  }
}
