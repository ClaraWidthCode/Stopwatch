import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/circular_progress_widget.dart';
import '../../../../core/widgets/time_display_widget.dart';
import '../../../../core/widgets/custom_button.dart' as custom;

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool _isRunning = false;
  bool _isPaused = false;
  List<StopwatchLap> _laps = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStopwatch() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _elapsedTime = Duration(milliseconds: _elapsedTime.inMilliseconds + 10);
      });
    });
  }

  void _pauseStopwatch() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  void _resumeStopwatch() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _elapsedTime = Duration(milliseconds: _elapsedTime.inMilliseconds + 10);
      });
    });
  }

  void _resetStopwatch() {
    _timer?.cancel();
    setState(() {
      _elapsedTime = Duration.zero;
      _isRunning = false;
      _isPaused = false;
      _laps.clear();
    });
  }

  void _addLap() {
    if (_isRunning || _isPaused) {
      final lapNumber = _laps.length + 1;
      final lapTime = _laps.isEmpty
          ? _elapsedTime
          : Duration(
              milliseconds:
                  _elapsedTime.inMilliseconds -
                  _laps.last.totalTime.inMilliseconds,
            );

      setState(() {
        _laps.add(
          StopwatchLap(
            lapNumber: lapNumber,
            lapTime: lapTime,
            totalTime: _elapsedTime,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Stopwatch Display Section
            _buildStopwatchDisplay(context),

            const SizedBox(height: 32),

            // Control Buttons Section
            _buildControlButtons(context),

            const SizedBox(height: 32),

            // Laps Section
            Expanded(child: _buildLapsSection(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildStopwatchDisplay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'CRONÓMETRO',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),

          CircularProgressWidget(
            progress: _calculateStopwatchProgress(),
            size: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TimeDisplayWidget(
                  duration: _elapsedTime,
                  showMilliseconds: true,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('min', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 16),
                    Text('seg', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 16),
                    Text('mseg', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                if (_isRunning || _isPaused) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isRunning ? 'Activo ahora' : 'Pausado',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Reset Button
        custom.CustomIconButton(
          icon: Icons.refresh,
          size: 50,
          backgroundColor: Theme.of(context).colorScheme.surface,
          iconColor: Theme.of(context).textTheme.bodyMedium?.color,
          onPressed: _elapsedTime.inMilliseconds > 0 ? _resetStopwatch : null,
        ),

        // Play/Pause Button
        custom.CustomIconButton(
          icon: _isRunning ? Icons.pause : Icons.play_arrow,
          size: 70,
          backgroundColor: AppColors.primary,
          iconColor: Colors.white,
          onPressed: () {
            if (_isRunning) {
              _pauseStopwatch();
            } else if (_isPaused) {
              _resumeStopwatch();
            } else {
              _startStopwatch();
            }
          },
        ),

        // Lap Button
        custom.CustomIconButton(
          icon: Icons.flag,
          size: 50,
          backgroundColor: Theme.of(context).colorScheme.surface,
          iconColor: Theme.of(context).textTheme.bodyMedium?.color,
          onPressed:
              (_isRunning || _isPaused) && _elapsedTime.inMilliseconds > 0
              ? _addLap
              : null,
        ),
      ],
    );
  }

  Widget _buildLapsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'VUELTAS',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: _laps.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 64,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay vueltas registradas',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toca el botón de bandera para agregar una vuelta',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _laps.length,
                  itemBuilder: (context, index) {
                    final lap = _laps[index];
                    return _buildLapItem(context, lap);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLapItem(BuildContext context, StopwatchLap lap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Lap Number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                lap.lapNumber.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Lap Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TimeDisplayWidget(
                  duration: lap.lapTime,
                  showMilliseconds: true,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Tiempo de vuelta',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Total Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TimeDisplayWidget(
                duration: lap.totalTime,
                showMilliseconds: true,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                'Tiempo total',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateStopwatchProgress() {
    // Simple progress calculation based on elapsed time
    final elapsedMinutes = _elapsedTime.inMinutes;
    final progress = (elapsedMinutes % 60) / 60.0;
    return progress;
  }
}

class StopwatchLap {
  final int lapNumber;
  final Duration lapTime;
  final Duration totalTime;

  StopwatchLap({
    required this.lapNumber,
    required this.lapTime,
    required this.totalTime,
  });
}
