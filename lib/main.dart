import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/assignment_service.dart';
import 'services/auth_service.dart';
import 'services/desktop_window_service.dart';
import 'services/debug_logger.dart';
import 'services/http_client.dart';
import 'services/schedule_service.dart';
import 'services/service_provider.dart';
import 'services/storage_service.dart';
import 'services/theme_service.dart';
import 'widgets/app_shell/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final desktopWindowService = DesktopWindowService(prefs);
  await desktopWindowService.initialize();

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
      desktopWindowService: desktopWindowService,
      authService: authService,
      debugLogger: debugLogger,
      storageService: storageService,
      themeService: themeService,
      scheduleService: scheduleService,
      assignmentService: assignmentService,
    ),
  );
}

class TechPieApp extends StatefulWidget {
  final DesktopWindowService desktopWindowService;
  final AuthService authService;
  final DebugLogger debugLogger;
  final StorageService storageService;
  final ThemeService themeService;
  final ScheduleService scheduleService;
  final AssignmentService assignmentService;

  const TechPieApp({
    super.key,
    required this.desktopWindowService,
    required this.authService,
    required this.debugLogger,
    required this.storageService,
    required this.themeService,
    required this.scheduleService,
    required this.assignmentService,
  });

  @override
  State<TechPieApp> createState() => _TechPieAppState();
}

class _TechPieAppState extends State<TechPieApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      widget.desktopWindowService.close();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.desktopWindowService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.themeService,
      builder: (context, _) => ServiceProvider(
        authService: widget.authService,
        debugLogger: widget.debugLogger,
        storageService: widget.storageService,
        themeService: widget.themeService,
        scheduleService: widget.scheduleService,
        assignmentService: widget.assignmentService,
        child: MaterialApp(
          title: 'TechPie',
          theme: widget.themeService.lightTheme,
          darkTheme: widget.themeService.darkTheme,
          themeMode: widget.themeService.themeMode,
          home: const AppShell(),
        ),
      ),
    );
  }
}
