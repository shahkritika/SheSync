import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'features/onboarding/onboarding_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('darkMode') ?? false;
  runApp(SheSyncApp(initialDarkMode: isDark));
}

// ─────────────────────────────────────────────
//  THEME NOTIFIER — lets any widget in the tree
//  read and update the app-wide theme mode.
// ─────────────────────────────────────────────
class ThemeNotifier extends InheritedWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const ThemeNotifier({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
    required super.child,
  });

  static ThemeNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeNotifier>();
  }

  @override
  bool updateShouldNotify(ThemeNotifier old) =>
      isDarkMode != old.isDarkMode;
}

// ─────────────────────────────────────────────
//  ROOT APP
// ─────────────────────────────────────────────
class SheSyncApp extends StatefulWidget {
  final bool initialDarkMode;
  const SheSyncApp({super.key, this.initialDarkMode = false});

  @override
  State<SheSyncApp> createState() => _SheSyncAppState();
}

class _SheSyncAppState extends State<SheSyncApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = !_isDarkMode);
    await prefs.setBool('darkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeNotifier(
      isDarkMode: _isDarkMode,
      toggleTheme: _toggleTheme,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SheSync',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const OnboardingSplash(),
      ),
    );
  }
}