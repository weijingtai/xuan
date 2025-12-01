import 'package:flutter/material.dart';

class TitleSliderWidget extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  const TitleSliderWidget(
      {super.key,
      required this.label,
      required this.value,
      required this.min,
      required this.max,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(value.toStringAsFixed(0)),
          ],
        ),
        Slider(
            value: value,
            min: min,
            max: max,
            divisions: max.toInt(),
            onChanged: onChanged),
        const SizedBox(height: 8),
      ],
    );
  }
}
