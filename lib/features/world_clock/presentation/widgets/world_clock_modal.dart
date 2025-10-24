import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/world_clock.dart';
import '../bloc/world_clock_bloc.dart';
import '../bloc/world_clock_event.dart';
import '../bloc/world_clock_state.dart';

class WorldClockModal extends StatefulWidget {
  final WorldClock worldClock;

  const WorldClockModal({
    super.key,
    required this.worldClock,
  });

  @override
  State<WorldClockModal> createState() => _WorldClockModalState();
}

class _WorldClockModalState extends State<WorldClockModal> {
  late DateTime currentTime;
  late Timer _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    currentTime = widget.worldClock.currentTime;
    print('🖥️ MODAL: InitState - Ciudad: ${widget.worldClock.city}, Timezone: ${widget.worldClock.timezone}, Hora inicial: ${widget.worldClock.currentTime}');
    print('🖥️ MODAL: La hora inicial es UTC y será convertida a hora local de ${widget.worldClock.timezone}');
    _loadCurrentTime();
  }

  void _loadCurrentTime() {
    print('🖥️ MODAL: Llamando a API para obtener hora actual de ${widget.worldClock.timezone}');
    context.read<WorldClockBloc>().add(
      GetWorldClockTime(timezone: widget.worldClock.timezone),
    );
  }


  void _startTimer() {
    print('🖥️ MODAL: Iniciando timer de actualización cada segundo');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = currentTime.add(const Duration(seconds: 1));
      });
      // Imprimir cada 10 segundos para no saturar el log
      if (timer.tick % 10 == 0) {
        print('🖥️ MODAL: Timer ejecutándose - Hora actual: ${currentTime.toString().substring(11, 19)}');
      }
    });
  }

  @override
  void dispose() {
    print('🖥️ MODAL: Dispose - Cancelando timer y destruyendo modal');
    print('🖥️ MODAL: Hora final: ${currentTime.toString().substring(11, 19)}');
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm:ss');
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'es');
    final dayFormat = DateFormat('EEEE', 'es');
    
    return BlocListener<WorldClockBloc, WorldClockState>(
      listener: (context, state) {
        print('🖥️ MODAL: Estado recibido: ${state.runtimeType}');

        if (state is WorldClockTimeLoaded) {
          print('🖥️ MODAL: WorldClockTimeLoaded recibido');
          print('🖥️ MODAL: Nueva hora obtenida (UTC): ${state.worldClock.currentTime}');
          print('🖥️ MODAL: Ciudad: ${state.worldClock.city}, País: ${state.worldClock.country}');

          // Convertir UTC a hora local usando el offset de la API
          final localTime = state.worldClock.currentTime.add(Duration(seconds: state.worldClock.utcOffsetSeconds));
          print('🖥️ MODAL: Nueva hora obtenida (UTC): ${state.worldClock.currentTime}');
          print('🖥️ MODAL: Offset de API: ${state.worldClock.utcOffsetSeconds} segundos (${state.worldClock.utcOffsetSeconds / 3600} horas)');
          print('🖥️ MODAL: Hora convertida a local: $localTime');
          print('🖥️ MODAL: Diferencia UTC vs Local: ${localTime.difference(state.worldClock.currentTime)}');

          setState(() {
            currentTime = localTime;
            _isLoading = false;
          });
          print('🖥️ MODAL: UI actualizada con nueva hora local, loading = false');
          _startTimer();
        } else if (state is WorldClockError) {
          print('🖥️ MODAL: WorldClockError recibido: ${state.message}');
          print('🖥️ MODAL: Usando hora local como fallback');

          setState(() {
            _isLoading = false;
          });
          print('🖥️ MODAL: UI actualizada con fallback, loading = false');
          _startTimer(); // Iniciar timer con hora local como fallback
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con botón de cerrar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24), // Espacio para centrar el contenido
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              widget.worldClock.flag,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.worldClock.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.worldClock.country,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón de cerrar
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Hora principal
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else ...[
                      Text(
                        timeFormat.format(currentTime),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dayFormat.format(currentTime),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        dateFormat.format(currentTime),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Información adicional
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Zona horaria', widget.worldClock.timezone),
                    const SizedBox(height: 8),
                    _buildInfoRow('Ciudad', widget.worldClock.city),
                    const SizedBox(height: 8),
                    _buildInfoRow('País', widget.worldClock.country),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
