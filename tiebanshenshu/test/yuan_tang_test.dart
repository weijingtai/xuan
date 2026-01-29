import 'dart:math';

import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/pure_yuan_tang_gua.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_calculator.dart';
import 'package:tiebanshenshu/utils/utils.dart' as gua_utils;
import 'package:tiebanshenshu/constant/constants.dart' as constants;
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('天地卦取数', () {
    group('天数', () {
      test('天数>25：减去25取个位数（例：39→4）', () {
        final result = gua_utils.calculateGuaNum(39, 25, 5);
        expect(result, 4);
      });

      test('天数==25：舍去十位取个位数5', () {
        final result = gua_utils.calculateGuaNum(25, 25, 5);
        expect(result, 5);
      });

      test('天数<25：舍去十位只取个位（例：24→4）', () {
        final result = gua_utils.calculateGuaNum(24, 25, 5);
        expect(result, 4);
      });

      test('天数>25且天数-25=10：取十位数1（例：35→1）', () {
        final result = gua_utils.calculateGuaNum(35, 25, 5);
        expect(result, 1);
      });

      test('天数>25且天数-25=20：取十位数2（例：45→2）', () {
        final result = gua_utils.calculateGuaNum(45, 25, 5);
        expect(result, 2);
      });
    });

    group('地数', () {
      test('地数==30：取3', () {
        final result = gua_utils.calculateGuaNum(30, 30, 3);
        expect(result, 3);
      });

      test('地数<30：舍去十位取个位（例：26→6）', () {
        final result = gua_utils.calculateGuaNum(26, 30, 3);
        expect(result, 6);
      });

      test('地数>30且地数-30=10：取十位数1（例：40→1）', () {
        final result = gua_utils.calculateGuaNum(40, 30, 3);
        expect(result, 1);
      });

      test('地数>30且地数-30=20：取十位数2（例：50→2）', () {
        final result = gua_utils.calculateGuaNum(50, 30, 3);
        expect(result, 2);
      });
    });
  });

  group('三元五宫穷举', () {
    test('上元 男：number==5 时阴阳皆艮', () {
      final yang = YuanTangCalculator.numberToHouTianGua(
        number: 5,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        yearYinYang: YinYang.YANG,
      );
      final yin = YuanTangCalculator.numberToHouTianGua(
        number: 5,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        yearYinYang: YinYang.YIN,
      );
      expect(yang, Enum8Gua.Gen);
      expect(yin, Enum8Gua.Gen);
    });

    test('上元 女：number==5 时阴阳皆坤', () {
      final yang = YuanTangCalculator.numberToHouTianGua(
        number: 5,
        gender: Gender.female,
        threeYuan: YuanYunOrder.upper,
        yearYinYang: YinYang.YANG,
      );
      final yin = YuanTangCalculator.numberToHouTianGua(
        number: 5,
        gender: Gender.female,
        threeYuan: YuanYunOrder.upper,
        yearYinYang: YinYang.YIN,
      );
      expect(yang, Enum8Gua.Kun);
      expect(yin, Enum8Gua.Kun);
    });

    test('中元 男：number==5 时阳艮 阴坤', () {
      final yang = YuanTangCalculator.numberToHouTianGua(
        number: 5,
        gender: Gender.male,
        threeYuan: YuanYunOrder.middle,
        yearYinYang: YinYang.YANG,
      );
      final yin = YuanTangCalculator.numberToHouTianGua(
        number: 5,
        gender: Gender.male,
        threeYuan: YuanYunOrder.middle,
        yearYinYang: YinYang.YIN,
      );
      expect(yang, Enum8Gua.Gen);
      expect(yin, Enum8Gua.Kun);
    });

    test('中元 女：number==5 时阳坤 阴艮', () {
      final yang = YuanTangCalculator.numberToHouTianGua(
        number: 5,
        gender: Gender.female,
        threeYuan: YuanYunOrder.middle,
        yearYinYang: YinYang.YANG,
      );
      final yin = YuanTangCalculator.numberToHouTianGua(
        number: 5,
        gender: Gender.female,
        threeYuan: YuanYunOrder.middle,
        yearYinYang: YinYang.YIN,
      );
      expect(yang, Enum8Gua.Kun);
      expect(yin, Enum8Gua.Gen);
    });

    test('下元 男：number==5 时阴阳皆离', () {
      final yang = YuanTangCalculator.numberToHouTianGua(
        number: 5,
        gender: Gender.male,
        threeYuan: YuanYunOrder.lower,
        yearYinYang: YinYang.YANG,
      );
      final yin = YuanTangCalculator.numberToHouTianGua(
        number: 5,
        gender: Gender.male,
        threeYuan: YuanYunOrder.lower,
        yearYinYang: YinYang.YIN,
      );
      expect(yang, Enum8Gua.Li);
      expect(yin, Enum8Gua.Li);
    });

    test('下元 女：number==5 时阴阳皆兑', () {
      final yang = YuanTangCalculator.numberToHouTianGua(
        number: 5,
        gender: Gender.female,
        threeYuan: YuanYunOrder.lower,
        yearYinYang: YinYang.YANG,
      );
      final yin = YuanTangCalculator.numberToHouTianGua(
        number: 5,
        gender: Gender.female,
        threeYuan: YuanYunOrder.lower,
        yearYinYang: YinYang.YIN,
      );
      expect(yang, Enum8Gua.Dui);
      expect(yin, Enum8Gua.Dui);
    });
  });

  group('数取卦映射穷举', () {
    test('数取卦映射：1,2,3,4,6,7,8,9 映射正确', () {
      final expected = {
        1: Enum8Gua.Kan,
        2: Enum8Gua.Kun,
        3: Enum8Gua.Zhen,
        4: Enum8Gua.Xun,
        6: Enum8Gua.Qian,
        7: Enum8Gua.Dui,
        8: Enum8Gua.Gen,
        9: Enum8Gua.Li,
      };
      for (final entry in expected.entries) {
        expect(
          constants.yuanTangHuaTianNumberGuaMapper[entry.key],
          entry.value,
          reason: '数字${entry.key}应映射为${entry.value.name}',
        );
      }
    });

    test('数取卦映射：不包含数字5（5专由三元五宫处理）', () {
      expect(constants.yuanTangHuaTianNumberGuaMapper.containsKey(5), false);
    });
  });

  group('64卦名组合映射', () {
    test('乾+巽 → 天风姤（fullname与本名）', () {
      final gua = Enum64Gua.getBy8Gua(Enum8Gua.Qian, Enum8Gua.Xun);
      expect(gua.fullname, '天风姤', reason: '上卦乾，下卦巽应为天风姤');
      expect(gua.name, '姤', reason: '本名应为姤');

      final pureName = gua_utils.getPureGuaNameByObject('天', '风');
      expect(pureName, '姤', reason: '对象名天+风应映射为姤');
    });

    test('巽+坎 → 风水涣（fullname与本名）', () {
      final gua = Enum64Gua.getBy8Gua(Enum8Gua.Xun, Enum8Gua.Kan);
      expect(gua.fullname, '风水涣', reason: '上卦巽，下卦坎应为风水涣');
      expect(gua.name, '涣', reason: '本名应为涣');

      final pureName = gua_utils.getPureGuaNameByObject('风', '水');
      expect(pureName, '涣', reason: '对象名风+水应映射为涣');
    });
  });

  group("元堂装卦", () {
    final yangZhiList = [
      DiZhi.ZI,
      DiZhi.CHOU,
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
    ];
    final yinZhiList = [
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU,
      DiZhi.HAI,
    ];
    test("5阳爻 天风姤 ['巳','子','丑','寅','卯','辰']", () {
      final guaBinaryList = [0, 1, 1, 1, 1, 1];
      final zhiList = YuanTangCalculator.zhuangGua45(
        guaBinaryList,
        yangZhiList,
        YinYang.YANG,
      );
      expect(zhiList, [
        [DiZhi.SI],
        [DiZhi.ZI],
        [DiZhi.CHOU],
        [DiZhi.YIN],
        [DiZhi.MAO],
        [DiZhi.CHEN],
      ], reason: "元堂地支列表应为['巳','子','丑','寅','卯','辰']");
    });

    test("5阳爻 天泽履 ['子','丑','巳','寅','卯','辰']", () {
      final guaBinaryList = [1, 1, 0, 1, 1, 1];
      final zhiList = YuanTangCalculator.zhuangGua45(
        guaBinaryList,
        yangZhiList,
        YinYang.YANG,
      );
      expect(zhiList, [
        [DiZhi.ZI],
        [DiZhi.CHOU],
        [DiZhi.SI],
        [DiZhi.YIN],
        [DiZhi.MAO],
        [DiZhi.CHEN],
      ], reason: "元堂地支列表应为['子','丑','巳','寅','卯','辰']");
    });

    test("4阳爻 雷天大壮 ['子','丑','寅','卯','辰','巳']", () {
      final guaBinaryList = [1, 1, 1, 1, 0, 0];
      final zhiList = YuanTangCalculator.zhuangGua45(
        guaBinaryList,
        yangZhiList,
        YinYang.YANG,
      );
      expect(zhiList, [
        [DiZhi.ZI],
        [DiZhi.CHOU],
        [DiZhi.YIN],
        [DiZhi.MAO],
        [DiZhi.CHEN],
        [DiZhi.SI],
      ], reason: "元堂地支列表应为['子','丑','寅','卯','辰','巳']");
    });

    test("3阳爻 风山渐 [[],[],['子','卯'],[],['丑','辰'],['巳','寅']]", () {
      final guaBinaryList = [0, 0, 1, 0, 1, 1];
      final zhiList = YuanTangCalculator.zhuangGua123(
        guaBinaryList,
        yangZhiList,
        YinYang.YANG,
      );
      expect(zhiList, [
        [],
        [],
        [DiZhi.ZI, DiZhi.MAO],
        [],
        [DiZhi.CHOU, DiZhi.CHEN],
        [DiZhi.YIN, DiZhi.SI],
      ], reason: "元堂地支列表应为[[],[],['子','卯'],[],['丑','辰'],['巳','寅']]");
    });

    test("2阳爻 地火明夷 [[子,寅],['辰'],['丑','卯'],['巳'],[],[]]", () {
      final guaBinaryList = [1, 0, 1, 0, 0, 0];
      final zhiList = YuanTangCalculator.zhuangGua123(
        guaBinaryList,
        yangZhiList,
        YinYang.YANG,
      );
      expect(zhiList, [
        [DiZhi.ZI, DiZhi.YIN],
        [DiZhi.CHEN],
        [DiZhi.CHOU, DiZhi.MAO],
        [DiZhi.SI],
        [],
        [],
      ], reason: "元堂地支列表应为[[子,寅],['辰'],['丑','卯'],['巳'],[],[]]");
    });

    test("1阳爻 水地比 [[寅],[卯],[辰],[巳],[子,丑],[]]", () {
      final guaBinaryList = [0, 0, 0, 0, 1, 0];
      final zhiList = YuanTangCalculator.zhuangGua123(
        guaBinaryList,
        yangZhiList,
        YinYang.YANG,
      );
      expect(zhiList, [
        [DiZhi.YIN],
        [DiZhi.MAO],
        [DiZhi.CHEN],
        [DiZhi.SI],
        [DiZhi.ZI, DiZhi.CHOU],
        [],
      ], reason: "元堂地支列表应为[[寅],[卯],[辰],[巳],[子,丑],[]]");
    });

    test("5阴爻 地水师 ['午','亥','未','申','酉','戌']", () {
      final guaBinaryList = [0, 1, 0, 0, 0, 0];
      final zhiList = YuanTangCalculator.zhuangGua45(
        guaBinaryList,
        yinZhiList,
        YinYang.YIN,
      );
      expect(zhiList, [
        [DiZhi.WU],
        [DiZhi.HAI],
        [DiZhi.WEI],
        [DiZhi.SHEN],
        [DiZhi.YOU],
        [DiZhi.XU],
      ], reason: "元堂地支列表应为['午','亥','未','申','酉','戌']");
    });

    test("4阴爻 坎为水 ['午','戌','未','申','亥','酉']", () {
      final guaBinaryList = [0, 1, 0, 0, 1, 0];
      final zhiList = YuanTangCalculator.zhuangGua45(
        guaBinaryList,
        yinZhiList,
        YinYang.YIN,
      );
      expect(zhiList, [
        [DiZhi.WU],
        [DiZhi.XU],
        [DiZhi.WEI],
        [DiZhi.SHEN],
        [DiZhi.HAI],
        [DiZhi.YOU],
      ], reason: "元堂地支列表应为['午','戌','未','申','亥','酉']");
    });

    test("3阴爻 风水涣 [[午,酉],[],[未,戌],[申,亥],[],[]]", () {
      final guaBinaryList = [0, 1, 0, 0, 1, 1];
      final zhiList = YuanTangCalculator.zhuangGua123(
        guaBinaryList,
        yinZhiList,
        YinYang.YIN,
      );
      expect(zhiList, [
        [DiZhi.WU, DiZhi.YOU],
        [],
        [DiZhi.WEI, DiZhi.XU],
        [DiZhi.SHEN, DiZhi.HAI],
        [],
        [],
      ], reason: "元堂地支列表应为[[午,酉],[],[未,戌],[申,亥],[],[]]");
    });
    test("2阴爻 天山遁 [[午,申],[未,酉],[戌],[亥],[],[]]", () {
      final guaBinaryList = [0, 0, 1, 1, 1, 1];
      final zhiList = YuanTangCalculator.zhuangGua123(
        guaBinaryList,
        yinZhiList,
        YinYang.YIN,
      );
      expect(zhiList, [
        [DiZhi.WU, DiZhi.SHEN],
        [DiZhi.WEI, DiZhi.YOU],
        [DiZhi.XU],
        [DiZhi.HAI],
        [],
        [],
      ], reason: "元堂地支列表应为[[午,酉],[],[未,戌],[申,亥],[],[]]");
    });

    test("1阴爻 天风姤 [[午,未],[申],[酉],[戌],[亥],[]]", () {
      final guaBinaryList = [0, 1, 1, 1, 1, 1];
      final zhiList = YuanTangCalculator.zhuangGua123(
        guaBinaryList,
        yinZhiList,
        YinYang.YIN,
      );
      expect(zhiList, [
        [DiZhi.WU, DiZhi.WEI],
        [DiZhi.SHEN],
        [DiZhi.YOU],
        [DiZhi.XU],
        [DiZhi.HAI],
        [],
      ], reason: "元堂地支列表应为[[午,未],[申],[酉],[戌],[亥],[]]");
    });

    test("阳男，甲子 丁卯 庚申 庚辰", () {
      final EightChars eightChars = EightChars(
        year: JiaZi.JIA_ZI,
        month: JiaZi.DING_MAO,
        day: JiaZi.GENG_SHEN,
        time: JiaZi.GENG_CHEN,
      );
      final Enum64Gua gua64 = Enum64Gua.getBy8Gua(Enum8Gua.Qian, Enum8Gua.Xun);
      final gua = YuanTangCalculator.yuanTangZhuangGua(
        eightChars: eightChars,
        gua: gua64,
        gender: Gender.male,
        birthAfterZhi: TwentyFourJieQi.DONG_ZHI,
      );
      expect(
        gua.yuanTangYaoList.map((e) => e.yangTangZhiList),
        [
          [DiZhi.SI],
          [DiZhi.ZI],
          [DiZhi.CHOU],
          [DiZhi.YIN],
          [DiZhi.MAO],
          [DiZhi.CHEN],
        ],
        reason: "元堂地支列表应为['巳','子','丑','寅','卯','辰']",
      );
      expect(gua.yuanTangYao.indexAtYaoList, 5, reason: "元堂爻索引应为5");
      final houGua = YuanTangCalculator.xianTianGuaToHouTianGua(
        gua,
        YinYang.YANG,
      );
      expect(
        houGua,
        Enum64Gua.getBy8Gua(Enum8Gua.Xun, Enum8Gua.Dui),
        reason: "应该为风泽中孚",
      );
      var gua2 = YuanTangCalculator.yuanTangZhuangGua(
        eightChars: eightChars,
        gua: houGua.gua,
        gender: Gender.male,
        birthAfterZhi: TwentyFourJieQi.DONG_ZHI,
      );
      expect(gua2.yuanTangYao.indexAtYaoList, 2, reason: "元堂爻索引应为2");
    });

    test("阴女，庚午，戊戌，己酉，乙亥", () {
      final EightChars eightChars = EightChars(
        year: JiaZi.GENG_WU,
        month: JiaZi.WU_XU,
        day: JiaZi.JI_YOU,
        time: JiaZi.YI_HAI,
      );
      final Enum64Gua gua64 = Enum64Gua.getBy8Gua(Enum8Gua.Xun, Enum8Gua.Kan);
      final PureYuanTangGua gua = YuanTangCalculator.yuanTangZhuangGua(
        eightChars: eightChars,
        gua: gua64,
        gender: Gender.female,
        birthAfterZhi: TwentyFourJieQi.DONG_ZHI,
      );
      expect(
        gua.yuanTangYaoList.map((e) => e.yangTangZhiList),
        [
          [DiZhi.WU, DiZhi.YOU],
          [],
          [DiZhi.WEI, DiZhi.XU],
          [DiZhi.SHEN, DiZhi.HAI],
          [],
          [],
        ],
        reason: "元堂地支列表应为[[午,酉],[],[未,戌],[申,亥],[],[]]",
      );
      expect(gua.yuanTangYao.indexAtYaoList, 3, reason: "元堂爻索引应为3");
      final houGua = YuanTangCalculator.xianTianGuaToHouTianGua(
        gua,
        YinYang.YIN,
      );
      expect(
        houGua,
        Enum64Gua.getBy8Gua(Enum8Gua.Kan, Enum8Gua.Qian),
        reason: "应该为水天需",
      );
      final gua2 = YuanTangCalculator.yuanTangZhuangGua(
        eightChars: eightChars,
        gua: houGua.gua,
        gender: Gender.female,
        birthAfterZhi: TwentyFourJieQi.DONG_ZHI,
      );
      expect(gua2.yuanTangYao.indexAtYaoList, 0, reason: "元堂爻索引应为0");
    });
  });

  group('zhuangGua6 穷举', () {
    group('六阳', () {
      test('男 阳时：节气无关，入下三爻', () {
        final expected = [
          [DiZhi.ZI, DiZhi.MAO],
          [DiZhi.CHOU, DiZhi.CHEN],
          [DiZhi.YIN, DiZhi.SI],
          [],
          [],
          [],
        ];
        final dong = YuanTangCalculator.zhuangGua6(
          YinYang.YANG,
          Gender.male,
          YinYang.YANG,
          TwentyFourJieQi.DONG_ZHI,
        );
        final xia = YuanTangCalculator.zhuangGua6(
          YinYang.YANG,
          Gender.male,
          YinYang.YANG,
          TwentyFourJieQi.XIA_ZHI,
        );
        expect(dong, expected);
        expect(xia, expected);
      });

      test('男 阴时：节气无关，入上三爻', () {
        final expected = [
          [],
          [],
          [],
          [DiZhi.YOU, DiZhi.WU],
          [DiZhi.WEI, DiZhi.XU],
          [DiZhi.SHEN, DiZhi.HAI],
        ];
        final dong = YuanTangCalculator.zhuangGua6(
          YinYang.YANG,
          Gender.male,
          YinYang.YIN,
          TwentyFourJieQi.DONG_ZHI,
        );
        final xia = YuanTangCalculator.zhuangGua6(
          YinYang.YANG,
          Gender.male,
          YinYang.YIN,
          TwentyFourJieQi.XIA_ZHI,
        );
        expect(dong, expected);
        expect(xia, expected);
      });

      test('女 阳时：冬至上三爻，夏至下三爻', () {
        final expectedDong = [
          [],
          [],
          [],
          [DiZhi.YIN, DiZhi.SI],
          [DiZhi.CHOU, DiZhi.CHEN],
          [DiZhi.ZI, DiZhi.MAO],
        ];
        final expectedXia = [
          [DiZhi.ZI, DiZhi.MAO],
          [DiZhi.CHOU, DiZhi.CHEN],
          [DiZhi.YIN, DiZhi.SI],
          [],
          [],
          [],
        ];
        final dong = YuanTangCalculator.zhuangGua6(
          YinYang.YANG,
          Gender.female,
          YinYang.YANG,
          TwentyFourJieQi.DONG_ZHI,
        );
        final xia = YuanTangCalculator.zhuangGua6(
          YinYang.YANG,
          Gender.female,
          YinYang.YANG,
          TwentyFourJieQi.XIA_ZHI,
        );
        expect(dong, expectedDong);
        expect(xia, expectedXia);
      });

      test('女 阴时：冬至下三爻，夏至上三爻', () {
        final expectedDong = [
          [DiZhi.SHEN, DiZhi.HAI],
          [DiZhi.WEI, DiZhi.XU],
          [DiZhi.WU, DiZhi.YOU],
          [],
          [],
          [],
        ];
        final expectedXia = [
          [],
          [],
          [],
          [DiZhi.WU, DiZhi.YOU],
          [DiZhi.WEI, DiZhi.XU],
          [DiZhi.SHEN, DiZhi.HAI],
        ];
        final dong = YuanTangCalculator.zhuangGua6(
          YinYang.YANG,
          Gender.female,
          YinYang.YIN,
          TwentyFourJieQi.DONG_ZHI,
        );
        final xia = YuanTangCalculator.zhuangGua6(
          YinYang.YANG,
          Gender.female,
          YinYang.YIN,
          TwentyFourJieQi.XIA_ZHI,
        );
        expect(dong, expectedDong);
        expect(xia, expectedXia);
      });
    });

    group('六阴', () {
      test('女 阳时：节气无关，入下三爻', () {
        final expected = [
          [DiZhi.ZI, DiZhi.MAO],
          [DiZhi.CHOU, DiZhi.CHEN],
          [DiZhi.YIN, DiZhi.SI],
          [],
          [],
          [],
        ];
        final dong = YuanTangCalculator.zhuangGua6(
          YinYang.YIN,
          Gender.female,
          YinYang.YANG,
          TwentyFourJieQi.DONG_ZHI,
        );
        final xia = YuanTangCalculator.zhuangGua6(
          YinYang.YIN,
          Gender.female,
          YinYang.YANG,
          TwentyFourJieQi.XIA_ZHI,
        );
        expect(dong, expected);
        expect(xia, expected);
      });

      test('女 阴时：节气无关，入上三爻', () {
        final expected = [
          [],
          [],
          [],
          [DiZhi.YOU, DiZhi.WU],
          [DiZhi.WEI, DiZhi.XU],
          [DiZhi.SHEN, DiZhi.HAI],
        ];
        final dong = YuanTangCalculator.zhuangGua6(
          YinYang.YIN,
          Gender.female,
          YinYang.YIN,
          TwentyFourJieQi.DONG_ZHI,
        );
        final xia = YuanTangCalculator.zhuangGua6(
          YinYang.YIN,
          Gender.female,
          YinYang.YIN,
          TwentyFourJieQi.XIA_ZHI,
        );
        expect(dong, expected);
        expect(xia, expected);
      });

      test('男 阳时：冬至上三爻，夏至下三爻', () {
        final expectedDong = [
          [],
          [],
          [],
          [DiZhi.YIN, DiZhi.SI],
          [DiZhi.CHOU, DiZhi.CHEN],
          [DiZhi.ZI, DiZhi.MAO],
        ];
        final expectedXia = [
          [DiZhi.ZI, DiZhi.MAO],
          [DiZhi.CHOU, DiZhi.CHEN],
          [DiZhi.YIN, DiZhi.SI],
          [],
          [],
          [],
        ];
        final dong = YuanTangCalculator.zhuangGua6(
          YinYang.YIN,
          Gender.male,
          YinYang.YANG,
          TwentyFourJieQi.DONG_ZHI,
        );
        final xia = YuanTangCalculator.zhuangGua6(
          YinYang.YIN,
          Gender.male,
          YinYang.YANG,
          TwentyFourJieQi.XIA_ZHI,
        );
        expect(dong, expectedDong);
        expect(xia, expectedXia);
      });

      test('男 阴时：冬至下三爻，夏至上三爻', () {
        final expectedDong = [
          [DiZhi.SHEN, DiZhi.HAI],
          [DiZhi.WEI, DiZhi.XU],
          [DiZhi.WU, DiZhi.YOU],
          [],
          [],
          [],
        ];
        final expectedXia = [
          [],
          [],
          [],
          [DiZhi.WU, DiZhi.YOU],
          [DiZhi.WEI, DiZhi.XU],
          [DiZhi.SHEN, DiZhi.HAI],
        ];
        final dong = YuanTangCalculator.zhuangGua6(
          YinYang.YIN,
          Gender.male,
          YinYang.YIN,
          TwentyFourJieQi.DONG_ZHI,
        );
        final xia = YuanTangCalculator.zhuangGua6(
          YinYang.YIN,
          Gender.male,
          YinYang.YIN,
          TwentyFourJieQi.XIA_ZHI,
        );
        expect(dong, expectedDong);
        expect(xia, expectedXia);
      });
    });
  });

  group("元堂大运测试", () {
    test("先天【天风姤】，后天【风泽中孚】", () {
      List<YuanTangDaYunPeriod> daYunList = YuanTangCalculator.calculateDaYun(
        PureYuanTangGua.from64Gua(
          Enum64Gua.tian_feng_gou,
          EnumYaoOrder.fromIndex(5),
        ),
        1,
      );
      expect(daYunList.length, 6);
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.top).startAge,
        1,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.top).endAge,
        9,
      );

      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.init).startAge,
        10,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.init).endAge,
        15,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.second).startAge,
        16,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.second).endAge,
        24,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.third).startAge,
        25,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.third).endAge,
        33,
      );

      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.fourth).startAge,
        34,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.fourth).endAge,
        42,
      );

      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.fifth).startAge,
        43,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.fifth).endAge,
        51,
      );

      List<YuanTangDaYunPeriod> houDaYun = YuanTangCalculator.calculateDaYun(
        PureYuanTangGua.from64Gua(
          Enum64Gua.feng_ze_zhong_fu,
          EnumYaoOrder.fromIndex(2),
        ),
        52,
      );
      expect(houDaYun.length, 6);
      expect(
        houDaYun.firstWhere((t) => t.order == EnumYaoOrder.init).startAge,
        82,
      );
      expect(
        houDaYun.firstWhere((t) => t.order == EnumYaoOrder.init).endAge,
        90,
      );

      expect(
        houDaYun.firstWhere((t) => t.order == EnumYaoOrder.second).startAge,
        91,
      );
      expect(
        houDaYun.firstWhere((t) => t.order == EnumYaoOrder.second).endAge,
        99,
      );
      expect(
        houDaYun.firstWhere((t) => t.order == EnumYaoOrder.third).startAge,
        52,
      );
      expect(
        houDaYun.firstWhere((t) => t.order == EnumYaoOrder.third).endAge,
        57,
      );

      expect(
        houDaYun.firstWhere((t) => t.order == EnumYaoOrder.fourth).startAge,
        58,
      );
      expect(
        houDaYun.firstWhere((t) => t.order == EnumYaoOrder.fourth).endAge,
        63,
      );

      expect(
        houDaYun.firstWhere((t) => t.order == EnumYaoOrder.fifth).startAge,
        64,
      );
      expect(
        houDaYun.firstWhere((t) => t.order == EnumYaoOrder.fifth).endAge,
        72,
      );

      expect(
        houDaYun.firstWhere((t) => t.order == EnumYaoOrder.top).startAge,
        73,
      );
      expect(
        houDaYun.firstWhere((t) => t.order == EnumYaoOrder.top).endAge,
        81,
      );
    });

    test("先天【雷地豫】，后天【水雷屯】", () {
      List<YuanTangDaYunPeriod> daYunList = YuanTangCalculator.calculateDaYun(
        PureYuanTangGua.from64Gua(
          Enum64Gua.lei_di_yu,
          EnumYaoOrder.fromIndex(1),
        ),
        1,
      );
      expect(daYunList.length, 6);

      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.second).startAge,
        1,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.second).endAge,
        6,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.third).startAge,
        7,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.third).endAge,
        12,
      );

      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.fourth).startAge,
        13,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.fourth).endAge,
        21,
      );

      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.fifth).startAge,
        22,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.fifth).endAge,
        27,
      );

      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.top).startAge,
        28,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.top).endAge,
        33,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.init).startAge,
        34,
      );
      expect(
        daYunList.firstWhere((t) => t.order == EnumYaoOrder.init).endAge,
        39,
      );

      List<YuanTangDaYunPeriod> houYaoList = YuanTangCalculator.calculateDaYun(
        PureYuanTangGua.from64Gua(
          Enum64Gua.shui_lei_tun,
          EnumYaoOrder.fromIndex(4),
        ),
        40,
      );
      expect(houYaoList.length, 6);
      expect(
        houYaoList.firstWhere((t) => t.order == EnumYaoOrder.init).startAge,
        55,
      );
      expect(
        houYaoList.firstWhere((t) => t.order == EnumYaoOrder.init).endAge,
        63,
      );
      expect(
        houYaoList.firstWhere((t) => t.order == EnumYaoOrder.second).startAge,
        64,
      );
      expect(
        houYaoList.firstWhere((t) => t.order == EnumYaoOrder.second).endAge,
        69,
      );

      expect(
        houYaoList.firstWhere((t) => t.order == EnumYaoOrder.third).startAge,
        70,
      );
      expect(
        houYaoList.firstWhere((t) => t.order == EnumYaoOrder.third).endAge,
        75,
      );

      expect(
        houYaoList.firstWhere((t) => t.order == EnumYaoOrder.fourth).startAge,
        76,
      );
      expect(
        houYaoList.firstWhere((t) => t.order == EnumYaoOrder.fourth).endAge,
        81,
      );

      expect(
        houYaoList.firstWhere((t) => t.order == EnumYaoOrder.fifth).startAge,
        40,
      );
      expect(
        houYaoList.firstWhere((t) => t.order == EnumYaoOrder.fifth).endAge,
        48,
      );

      expect(
        houYaoList.firstWhere((t) => t.order == EnumYaoOrder.top).startAge,
        49,
      );
      expect(
        houYaoList.firstWhere((t) => t.order == EnumYaoOrder.top).endAge,
        54,
      );
    });
  });

  group("元堂卦 流年", () {
    test("先天卦 阳爻 大运阳年起", () {
      List<YuanTangLiuYearGua> liunianList =
          YuanTangCalculator.calculateLiuYearForDayun(
            YuanTangDaYunPeriod(
              order: EnumYaoOrder.top,
              yinYang: YinYang.YANG,
              startAge: 1,
              diZhiList: null,
            ),
            Enum64Gua.tian_feng_gou,
            "先天卦",
            JiaZi.JIA_ZI,
          );
      expect(liunianList.length, 9);
      expect(
        liunianList.map((l) => Tuple3(l.age, l.gua, l.changedYao)).toList(),
        [
          Tuple3(1, Enum64Gua.tian_feng_gou, EnumYaoOrder.top),
          Tuple3(2, Enum64Gua.tian_shui_song, EnumYaoOrder.third),
          Tuple3(3, Enum64Gua.ze_shui_kun, EnumYaoOrder.top),
          Tuple3(4, Enum64Gua.dui_wei_ze, EnumYaoOrder.init),
          Tuple3(5, Enum64Gua.ze_lei_sui, EnumYaoOrder.second),
          Tuple3(6, Enum64Gua.ze_huo_ge, EnumYaoOrder.third),
          Tuple3(7, Enum64Gua.shui_huo_ji_ji, EnumYaoOrder.fourth),
          Tuple3(8, Enum64Gua.di_huo_ming_yi, EnumYaoOrder.fifth),
          Tuple3(9, Enum64Gua.shan_huo_bi, EnumYaoOrder.top),
        ],
      );
    });

    test("先天卦 阳爻 大运阴年起", () {
      List<YuanTangLiuYearGua> liunianList =
          YuanTangCalculator.calculateLiuYearForDayun(
            YuanTangDaYunPeriod(
              order: EnumYaoOrder.top,
              yinYang: YinYang.YANG,
              startAge: 1,
              diZhiList: null,
            ),
            Enum64Gua.tian_feng_gou,
            "先天卦",
            JiaZi.YI_CHOU,
          );
      expect(liunianList.length, 9);
      expect(
        liunianList.map((l) => Tuple3(l.age, l.gua, l.changedYao)).toList(),
        [
          Tuple3(1, Enum64Gua.ze_feng_da_guo, EnumYaoOrder.top),
          Tuple3(2, Enum64Gua.ze_shui_kun, EnumYaoOrder.third),
          Tuple3(3, Enum64Gua.tian_shui_song, EnumYaoOrder.top),
          Tuple3(4, Enum64Gua.tian_ze_lv, EnumYaoOrder.init),
          Tuple3(5, Enum64Gua.tian_lei_wu_wang, EnumYaoOrder.second),
          Tuple3(6, Enum64Gua.tian_huo_tong_ren, EnumYaoOrder.third),
          Tuple3(7, Enum64Gua.feng_huo_jia_ren, EnumYaoOrder.fourth),
          Tuple3(8, Enum64Gua.shan_huo_bi, EnumYaoOrder.fifth),
          Tuple3(9, Enum64Gua.di_huo_ming_yi, EnumYaoOrder.top),
        ],
      );
    });

    test("先天卦 大运阴爻起", () {
      List<YuanTangLiuYearGua> liunianList =
          YuanTangCalculator.calculateLiuYearForDayun(
            YuanTangDaYunPeriod(
              order: EnumYaoOrder.init,
              yinYang: YinYang.YIN,
              startAge: 10,
              diZhiList: null,
            ),
            Enum64Gua.tian_feng_gou,
            "先天卦",
            JiaZi.YI_CHOU,
          );
      expect(liunianList.length, 6);
      expect(
        liunianList.map((l) => Tuple3(l.age, l.gua, l.changedYao)).toList(),
        [
          Tuple3(10, Enum64Gua.qian_wei_tian, EnumYaoOrder.init),
          Tuple3(11, Enum64Gua.tian_huo_tong_ren, EnumYaoOrder.second),
          Tuple3(12, Enum64Gua.tian_lei_wu_wang, EnumYaoOrder.third),
          Tuple3(13, Enum64Gua.feng_lei_yi, EnumYaoOrder.fourth),
          Tuple3(14, Enum64Gua.shan_lei_yi, EnumYaoOrder.fifth),
          Tuple3(15, Enum64Gua.di_lei_fu, EnumYaoOrder.top),
        ],
      );
    });

    test("流月 流年卦 风雷益 九五元堂爻", () {
      List<YuanTangLiuMonthGua> liuyueList =
          YuanTangCalculator.calculateLiuMonthForAge(
            50,
            Enum64Gua.feng_lei_yi,
            4,
            true,
          );
      expect(liuyueList.length, 12);
      expect(
        liuyueList
            .map((l) => Tuple3(l.month, l.gua, l.changedYaoIndex))
            .toList(),
        [
          Tuple3(1, Enum64Gua.shui_lei_tun, EnumYaoOrder.top),
          Tuple3(2, Enum64Gua.shui_huo_ji_ji, EnumYaoOrder.third),
          Tuple3(3, Enum64Gua.shui_di_bi, EnumYaoOrder.init),
          Tuple3(4, Enum64Gua.ze_di_cui, EnumYaoOrder.fourth),
          Tuple3(5, Enum64Gua.kan_wei_shui, EnumYaoOrder.second),
          Tuple3(6, Enum64Gua.di_shui_shi, EnumYaoOrder.fifth),
          Tuple3(7, Enum64Gua.shui_feng_jing, EnumYaoOrder.third),
          Tuple3(8, Enum64Gua.xun_wei_feng, EnumYaoOrder.top),
          Tuple3(9, Enum64Gua.ze_feng_da_guo, EnumYaoOrder.fourth),
          Tuple3(10, Enum64Gua.ze_tian_guai, EnumYaoOrder.init),
          Tuple3(11, Enum64Gua.lei_feng_heng, EnumYaoOrder.fifth),
          Tuple3(12, Enum64Gua.lei_shan_xiao_gu, EnumYaoOrder.second),
        ],
      );
    });
  });
}
