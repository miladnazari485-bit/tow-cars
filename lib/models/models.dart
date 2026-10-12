import 'package:flutter/material.dart';

enum HabitKind { count, quantity, steps }

class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.kind,
    required this.target,
    required this.unit,
    this.progressByDay = const {},
    this.autoSync = false,
  });

  final String id;
  final String name;
  final int colorValue;
  final HabitKind kind;
  final double target;
  final String unit;
  final Map<String, double> progressByDay;
  final bool autoSync;

  Color get color => Color(colorValue);

  double progressOn(DateTime day) => progressByDay[_key(day)] ?? 0;

  bool isCompleteOn(DateTime day) => progressOn(day) >= target;

  int streakEndingOn(DateTime day) {
    var streak = 0;
    var cursor = DateTime(day.year, day.month, day.day);
    while (isCompleteOn(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Habit copyWith({
    String? name,
    int? colorValue,
    HabitKind? kind,
    double? target,
    String? unit,
    Map<String, double>? progressByDay,
    bool? autoSync,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      kind: kind ?? this.kind,
      target: target ?? this.target,
      unit: unit ?? this.unit,
      progressByDay: progressByDay ?? this.progressByDay,
      autoSync: autoSync ?? this.autoSync,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'kind': kind.name,
        'target': target,
        'unit': unit,
        'progressByDay': progressByDay,
        'autoSync': autoSync,
      };

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['colorValue'] as int,
      kind: HabitKind.values.firstWhere((k) => k.name == json['kind']),
      target: (json['target'] as num).toDouble(),
      unit: json['unit'] as String,
      progressByDay: {
        for (final e in (json['progressByDay'] as Map).entries)
          e.key as String: (e.value as num).toDouble(),
      },
      autoSync: json['autoSync'] as bool? ?? false,
    );
  }
}

class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    required this.due,
    this.done = false,
    this.colorValue = 0xFF7C6CF0,
  });

  final String id;
  final String title;
  final DateTime due;
  final bool done;
  final int colorValue;

  Color get color => Color(colorValue);

  bool isOverdueOn(DateTime day) {
    final today = DateTime(day.year, day.month, day.day);
    final dueDay = DateTime(due.year, due.month, due.day);
    return !done && dueDay.isBefore(today);
  }

  TaskItem copyWith({String? title, DateTime? due, bool? done, int? colorValue}) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      due: due ?? this.due,
      done: done ?? this.done,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'due': due.toIso8601String(),
        'done': done,
        'colorValue': colorValue,
      };

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      due: DateTime.parse(json['due'] as String),
      done: json['done'] as bool? ?? false,
      colorValue: json['colorValue'] as int? ?? 0xFF7C6CF0,
    );
  }
}

String dayKey(DateTime day) => _key(day);

String _key(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
