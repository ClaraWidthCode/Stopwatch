import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../features/alarm/data/repositories/alarm_repository_impl.dart';
import '../../features/alarm/domain/repositories/alarm_repository.dart';
import '../../features/alarm/presentation/bloc/alarm_bloc.dart';
import '../../features/world_clock/data/datasources/world_clock_local_datasource.dart';
import '../../features/world_clock/data/datasources/world_clock_remote_datasource.dart';
import '../../features/world_clock/data/repositories/world_clock_database_repository.dart';
import '../../features/world_clock/data/repositories/world_clock_repository_impl.dart';
import '../../features/world_clock/domain/repositories/world_clock_repository.dart';
import '../../features/world_clock/presentation/bloc/world_clock_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  sl.registerLazySingleton(() => http.Client());

  // Database repositories
  sl.registerLazySingleton(() => WorldClockDatabaseRepository());

  // Data sources
  sl.registerLazySingleton<WorldClockLocalDataSource>(
    () => WorldClockLocalDataSourceImpl(databaseRepository: sl()),
  );
  sl.registerLazySingleton<WorldClockRemoteDataSource>(
    () => WorldClockRemoteDataSourceImpl(client: sl()),
  );

  // Repository
  sl.registerLazySingleton<AlarmRepository>(() => AlarmRepositoryImpl());
  sl.registerLazySingleton<WorldClockRepository>(
    () => WorldClockRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // BLoC
  sl.registerFactory(() => AlarmBloc(repository: sl()));
  sl.registerFactory(() => WorldClockBloc(repository: sl()));
}
