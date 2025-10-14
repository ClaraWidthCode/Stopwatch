import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//Core
import '../core/di/injection_container.dart';
import '../core/widgets/bottom_navigation_bar_widget.dart';

//Features
import '../features/alarm/presentation/bloc/alarm_bloc.dart';
import '../features/alarm/presentation/bloc/alarm_event.dart';
import '../features/alarm/presentation/pages/alarm_screen.dart';
import '../features/timer/presentation/pages/timer_screen.dart';
import '../features/stopwatch/presentation/pages/stopwatch_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode currentThemeMode;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.currentThemeMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              widget.currentThemeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Reloj Mundial';
      case 1:
        return 'Alarmas';
      case 2:
        return 'Cronómetro';
      case 3:
        return 'Temporizador';
      default:
        return 'Stopwatch App';
    }
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildWorldClockScreen();
      case 1:
        return BlocProvider(
          create: (context) => sl<AlarmBloc>()..add(LoadAlarms()),
          child: AlarmScreen(),
        );
      case 2:
        return StopwatchScreen();
      case 3:
        return TimerScreen();
      default:
        return AlarmScreen();
    }
  }

  Widget _buildWorldClockScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            size: 64,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 16),
          Text(
            'Reloj Mundial',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente disponible',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
