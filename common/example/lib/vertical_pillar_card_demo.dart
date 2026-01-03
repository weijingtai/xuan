import 'package:common/enums.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/pillar_data.dart';
import 'package:common/widgets/vertical_pillar_card.dart';
import 'package:flutter/material.dart';

/// 垂直柱式卡片演示页面
class VerticalPillarCardDemo extends StatelessWidget {
  const VerticalPillarCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // 创建示例数据 - 符合设计稿中的流年盘
    const pillars = <PillarData>[
      PillarData(
        pillarId: 'day',
        pillarType: PillarType.day,
        label: '日',
        jiaZi: JiaZi.JIA_ZI, // 甲子
      ),
      PillarData(
        pillarId: 'dayun',
        label: '大运',
        pillarType: PillarType.luckCycle,
        jiaZi: JiaZi.GUI_MAO, // 癸卯
      ),
      PillarData(
        pillarId: 'liunian',
        pillarType: PillarType.annual,
        label: '流年',
        jiaZi: JiaZi.JIA_CHEN, // 甲辰
      ),
      PillarData(
        pillarId: 'liuyue',
        pillarType: PillarType.monthly,
        label: '流月',
        jiaZi: JiaZi.BING_YIN, // 丙寅
      ),
      PillarData(
        pillarId: 'liushi',
        pillarType: PillarType.hourly,
        label: '流时',
        jiaZi: JiaZi.WU_XU, // 戊戌
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('垂直柱式八字卡片演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '符合设计稿的垂直柱布局',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),

            // 示例1：完整功能展示
            VerticalPillarCard(
              title: '流年盘',
              pillars: pillars,
              dayMaster: TianGan.JIA, // 以甲为日主
              isBenMing: false,
              showTenGods: true,
              showTianGan: true,
              showDiZhi: true,
              showCangGanMain: true,
              showKongWang: true,
              showNaYin: true,
            ),

            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '简化版本（仅显示天干地支）',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),

            // 示例2：简化版
            VerticalPillarCard(
              title: '四柱分析',
              pillars: [
                PillarData(
                  pillarId: 'year',
                  label: '年',
                  pillarType: PillarType.year,
                  jiaZi: JiaZi.JIA_ZI,
                ),
                PillarData(
                  pillarId: 'month',
                  label: '月',
                  pillarType: PillarType.month,
                  jiaZi: JiaZi.BING_YIN,
                ),
                PillarData(
                  pillarId: 'day',
                  label: '日',
                  pillarType: PillarType.day,
                  jiaZi: JiaZi.WU_CHEN,
                ),
                PillarData(
                  pillarId: 'time',
                  label: '时',
                  pillarType: PillarType.hour,
                  jiaZi: JiaZi.GUI_HAI,
                ),
              ],
              dayMaster: TianGan.WU,
              isBenMing: true,
              gender: Gender.male,
              showTenGods: false,
              showTianGan: true,
              showDiZhi: true,
              showCangGanMain: false,
              showKongWang: false,
              showNaYin: false,
            ),

            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '完整版本（所有信息）',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),

            // 示例3：完整版
            VerticalPillarCard(
              title: '本命盘',
              pillars: [
                PillarData(
                  pillarId: 'year',
                  label: '年',
                  pillarType: PillarType.year,
                  jiaZi: JiaZi.BING_YIN,
                ),
                PillarData(
                  pillarId: 'month',
                  label: '月',
                  pillarType: PillarType.month,
                  jiaZi: JiaZi.GENG_YIN,
                ),
                PillarData(
                  pillarId: 'day',
                  label: '日',
                  pillarType: PillarType.day,
                  jiaZi: JiaZi.REN_CHEN,
                ),
                PillarData(
                  pillarId: 'time',
                  label: '时',
                  pillarType: PillarType.hour,
                  jiaZi: JiaZi.XIN_HAI,
                ),
              ],
              dayMaster: TianGan.REN,
              isBenMing: true,
              gender: Gender.female,
              showTenGods: true,
              showTianGan: true,
              showDiZhi: true,
              showCangGanMain: true,
              showCangGanZhong: true,
              showCangGanYu: true,
              showKongWang: true,
              showNaYin: true,
              showXunShou: true,
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
