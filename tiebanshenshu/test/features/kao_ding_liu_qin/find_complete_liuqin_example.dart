import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:tiebanshenshu/features/kao_ding_liu_qin/services/qi_gua_helper.dart';
import 'package:tiebanshenshu/features/kao_ding_liu_qin/services/na_jia_liu_qin_helper.dart';
import 'package:tiebanshenshu/features/kao_ding_liu_qin/models/liu_qin_type.dart';

void main() {
  test('查找包含父母爻的八字示例', () {
    // 尝试不同的干支组合，找到包含父母爻的卦
    final testCases = [
      {'jiaZi': JiaZi.JIA_ZI, 'dayGan': TianGan.JIA},
      {'jiaZi': JiaZi.YI_CHOU, 'dayGan': TianGan.YI},
      {'jiaZi': JiaZi.BING_YIN, 'dayGan': TianGan.BING},
      {'jiaZi': JiaZi.DING_MAO, 'dayGan': TianGan.DING},
      {'jiaZi': JiaZi.WU_CHEN, 'dayGan': TianGan.WU},
      {'jiaZi': JiaZi.JI_SI, 'dayGan': TianGan.JI},
      {'jiaZi': JiaZi.GENG_WU, 'dayGan': TianGan.GENG},
      {'jiaZi': JiaZi.XIN_WEI, 'dayGan': TianGan.XIN},
      {'jiaZi': JiaZi.REN_SHEN, 'dayGan': TianGan.REN},
      {'jiaZi': JiaZi.GUI_YOU, 'dayGan': TianGan.GUI},
    ];

    print('\n【查找包含父母爻的示例】\n');

    for (final testCase in testCases) {
      final jiaZi = testCase['jiaZi'] as JiaZi;
      final dayGan = testCase['dayGan'] as TianGan;

      final qiGuaResult = QiGuaHelper.qiGuaFromGanZhiPair(jiaZi);
      final gua64 = QiGuaHelper.get64Gua(qiGuaResult);
      final result = NaJiaLiuQinHelper.installNaJiaAndLiuQin(gua64, dayGan);

      // 查找各种六亲
      final fuMuYao = NaJiaLiuQinHelper.findTargetYao(result, LiuQinType.father);
      final qiCaiYao = NaJiaLiuQinHelper.findTargetYao(result, LiuQinType.wife);
      final xiongDiYao = NaJiaLiuQinHelper.findTargetYao(result, LiuQinType.sibling);
      final ziSunYao = NaJiaLiuQinHelper.findTargetYao(result, LiuQinType.son);

      // 统计包含的六亲类型数量
      final liuQinCount = [fuMuYao, qiCaiYao, xiongDiYao, ziSunYao]
          .where((yao) => yao != null)
          .length;

      if (fuMuYao != null) {
        print('✅ ${jiaZi.name} + 日干${dayGan.name} → ${gua64.name} → '
            '父母=${fuMuYao.order.name}爻(${fuMuYao.naZhi?.name}), '
            '六亲种类=$liuQinCount/4');

        // 打印详细信息
        print('   卦象: ${qiGuaResult.shangGua.name}${qiGuaResult.xiaGua.name}');
        print('   归宫: ${result.gongGua.name}');
        print('   六爻:');
        for (final yao in result.sixYaoGua.yaoList) {
          print('     ${yao.order.name}爻: ${yao.naZhi?.name} → ${yao.liuQin?.name}');
        }
        print('');
      }
    }
  });
}
