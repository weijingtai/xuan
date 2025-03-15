import 'package:common/const_resources_mapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qimendunjia/widgets/ten_gan_ke_ying_yin_zhang.dart';

import '../model/ten_gan_ke_ying_ge_ju.dart';
import '../utils/constant_ui_resources_of_qi_men.dart';

class TenGanKeYingGeJuDetail extends StatelessWidget {
  final TenGanKeYingGeJu geJu;
  const TenGanKeYingGeJuDetail({super.key, required this.geJu});

  @override
  Widget build(BuildContext context) {
    return buildTenGanKeYingGeJuDetail(geJu);
  }

  Widget buildTenGanKeYingGeJuDetail(TenGanKeYingGeJu geJu) {
    List<Widget> explainList = [];
    for (int i = 0; i < geJu.explains.length; i++) {
      if (i != 0) {
        explainList.add(const SizedBox(
          height: 8,
        ));
      }
      explainList.add(
        Text(geJu.explains[i],
            overflow: TextOverflow.visible,
            softWrap: true,
            style: const TextStyle(
                fontWeight: FontWeight.w300, fontSize: 16, height: 1.2)),
      );
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                            style: ConstantUiResourcesOfQiMen.tianGanTextStyle,
                            children: [
                              TextSpan(
                                  text: geJu.tianPan.name,
                                  style: ConstantUiResourcesOfQiMen
                                      .tianGanTextStyle
                                      .copyWith(
                                          color: ConstResourcesMapper
                                              .zodiacGanColors[geJu.tianPan])),
                              const TextSpan(text: "+"),
                              TextSpan(
                                  text: geJu.diPan.name,
                                  style: ConstantUiResourcesOfQiMen
                                      .tianGanTextStyle
                                      .copyWith(
                                          color: ConstResourcesMapper
                                              .zodiacGanColors[geJu.diPan])),
                            ]),
                      ),
                    ),
                    const Divider(
                      height: 4,
                    ),
                    RichText(
                      text: TextSpan(
                          // style: ConstantUiResourcesOfQiMen.tianGanTextStyle,
                          text: geJu.geJuNames.join("、"),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              // buildTenGanKeYingYinZhang(geJu.geJuNames.first,geJu.jiXiong)
              TenGanKeYingYinZhang(
                geJuName: geJu.geJuNames.first,
                jiXiong: geJu.jiXiong,
                size: const Size(48, 48),
                textStyle: GoogleFonts.maShanZheng(
                    height: 1.0,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: explainList,
          )
        ]);
  }
}
