import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'stopwatch.db';

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

    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de alarmas
    await db.execute('''
      CREATE TABLE alarms(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        time TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        repeat_days TEXT
      )
    ''');

    // Crear tabla de world clocks
    await db.execute('''
      CREATE TABLE world_clocks(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        timezone TEXT NOT NULL,
        country TEXT NOT NULL,
        city TEXT NOT NULL,
        flag TEXT NOT NULL,
        utc_offset_seconds INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Insertar las zonas horarias predefinidas
    await _insertPredefinedWorldClocks(db);
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
        'utc_offset_seconds': -18000, // -5 horas en segundos
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
        'utc_offset_seconds': 0, // GMT (sin considerar DST por simplicidad)
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
        'utc_offset_seconds': 32400, // +9 horas en segundos
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
        'utc_offset_seconds': 36000, // +10 horas en segundos
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
        'utc_offset_seconds': -10800, // -3 horas en segundos
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (int i = 0; i < predefinedClocks.length; i++) {
      final clock = predefinedClocks[i];
      try {
        await db.insert('world_clocks', clock);
      } catch (e) {
        rethrow;
      }
    }
  }
}
