import 'package:flutter/material.dart';

class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({
    super.key,
    required this.color,
    required this.values,
    this.columns = 28,
    this.rows = 4,
  });

  final Color color;
  final List<double> values;
  final int columns;
  final int rows;

  @override
  Widget build(BuildContext context) {
    final cells = columns * rows;
    final padded = List<double>.generate(
      cells,
      (i) => i < values.length ? values[i] : 0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 2.2;
        final size = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final value in padded)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12 + (0.78 * value.clamp(0, 1))),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
          ],
        );
      },
    );
  }
}
