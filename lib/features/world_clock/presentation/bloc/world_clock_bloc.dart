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
    emit(const WorldClockLoading());
    
    try {
      final worldClocks = await repository.getWorldClocks();
      _cachedWorldClocks = worldClocks;
      emit(WorldClockLoaded(worldClocks: worldClocks));
    } catch (e) {
      emit(WorldClockError(message: 'Error al cargar los relojes: $e'));
    }
  }

  Future<void> _onGetWorldClockTime(
    GetWorldClockTime event,
    Emitter<WorldClockState> emit,
  ) async {
    try {
      final worldClock = await repository.getWorldClockByTimezone(event.timezone);
      emit(WorldClockTimeLoaded(
        worldClock: worldClock,
        worldClocks: _cachedWorldClocks,
      ));
    } catch (e) {
      emit(WorldClockError(message: 'Error al obtener la hora: $e'));
    }
  }

  Future<void> _onResetToInitialState(
    ResetToInitialState event,
    Emitter<WorldClockState> emit,
  ) async {
    emit(const WorldClockInitial());
  }
}
