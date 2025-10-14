import 'package:equatable/equatable.dart';

//Domain
import '../../domain/entities/alarm.dart';

abstract class AlarmEvent extends Equatable {
  const AlarmEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlarms extends AlarmEvent {}

class CreateAlarm extends AlarmEvent {
  final Alarm alarm;
  const CreateAlarm(this.alarm);

  @override
  List<Object> get props => [alarm];
}

class UpdateAlarm extends AlarmEvent {
  final Alarm alarm;
  const UpdateAlarm(this.alarm);

  @override
  List<Object> get props => [alarm];
}

class DeleteAlarm extends AlarmEvent {
  final String id;
  const DeleteAlarm(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleAlarm extends AlarmEvent {
  final String id;
  const ToggleAlarm(this.id);

  @override
  List<Object> get props => [id];
}
