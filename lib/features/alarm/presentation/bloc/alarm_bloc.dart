import 'package:flutter_application_1/features/alarm/presentation/bloc/alarm_event.dart';
import 'package:flutter_application_1/features/alarm/presentation/bloc/alarm_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/alarm_repository.dart';

// BLoC
class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final AlarmRepository repository;

  AlarmBloc({required this.repository}) : super(AlarmInitial()) {
    on<LoadAlarms>(_onLoadAlarms);
    on<CreateAlarm>(_onCreateAlarm);
    on<UpdateAlarm>(_onUpdateAlarm);
    on<DeleteAlarm>(_onDeleteAlarm);
    on<ToggleAlarm>(_onToggleAlarm);
  }

  Future<void> _onLoadAlarms(LoadAlarms event, Emitter<AlarmState> emit) async {
    emit(AlarmLoading());
    try {
      final alarms = await repository.getAllAlarms();
      emit(AlarmLoaded(alarms: alarms));
    } catch (e) {
      emit(AlarmError(e.toString()));
    }
  }

  Future<void> _onCreateAlarm(
    CreateAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await repository.createAlarm(event.alarm);
      add(LoadAlarms());
    } catch (e) {
      emit(AlarmError(e.toString()));
    }
  }

  Future<void> _onUpdateAlarm(
    UpdateAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await repository.updateAlarm(event.alarm);
      add(LoadAlarms());
    } catch (e) {
      emit(AlarmError(e.toString()));
    }
  }

  Future<void> _onDeleteAlarm(
    DeleteAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await repository.deleteAlarm(event.id);
      add(LoadAlarms());
    } catch (e) {
      emit(AlarmError(e.toString()));
    }
  }

  Future<void> _onToggleAlarm(
    ToggleAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await repository.toggleAlarm(event.id);
      add(LoadAlarms());
    } catch (e) {
      emit(AlarmError(e.toString()));
    }
  }
}
