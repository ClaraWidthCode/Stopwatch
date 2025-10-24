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
    print('📡 REPOSITORY: Cargando lista de relojes predefinidos');
    final predefinedClocks = await localDataSource.getPredefinedWorldClocks();
    print('📡 REPOSITORY: Obtenidos ${predefinedClocks.length} relojes de la base de datos local');

    final entities = predefinedClocks.map((clock) => clock.toEntity()).toList();
    print('📡 REPOSITORY: Convertidos a entidades - Primer reloj: ${entities.first.name}, Hora: ${entities.first.currentTime}');
    return entities;
  }

  @override
  Future<WorldClock> getWorldClockByTimezone(String timezone) async {
    print('📡 REPOSITORY: Solicitando hora para timezone: $timezone');

    try {
      print('📡 REPOSITORY: Llamando a remoteDataSource para $timezone');
      final clockModel = await remoteDataSource.getCurrentTimeByTimezone(timezone);
      print('📡 REPOSITORY: Datos obtenidos exitosamente de API para $timezone');
      print('📡 REPOSITORY: Ciudad: ${clockModel.city}, País: ${clockModel.country}, Hora: ${clockModel.currentTime}');

      final entity = clockModel.toEntity();
      print('📡 REPOSITORY: Convertido a entidad - ID: ${entity.id}, Hora: ${entity.currentTime}');
      return entity;
    } catch (e) {
      print('📡 REPOSITORY: Error al obtener datos de API para $timezone: $e');
      print('📡 REPOSITORY: Creando fallback con hora local para $timezone');

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

      final fallbackEntity = fallbackClock.toEntity();
      print('📡 REPOSITORY: Fallback creado - ID: ${fallbackEntity.id}, Hora: ${fallbackEntity.currentTime}');
      return fallbackEntity;
    }
  }

  @override
  Future<List<WorldClock>> getPredefinedWorldClocks() async {
    final predefinedClocks = await localDataSource.getPredefinedWorldClocks();
    return predefinedClocks.map((clock) => clock.toEntity()).toList();
  }
}
