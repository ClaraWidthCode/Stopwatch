import '../../domain/entities/world_clock.dart';

class WorldClockModel extends WorldClock {
  const WorldClockModel({
    required super.id,
    required super.name,
    required super.timezone,
    required super.country,
    required super.city,
    required super.currentTime,
    required super.flag,
  });

  factory WorldClockModel.fromEntity(WorldClock worldClock) {
    return WorldClockModel(
      id: worldClock.id,
      name: worldClock.name,
      timezone: worldClock.timezone,
      country: worldClock.country,
      city: worldClock.city,
      currentTime: worldClock.currentTime,
      flag: worldClock.flag,
    );
  }

  factory WorldClockModel.fromMap(Map<String, dynamic> map) {
    try {
      final model = WorldClockModel(
        id: map['id'] as String,
        name: map['name'] as String,
        timezone: map['timezone'] as String,
        country: map['country'] as String,
        city: map['city'] as String,
        currentTime: DateTime.now(), // Usar hora actual como placeholder
        flag: map['flag'] as String,
      );
      return model;
    } catch (e) {
      rethrow;
    }
  }

  factory WorldClockModel.fromApiResponse(Map<String, dynamic> map) {
    final timezone = map['timezone'] as String;
    final cityName = timezone.split('/').last.replaceAll('_', ' ');
    
    return WorldClockModel(
      id: timezone,
      name: cityName,
      timezone: timezone,
      country: _getCountryFromTimezone(timezone),
      city: cityName,
      currentTime: DateTime.parse(map['datetime'] as String),
      flag: _getFlagFromTimezone(timezone),
    );
  }

  static String _getCountryFromTimezone(String timezone) {
    if (timezone.startsWith('America/')) return 'América';
    if (timezone.startsWith('Europe/')) return 'Europa';
    if (timezone.startsWith('Asia/')) return 'Asia';
    if (timezone.startsWith('Africa/')) return 'África';
    if (timezone.startsWith('Australia/')) return 'Oceanía';
    return 'Mundial';
  }

  static String _getFlagFromTimezone(String timezone) {
    if (timezone.contains('New_York')) return '🇺🇸';
    if (timezone.contains('London')) return '🇬🇧';
    if (timezone.contains('Tokyo')) return '🇯🇵';
    if (timezone.contains('Sydney')) return '🇦🇺';
    if (timezone.contains('Sao_Paulo')) return '🇧🇷';
    if (timezone.contains('Paris')) return '🇫🇷';
    if (timezone.contains('Berlin')) return '🇩🇪';
    if (timezone.contains('Madrid')) return '🇪🇸';
    if (timezone.contains('Rome')) return '🇮🇹';
    if (timezone.contains('Moscow')) return '🇷🇺';
    if (timezone.contains('Beijing')) return '🇨🇳';
    if (timezone.contains('Delhi')) return '🇮🇳';
    if (timezone.contains('Dubai')) return '🇦🇪';
    if (timezone.contains('Cairo')) return '🇪🇬';
    if (timezone.contains('Johannesburg')) return '🇿🇦';
    if (timezone.contains('Los_Angeles')) return '🇺🇸';
    if (timezone.contains('Chicago')) return '🇺🇸';
    if (timezone.contains('Denver')) return '🇺🇸';
    if (timezone.contains('Toronto')) return '🇨🇦';
    if (timezone.contains('Mexico_City')) return '🇲🇽';
    if (timezone.contains('Buenos_Aires')) return '🇦🇷';
    if (timezone.contains('Santiago')) return '🇨🇱';
    if (timezone.contains('Lima')) return '🇵🇪';
    if (timezone.contains('Bogota')) return '🇨🇴';
    if (timezone.contains('Caracas')) return '🇻🇪';
    return '🌍';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'timezone': timezone,
      'country': country,
      'city': city,
      'currentTime': currentTime.toIso8601String(),
      'flag': flag,
    };
  }

  WorldClock toEntity() {
    return WorldClock(
      id: id,
      name: name,
      timezone: timezone,
      country: country,
      city: city,
      currentTime: currentTime,
      flag: flag,
    );
  }
}
