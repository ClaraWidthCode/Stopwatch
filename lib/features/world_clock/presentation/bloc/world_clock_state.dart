import 'package:equatable/equatable.dart';
import '../../domain/entities/world_clock.dart';

abstract class WorldClockState extends Equatable {
  const WorldClockState();

  @override
  List<Object?> get props => [];
}

class WorldClockInitial extends WorldClockState {
  const WorldClockInitial();
}

class WorldClockLoading extends WorldClockState {
  const WorldClockLoading();
}

class WorldClockLoaded extends WorldClockState {
  final List<WorldClock> worldClocks;

  const WorldClockLoaded({
    required this.worldClocks,
  });

  @override
  List<Object?> get props => [worldClocks];
}

class WorldClockTimeLoaded extends WorldClockState {
  final WorldClock worldClock;
  final List<WorldClock>? worldClocks; // Lista de relojes para mantener el contexto

  const WorldClockTimeLoaded({
    required this.worldClock,
    this.worldClocks,
  });

  @override
  List<Object?> get props => [worldClock, worldClocks];
}

class WorldClockError extends WorldClockState {
  final String message;

  const WorldClockError({required this.message});

  @override
  List<Object?> get props => [message];
}
