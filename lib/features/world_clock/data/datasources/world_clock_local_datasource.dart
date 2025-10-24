import '../models/world_clock_model.dart';
import '../repositories/world_clock_database_repository.dart';

abstract class WorldClockLocalDataSource {
  Future<List<WorldClockModel>> getPredefinedWorldClocks();
}

class WorldClockLocalDataSourceImpl implements WorldClockLocalDataSource {
  final WorldClockDatabaseRepository _databaseRepository;

  WorldClockLocalDataSourceImpl({
    required WorldClockDatabaseRepository databaseRepository,
  }) : _databaseRepository = databaseRepository;

  @override
  Future<List<WorldClockModel>> getPredefinedWorldClocks() async {
    print('💾 LOCAL DS: Solicitando relojes predefinidos');

    try {
      print('💾 LOCAL DS: Consultando base de datos');
      final worldClocks = await _databaseRepository.getAllWorldClocks();
      print(
        '💾 LOCAL DS: ${worldClocks.length} relojes obtenidos de la base de datos',
      );

      final models = worldClocks
          .map((clock) => WorldClockModel.fromEntity(clock))
          .toList();
      print(
        '💾 LOCAL DS: Convertidos a modelos - Primer reloj: ${models.first.name}',
      );
      return models;
    } catch (e) {
      print('💾 LOCAL DS: Error al consultar base de datos: $e');
      print('💾 LOCAL DS: Usando datos hardcodeados como fallback');
      return _getHardcodedWorldClocks();
    }
  }

  List<WorldClockModel> _getHardcodedWorldClocks() {
    print('💾 LOCAL DS: Creando datos hardcodeados como fallback');
    final now = DateTime.now().toUtc(); // Usar UTC para consistencia
    print('💾 LOCAL DS: Hora UTC actual para fallback: $now');

    return [
      WorldClockModel(
        id: 'America/New_York',
        name: 'Nueva York',
        timezone: 'America/New_York',
        country: 'Estados Unidos',
        city: 'Nueva York',
        currentTime: now,
        flag: '🇺🇸',
        utcOffsetSeconds: -18000, // -5 horas en segundos
      ),
      WorldClockModel(
        id: 'Europe/London',
        name: 'Londres',
        timezone: 'Europe/London',
        country: 'Reino Unido',
        city: 'Londres',
        currentTime: now,
        flag: '🇬🇧',
        utcOffsetSeconds: 0, // GMT (sin DST)
      ),
      WorldClockModel(
        id: 'Asia/Tokyo',
        name: 'Tokio',
        timezone: 'Asia/Tokyo',
        country: 'Japón',
        city: 'Tokio',
        currentTime: now,
        flag: '🇯🇵',
        utcOffsetSeconds: 32400, // +9 horas en segundos
      ),
      WorldClockModel(
        id: 'Australia/Sydney',
        name: 'Sídney',
        timezone: 'Australia/Sydney',
        country: 'Australia',
        city: 'Sídney',
        currentTime: now,
        flag: '🇦🇺',
        utcOffsetSeconds: 36000, // +10 horas en segundos
      ),
      WorldClockModel(
        id: 'America/Sao_Paulo',
        name: 'São Paulo',
        timezone: 'America/Sao_Paulo',
        country: 'Brasil',
        city: 'São Paulo',
        currentTime: now,
        flag: '🇧🇷',
        utcOffsetSeconds: -10800, // -3 horas en segundos
      ),
    ];
  }
}
