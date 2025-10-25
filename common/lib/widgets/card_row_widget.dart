import 'package:flutter/material.dart';

class CardRowWidget extends StatelessWidget {
  final Widget label;
  final List<Widget> cells;
  final EdgeInsets? padding;
  final BoxBorder? border;

  const CardRowWidget({
    Key? key,
    required this.label,
    required this.cells,
    this.padding,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(border: border),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: label,
          ),
          Expanded(
            child: Row(
              children: cells,
            ),
          ),
        ],
      ),
    );
  }
}
