import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../app_destination.dart';
import 'desktop_sidebar_item.dart';
import 'desktop_sidebar_tokens.dart';

class DesktopSidebar extends StatelessWidget {
  final List<AppDestination> destinations;
  final int selectedIndex;
  final bool collapsed;
  final ValueChanged<int> onSelected;
  final VoidCallback onToggleCollapsed;

  const DesktopSidebar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.collapsed,
    required this.onSelected,
    required this.onToggleCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final horizontalPadding = collapsed
        ? DesktopSidebarTokens.collapsedHorizontalPadding
        : DesktopSidebarTokens.expandedHorizontalPadding;

    return ColoredBox(
      color: colorScheme.surfaceContainerLow,
      child: SafeArea(
        right: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SidebarDragHeader(horizontalPadding: horizontalPadding),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  DesktopSidebarTokens.navTopPadding,
                  horizontalPadding,
                  DesktopSidebarTokens.navBottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (
                      int index = 0;
                      index < destinations.length;
                      index++
                    ) ...[
                      DesktopSidebarItem(
                        destination: destinations[index],
                        selected: index == selectedIndex,
                        collapsed: collapsed,
                        onTap: () => onSelected(index),
                      ),
                      if (index < destinations.length - 1)
                        const SizedBox(
                          height: DesktopSidebarTokens.navItemSpacing,
                        ),
                    ],
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: _SidebarToggleButton(
                        collapsed: collapsed,
                        onPressed: onToggleCollapsed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarDragHeader extends StatelessWidget {
  final double horizontalPadding;

  const _SidebarDragHeader({required this.horizontalPadding});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DesktopSidebarTokens.headerHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          DesktopSidebarTokens.headerTopPadding,
          horizontalPadding,
          DesktopSidebarTokens.headerBottomPadding,
        ),
        child: SizedBox.expand(child: DragToMoveArea(child: const SizedBox())),
      ),
    );
  }
}

class _SidebarToggleButton extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onPressed;

  const _SidebarToggleButton({
    required this.collapsed,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: collapsed ? 'Expand sidebar' : 'Collapse sidebar',
      onPressed: onPressed,
      icon: SizedBox(
        width: DesktopSidebarTokens.iconColumnWidth,
        height: DesktopSidebarTokens.navItemHeight,
        child: Center(
          child: Icon(
            Icons.menu_rounded,
            size: DesktopSidebarTokens.toggleIconSize,
          ),
        ),
      ),
      style: IconButton.styleFrom(
        fixedSize: const Size(
          DesktopSidebarTokens.iconColumnWidth,
          DesktopSidebarTokens.navItemHeight,
        ),
        minimumSize: const Size(
          DesktopSidebarTokens.iconColumnWidth,
          DesktopSidebarTokens.navItemHeight,
        ),
        padding: EdgeInsets.zero,
        foregroundColor: colorScheme.onSurfaceVariant,
        backgroundColor: Colors.transparent,
        hoverColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            DesktopSidebarTokens.navItemRadius,
          ),
        ),
      ),
    );
  }
}
