import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/world_clock.dart';
import '../../domain/repositories/world_clock_repository.dart';
import 'world_clock_event.dart';
import 'world_clock_state.dart';

class WorldClockBloc extends Bloc<WorldClockEvent, WorldClockState> {
  final WorldClockRepository repository;
  List<WorldClock>? _cachedWorldClocks; // Cache para mantener la lista de relojes

  WorldClockBloc({required this.repository}) : super(const WorldClockInitial()) {
    on<LoadWorldClocks>(_onLoadWorldClocks);
    on<GetWorldClockTime>(_onGetWorldClockTime);
    on<ResetToInitialState>(_onResetToInitialState);
  }

  Future<void> _onLoadWorldClocks(
    LoadWorldClocks event,
    Emitter<WorldClockState> emit,
  ) async {
    print('🎯 BLOC: Evento LoadWorldClocks recibido');
    emit(const WorldClockLoading());
    print('🎯 BLOC: Estado cambiado a WorldClockLoading');

    try {
      print('🎯 BLOC: Llamando a repository.getWorldClocks()');
      final worldClocks = await repository.getWorldClocks();
      _cachedWorldClocks = worldClocks;
      print('🎯 BLOC: ${worldClocks.length} relojes cargados exitosamente');
      print('🎯 BLOC: Cache actualizado con ${worldClocks.length} relojes');
      emit(WorldClockLoaded(worldClocks: worldClocks));
      print('🎯 BLOC: Estado cambiado a WorldClockLoaded');
    } catch (e) {
      print('🎯 BLOC: Error al cargar relojes: $e');
      emit(WorldClockError(message: 'Error al cargar los relojes: $e'));
      print('🎯 BLOC: Estado cambiado a WorldClockError');
    }
  }

  Future<void> _onGetWorldClockTime(
    GetWorldClockTime event,
    Emitter<WorldClockState> emit,
  ) async {
    print('🎯 BLOC: Evento GetWorldClockTime recibido para timezone: ${event.timezone}');

    try {
      print('🎯 BLOC: Llamando a repository.getWorldClockByTimezone(${event.timezone})');
      final worldClock = await repository.getWorldClockByTimezone(event.timezone);
      print('🎯 BLOC: Hora obtenida exitosamente para ${event.timezone}');
      print('🎯 BLOC: Ciudad: ${worldClock.city}, Hora: ${worldClock.currentTime}');

      final newState = WorldClockTimeLoaded(
        worldClock: worldClock,
        worldClocks: _cachedWorldClocks,
      );
      emit(newState);
      print('🎯 BLOC: Estado cambiado a WorldClockTimeLoaded');
      print('🎯 BLOC: Relojes en cache: ${_cachedWorldClocks?.length ?? 0}');
    } catch (e) {
      print('🎯 BLOC: Error al obtener hora para ${event.timezone}: $e');
      emit(WorldClockError(message: 'Error al obtener la hora: $e'));
      print('🎯 BLOC: Estado cambiado a WorldClockError');
    }
  }

  Future<void> _onResetToInitialState(
    ResetToInitialState event,
    Emitter<WorldClockState> emit,
  ) async {
    print('🎯 BLOC: Evento ResetToInitialState recibido');
    emit(const WorldClockInitial());
    print('🎯 BLOC: Estado cambiado a WorldClockInitial');
  }
}
