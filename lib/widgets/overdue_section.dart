import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';

class OverdueSection extends StatelessWidget {
  const OverdueSection({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onPostpone,
  });

  final List<TaskItem> tasks;
  final ValueChanged<String> onToggle;
  final VoidCallback onPostpone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEDEDEF);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              const Text(
                'Overdue',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (_) => onPostpone(),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'postpone', child: Text('Postpone to today')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFDCDCE0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Postpone (${tasks.length})',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      const Icon(Icons.expand_more, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final task in tasks)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF262626) : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: task.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.low_priority, size: 16, color: task.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                  Text(
                    DateFormat('MMM d').format(task.due),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => onToggle(task.id),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(
                        task.done ? Icons.check : Icons.check,
                        size: 18,
                        color: task.done ? Colors.green : Colors.grey.shade500,
                      ),
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
