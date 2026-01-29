import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:tiebanshenshu/features/kao_ding_liu_qin/services/qi_gua_helper.dart';
import 'package:tiebanshenshu/features/kao_ding_liu_qin/services/na_jia_liu_qin_helper.dart';
import 'package:tiebanshenshu/features/kao_ding_liu_qin/models/liu_qin_type.dart';

void main() {
  group('调试测试 - 起卦和纳甲', () {
    test('测试甲子起卦', () {
      final jiaZi = JiaZi.JIA_ZI;
      final qiGuaResult = QiGuaHelper.qiGuaFromGanZhiPair(jiaZi);

      print('\n【甲子起卦】');
      print('干: ${jiaZi.gan.name}, 配数: ${qiGuaResult.ganNumber}');
      print('支: ${jiaZi.zhi.name}, 奇数: ${qiGuaResult.zhiOddNumber}, 偶数: ${qiGuaResult.zhiEvenNumber}');
      print('下卦: ${qiGuaResult.xiaGua.name} (${qiGuaResult.xiaGuaNumber})');
      print('上卦: ${qiGuaResult.shangGua.name} (${qiGuaResult.shangGuaNumber})');

      final gua64 = QiGuaHelper.get64Gua(qiGuaResult);
      print('64卦: ${gua64.name}');

      expect(qiGuaResult.xiaGua, equals(Enum8Gua.Gen)); // 7 = 艮
      expect(qiGuaResult.shangGua, equals(Enum8Gua.Zhen)); // 4 = 震
      expect(gua64.name, equals('小过'));
    });

    test('测试纳甲和六亲 - 小过卦', () {
      // 甲子起卦得小过卦
      final jiaZi = JiaZi.JIA_ZI;
      final qiGuaResult = QiGuaHelper.qiGuaFromGanZhiPair(jiaZi);
      final gua64 = QiGuaHelper.get64Gua(qiGuaResult);

      // 日干丙
      final dayGan = TianGan.BING;

      final result = NaJiaLiuQinHelper.installNaJiaAndLiuQin(gua64, dayGan);

      print('\n【小过卦纳甲六亲】');
      print('归宫: ${result.gongGua.name}');
      print('世爻: ${result.shiYaoIndex} (${result.shiYao.order.name}爻)');
      print('应爻: ${result.yingYaoIndex} (${result.yingYao.order.name}爻)');
      print('\n六个爻的纳支和六亲:');

      for (int i = 0; i < result.sixYaoGua.yaoList.length; i++) {
        final yao = result.sixYaoGua.yaoList[i];
        print('${yao.order.name}爻: '
            '纳支=${yao.naZhi?.name}, '
            '干支=${yao.ganZhi?.name}, '
            '六亲=${yao.liuQin?.name}');
      }

      // 查找父母爻
      print('\n【查找父母爻】');
      final targetYao = NaJiaLiuQinHelper.findTargetYao(result, LiuQinType.father);

      if (targetYao == null) {
        print('❌ 未找到父母爻');
        print('\n原因分析:');
        print('1. 日干: ${dayGan.name}, 五行: ${dayGan.fiveXing.name}');
        print('2. 应该查找的是「父母爻」，在六亲系统中对应 LiuQin.FU_MU');

        // 检查每个爻的六亲分配
        for (int i = 0; i < result.sixYaoGua.yaoList.length; i++) {
          final yao = result.sixYaoGua.yaoList[i];
          if (yao.naZhi != null) {
            print('${yao.order.name}爻: '
                '支=${yao.naZhi!.name}, '
                '支五行=${yao.naZhi!.fiveXing.name}, '
                '六亲=${yao.liuQin?.name}');
          }
        }
      } else {
        print('✅ 找到父母爻: ${targetYao.order.name}爻, 纳支: ${targetYao.naZhi?.name}');
      }
    });

    test('测试不同日干的六亲分配', () {
      final jiaZi = JiaZi.JIA_ZI;
      final qiGuaResult = QiGuaHelper.qiGuaFromGanZhiPair(jiaZi);
      final gua64 = QiGuaHelper.get64Gua(qiGuaResult);

      print('\n【不同日干的六亲分配】');

      for (final dayGan in [TianGan.BING, TianGan.JIA, TianGan.WU]) {
        final result = NaJiaLiuQinHelper.installNaJiaAndLiuQin(gua64, dayGan);

        print('\n日干: ${dayGan.name} (${dayGan.fiveXing.name})');

        // 查找父母爻
        final fuMuYao = NaJiaLiuQinHelper.findTargetYao(result, LiuQinType.father);
        print('  父母爻: ${fuMuYao != null ? '${fuMuYao.order.name}爻' : '未找到'}');

        // 查找妻财爻
        final qiCaiYao = NaJiaLiuQinHelper.findTargetYao(result, LiuQinType.wife);
        print('  妻财爻: ${qiCaiYao != null ? '${qiCaiYao.order.name}爻' : '未找到'}');

        // 查找兄弟爻
        final xiongDiYao = NaJiaLiuQinHelper.findTargetYao(result, LiuQinType.sibling);
        print('  兄弟爻: ${xiongDiYao != null ? '${xiongDiYao.order.name}爻' : '未找到'}');

        // 查找子孙爻
        final ziSunYao = NaJiaLiuQinHelper.findTargetYao(result, LiuQinType.son);
        print('  子孙爻: ${ziSunYao != null ? '${ziSunYao.order.name}爻' : '未找到'}');
      }
    });
  });
}
