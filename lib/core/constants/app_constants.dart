class AppConstants {
  // Timer constants
  static const int maxHours = 23;
  static const int maxMinutes = 59;
  static const int maxSeconds = 59;
  
  // Stopwatch constants
  static const int maxLaps = 100;
  
  // Alarm constants
  static const int maxAlarms = 20;
  static const int snoozeMinutes = 5;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Storage keys
  static const String alarmsKey = 'alarms';
  static const String themeKey = 'theme';
  static const String stopwatchHistoryKey = 'stopwatch_history';
}
