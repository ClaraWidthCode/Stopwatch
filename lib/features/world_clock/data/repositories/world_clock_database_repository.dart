import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../../domain/entities/world_clock.dart';
import '../models/world_clock_model.dart';

class WorldClockDatabaseRepository {
  static Database? _database;
  static const String _tableName = 'world_clocks';

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
    
    String path = join(await getDatabasesPath(), 'world_clocks.db');
    
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE $_tableName(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          timezone TEXT NOT NULL,
          country TEXT NOT NULL,
          city TEXT NOT NULL,
          flag TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // Insertar las zonas horarias predefinidas
      await _insertPredefinedWorldClocks(db);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _insertPredefinedWorldClocks(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    final predefinedClocks = [
      {
        'id': 'America/New_York',
        'name': 'Nueva York',
        'timezone': 'America/New_York',
        'country': 'Estados Unidos',
        'city': 'Nueva York',
        'flag': '🇺🇸',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'Europe/London',
        'name': 'Londres',
        'timezone': 'Europe/London',
        'country': 'Reino Unido',
        'city': 'Londres',
        'flag': '🇬🇧',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'Asia/Tokyo',
        'name': 'Tokio',
        'timezone': 'Asia/Tokyo',
        'country': 'Japón',
        'city': 'Tokio',
        'flag': '🇯🇵',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'Australia/Sydney',
        'name': 'Sídney',
        'timezone': 'Australia/Sydney',
        'country': 'Australia',
        'city': 'Sídney',
        'flag': '🇦🇺',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'America/Sao_Paulo',
        'name': 'São Paulo',
        'timezone': 'America/Sao_Paulo',
        'country': 'Brasil',
        'city': 'São Paulo',
        'flag': '🇧🇷',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (int i = 0; i < predefinedClocks.length; i++) {
      final clock = predefinedClocks[i];
      try {
        await db.insert(_tableName, clock);
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<List<WorldClock>> getAllWorldClocks() async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'name ASC',
      );
      
      final result = List.generate(maps.length, (i) {
        return WorldClockModel.fromMap(maps[i]).toEntity();
      });
      
      return result;
    } catch (e) {
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
    
    await db.insert(_tableName, map);
    return worldClock.id;
  }

  Future<void> updateWorldClock(WorldClock worldClock) async {
    final db = await database;
    final worldClockModel = WorldClockModel.fromEntity(worldClock);
    final now = DateTime.now().toIso8601String();
    
    final map = worldClockModel.toMap();
    map['updated_at'] = now;
    
    await db.update(
      _tableName,
      map,
      where: 'id = ?',
      whereArgs: [worldClock.id],
    );
  }

  Future<void> deleteWorldClock(String id) async {
    final db = await database;
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

