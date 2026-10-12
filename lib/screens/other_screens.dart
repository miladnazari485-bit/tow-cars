import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/habit_store.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: store.selectedDay,
            firstDate: DateTime(2020),
            lastDate: DateTime(2035),
            onDateChanged: store.selectDay,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Showing habits for ${DateFormat.yMMMMEEEEd().format(store.selectedDay)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: const Center(
        child: Text('Capture quick notes and templates here.'),
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    final completedToday = store.habits
        .where((h) => h.isCompleteOn(store.selectedDay))
        .length;
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StatTile(
            label: 'Habits',
            value: '${store.habits.length}',
            icon: Icons.loop,
          ),
          _StatTile(
            label: 'Completed today',
            value: '$completedToday / ${store.habits.length}',
            icon: Icons.check_circle_outline,
          ),
          _StatTile(
            label: 'Open tasks',
            value: '${store.tasks.where((t) => !t.done).length}',
            icon: Icons.task_alt,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}
