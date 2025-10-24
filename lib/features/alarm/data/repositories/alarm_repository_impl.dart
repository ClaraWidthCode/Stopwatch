
import 'package:sqflite/sqflite.dart';

//Core
import '../../../../core/database/database_helper.dart';

//Domain
import '../../domain/entities/alarm.dart';
import '../../domain/repositories/alarm_repository.dart';

//Model
import '../models/alarm_model.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final DatabaseHelper _databaseHelper;
  static const String _tableName = 'alarms';

  AlarmRepositoryImpl({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  Future<Database> get database => _databaseHelper.database;

  @override
  Future<List<Alarm>> getAllAlarms() async {
    final db = await database;
    print('🔊 ALARM REPO: Consultando todas las alarmas desde tabla compartida');
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'time ASC',
    );

    print('🔊 ALARM REPO: ${maps.length} alarmas encontradas');
    return List.generate(maps.length, (i) {
      return AlarmModel.fromMap(maps[i]).toEntity();
    });
  }

  @override
  Future<Alarm?> getAlarmById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AlarmModel.fromMap(maps.first).toEntity();
    }
    return null;
  }

  @override
  Future<String> createAlarm(Alarm alarm) async {
    final db = await database;
    final alarmModel = AlarmModel.fromEntity(alarm);
    print('🔊 ALARM REPO: Creando nueva alarma: ${alarm.title}');
    await db.insert(_tableName, alarmModel.toMap());
    return alarm.id;
  }

  @override
  Future<void> updateAlarm(Alarm alarm) async {
    final db = await database;
    final alarmModel = AlarmModel.fromEntity(alarm);
    print('🔊 ALARM REPO: Actualizando alarma: ${alarm.title}');
    await db.update(
      _tableName,
      alarmModel.toMap(),
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
  }

  @override
  Future<void> deleteAlarm(String id) async {
    final db = await database;
    print('🔊 ALARM REPO: Eliminando alarma con ID: $id');
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> toggleAlarm(String id) async {
    final alarm = await getAlarmById(id);
    if (alarm != null) {
      final updatedAlarm = alarm.copyWith(isActive: !alarm.isActive);
      print('🔊 ALARM REPO: Cambiando estado de alarma: ${alarm.title} -> ${updatedAlarm.isActive}');
      await updateAlarm(updatedAlarm);
    }
  }
}
