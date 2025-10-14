import 'package:equatable/equatable.dart';

//Domain
import '../../domain/entities/alarm.dart';

abstract class AlarmState extends Equatable {
  const AlarmState();

  @override
  List<Object?> get props => [];
}

class AlarmInitial extends AlarmState {}

class AlarmLoading extends AlarmState {}

class AlarmLoaded extends AlarmState {
  final List<Alarm> alarms;
  const AlarmLoaded({required this.alarms});

  @override
  List<Object> get props => [alarms];
}

class AlarmError extends AlarmState {
  final String message;
  const AlarmError(this.message);

  @override
  List<Object> get props => [message];
}
