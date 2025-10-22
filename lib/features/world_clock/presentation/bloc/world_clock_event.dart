import 'package:equatable/equatable.dart';

abstract class WorldClockEvent extends Equatable {
  const WorldClockEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorldClocks extends WorldClockEvent {
  const LoadWorldClocks();
}

class GetWorldClockTime extends WorldClockEvent {
  final String timezone;

  const GetWorldClockTime({required this.timezone});

  @override
  List<Object?> get props => [timezone];
}

class ResetToInitialState extends WorldClockEvent {
  const ResetToInitialState();
}
