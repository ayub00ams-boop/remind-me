import 'package:equatable/equatable.dart';

class Reminder extends Equatable {
  final String id;
  final String title;
  final DateTime remindAt;
  final ReminderKind kind;
  final int? minutes;
  final DateTime createdAt;
  final bool isActive;

  const Reminder({
    required this.id,
    required this.title,
    required this.remindAt,
    required this.kind,
    this.minutes,
    required this.createdAt,
    this.isActive = true,
  });

  Reminder copyWith({
    String? id,
    String? title,
    DateTime? remindAt,
    ReminderKind? kind,
    int? minutes,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      remindAt: remindAt ?? this.remindAt,
      kind: kind ?? this.kind,
      minutes: minutes ?? this.minutes,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'remindAt': remindAt.toIso8601String(),
      'kind': kind.name,
      'minutes': minutes,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      title: map['title'] as String,
      remindAt: DateTime.parse(map['remindAt'] as String),
      kind: ReminderKind.values.firstWhere(
        (k) => k.name == map['kind'],
        orElse: () => ReminderKind.absolute,
      ),
      minutes: map['minutes'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isActive: (map['isActive'] as int) == 1,
    );
  }

  @override
  List<Object?> get props => [id, title, remindAt, kind, minutes, createdAt, isActive];
}

enum ReminderKind { relative, absolute }