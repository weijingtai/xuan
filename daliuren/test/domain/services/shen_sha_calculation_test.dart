import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:daliuren/domain/entities/shen_sha_entity.dart';
import 'package:daliuren/domain/services/shen_sha_calculation_service_impl.dart';
import 'package:daliuren/data/services/shen_sha_data_service_impl.dart';
import 'package:daliuren/domain/usecases/calculate_shen_sha_usecase.dart';

void main() {
  // 在测试开始前初始化Flutter绑定
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('神煞计算测试', () {
    late ShenShaCalculationServiceImpl shenShaService;
    late ShenShaDataServiceImpl dataService;
    late CalculateShenShaUseCase calculateShenShaUseCase;

    setUpAll(() async {
      // 初始化服务
      dataService = ShenShaDataServiceImpl();
      shenShaService = ShenShaCalculationServiceImpl(dataService: dataService);
      calculateShenShaUseCase = CalculateShenShaUseCase(shenShaService);
    });

    test('测试甲子年甲寅月甲子日甲子时的神煞计算', () async {
      // 准备测试数据 - 甲子年甲寅月甲子日甲子时
      final yearJiaZi = JiaZi.JIA_ZI;
      final monthJiaZi = JiaZi.JIA_YIN;
      final dayJiaZi = JiaZi.JIA_ZI;
      final hourJiaZi = JiaZi.JIA_ZI;

      final params = CalculateShenShaParams(
        yearJiaZi: yearJiaZi,
        monthJiaZi: monthJiaZi,
        dayJiaZi: dayJiaZi,
        hourJiaZi: hourJiaZi,
      );

      // 执行计算
      final result = await calculateShenShaUseCase(params);

      // 验证结果
      expect(result, isNotNull);
      expect(result, isA<Map<DiZhi, List<ShenShaResult>>>());

      // 打印结果用于调试
      print('=== 甲子年甲寅月甲子日甲子时神煞分布 ===');
      for (final entry in result.entries) {
        if (entry.value.isNotEmpty) {
          print('${entry.key.name}宫:');
          for (final shenSha in entry.value) {
            print('  - ${shenSha.shenSha.name}(${shenSha.shenSha.jiXiong.name})');
          }
        }
      }

      // 基本验证：应该有神煞分布在各个宫位
      final totalShenSha = result.values.fold<int>(0, (sum, list) => sum + list.length);
      expect(totalShenSha, greaterThan(0), reason: '应该计算出一些神煞');
    });

    test('测试天干神煞计算', () async {
      // 测试甲日的天干神煞
      final yearJiaZi = JiaZi.JIA_ZI;
      final monthJiaZi = JiaZi.JIA_YIN;
      final dayJiaZi = JiaZi.JIA_ZI;
      final hourJiaZi = JiaZi.JIA_ZI;

      final result = await shenShaService.calculateTianGanShenSha(
        yearJiaZi: yearJiaZi,
        monthJiaZi: monthJiaZi,
        dayJiaZi: dayJiaZi,
        hourJiaZi: hourJiaZi,
      );

      expect(result, isNotNull);
      expect(result, isA<List<ShenShaResult>>());

      // 打印天干神煞结果
      print('=== 甲日天干神煞 ===');
      for (final shenShaResult in result) {
        print('${shenShaResult.shenSha.name} -> ${shenShaResult.location.name}');
      }

      // 应该有天干神煞结果
      expect(result.length, greaterThan(0), reason: '甲日应该有天干神煞');
    });

    test('测试年支神煞计算', () async {
      // 测试子年的年支神煞
      final yearJiaZi = JiaZi.JIA_ZI;

      final result = await shenShaService.calculateYearShenSha(yearJiaZi: yearJiaZi);

      expect(result, isNotNull);
      expect(result, isA<List<ShenShaResult>>());

      // 打印年支神煞结果
      print('=== 子年年支神煞 ===');
      for (final shenShaResult in result) {
        print('${shenShaResult.shenSha.name} -> ${shenShaResult.location.name}');
      }

      // 应该有年支神煞结果，比如太岁在子
      expect(result.length, greaterThan(0), reason: '子年应该有年支神煞');
      
      // 验证太岁应该在子位
      final taiSui = result.firstWhere(
        (r) => r.shenSha.name == '太岁',
        orElse: () => throw Exception('没有找到太岁'),
      );
      expect(taiSui.location, equals(DiZhi.ZI), reason: '子年太岁应该在子位');
    });

    test('测试月支神煞计算', () async {
      // 测试寅月的月支神煞
      final monthJiaZi = JiaZi.JIA_YIN;

      final result = await shenShaService.calculateMonthShenSha(monthJiaZi: monthJiaZi);

      expect(result, isNotNull);
      expect(result, isA<List<ShenShaResult>>());

      // 打印月支神煞结果
      print('=== 寅月月支神煞 ===');
      for (final shenShaResult in result) {
        print('${shenShaResult.shenSha.name} -> ${shenShaResult.location.name}');
      }

      // 应该有月支神煞结果
      expect(result.length, greaterThan(0), reason: '寅月应该有月支神煞');
    });

    test('测试按名称查找神煞', () async {
      // 测试查找太岁
      final taiSui = await shenShaService.findShenShaByName('太岁');
      
      expect(taiSui, isNotNull);
      expect(taiSui!.name, equals('太岁'));
      expect(taiSui.type, equals('年煞'));

      print('=== 太岁信息 ===');
      print('名称: ${taiSui.name}');
      print('类型: ${taiSui.type}');
      print('吉凶: ${taiSui.jiXiong.name}');
      print('描述: ${taiSui.descriptionList.join(', ')}');

      // 测试查找不存在的神煞
      final notFound = await shenShaService.findShenShaByName('不存在的神煞');
      expect(notFound, isNull);
    });

    test('测试获取指定位置的神煞', () async {
      final yearJiaZi = JiaZi.JIA_ZI;
      final monthJiaZi = JiaZi.JIA_YIN;
      final dayJiaZi = JiaZi.JIA_ZI;
      final hourJiaZi = JiaZi.JIA_ZI;

      // 获取子位的神煞
      final result = await shenShaService.getShenShaAtLocation(
        DiZhi.ZI,
        yearJiaZi: yearJiaZi,
        monthJiaZi: monthJiaZi,
        dayJiaZi: dayJiaZi,
        hourJiaZi: hourJiaZi,
      );

      expect(result, isNotNull);
      expect(result, isA<List<ShenShaResult>>());

      print('=== 子位神煞 ===');
      for (final shenShaResult in result) {
        print('${shenShaResult.shenSha.name}(${shenShaResult.shenSha.jiXiong.name})');
      }

      // 子年太岁应该在子位
      final hasTaiSui = result.any((r) => r.shenSha.name == '太岁');
      expect(hasTaiSui, isTrue, reason: '子位应该有太岁');
    });
  });
}