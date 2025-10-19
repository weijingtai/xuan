import 'package:common/pages/layout_editor_page.dart';
import 'package:common/dev_constant.dart';
import 'package:common/enums/enum_di_zhi.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:common/features/tai_yuan/enum_calculate_strategy.dart';
import 'package:common/features/tai_yuan/tai_yuan_model.dart';
import 'package:common/themes/app_themes.dart';
import 'package:common/widgets/lunar_date_info_card.dart';
import 'package:common/widgets/pillar_options_card.dart';
import 'package:flutter/material.dart';

import '../models/divination_datetime.dart';

class DevTestLunarInfoCardPage extends StatefulWidget {
  const DevTestLunarInfoCardPage({Key? key}) : super(key: key);

  @override
  State<DevTestLunarInfoCardPage> createState() => _DevTestLunarInfoCardPageState();
}

class _DevTestLunarInfoCardPageState extends State<DevTestLunarInfoCardPage> {
  bool _isDarkMode = false;

  JiaZi _calculateTaiYuan(JiaZi monthPillar) {
    final tianGanList = TianGan.listAll;
    final diZhiList = DiZhi.listAll;

    final monthTianGanIndex = tianGanList.indexOf(monthPillar.tianGan);
    final monthDiZhiIndex = diZhiList.indexOf(monthPillar.diZhi);

    final taiYuanTianGan = tianGanList[(monthTianGanIndex + 1) % tianGanList.length];
    final taiYuanDiZhi = diZhiList[(monthDiZhiIndex + 3) % diZhiList.length];

    return JiaZi.getFromGanZhiEnum(taiYuanTianGan, taiYuanDiZhi);
  }

  @override
  Widget build(BuildContext context) {
    final devData = DevConstant.dev_usa;
    final eightChars = devData.standeredChineseInfo.eightChars;
    final taiYuanJiaZi = _calculateTaiYuan(eightChars.month);
    final taiYuanModel = TaiYuanModel(
      taiYuanGanZhi: taiYuanJiaZi,
      taiYuanBeforeMonth: 0, // Dummy data for dev page
      calculateStrategy: TaiYuanCalculateStrategy.monthPillarMethod, // Dummy data for dev page
    );

    return MaterialApp(
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lunar Info Card Dev Page'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LayoutEditorPage(),
                  ),
                );
              },
            ),
            Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            LunarDateInfoCard(
              bundle: devData,
              inUsed: EnumDatetimeType.standard,
              isHiddenDatetimeType: false,
            ),
            const SizedBox(height: 20),
            PillarOptionsCard(
              eightChars: eightChars,
              taiYuan: taiYuanModel,
              dateTime: devData.standeredDatetime,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}