import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class HabitStore extends ChangeNotifier {
  HabitStore();

  static const _dataKey = 'habit_tracker_data_v1';
  static const _themeKey = 'habit_tracker_theme_v1';

  ThemeMode themeMode = ThemeMode.light;
  DateTime selectedDay = _dateOnly(DateTime.now());
  List<Habit> habits = [];
  List<TaskItem> tasks = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_themeKey);
    themeMode = theme == 'dark'
        ? ThemeMode.dark
        : theme == 'system'
            ? ThemeMode.system
            : ThemeMode.light;

    final raw = prefs.getString(_dataKey);
    if (raw == null) {
      _seedDemo();
      await _persist();
      notifyListeners();
      return;
    }

    final json = jsonDecode(raw) as Map<String, dynamic>;
    habits = (json['habits'] as List)
        .map((e) => Habit.fromJson(e as Map<String, dynamic>))
        .toList();
    tasks = (json['tasks'] as List)
        .map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    themeMode =
        themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }

  void selectDay(DateTime day) {
    selectedDay = _dateOnly(day);
    notifyListeners();
  }

  List<TaskItem> overdueOn(DateTime day) =>
      tasks.where((t) => t.isOverdueOn(day)).toList();

  Future<void> addHabit(Habit habit) async {
    habits = [...habits, habit];
    await _persist();
    notifyListeners();
  }

  Future<void> addTask(TaskItem task) async {
    tasks = [...tasks, task];
    await _persist();
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    tasks = [
      for (final t in tasks)
        if (t.id == id) t.copyWith(done: !t.done) else t,
    ];
    await _persist();
    notifyListeners();
  }

  Future<void> postponeOverdue() async {
    tasks = [
      for (final t in tasks)
        if (t.isOverdueOn(selectedDay))
          t.copyWith(due: selectedDay)
        else
          t,
    ];
    await _persist();
    notifyListeners();
  }

  Future<void> incrementHabit(String id, {double amount = 1}) async {
    habits = [
      for (final h in habits)
        if (h.id == id) _bump(h, amount) else h,
    ];
    await _persist();
    notifyListeners();
  }

  Future<void> syncSteps(String id) async {
    final random = Random();
    habits = [
      for (final h in habits)
        if (h.id == id)
          _setProgress(
            h,
            (h.progressOn(selectedDay) + 120 + random.nextInt(400))
                .clamp(0, h.target)
                .toDouble(),
          )
        else
          h,
    ];
    await _persist();
    notifyListeners();
  }

  Habit _bump(Habit habit, double amount) {
    final next = (habit.progressOn(selectedDay) + amount)
        .clamp(0, habit.kind == HabitKind.steps ? habit.target : habit.target)
        .toDouble();
    return _setProgress(habit, next);
  }

  Habit _setProgress(Habit habit, double value) {
    final map = Map<String, double>.from(habit.progressByDay);
    map[dayKey(selectedDay)] = value;
    return habit.copyWith(progressByDay: map);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _dataKey,
      jsonEncode({
        'habits': habits.map((h) => h.toJson()).toList(),
        'tasks': tasks.map((t) => t.toJson()).toList(),
      }),
    );
  }

  void _seedDemo() {
    final today = selectedDay;
    habits = [
      Habit(
        id: 'wake',
        name: 'Wake Up Early',
        colorValue: 0xFFF5D76E,
        kind: HabitKind.count,
        target: 1,
        unit: 'time',
      ),
      Habit(
        id: 'water',
        name: 'Drink Water',
        colorValue: 0xFFB7B4F0,
        kind: HabitKind.quantity,
        target: 6,
        unit: 'liters',
      ),
      Habit(
        id: 'train',
        name: 'Training',
        colorValue: 0xFFD81B60,
        kind: HabitKind.steps,
        target: 10000,
        unit: 'steps',
        autoSync: true,
        progressByDay: {
          dayKey(today): 1698,
          for (var i = 1; i <= 18; i++)
            dayKey(today.subtract(Duration(days: i))):
                i.isEven ? 10000 : 4200 + (i * 110),
        },
      ),
    ];
    tasks = [
      TaskItem(
        id: 'groceries',
        title: 'Buy groceries',
        due: DateTime(today.year, today.month - 1, 19),
      ),
    ];
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

String newId() => DateTime.now().microsecondsSinceEpoch.toString();
