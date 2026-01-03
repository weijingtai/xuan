import 'package:flutter/material.dart';
import 'enhanced_calculator.dart';
import 'enhanced_snapshot.dart';

class GhostPillarWidget extends StatelessWidget {
  final EnhancedCardMetricsCalculator calculator;
  final EnhancedCardMetricsSnapshot snapshot;

  const GhostPillarWidget({
    super.key,
    required this.calculator,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    final dragState = snapshot.dragState;
    if (dragState is ColumnDragging) {
      final size = calculator.getColumnGhostSize();
      if (size == Size.zero) return const SizedBox.shrink();

      return Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          border: Border.all(color: Colors.blue),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class GhostRowWidget extends StatelessWidget {
  final EnhancedCardMetricsCalculator calculator;
  final EnhancedCardMetricsSnapshot snapshot;

  const GhostRowWidget({
    super.key,
    required this.calculator,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    final dragState = snapshot.dragState;
    if (dragState is RowDragging) {
      final size = calculator.getRowGhostSize();
      if (size == Size.zero) return const SizedBox.shrink();

      return Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          border: Border.all(color: Colors.blue),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
