import 'package:flutter/material.dart';

import '../../domain/entities/yuding_entry.dart';
// 请根据实际路径导入 YuDingDaLiuRen 类型
// import 'path/to/your/yuding_model.dart';

class YuDingDisplayWidget extends StatelessWidget {
  final YuDingEntry yuDingEntry;

  const YuDingDisplayWidget({
    Key? key,
    required this.yuDingEntry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Text(
            // "${yuDing.dayJiaZi.name}日 第${ConstResourcesMapper.chineseNumberMapper[yuDing.juNumber]!} 干上${yuDing.juName.name}",
            yuDingEntry.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          child: RichText(
              text: TextSpan(
                  text: yuDingEntry.raw.join(" "),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)
                  // children: yuDing.body.join(" ").map((e)=>TextSpan(text:e)).toList()
                  )),
        ),
        RichText(
          text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              text: "课义：",
              children: [TextSpan(text: yuDingEntry.meaning)]),
        ),
        const SizedBox(
          height: 12,
        ),
        RichText(
          text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              text: "解曰：",
              children: [TextSpan(text: yuDingEntry.explanation)]),
        ),
        const SizedBox(
          height: 12,
        ),
        RichText(
          text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              text: "断曰：",
              children: [TextSpan(text: yuDingEntry.perdiction)]),
        ),
        const SizedBox(
          height: 12,
        ),
        ...yuDingEntry.otherDetails.entries
            .map((entry) => RichText(
                  text: TextSpan(
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                      text: "${entry.key}：",
                      children: [TextSpan(text: entry.value)]),
                ))
            .toList(),
        const SizedBox(
          height: 12,
        ),
        ...yuDingEntry.ancientsBookTextMapper.entries
            .map((entry) => RichText(
                  text: TextSpan(
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                      text: "${entry.key}：",
                      children: [TextSpan(text: entry.value)]),
                ))
            .toList()
      ],
    );
  }
}
