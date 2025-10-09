import 'package:flutter/material.dart';
import 'core/constants/app_themes.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark 
          ? ThemeMode.light 
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stopwatch App',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(
        onThemeToggle: toggleTheme,
        currentThemeMode: _themeMode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
