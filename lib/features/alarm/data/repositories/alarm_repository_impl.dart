import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

//Domian
import '../../domain/entities/alarm.dart';
import '../../domain/repositories/alarm_repository.dart';

//Model
import '../models/alarm_model.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  static Database? _database;
  static const String _tableName = 'alarms';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), 'alarms.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        time TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        repeat_days TEXT
      )
    ''');
  }

  @override
  Future<List<Alarm>> getAllAlarms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'time ASC',
    );

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
    await db.insert(_tableName, alarmModel.toMap());
    return alarm.id;
  }

  @override
  Future<void> updateAlarm(Alarm alarm) async {
    final db = await database;
    final alarmModel = AlarmModel.fromEntity(alarm);
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
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> toggleAlarm(String id) async {
    final alarm = await getAlarmById(id);
    if (alarm != null) {
      final updatedAlarm = alarm.copyWith(isActive: !alarm.isActive);
      await updateAlarm(updatedAlarm);
    }
  }
}
