import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../screens/app_shell.dart';
import '../state/habit_store.dart';
import '../widgets/habit_card.dart';
import '../widgets/month_day_strip.dart';
import '../widgets/overdue_section.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final _stripKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    final day = store.selectedDay;
    final overdue = store.overdueOn(day);
    final isToday = DateUtils.isSameDay(day, DateTime.now());
    final title = isToday ? 'Today' : DateFormat('MMM d').format(day);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 96,
        leading: Row(
          children: [
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => ShellScope.of(context).openDrawer(),
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.bar_chart_rounded),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 14,
                    height: 14,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Focus timer coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          MonthDayStrip(
            key: _stripKey,
            month: DateTime(day.year, day.month),
            selected: day,
            onSelect: store.selectDay,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                if (overdue.isNotEmpty)
                  OverdueSection(
                    tasks: overdue,
                    onToggle: store.toggleTask,
                    onPostpone: store.postponeOverdue,
                  ),
                _HabitsHeader(count: store.habits.length),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (final habit in store.habits)
                        HabitCard(
                          habit: habit,
                          day: day,
                          onIncrement: () => store.incrementHabit(
                            habit.id,
                            amount: habit.kind == HabitKind.quantity ? 0.5 : 1,
                          ),
                          onSync: () => store.syncSteps(habit.id),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitsHeader extends StatelessWidget {
  const _HabitsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          Icon(Icons.view_agenda_outlined, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          const Text(
            'Daily Habits',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const Spacer(),
          Text(
            '$count',
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
          Icon(Icons.expand_more, color: Colors.grey.shade600),
        ],
      ),
    );
  }
}
