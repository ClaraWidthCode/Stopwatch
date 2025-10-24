import 'package:sqflite/sqflite.dart';

//Core
import '../../../../core/database/database_helper.dart';

import '../../domain/entities/world_clock.dart';
import '../models/world_clock_model.dart';

class WorldClockDatabaseRepository {
  final DatabaseHelper _databaseHelper;
  static const String _tableName = 'world_clocks';

  WorldClockDatabaseRepository({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  Future<Database> get database => _databaseHelper.database;


  Future<List<WorldClock>> getAllWorldClocks() async {
    final db = await database;
    print('🕐 WORLD CLOCK REPO: Consultando relojes mundiales desde tabla compartida');

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'name ASC',
      );

      print('🕐 WORLD CLOCK REPO: ${maps.length} relojes mundiales encontrados');
      final result = List.generate(maps.length, (i) {
        return WorldClockModel.fromMap(maps[i]).toEntity();
      });

      return result;
    } catch (e) {
      print('🕐 WORLD CLOCK REPO: Error consultando relojes mundiales: $e');
      rethrow;
    }
  }

  Future<WorldClock?> getWorldClockById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return WorldClockModel.fromMap(maps.first).toEntity();
    }
    return null;
  }

  Future<String> createWorldClock(WorldClock worldClock) async {
    final db = await database;
    final worldClockModel = WorldClockModel.fromEntity(worldClock);
    final now = DateTime.now().toIso8601String();

    final map = worldClockModel.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    map['is_active'] = 1;

    print('🕐 WORLD CLOCK REPO: Creando nuevo reloj mundial: ${worldClock.name}');
    await db.insert(_tableName, map);
    return worldClock.id;
  }

  Future<void> updateWorldClock(WorldClock worldClock) async {
    final db = await database;
    final worldClockModel = WorldClockModel.fromEntity(worldClock);
    final now = DateTime.now().toIso8601String();

    final map = worldClockModel.toMap();
    map['updated_at'] = now;

    print('🕐 WORLD CLOCK REPO: Actualizando reloj mundial: ${worldClock.name}');
    await db.update(
      _tableName,
      map,
      where: 'id = ?',
      whereArgs: [worldClock.id],
    );
  }

  Future<void> deleteWorldClock(String id) async {
    final db = await database;
    print('🕐 WORLD CLOCK REPO: Desactivando reloj mundial con ID: $id');
    await db.update(
      _tableName,
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleWorldClock(String id) async {
    final worldClock = await getWorldClockById(id);
    if (worldClock != null) {
      final db = await database;
      final isActive = await db.query(
        _tableName,
        columns: ['is_active'],
        where: 'id = ?',
        whereArgs: [id],
      );

      final currentStatus = isActive.first['is_active'];
      final newActiveStatus = currentStatus == 1 ? 0 : 1;

      print('🕐 WORLD CLOCK REPO: Cambiando estado de reloj mundial: ${worldClock.name} -> ${newActiveStatus == 1}');
      await db.update(
        _tableName,
        {
          'is_active': newActiveStatus,
          'updated_at': DateTime.now().toIso8601String()
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}

