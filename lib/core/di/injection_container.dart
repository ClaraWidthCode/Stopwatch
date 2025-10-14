import 'package:get_it/get_it.dart';
import '../../features/alarm/data/repositories/alarm_repository_impl.dart';
import '../../features/alarm/domain/repositories/alarm_repository.dart';
import '../../features/alarm/presentation/bloc/alarm_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Repository
  sl.registerLazySingleton<AlarmRepository>(() => AlarmRepositoryImpl());

  // BLoC
  sl.registerFactory(() => AlarmBloc(repository: sl()));
}
