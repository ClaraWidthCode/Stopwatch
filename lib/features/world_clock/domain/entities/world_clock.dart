import 'package:equatable/equatable.dart';

class WorldClock extends Equatable {
  final String id;
  final String name;
  final String timezone;
  final String country;
  final String city;
  final DateTime currentTime;
  final String flag;

  const WorldClock({
    required this.id,
    required this.name,
    required this.timezone,
    required this.country,
    required this.city,
    required this.currentTime,
    required this.flag,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        timezone,
        country,
        city,
        currentTime,
        flag,
      ];

  WorldClock copyWith({
    String? id,
    String? name,
    String? timezone,
    String? country,
    String? city,
    DateTime? currentTime,
    String? flag,
  }) {
    return WorldClock(
      id: id ?? this.id,
      name: name ?? this.name,
      timezone: timezone ?? this.timezone,
      country: country ?? this.country,
      city: city ?? this.city,
      currentTime: currentTime ?? this.currentTime,
      flag: flag ?? this.flag,
    );
  }
}

