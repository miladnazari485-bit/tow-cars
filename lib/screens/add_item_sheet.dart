import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/habit_store.dart';

Future<void> showAddItemSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const AddItemSheet(),
  );
}

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  int _tab = 0;
  final _name = TextEditingController();
  final _target = TextEditingController(text: '1');
  HabitKind _kind = HabitKind.count;
  Color _color = const Color(0xFFF5D76E);
  DateTime _due = DateUtils.dateOnly(DateTime.now());

  static const _palette = [
    Color(0xFFF5D76E),
    Color(0xFFB7B4F0),
    Color(0xFFD81B60),
    Color(0xFF4DB6AC),
    Color(0xFF90CAF9),
    Color(0xFFFFAB91),
  ];

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Habit'), icon: Icon(Icons.loop)),
              ButtonSegment(value: 1, label: Text('Task'), icon: Icon(Icons.check_box_outlined)),
            ],
            selected: {_tab},
            onSelectionChanged: (v) => setState(() => _tab = v.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: _tab == 0 ? 'Habit name' : 'Task title',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (_tab == 0) ...[
            DropdownButtonFormField<HabitKind>(
              value: _kind,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: HabitKind.count, child: Text('Count (times)')),
                DropdownMenuItem(value: HabitKind.quantity, child: Text('Quantity (liters, pages...)')),
                DropdownMenuItem(value: HabitKind.steps, child: Text('Steps / sync')),
              ],
              onChanged: (v) => setState(() => _kind = v ?? HabitKind.count),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _target,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily target',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final c in _palette)
                  GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: CircleAvatar(
                      backgroundColor: c,
                      radius: 16,
                      child: _color == c ? const Icon(Icons.check, size: 16, color: Colors.black54) : null,
                    ),
                  ),
              ],
            ),
          ] else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due date'),
              subtitle: Text(DateFormat.yMMMd().format(_due)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _due,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) setState(() => _due = picked);
              },
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: Text(_tab == 0 ? 'Create habit' : 'Create task'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final store = context.read<HabitStore>();
    if (_tab == 0) {
      await store.addHabit(
        Habit(
          id: newId(),
          name: name,
          colorValue: _color.toARGB32(), // ignore: deprecated_member_use
          kind: _kind,
          target: double.tryParse(_target.text) ?? 1,
          unit: _kind == HabitKind.steps
              ? 'steps'
              : _kind == HabitKind.quantity
                  ? 'liters'
                  : 'time',
          autoSync: _kind == HabitKind.steps,
        ),
      );
    } else {
      await store.addTask(
        TaskItem(id: newId(), title: name, due: _due),
      );
    }
    if (mounted) Navigator.pop(context);
  }
}
