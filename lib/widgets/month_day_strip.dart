import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthDayStrip extends StatefulWidget {
  const MonthDayStrip({
    super.key,
    required this.month,
    required this.selected,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  State<MonthDayStrip> createState() => _MonthDayStripState();
}

class _MonthDayStripState extends State<MonthDayStrip> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToSelected());
  }

  @override
  void didUpdateWidget(MonthDayStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DateUtils.isSameDay(oldWidget.selected, widget.selected) ||
        oldWidget.month != widget.month) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToSelected());
    }
  }

  void _jumpToSelected() {
    if (!_controller.hasClients) return;
    const itemWidth = 66.0;
    final index = widget.selected.day - 1;
    final offset = (index * itemWidth) - 80;
    _controller.animateTo(
      offset.clamp(0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final month = widget.month;
    final selected = widget.selected;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final today = DateUtils.dateOnly(DateTime.now());
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 78,
      child: ListView.separated(
        controller: _controller,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: daysInMonth,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = DateTime(month.year, month.month, index + 1);
          final isSelected = DateUtils.isSameDay(day, selected);
          final isToday = DateUtils.isSameDay(day, today);
          final weekday = DateFormat('E').format(day);
          final bg = isSelected
              ? (isDark ? Colors.white : const Color(0xFF1C1C1C))
              : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE9E9EB));
          final fg = isSelected
              ? (isDark ? Colors.black : Colors.white)
              : scheme.onSurface.withValues(alpha: 0.72);

          return GestureDetector(
            onTap: () => widget.onSelect(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 58,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected
                    ? Border.all(color: scheme.primary.withValues(alpha: 0.45))
                    : null,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
