import 'package:flutter/material.dart';

class CardRowWidget extends StatelessWidget {
  final Widget label;
  final List<Widget> cells;

  const CardRowWidget({
    Key? key,
    required this.label,
    required this.cells,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: label,
        ),
        Expanded(
          child: Row(
            children: cells.map((cell) => Expanded(child: cell)).toList(),
          ),
        ),
      ],
    );
  }
}
