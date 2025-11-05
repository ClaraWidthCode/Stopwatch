import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'stopwatch.db';

  /// ID fijo del usuario por defecto
  static const String adminId = '1';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // FFI para desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON;');

    // 1) Tabla de usuarios
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        role TEXT NOT NULL DEFAULT 'admin',
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    // 2) Insertar admin por defecto
    final now = DateTime.now().toIso8601String();
    await db.insert('users', {
      'id': adminId,
      'username': 'admin',
      'role': 'admin',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });

    // 3) Tabla de alarmas (1 usuario -> muchas alarmas)
    await db.execute('''
      CREATE TABLE alarms(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        time TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        repeat_days TEXT,
        user_id TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES users(id)
          ON UPDATE CASCADE
          ON DELETE RESTRICT
      );
    ''');
    await db.execute('CREATE INDEX idx_alarms_user_id ON alarms(user_id);');

    // 4) Tabla de world_clocks (1 usuario -> muchos relojes)
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
        updated_at TEXT NOT NULL,
        user_id TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
          ON UPDATE CASCADE
          ON DELETE RESTRICT
      );
    ''');
    await db.execute(
      'CREATE INDEX idx_world_clocks_user_id ON world_clocks(user_id);',
    );

    // 5) Insertar relojes predefinidos con el usuario admin
    await _insertPredefinedWorldClocks(db, userId: adminId);
  }

  Future<void> _insertPredefinedWorldClocks(
    Database db, {
    required String userId,
  }) async {
    final now = DateTime.now().toIso8601String();

    final predefinedClocks = [
      {
        'id': 'America/New_York',
        'name': 'Nueva York',
        'timezone': 'America/New_York',
        'country': 'Estados Unidos',
        'city': 'Nueva York',
        'flag': '🇺🇸',
        'utc_offset_seconds': -18000,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
        'user_id': userId,
      },
      {
        'id': 'Europe/London',
        'name': 'Londres',
        'timezone': 'Europe/London',
        'country': 'Reino Unido',
        'city': 'Londres',
        'flag': '🇬🇧',
        'utc_offset_seconds': 0,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
        'user_id': userId,
      },
      {
        'id': 'Asia/Tokyo',
        'name': 'Tokio',
        'timezone': 'Asia/Tokyo',
        'country': 'Japón',
        'city': 'Tokio',
        'flag': '🇯🇵',
        'utc_offset_seconds': 32400,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
        'user_id': userId,
      },
      {
        'id': 'Australia/Sydney',
        'name': 'Sídney',
        'timezone': 'Australia/Sydney',
        'country': 'Australia',
        'city': 'Sídney',
        'flag': '🇦🇺',
        'utc_offset_seconds': 36000,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
        'user_id': userId,
      },
      {
        'id': 'America/Sao_Paulo',
        'name': 'São Paulo',
        'timezone': 'America/Sao_Paulo',
        'country': 'Brasil',
        'city': 'São Paulo',
        'flag': '🇧🇷',
        'utc_offset_seconds': -10800,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
        'user_id': userId,
      },
    ];

    for (final clock in predefinedClocks) {
      await db.insert('world_clocks', clock);
    }
  }
}
