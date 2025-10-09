import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/circular_progress_widget.dart';
import '../../../../core/widgets/time_display_widget.dart';
import '../../../../core/widgets/custom_switch.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  List<AlarmData> _alarms = [];
  AlarmData? _nextAlarm;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Sample data for demonstration
    _alarms = [
      AlarmData(
        id: '1',
        time: DateTime.now().add(const Duration(hours: 2)),
        label: 'Despertar',
        isEnabled: true,
      ),
      AlarmData(
        id: '2',
        time: DateTime.now().add(const Duration(hours: 8)),
        label: 'Trabajo',
        isEnabled: false,
      ),
    ];
    _nextAlarm = _alarms.firstWhere((alarm) => alarm.isEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Next Alarm Section
            _buildNextAlarmSection(context),
            
            const SizedBox(height: 24),
            
            // Alarms List Section
            Expanded(
              child: _buildAlarmsList(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAlarmDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNextAlarmSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'PRÓXIMA ALARMA',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_nextAlarm != null) ...[
            CircularProgressWidget(
              progress: _calculateAlarmProgress(_nextAlarm!),
              size: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TimeDisplayWidget(
                    duration: _calculateTimeUntilAlarm(_nextAlarm!),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.alarm,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_nextAlarm!.time.hour.toString().padLeft(2, '0')}:${_nextAlarm!.time.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.alarm_off,
                      size: 48,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sin alarmas',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlarmsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'ALARMAS',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _alarms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.alarm_add,
                        size: 64,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay alarmas configuradas',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca el botón + para agregar una nueva alarma',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _alarms.length,
                  itemBuilder: (context, index) {
                    final alarm = _alarms[index];
                    return _buildAlarmItem(context, alarm);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAlarmItem(BuildContext context, AlarmData alarm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alarm.label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          CustomSwitch(
            value: alarm.isEnabled,
            onChanged: (value) {
              setState(() {
                alarm.isEnabled = value;
                _nextAlarm = _alarms.where((a) => a.isEnabled).isNotEmpty 
                    ? _alarms.firstWhere((a) => a.isEnabled)
                    : null;
              });
            },
          ),
        ],
      ),
    );
  }

  double _calculateAlarmProgress(AlarmData alarm) {
    final now = DateTime.now();
    final alarmTime = DateTime(now.year, now.month, now.day, alarm.time.hour, alarm.time.minute);
    
    Duration timeUntilAlarm;
    if (alarmTime.isAfter(now)) {
      timeUntilAlarm = alarmTime.difference(now);
    } else {
      final tomorrowAlarm = alarmTime.add(const Duration(days: 1));
      timeUntilAlarm = tomorrowAlarm.difference(now);
    }

    // Calculate progress as percentage of 24 hours
    final totalSecondsInDay = 24 * 60 * 60;
    final remainingSeconds = timeUntilAlarm.inSeconds;
    
    return 1.0 - (remainingSeconds / totalSecondsInDay);
  }

  Duration _calculateTimeUntilAlarm(AlarmData alarm) {
    final now = DateTime.now();
    final alarmTime = DateTime(now.year, now.month, now.day, alarm.time.hour, alarm.time.minute);
    
    if (alarmTime.isAfter(now)) {
      return alarmTime.difference(now);
    } else {
      final tomorrowAlarm = alarmTime.add(const Duration(days: 1));
      return tomorrowAlarm.difference(now);
    }
  }

  void _showAddAlarmDialog(BuildContext context) {
    TimeOfDay selectedTime = TimeOfDay.now();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva Alarma'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Hora'),
                subtitle: Text(selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                    });
                  }
                },
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
                final now = DateTime.now();
                final alarmTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                
                final alarm = AlarmData(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  time: alarmTime,
                  label: 'Nueva Alarma',
                );
                
                setState(() {
                  _alarms.add(alarm);
                  _nextAlarm = _alarms.where((a) => a.isEnabled).isNotEmpty 
                      ? _alarms.firstWhere((a) => a.isEnabled)
                      : null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }
}

class AlarmData {
  final String id;
  final DateTime time;
  final String label;
  bool isEnabled;

  AlarmData({
    required this.id,
    required this.time,
    required this.label,
    this.isEnabled = true,
  });
}