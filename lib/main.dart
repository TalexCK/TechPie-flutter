import 'package:flutter/foundation.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/assignments_page.dart';
import 'pages/home_page.dart';
import 'pages/schedule_page.dart';
import 'pages/settings_page.dart';
import 'services/assignment_service.dart';
import 'services/auth_service.dart';
import 'services/debug_logger.dart';
import 'services/http_client.dart';
import 'services/schedule_service.dart';
import 'services/service_provider.dart';
import 'services/storage_service.dart';
import 'services/theme_service.dart';
import 'widgets/ios_liquid/ios_glass_floating_button.dart';
import 'widgets/ios_liquid/ios_glass_tab_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  final debugLogger = DebugLogger()..enabled = storageService.debugMode;
  final httpClient = LoggingHttpClient(debugLogger);
  final authService = AuthService(storageService, httpClient);
  final themeService = ThemeService(storageService);
  final scheduleService = ScheduleService(
    storageService,
    httpClient,
    authService,
  );
  final assignmentService = AssignmentService(
    storageService,
    httpClient,
    authService,
  );

  await authService.initialize();

  // Load cached schedule data so widgets (e.g. home page) render immediately
  await scheduleService.loadCachedData();

  // Fetch fresh schedule data in the background if logged in
  if (authService.isLoggedIn) {
    scheduleService.fetchAll(); // fire-and-forget, UI uses cache first
    assignmentService.fetchAssignments();
  }

  runApp(
    TechPieApp(
      authService: authService,
      debugLogger: debugLogger,
      storageService: storageService,
      themeService: themeService,
      scheduleService: scheduleService,
      assignmentService: assignmentService,
    ),
  );
}

class TechPieApp extends StatelessWidget {
  final AuthService authService;
  final DebugLogger debugLogger;
  final StorageService storageService;
  final ThemeService themeService;
  final ScheduleService scheduleService;
  final AssignmentService assignmentService;

  const TechPieApp({
    super.key,
    required this.authService,
    required this.debugLogger,
    required this.storageService,
    required this.themeService,
    required this.scheduleService,
    required this.assignmentService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) => ServiceProvider(
        authService: authService,
        debugLogger: debugLogger,
        storageService: storageService,
        themeService: themeService,
        scheduleService: scheduleService,
        assignmentService: assignmentService,
        child: MaterialApp(
          title: 'TechPie',
          theme: themeService.lightTheme,
          darkTheme: themeService.darkTheme,
          themeMode: themeService.themeMode,
          home: const AppShell(),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const int _assignmentsIndex = 2;

  int _selectedIndex = 0;

  bool get _usesIosLiquidGlass =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static const List<IosGlassTabBarItem> _navigationItems = [
    IosGlassTabBarItem(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      sfSymbol: 'house',
      selectedSfSymbol: 'house.fill',
    ),
    IosGlassTabBarItem(
      label: 'Schedule',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      sfSymbol: 'calendar',
      selectedSfSymbol: 'calendar.circle.fill',
    ),
    IosGlassTabBarItem(
      label: 'Assignments',
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment,
      sfSymbol: 'checkmark.circle',
      selectedSfSymbol: 'checkmark.circle.fill',
    ),
    IosGlassTabBarItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      sfSymbol: 'gearshape',
      selectedSfSymbol: 'gearshape.fill',
    ),
  ];

  static const List<Widget> _pages = [
    HomePage(key: ValueKey('home')),
    SchedulePage(key: ValueKey('schedule')),
    AssignmentsPage(key: ValueKey('assignments')),
    SettingsPage(key: ValueKey('settings')),
  ];

  @override
  Widget build(BuildContext context) {
    final usesIosLiquidGlass = _usesIosLiquidGlass;

    return Scaffold(
      extendBody: true,
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            fillColor: Colors.transparent,
            child: child,
          );
        },
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: _selectedIndex == _assignmentsIndex
          ? usesIosLiquidGlass
                ? IosGlassFloatingButton(
                    onPressed: () {},
                    icon: Icons.add,
                    sfSymbol: 'plus',
                  )
                : FloatingActionButton(
                    onPressed: () {},
                    child: const Icon(Icons.add),
                  )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: usesIosLiquidGlass
          ? IosGlassTabBar(
              selectedIndex: _selectedIndex,
              items: _navigationItems,
              onSelected: _handleSelectedIndexChanged,
            )
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _handleSelectedIndexChanged,
              destinations: [
                for (final item in _navigationItems)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
              ],
            ),
    );
  }

  void _handleSelectedIndexChanged(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });
  }
}
