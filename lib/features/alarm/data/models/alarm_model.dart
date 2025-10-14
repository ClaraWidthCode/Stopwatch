//Domian
import '../../domain/entities/alarm.dart';

class AlarmModel extends Alarm {
  const AlarmModel({
    required super.id,
    required super.title,
    required super.time,
    super.isActive,
    super.repeatDays,
  });

  factory AlarmModel.fromEntity(Alarm alarm) {
    return AlarmModel(
      id: alarm.id,
      title: alarm.title,
      time: alarm.time,
      isActive: alarm.isActive,
      repeatDays: alarm.repeatDays,
    );
  }

  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id'] as String,
      title: map['title'] as String,
      time: DateTime.parse(map['time'] as String),
      isActive: (map['is_active'] as int) == 1,
      repeatDays: _parseRepeatDays(map['repeat_days'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'repeat_days': _encodeRepeatDays(repeatDays),
    };
  }

  static List<int> _parseRepeatDays(String? repeatDaysString) {
    if (repeatDaysString == null || repeatDaysString.isEmpty) {
      return [];
    }
    return repeatDaysString.split(',').map(int.parse).toList();
  }

  static String _encodeRepeatDays(List<int> repeatDays) {
    return repeatDays.join(',');
  }

  Alarm toEntity() {
    return Alarm(
      id: id,
      title: title,
      time: time,
      isActive: isActive,
      repeatDays: repeatDays,
    );
  }
}
