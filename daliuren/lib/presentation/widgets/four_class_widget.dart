// lib/presentation/widgets/four_class_widget.dart

import 'package:flutter/material.dart';
// Assuming FourClass entity or a similar structure from LiuRenPan
// import 'package:daliuren/domain/entities/liuren_pan.dart';

class FourClassWidget extends StatelessWidget {
  // final FourClassInfo fourClassInfo; // Replace with actual FourClass entity/model
  final List<Map<String, dynamic>> fourClasses;


  // const FourClassWidget({Key? key, required this.fourClassInfo}) : super(key: key);
  const FourClassWidget({Key? key, required this.fourClasses}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    if (fourClasses.isEmpty) {
      return const SizedBox.shrink();
    }
    // TODO: Implement the detailed UI for displaying the Four Classes (四课)
    // This would typically involve showing each of the four classes:
    // 日干上神 (第一课), 日支上神 (第二课), 辰上神 (第三课), 酉上神 (第四课) - (this is one way, original code has different structure)
    // Or based on the structure of the original my_home_page.dart's build_four_ke method.
    // Each class shows 天盘地支, 地盘地支, and 神将. The first class also shows 日干.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("四课:", style: Theme.of(context).textTheme.titleSmall),
        // Placeholder representation:
        ...fourClasses.map((ke) {
          // Assuming 'ke' is a map with keys like 'sky', 'ground', 'guiRen', 'tianGan' (for first class)
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              "上:${ke['sky'] ?? '?'} (${ke['guiRen'] ?? '?'}) / 下:${ke['ground'] ?? '?'} ${ke.containsKey('tianGan') ? '(干:${ke['tianGan']})' : ''}"
            ),
          );
        }).toList(),
      ],
    );
  }
}
