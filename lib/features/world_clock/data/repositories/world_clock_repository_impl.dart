import '../../domain/entities/world_clock.dart';
import '../../domain/repositories/world_clock_repository.dart';
import '../datasources/world_clock_local_datasource.dart';
import '../datasources/world_clock_remote_datasource.dart';
import '../models/world_clock_model.dart';

class WorldClockRepositoryImpl implements WorldClockRepository {
  final WorldClockRemoteDataSource remoteDataSource;
  final WorldClockLocalDataSource localDataSource;

  WorldClockRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<WorldClock>> getWorldClocks() async {
    final predefinedClocks = await localDataSource.getPredefinedWorldClocks();
    return predefinedClocks.map((clock) => clock.toEntity()).toList();
  }

  @override
  Future<WorldClock> getWorldClockByTimezone(String timezone) async {
    try {
      final clockModel = await remoteDataSource.getCurrentTimeByTimezone(timezone);
      return clockModel.toEntity();
    } catch (e) {
      // Fallback: crear un reloj con la hora local
      final fallbackClock = WorldClockModel(
        id: timezone,
        name: timezone.split('/').last.replaceAll('_', ' '),
        timezone: timezone,
        country: '',
        city: '',
        currentTime: DateTime.now(),
        flag: '🏳️',
      );
      return fallbackClock.toEntity();
    }
  }

  @override
  Future<List<WorldClock>> getPredefinedWorldClocks() async {
    final predefinedClocks = await localDataSource.getPredefinedWorldClocks();
    return predefinedClocks.map((clock) => clock.toEntity()).toList();
  }
}
