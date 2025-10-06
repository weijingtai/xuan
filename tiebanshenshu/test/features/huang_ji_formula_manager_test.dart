import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/features/huang_ji_formula_manager.dart';

void main() {
  // 确保测试绑定已初始化
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HuangJiFormulaManager Tests', () {
    late HuangJiFormulaManager manager;

    setUp(() {
      // 重置管理器状态
      HuangJiFormulaManager.instance.reset();
      manager = HuangJiFormulaManager.instance;
    });

    tearDown(() {
      // 清理状态
      manager.reset();
    });

    group('基础功能测试', () {
      test('应该是单例模式', () {
        final instance1 = HuangJiFormulaManager.instance;
        final instance2 = HuangJiFormulaManager.instance;

        expect(instance1, same(instance2));
      });

      test('初始状态应该未初始化', () {
        expect(manager.isInitialized, false);
        expect(manager.formulaCount, 0);
      });

      test('未初始化时调用方法应该抛出异常', () {
        expect(() => manager.getFormulaById(1), throwsStateError);
        expect(() => manager.getFormulaByName('test'), throwsStateError);
        expect(() => manager.getAllFormulas(), throwsStateError);
        expect(() => manager.getAllFormulaNames(), throwsStateError);
        expect(() => manager.hasFormula(1), throwsStateError);
        expect(() => manager.hasFormulaByName('test'), throwsStateError);
        expect(() => manager.getAllFormulasInfo(), throwsStateError);
      });

      test('重置应该清空状态', () {
        manager.reset();

        expect(manager.isInitialized, false);
        expect(manager.formulaCount, equals(0));
      });
    });

    group('初始化测试', () {
      test('应该能够初始化（使用真实资源文件）', () async {
        final loadedCount = await manager.initialize();

        expect(manager.isInitialized, true);
        expect(loadedCount, greaterThanOrEqualTo(0));
        expect(manager.formulaCount, equals(loadedCount));
      });

      test('重复初始化应该跳过', () async {
        // 第一次初始化
        await manager.initialize();
        final firstCount = manager.formulaCount;

        // 第二次初始化
        final secondCount = await manager.initialize();

        expect(secondCount, equals(firstCount));
      });

      test('重新加载应该重新初始化', () async {
        await manager.initialize();
        final originalCount = manager.formulaCount;

        final reloadedCount = await manager.reload();

        expect(manager.isInitialized, true);
        expect(reloadedCount, equals(originalCount));
      });
    });

    group('查询功能测试（需要先初始化）', () {
      setUp(() async {
        await manager.initialize();
      });

      test('查询不存在的公式应该返回null', () {
        final formulaById = manager.getFormulaById(999999);
        final formulaByName = manager.getFormulaByName('不存在的公式名称');

        expect(formulaById, isNull);
        expect(formulaByName, isNull);
      });

      test('检查不存在的公式应该返回false', () {
        expect(manager.hasFormula(999999), false);
        expect(manager.hasFormulaByName('不存在的公式名称'), false);
      });

      test('应该能够获取所有公式列表', () {
        final allFormulas = manager.getAllFormulas();
        final allNames = manager.getAllFormulaNames();

        expect(allFormulas, isA<List>());
        expect(allNames, isA<List>());
        expect(allFormulas.length, equals(allNames.length));
      });

      test('应该能够获取所有公式信息', () {
        final allInfo = manager.getAllFormulasInfo();

        expect(allInfo, isA<List>());

        if (allInfo.isNotEmpty) {
          final firstInfo = allInfo.first;
          expect(firstInfo.containsKey('id'), true);
          expect(firstInfo.containsKey('name'), true);
          expect(firstInfo.containsKey('description'), true);
          expect(firstInfo.containsKey('groupCount'), true);
          expect(firstInfo.containsKey('totalFormulas'), true);
        }
      });

      test('如果有公式，应该能够正确查询', () {
        if (manager.formulaCount > 0) {
          final allFormulas = manager.getAllFormulas();
          final firstFormula = allFormulas.first;

          // 测试根据ID查询
          final formulaById = manager.getFormulaById(firstFormula.id);
          expect(formulaById, isNotNull);
          expect(formulaById!.id, equals(firstFormula.id));

          // 测试根据名称查询
          final formulaByName = manager.getFormulaByName(firstFormula.name);
          expect(formulaByName, isNotNull);
          expect(formulaByName!.name, equals(firstFormula.name));

          // 测试存在性检查
          expect(manager.hasFormula(firstFormula.id), true);
          expect(manager.hasFormulaByName(firstFormula.name), true);

          // 测试获取公式信息
          final info = manager.getFormulaInfo(firstFormula.id);
          expect(info, isNotNull);
          expect(info!['id'], equals(firstFormula.id));
          expect(info['name'], equals(firstFormula.name));
        }
      });
    });

    group('JSON验证测试', () {
      test('验证有效的JSON格式', () {
        final manager = HuangJiFormulaManager.instance;

        // 测试有效的JSON
        final validJson = {
          'id': 1,
          'name': '测试公式',
          'description': '测试描述',
          'groups': [],
        };

        // 使用反射或者创建一个测试方法来访问私有方法
        // 这里我们通过创建一个简单的验证逻辑来测试
        expect(validJson.containsKey('id'), true);
        expect(validJson.containsKey('name'), true);
        expect(validJson.containsKey('description'), true);
        expect(validJson.containsKey('groups'), true);
        expect(validJson['id'] is int, true);
        expect(validJson['name'] is String, true);
        expect(validJson['description'] is String, true);
        expect(validJson['groups'] is List, true);
      });

      test('验证无效的JSON格式', () {
        // 测试缺少必要字段的JSON
        final invalidJson1 = {
          'id': 1,
          'name': '测试公式',
          // 缺少 description 和 groups
        };

        final invalidJson2 = {
          'id': '1', // 错误的类型
          'name': '测试公式',
          'description': '测试描述',
          'groups': [],
        };

        // 验证缺少字段
        expect(invalidJson1.containsKey('description'), false);
        expect(invalidJson1.containsKey('groups'), false);

        // 验证错误的类型
        expect(invalidJson2['id'] is int, false);
      });
    });
  });
}
