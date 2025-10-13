
import 'package:common/features/tai_yuan/tai_yuan_model.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/widgets/eight_chars_card_v3.dart';
import 'package:flutter/material.dart';

import '../enums/enum_jia_zi.dart';

class PillarOptionsCard extends StatelessWidget {
  final EightChars eightChars;
  final TaiYuanModel taiYuan;
  final DateTime dateTime;

  const PillarOptionsCard({
    Key? key,
    required this.eightChars,
    required this.taiYuan,
    required this.dateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: This is a placeholder for keZhu calculation.
    JiaZi keZhu = eightChars.time;

    return Center(
      child: EightCharsCardV3(
        eightChars: eightChars,
        taiYuan: taiYuan,
        keZhu: keZhu,
      ),
    );

  }
}
