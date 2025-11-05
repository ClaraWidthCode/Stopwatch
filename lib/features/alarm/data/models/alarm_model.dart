// Domain
import '../../domain/entities/alarm.dart';

// Core
import '../../../../core/database/database_helper.dart';

class AlarmModel extends Alarm {
  const AlarmModel({
    required super.id,
    required super.title,
    required super.time,
    super.isActive = true,
    super.repeatDays = const [],
    super.userId = DatabaseHelper.adminId,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un modelo a partir de la entidad del dominio
  factory AlarmModel.fromEntity(Alarm alarm) {
    return AlarmModel(
      id: alarm.id,
      title: alarm.title,
      time: alarm.time,
      isActive: alarm.isActive,
      repeatDays: alarm.repeatDays,
      userId: alarm.userId,
      createdAt: alarm.createdAt,
      updatedAt: alarm.updatedAt,
    );
  }

  /// Crea un modelo desde un registro de la base de datos (Map)
  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id'] as String,
      title: map['title'] as String,
      time: DateTime.parse(map['time'] as String),
      isActive: (map['is_active'] as int) == 1,
      repeatDays: _parseRepeatDays(map['repeat_days'] as String?),
      userId: map['user_id'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  /// Convierte el modelo en un Map para guardar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'repeat_days': _encodeRepeatDays(repeatDays),
      'user_id': userId ?? DatabaseHelper.adminId,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Convierte el modelo a la entidad del dominio
  Alarm toEntity() {
    return Alarm(
      id: id,
      title: title,
      time: time,
      isActive: isActive,
      repeatDays: repeatDays,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Helpers para codificar/decodificar los días de repetición
  static List<int> _parseRepeatDays(String? repeatDaysString) {
    if (repeatDaysString == null || repeatDaysString.isEmpty) return [];
    return repeatDaysString.split(',').map(int.parse).toList();
  }

  static String _encodeRepeatDays(List<int> repeatDays) {
    return repeatDays.join(',');
  }
}
