import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import 'heatmap_grid.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.day,
    required this.onIncrement,
    required this.onSync,
  });

  final Habit habit;
  final DateTime day;
  final VoidCallback onIncrement;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final progress = habit.progressOn(day);
    final ratio = habit.target == 0 ? 0.0 : (progress / habit.target).clamp(0.0, 1.0);
    final streak = habit.streakEndingOn(day);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final values = List<double>.generate(112, (i) {
      final d = day.subtract(Duration(days: 111 - i));
      return (habit.progressOn(d) / habit.target).clamp(0.0, 1.0);
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            (isDark ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: habit.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  habit.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: habit.color.computeLuminance() > 0.55
                        ? const Color(0xFF2A2A2A)
                        : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.local_fire_department_outlined,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 2),
              Text(
                '$streak',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                _progressLabel(progress),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                habit: habit,
                ratio: ratio,
                onPressed: habit.autoSync ? onSync : onIncrement,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HeatmapGrid(color: habit.color, values: values),
        ],
      ),
    );
  }

  String _progressLabel(double progress) {
    switch (habit.kind) {
      case HabitKind.count:
        return '${progress.round()} / ${habit.target.round()} ${habit.unit}';
      case HabitKind.quantity:
        return '${_trim(progress)} / ${_trim(habit.target)} ${habit.unit}';
      case HabitKind.steps:
        return '${NumberFormat.decimalPattern().format(progress.round())} / ${NumberFormat.decimalPattern().format(habit.target.round())} ${habit.unit}';
    }
  }

  String _trim(double n) => n == n.roundToDouble() ? '${n.round()}' : n.toStringAsFixed(1);
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.habit,
    required this.ratio,
    required this.onPressed,
  });

  final Habit habit;
  final double ratio;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (habit.autoSync) {
      return SizedBox(
        width: 42,
        height: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: ratio == 0 ? 0.04 : ratio,
              strokeWidth: 3,
              color: habit.color,
              backgroundColor: habit.color.withValues(alpha: 0.18),
            ),
            IconButton(
              onPressed: onPressed,
              icon: const Icon(Icons.sync, size: 18),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Icon(Icons.add, size: 22),
      ),
    );
  }
}
