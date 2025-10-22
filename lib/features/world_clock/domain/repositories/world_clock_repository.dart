import '../entities/world_clock.dart';

abstract class WorldClockRepository {
  Future<List<WorldClock>> getWorldClocks();
  Future<WorldClock> getWorldClockByTimezone(String timezone);
  Future<List<WorldClock>> getPredefinedWorldClocks();
}

