// lib/presentation/widgets/three_chuan_widget.dart

import 'package:flutter/material.dart';
// Assuming ThreeChuan entity or a similar structure from LiuRenPan
// import 'package:daliuren/domain/entities/liuren_pan.dart';

class ThreeChuanWidget extends StatelessWidget {
  // final ThreeChuanInfo threeChuanInfo; // Replace with actual ThreeChuan entity/model
  final List<Map<String, dynamic>> threeChuans;

  // const ThreeChuanWidget({Key? key, required this.threeChuanInfo}) : super(key: key);
  const ThreeChuanWidget({Key? key, required this.threeChuans}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (threeChuans.isEmpty) {
      return const SizedBox.shrink();
    }

    // TODO: Implement the detailed UI for displaying the Three Chuans (三传)
    // This involves showing:
    // - 初传 (First Chuan)
    // - 中传 (Middle Chuan)
    // - 末传 (Last Chuan)
    // Each Chuan shows: 地支, 天干 (if any, or空亡), 神将, 六亲.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("三传:", style: Theme.of(context).textTheme.titleSmall),
        // Placeholder representation:
        ...threeChuans.asMap().entries.map((entry) {
          int idx = entry.key;
          Map<String, dynamic> chuan = entry.value;
          String chuanName = "";
          if (idx == 0) chuanName = "初传";
          if (idx == 1) chuanName = "中传";
          if (idx == 2) chuanName = "末传";

          // Assuming 'chuan' is a map with keys like 'diZhi', 'tianGan', 'guiRen', 'liuQin'
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              "$chuanName: ${chuan['diZhi'] ?? '?'} (${chuan['tianGan'] ?? '空'}) - ${chuan['guiRen'] ?? '?'} - ${chuan['liuQin'] ?? '?'}"
            ),
          );
        }).toList(),
      ],
    );
  }
}
