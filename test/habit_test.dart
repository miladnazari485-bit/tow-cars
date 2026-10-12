import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/models.dart';

void main() {
  test('streak counts consecutive completed days', () {
    final today = DateTime(2026, 10, 3);
    final habit = Habit(
      id: 'h',
      name: 'Water',
      colorValue: 0xFFB7B4F0,
      kind: HabitKind.quantity,
      target: 6,
      unit: 'liters',
      progressByDay: {
        dayKey(today): 6,
        dayKey(today.subtract(const Duration(days: 1))): 6,
        dayKey(today.subtract(const Duration(days: 2))): 3,
      },
    );
    expect(habit.streakEndingOn(today), 2);
  });
}
