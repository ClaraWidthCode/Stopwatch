import '../models/world_clock_model.dart';
import '../repositories/world_clock_database_repository.dart';

abstract class WorldClockLocalDataSource {
  Future<List<WorldClockModel>> getPredefinedWorldClocks();
}

class WorldClockLocalDataSourceImpl implements WorldClockLocalDataSource {
  final WorldClockDatabaseRepository _databaseRepository;

  WorldClockLocalDataSourceImpl({required WorldClockDatabaseRepository databaseRepository})
      : _databaseRepository = databaseRepository;

  @override
  Future<List<WorldClockModel>> getPredefinedWorldClocks() async {
    try {
      final worldClocks = await _databaseRepository.getAllWorldClocks();
      final models = worldClocks.map((clock) => WorldClockModel.fromEntity(clock)).toList();
      return models;
    } catch (e) {
      // Fallback a datos hardcodeados si falla la BD
      return _getHardcodedWorldClocks();
    }
  }

  List<WorldClockModel> _getHardcodedWorldClocks() {
    final now = DateTime.now();
    return [
      WorldClockModel(
        id: 'America/New_York',
        name: 'Nueva York',
        timezone: 'America/New_York',
        country: 'Estados Unidos',
        city: 'Nueva York',
        currentTime: now,
        flag: '🇺🇸',
      ),
      WorldClockModel(
        id: 'Europe/London',
        name: 'Londres',
        timezone: 'Europe/London',
        country: 'Reino Unido',
        city: 'Londres',
        currentTime: now,
        flag: '🇬🇧',
      ),
      WorldClockModel(
        id: 'Asia/Tokyo',
        name: 'Tokio',
        timezone: 'Asia/Tokyo',
        country: 'Japón',
        city: 'Tokio',
        currentTime: now,
        flag: '🇯🇵',
      ),
      WorldClockModel(
        id: 'Australia/Sydney',
        name: 'Sídney',
        timezone: 'Australia/Sydney',
        country: 'Australia',
        city: 'Sídney',
        currentTime: now,
        flag: '🇦🇺',
      ),
      WorldClockModel(
        id: 'America/Sao_Paulo',
        name: 'São Paulo',
        timezone: 'America/Sao_Paulo',
        country: 'Brasil',
        city: 'São Paulo',
        currentTime: now,
        flag: '🇧🇷',
      ),
    ];
  }
}
