import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_switch.dart';
import '../../../../core/widgets/time_display_widget.dart';
import '../../../../core/widgets/circular_progress_widget.dart';

//Domain
import '../../domain/entities/alarm.dart';

//Bloc
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_state.dart';
import '../bloc/alarm_event.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  String? _lastAlarmId;
  bool _showAlarmDialog = false;
  DateTime? _lastAlarmTime;

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
            Expanded(child: _buildAlarmsList(context)),
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
    return BlocBuilder<AlarmBloc, AlarmState>(
      builder: (context, state) {
        if (state is AlarmLoaded && state.alarms.isNotEmpty) {
          final nextAlarm = _getNextAlarm(state.alarms);
          if (nextAlarm != null) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'PRÓXIMA ALARMA',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withAlpha(70),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  StreamBuilder<DateTime>(
                    stream: Stream.periodic(
                      const Duration(seconds: 1),
                      (_) => DateTime.now(),
                    ),
                    builder: (context, snapshot) {
                      final now = snapshot.data ?? DateTime.now();
                      final timeUntilAlarm = _getTimeUntilAlarm(nextAlarm, now);
                      final progress = _getProgressToNextAlarm(nextAlarm, now);

                      // Detectar cuando el temporizador llega a cero
                      if (timeUntilAlarm.inSeconds <= 0 &&
                          timeUntilAlarm.inSeconds >= -5 &&
                          !_showAlarmDialog &&
                          (_lastAlarmId != nextAlarm.id ||
                              _lastAlarmTime == null ||
                              now.difference(_lastAlarmTime!).inMinutes >= 1)) {
                        _lastAlarmId = nextAlarm.id;
                        _lastAlarmTime = now;
                        _showAlarmDialog = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _showAlarmFinishedDialog(context, nextAlarm);
                        });
                      }

                      return CircularProgressWidget(
                        progress: progress,
                        size: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TimeDisplayWidget(
                              duration: timeUntilAlarm,
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              nextAlarm.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat(
                                'EEEE, MMMM d',
                                'es',
                              ).format(nextAlarm.time),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        }

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'PRÓXIMA ALARMA',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withAlpha(70),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              CircularProgressWidget(
                progress: 0.0,
                size: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.alarm_off,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withAlpha(50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sin alarmas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withAlpha(70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlarmsList(BuildContext context) {
    return BlocBuilder<AlarmBloc, AlarmState>(
      builder: (context, state) {
        if (state is AlarmLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AlarmError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withAlpha(50),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar alarmas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state is AlarmLoaded) {
          if (state.alarms.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.alarm_add,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withAlpha(50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay alarmas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toca el botón + para agregar una alarma',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: state.alarms.length,
            itemBuilder: (context, index) {
              final alarm = state.alarms[index];
              return _buildAlarmItem(context, alarm);
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAlarmItem(BuildContext context, Alarm alarm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
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
                  DateFormat('HH:mm').format(alarm.time),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: alarm.isActive
                        ? Theme.of(context).textTheme.headlineMedium?.color
                        : Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withAlpha(50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alarm.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: alarm.isActive
                        ? Theme.of(context).textTheme.titleMedium?.color
                        : Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withAlpha(50),
                  ),
                ),
                if (alarm.repeatDays.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getRepeatText(alarm.repeatDays),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withAlpha(70),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              CustomSwitch(
                value: alarm.isActive,
                onChanged: (value) {
                  context.read<AlarmBloc>().add(ToggleAlarm(alarm.id));
                },
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditAlarmDialog(context, alarm);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, alarm);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddAlarmDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime selectedTime = DateTime.now().add(const Duration(hours: 1));
    List<int> selectedDays = [];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Nueva Alarma'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ej: Despertar',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Hora'),
                  subtitle: Text(DateFormat('HH:mm').format(selectedTime)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedTime),
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = DateTime(
                          selectedTime.year,
                          selectedTime.month,
                          selectedTime.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Repetir'),
                const SizedBox(height: 8),
                Wrap(
                  children: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final day = entry.value;
                        final isSelected = selectedDays.contains(index);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 8),
                          child: FilterChip(
                            label: Text(day),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedDays.add(index);
                                } else {
                                  selectedDays.remove(index);
                                }
                              });
                            },
                          ),
                        );
                      })
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final alarm = Alarm(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    time: selectedTime,
                    repeatDays: selectedDays,
                  );
                  context.read<AlarmBloc>().add(CreateAlarm(alarm));
                  _resetAlarmDialogState(); // Resetear estado del diálogo
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAlarmDialog(BuildContext context, Alarm alarm) {
    final titleController = TextEditingController(text: alarm.title);
    DateTime selectedTime = alarm.time;
    List<int> selectedDays = List.from(alarm.repeatDays);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Editar Alarma'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Hora'),
                  subtitle: Text(DateFormat('HH:mm').format(selectedTime)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedTime),
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = DateTime(
                          selectedTime.year,
                          selectedTime.month,
                          selectedTime.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Repetir'),
                const SizedBox(height: 8),
                Wrap(
                  children: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final day = entry.value;
                        final isSelected = selectedDays.contains(index);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 8),
                          child: FilterChip(
                            label: Text(day),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedDays.add(index);
                                } else {
                                  selectedDays.remove(index);
                                }
                              });
                            },
                          ),
                        );
                      })
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final updatedAlarm = alarm.copyWith(
                    title: titleController.text,
                    time: selectedTime,
                    repeatDays: selectedDays,
                  );
                  context.read<AlarmBloc>().add(UpdateAlarm(updatedAlarm));
                  _resetAlarmDialogState(); // Resetear estado del diálogo
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Alarm alarm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Alarma'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${alarm.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AlarmBloc>().add(DeleteAlarm(alarm.id));
              Navigator.of(dialogContext).pop();
            },

            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Alarm? _getNextAlarm(List<Alarm> alarms) {
    final activeAlarms = alarms.where((alarm) => alarm.isActive).toList();
    if (activeAlarms.isEmpty) return null;

    final now = DateTime.now();
    Alarm? nextAlarm;
    Duration? minDuration;

    for (final alarm in activeAlarms) {
      final alarmTime = DateTime(
        now.year,
        now.month,
        now.day,
        alarm.time.hour,
        alarm.time.minute,
      );
      Duration duration;

      if (alarmTime.isAfter(now)) {
        // La alarma es para hoy
        duration = alarmTime.difference(now);
      } else {
        // La alarma ya pasó hoy
        if (alarm.repeatDays.isEmpty) {
          // Si no tiene días de repetición, calcular para mañana
          final tomorrowAlarmTime = alarmTime.add(const Duration(days: 1));
          duration = tomorrowAlarmTime.difference(now);
        } else {
          // Si tiene días de repetición, buscar el próximo día válido
          final nextValidDay = _getNextValidDay(alarm.repeatDays, now.weekday);
          if (nextValidDay != null) {
            final daysUntilNext = (nextValidDay - now.weekday) % 7;
            final nextAlarmTime = alarmTime.add(
              Duration(days: daysUntilNext == 0 ? 7 : daysUntilNext),
            );
            duration = nextAlarmTime.difference(now);
          } else {
            // Si no hay días válidos, calcular para mañana
            final tomorrowAlarmTime = alarmTime.add(const Duration(days: 1));
            duration = tomorrowAlarmTime.difference(now);
          }
        }
      }

      if (minDuration == null || duration < minDuration) {
        minDuration = duration;
        nextAlarm = alarm;
      }
    }

    return nextAlarm;
  }

  int? _getNextValidDay(List<int> repeatDays, int currentWeekday) {
    if (repeatDays.isEmpty) return null;

    // Buscar el próximo día válido
    for (int i = 1; i <= 7; i++) {
      final nextDay = (currentWeekday + i) % 7;
      if (repeatDays.contains(nextDay)) {
        return nextDay;
      }
    }

    return null;
  }

  double _getProgressToNextAlarm(Alarm alarm, DateTime now) {
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    if (alarmTime.isAfter(now)) {
      // La alarma es para hoy
      final totalMinutes = 24 * 60; // Total minutes in a day
      final remainingMinutes = alarmTime.difference(now).inMinutes;
      return (totalMinutes - remainingMinutes) / totalMinutes;
    } else {
      // La alarma ya pasó hoy
      if (alarm.repeatDays.isNotEmpty) {
        // Si tiene días de repetición, calcular progreso basado en días
        final nextValidDay = _getNextValidDay(alarm.repeatDays, now.weekday);
        if (nextValidDay != null) {
          final daysUntilNext = (nextValidDay - now.weekday) % 7;
          final totalDays = daysUntilNext == 0 ? 7 : daysUntilNext;
          final progressPerDay = 1.0 / totalDays;
          return progressPerDay * (totalDays - daysUntilNext);
        }
      } else {
        // Si no tiene días de repetición, mostrar progreso para mañana
        final tomorrowAlarmTime = alarmTime.add(const Duration(days: 1));
        final totalMinutes = 24 * 60; // Total minutes in a day
        final remainingMinutes = tomorrowAlarmTime.difference(now).inMinutes;
        return (totalMinutes - remainingMinutes) / totalMinutes;
      }
      return 0.0;
    }
  }

  Duration _getTimeUntilAlarm(Alarm alarm, DateTime now) {
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    if (alarmTime.isAfter(now)) {
      // La alarma es para hoy
      return alarmTime.difference(now);
    } else {
      // La alarma ya pasó hoy, calcular para mañana
      if (alarm.repeatDays.isNotEmpty) {
        // Si tiene días de repetición, buscar el próximo día válido
        final nextValidDay = _getNextValidDay(alarm.repeatDays, now.weekday);
        if (nextValidDay != null) {
          final daysUntilNext = (nextValidDay - now.weekday) % 7;
          final nextAlarmTime = alarmTime.add(
            Duration(days: daysUntilNext == 0 ? 7 : daysUntilNext),
          );
          return nextAlarmTime.difference(now);
        }
      } else {
        // Si no tiene días de repetición, calcular para mañana
        final tomorrowAlarmTime = alarmTime.add(const Duration(days: 1));
        return tomorrowAlarmTime.difference(now);
      }
      return const Duration(seconds: 0);
    }
  }

  void _resetAlarmDialogState() {
    _lastAlarmId = null;
    _lastAlarmTime = null;
    _showAlarmDialog = false;
  }

  void _showAlarmFinishedDialog(BuildContext context, Alarm alarm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.alarm, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Alarma!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    alarm.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('HH:mm').format(alarm.time),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d', 'es').format(alarm.time),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'La alarma ha sonado. ¿Qué deseas hacer?',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Desactivar la alarma si no tiene repetición
              if (alarm.repeatDays.isEmpty) {
                context.read<AlarmBloc>().add(ToggleAlarm(alarm.id));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              alarm.repeatDays.isEmpty ? 'Desactivar' : 'Entendido',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ).then((_) {
      _showAlarmDialog = false;
    });
  }

  String _getRepeatText(List<int> repeatDays) {
    if (repeatDays.isEmpty) return 'Sin repetir';

    final dayNames = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    final selectedDays = repeatDays.map((day) => dayNames[day]).join(', ');

    return 'Repetir: $selectedDays';
  }
}
