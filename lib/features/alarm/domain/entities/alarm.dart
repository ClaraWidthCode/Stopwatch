import 'package:equatable/equatable.dart';
import '../../../../core/database/database_helper.dart';

class Alarm extends Equatable {
  final String id;
  final String title;
  final DateTime time;
  final bool isActive;
  final List<int> repeatDays; // 0 = Domingo, 1 = Lunes, ..., 6 = Sábado
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Alarm({
    required this.id,
    required this.title,
    required this.time,
    this.isActive = true,
    this.repeatDays = const [],
    this.userId = DatabaseHelper.adminId,
    this.createdAt,
    this.updatedAt,
  });

  /// Copia la alarma con cambios opcionales
  Alarm copyWith({
    String? id,
    String? title,
    DateTime? time,
    bool? isActive,
    List<int>? repeatDays,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      repeatDays: repeatDays ?? this.repeatDays,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    time,
    isActive,
    repeatDays,
    userId,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Alarm(id: $id, title: $title, time: $time, isActive: $isActive, userId: $userId)';
  }
}
