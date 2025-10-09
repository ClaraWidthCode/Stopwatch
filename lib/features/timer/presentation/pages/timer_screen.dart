import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/circular_progress_widget.dart';
import '../../../../core/widgets/time_display_widget.dart';
import '../../../../core/widgets/custom_button.dart' as custom;

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  Duration _totalTime = Duration.zero;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isCompleted = false;

  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();

  @override
  void dispose() {
    _timer?.cancel();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _startTimer(Duration duration) {
    if (duration.inMilliseconds <= 0) return;

    setState(() {
      _remainingTime = duration;
      _totalTime = duration;
      _isRunning = true;
      _isPaused = false;
      _isCompleted = false;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_remainingTime.inMilliseconds <= 0) {
          _timer?.cancel();
          _isRunning = false;
          _isCompleted = true;
          _remainingTime = Duration.zero;
          return;
        }

        _remainingTime = Duration(milliseconds: _remainingTime.inMilliseconds - 100);
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_remainingTime.inMilliseconds <= 0) {
          _timer?.cancel();
          _isRunning = false;
          _isCompleted = true;
          _remainingTime = Duration.zero;
          return;
        }

        _remainingTime = Duration(milliseconds: _remainingTime.inMilliseconds - 100);
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = Duration.zero;
      _totalTime = Duration.zero;
      _isRunning = false;
      _isPaused = false;
      _isCompleted = false;
    });
  }

  double get progress {
    if (_totalTime.inMilliseconds == 0) return 0.0;
    return 1.0 - (_remainingTime.inMilliseconds / _totalTime.inMilliseconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Timer Display Section
            _buildTimerDisplay(context),
            
            const SizedBox(height: 32),
            
            // Control Buttons Section
            _buildControlButtons(context),
            
            const SizedBox(height: 32),
            
            // Timer Setup Section
            Expanded(
              child: _buildTimerSetup(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'TEMPORIZADOR',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          
          CircularProgressWidget(
            progress: progress,
            size: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TimeDisplayWidget(
                  duration: _remainingTime,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _isCompleted 
                        ? AppColors.primary 
                        : Theme.of(context).textTheme.displayLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'horas',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'min',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'seg',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (_isRunning || _isPaused || _isCompleted) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isCompleted 
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isCompleted 
                          ? 'Completado'
                          : _isRunning 
                              ? 'Activo ahora'
                              : 'Pausado',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _isCompleted 
                            ? AppColors.success
                            : AppColors.primary,
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
        custom.CustomResetButton(
          size: 50,
          backgroundColor: Theme.of(context).colorScheme.surface,
          iconColor: Theme.of(context).textTheme.bodyMedium?.color,
          onPressed: _totalTime.inMilliseconds > 0 ? _resetTimer : null,
        ),
        
        // Play/Pause Button
        custom.CustomIconButton(
          icon: _isRunning ? Icons.pause : Icons.play_arrow,
          size: 70,
          backgroundColor: _isCompleted 
              ? AppColors.success 
              : AppColors.primary,
          iconColor: Colors.white,
          onPressed: () {
            if (_isRunning) {
              _pauseTimer();
            } else if (_isPaused) {
              _resumeTimer();
            } else {
              // Start timer with current setup
              final duration = _getDurationFromInputs();
              if (duration.inMilliseconds > 0) {
                _startTimer(duration);
              }
            }
          },
        ),
        
        // Setup Button
        custom.CustomIconButton(
          icon: Icons.settings,
          size: 50,
          backgroundColor: Theme.of(context).colorScheme.surface,
          iconColor: Theme.of(context).textTheme.bodyMedium?.color,
          onPressed: _isRunning || _isPaused ? null : () {
            _showTimerSetupDialog(context);
          },
        ),
        
      ],
    );
  }

  Widget _buildTimerSetup(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CONFIGURAR TEMPORIZADOR',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick Presets
            _buildQuickPresets(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPresets(BuildContext context) {
    final presets = [
      {'label': '1 min', 'duration': const Duration(minutes: 1)},
      {'label': '5 min', 'duration': const Duration(minutes: 5)},
      {'label': '10 min', 'duration': const Duration(minutes: 10)},
      {'label': '15 min', 'duration': const Duration(minutes: 15)},
      {'label': '30 min', 'duration': const Duration(minutes: 30)},
      {'label': '1 hora', 'duration': const Duration(hours: 1)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Presets rápidos',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((preset) {
            return ElevatedButton(
              onPressed: () {
                _startTimer(preset['duration'] as Duration);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(preset['label'] as String),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showTimerSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar Temporizador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Configuración manual',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeInput(
                    context,
                    'Horas',
                    _hoursController,
                    0,
                    23,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeInput(
                    context,
                    'Minutos',
                    _minutesController,
                    0,
                    59,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeInput(
                    context,
                    'Segundos',
                    _secondsController,
                    0,
                    59,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final duration = _getDurationFromInputs();
              if (duration.inMilliseconds > 0) {
                _startTimer(duration);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, configura un tiempo válido'),
                  ),
                );
              }
            },
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput(
    BuildContext context,
    String label,
    TextEditingController controller,
    int min,
    int max,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (value) {
            final intValue = int.tryParse(value) ?? 0;
            if (intValue > max) {
              controller.text = max.toString();
            }
          },
        ),
      ],
    );
  }

  Duration _getDurationFromInputs() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

}