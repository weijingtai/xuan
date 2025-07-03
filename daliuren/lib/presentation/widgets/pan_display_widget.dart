// lib/presentation/widgets/pan_display_widget.dart

import 'package:flutter/material.dart';
import 'package:daliuren/domain/entities/liuren_pan.dart'; // Placeholder

class PanDisplayWidget extends StatelessWidget {
  final LiuRenPan? liuRenPan; // Make it nullable if it can be empty

  const PanDisplayWidget({Key? key, required this.liuRenPan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (liuRenPan == null) {
      return const Center(child: Text("请先排盘")); // Or some other placeholder
    }

    // TODO: Reconstruct the detailed Pan UI here based on liuRenPan data
    // This will involve:
    // - Displaying Heaven Plate (天盘)
    // - Displaying Earth Plate (地盘) with Gods/Generals (神将)
    // - Displaying Four Classes (四课)
    // - Displaying Three Chuans (三传)
    // - Displaying Month General (月将)
    // - Displaying Day/Time GanZhi, Kong亡 etc.
    // - Displaying KeTi (课体)

    // For now, a simple placeholder:
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("排盘时间: ${liuRenPan!.panDateTime.toIso8601String()}", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text("日干支: ${liuRenPan!.dayGanZhi}"),
          Text("时干支: ${liuRenPan!.timeGanZhi}"),
          Text("月将: ${liuRenPan!.yueJiangName}"),
          Text("贵人: ${liuRenPan!.guiRenType}"),
          const SizedBox(height: 16),
          Text("课体: ${liuRenPan!.lessonsTitle} - ${liuRenPan!.keTi.join(', ')}"),
          const SizedBox(height: 16),
          const Text("天地盘 (Placeholder):", style: TextStyle(fontWeight: FontWeight.bold)),
          // Iterate over liuRenPan.heavenPlate and earthPlate to display them
          const SizedBox(height: 16),
          const Text("四课 (Placeholder):", style: TextStyle(fontWeight: FontWeight.bold)),
          // Iterate over liuRenPan.fourClasses
          ...liuRenPan!.fourClasses.map((ke) => Text(" - ${ke.toString()}")), // Replace with actual widget
          const SizedBox(height: 16),
          const Text("三传 (Placeholder):", style: TextStyle(fontWeight: FontWeight.bold)),
          // Iterate over liuRenPan.threeChuans
          ...liuRenPan!.threeChuans.map((chuan) => Text(" - ${chuan.toString()}")), // Replace with actual widget
        ],
      ),
    );
  }
}
