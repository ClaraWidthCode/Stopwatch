import 'package:equatable/equatable.dart';

class Alarm extends Equatable {
  final String id;
  final String title;
  final DateTime time;
  final bool isActive;
  final List<int> repeatDays; // 0 = Domingo, 1 = Lunes, ..., 6 = Martes

  const Alarm({
    required this.id,
    required this.title,
    required this.time,
    this.isActive = true,
    this.repeatDays = const [],
  });

  Alarm copyWith({
    String? id,
    String? title,
    DateTime? time,
    bool? isActive,
    List<int>? repeatDays,
  }) {
    return Alarm(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }

  @override
  List<Object?> get props => [id, title, time, isActive, repeatDays];

  @override
  String toString() {
    return 'Alarm(id: $id, title: $title, time: $time, isActive: $isActive)';
  }
}
