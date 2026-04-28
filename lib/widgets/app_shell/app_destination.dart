import 'package:flutter/material.dart';

import '../native_glass_tab_bar.dart';

class AppDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String sfSymbol;
  final String selectedSfSymbol;
  final Widget page;

  const AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.sfSymbol,
    required this.selectedSfSymbol,
    required this.page,
  });

  NativeGlassTabBarItem toNativeTabBarItem() {
    return NativeGlassTabBarItem(
      label: label,
      icon: icon,
      selectedIcon: selectedIcon,
      sfSymbol: sfSymbol,
      selectedSfSymbol: selectedSfSymbol,
    );
  }
}
