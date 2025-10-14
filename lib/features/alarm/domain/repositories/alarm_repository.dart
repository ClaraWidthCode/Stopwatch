//Domain
import '../../domain/entities/alarm.dart';

abstract class AlarmRepository {
  Future<List<Alarm>> getAllAlarms();
  Future<Alarm?> getAlarmById(String id);
  Future<String> createAlarm(Alarm alarm);
  Future<void> updateAlarm(Alarm alarm);
  Future<void> deleteAlarm(String id);
  Future<void> toggleAlarm(String id);
}

