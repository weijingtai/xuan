import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../lib/repository/tiao_wen_repository_impl.dart';
import '../lib/repository/datamodels/tiao_wen_datamodel.dart';
import 'package:common/enums.dart';

/// 条文数据仓库测试
void main() {
  group('TiaoWenRepositoryImpl Tests', () {
    late TiaoWenRepositoryImpl repository;

    setUpAll(() async {
      // 确保 Flutter 绑定已初始化（测试环境需要）
      TestWidgetsFlutterBinding.ensureInitialized();

      // 初始化仓库，指向 CSV 文件
      repository = TiaoWenRepositoryImpl(
        dataPath: 'assets/all_tiao_wen_v1.csv',
      );
    });

    tearDownAll(() {
      // 清理缓存
      TiaoWenRepositoryImpl.clearCache();
    });

    test('获取单个条文 - getById', () async {
      // Arrange
      const int testId = 1001;

      // Act
      final tiaoWen = await repository.getById(testId);

      // Assert
      expect(tiaoWen, isNotNull, reason: '应该能找到 ID 为 $testId 的条文');
      expect(tiaoWen!.id, equals(testId), reason: '返回的条文 ID 应该匹配');
      expect(tiaoWen.content1, isNotEmpty, reason: '条文内容不应为空');
      expect(tiaoWen.setName, isA<DiZhi>(), reason: '地支应该是有效的枚举值');

      print('✓ 条文 ${tiaoWen.id}: ${tiaoWen.content1}');
      print('✓ 地支: ${tiaoWen.setName}');
      if (tiaoWen.ageSet1 != null) {
        print('✓ 年龄集合: ${tiaoWen.ageSet1}');
      }
    });

    test('获取不存在的条文 - getById', () async {
      // Arrange
      const int nonExistentId = 99999;

      // Act
      final tiaoWen = await repository.getById(nonExistentId);

      // Assert
      expect(tiaoWen, isNull, reason: '不存在的 ID 应该返回 null');
    });

    test('按地支搜索条文 - search by setName', () async {
      // Arrange
      const String setName = '子';

      // Act
      final results = await repository.search(setName: setName);

      // Assert
      expect(results, isNotEmpty, reason: '应该能找到地支为"子"的条文');
      for (final tiaoWen in results) {
        expect(tiaoWen.setName.name, equals(setName), reason: '所有结果的地支都应该是"子"');
      }

      print('✓ 地支为"$setName"的条文数量: ${results.length}');
    });

    test('按内容关键词搜索条文 - search by contentKeyword', () async {
      // Arrange
      const String keyword = '花';

      // Act
      final results = await repository.search(contentKeyword: keyword);

      // Assert
      expect(results, isNotEmpty, reason: '应该能找到包含"花"的条文');
      for (final tiaoWen in results) {
        final containsKeyword =
            tiaoWen.content1.contains(keyword) ||
            (tiaoWen.content2?.contains(keyword) ?? false);
        expect(containsKeyword, isTrue, reason: '所有结果都应该包含关键词"$keyword"');
      }

      print('✓ 包含"$keyword"的条文数量: ${results.length}');
    });

    test('组合搜索条文 - search by setName and contentKeyword', () async {
      // Arrange
      const String setName = '子';
      const String keyword = '花';

      // Act
      final results = await repository.search(
        setName: setName,
        contentKeyword: keyword,
      );

      // Assert
      for (final tiaoWen in results) {
        expect(tiaoWen.setName.name, equals(setName), reason: '地支应该匹配');
        final containsKeyword =
            tiaoWen.content1.contains(keyword) ||
            (tiaoWen.content2?.contains(keyword) ?? false);
        expect(containsKeyword, isTrue, reason: '内容应该包含关键词');
      }

      print('✓ 地支为"$setName"且包含"$keyword"的条文数量: ${results.length}');
    });

    test('搜索不存在的地支 - search with invalid setName', () async {
      // Arrange
      const String invalidSetName = '不存在的地支';

      // Act
      final results = await repository.search(setName: invalidSetName);

      // Assert
      expect(results, isEmpty, reason: '不存在的地支应该返回空列表');
    });

    test('获取指定范围的条文 - getByIdRange', () async {
      // Arrange
      const int startId = 1001;
      const int endId = 1010;

      // Act
      final results = await repository.getByIdRange(
        startId: startId,
        endId: endId,
      );

      // Assert
      expect(results, isNotEmpty, reason: '指定范围内应该有条文');
      expect(
        results.length,
        lessThanOrEqualTo(endId - startId + 1),
        reason: '结果数量不应超过范围大小',
      );

      // 验证所有结果的 ID 都在指定范围内
      for (final tiaoWen in results) {
        expect(
          tiaoWen.id,
          greaterThanOrEqualTo(startId),
          reason: 'ID 应该 >= startId',
        );
        expect(tiaoWen.id, lessThanOrEqualTo(endId), reason: 'ID 应该 <= endId');
      }

      // 验证结果按 ID 升序排列
      for (int i = 1; i < results.length; i++) {
        expect(
          results[i].id,
          greaterThan(results[i - 1].id),
          reason: '结果应该按 ID 升序排列',
        );
      }

      print('✓ ID $startId-$endId 的条文数量: ${results.length}');
      for (final tiaoWen in results.take(3)) {
        print('✓ ${tiaoWen.id}: ${tiaoWen.content1}');
      }
    });

    test('获取无效范围的条文 - getByIdRange with invalid range', () async {
      // Arrange
      const int startId = 1010;
      const int endId = 1001; // startId > endId

      // Act & Assert
      expect(
        () => repository.getByIdRange(startId: startId, endId: endId),
        throwsArgumentError,
        reason: 'startId > endId 应该抛出 ArgumentError',
      );
    });

    test('获取指定 ID 周围的条文 - getAroundById', () async {
      // Arrange
      const int centerId = 1005;
      const int beforeCount = 2;
      const int afterCount = 2;

      // Act
      final results = await repository.getAroundById(
        centerId: centerId,
        beforeCount: beforeCount,
        afterCount: afterCount,
        includeCenterItem: true,
      );

      // Assert
      expect(results, isNotEmpty, reason: '周围应该有条文');

      // 验证中心条文存在
      final centerItem = results.firstWhere(
        (item) => item.id == centerId,
        orElse: () => throw StateError('中心条文应该存在'),
      );
      expect(centerItem.id, equals(centerId), reason: '应该包含中心条文');

      // 验证结果按 ID 升序排列
      for (int i = 1; i < results.length; i++) {
        expect(
          results[i].id,
          greaterThan(results[i - 1].id),
          reason: '结果应该按 ID 升序排列',
        );
      }

      print('✓ ID $centerId 周围的条文数量: ${results.length}');
      for (final tiaoWen in results) {
        print('✓ ${tiaoWen.id}: ${tiaoWen.content1}');
      }
    });

    test('获取周围条文不包含中心项 - getAroundById without center', () async {
      // Arrange
      const int centerId = 1005;
      const int beforeCount = 1;
      const int afterCount = 1;

      // Act
      final results = await repository.getAroundById(
        centerId: centerId,
        beforeCount: beforeCount,
        afterCount: afterCount,
        includeCenterItem: false,
      );

      // Assert
      final hasCenterItem = results.any((item) => item.id == centerId);
      expect(hasCenterItem, isFalse, reason: '不应该包含中心条文');

      print('✓ 不包含中心项的周围条文数量: ${results.length}');
    });

    test('获取周围条文参数验证 - getAroundById parameter validation', () async {
      // Arrange
      const int centerId = 1005;

      // Act & Assert
      expect(
        () => repository.getAroundById(
          centerId: centerId,
          beforeCount: -1,
          afterCount: 1,
        ),
        throwsArgumentError,
        reason: 'beforeCount < 0 应该抛出 ArgumentError',
      );

      expect(
        () => repository.getAroundById(
          centerId: centerId,
          beforeCount: 1,
          afterCount: -1,
        ),
        throwsArgumentError,
        reason: 'afterCount < 0 应该抛出 ArgumentError',
      );
    });

    test('按地支获取条文 - getByDiZhi', () async {
      // Arrange
      const DiZhi testDiZhi = DiZhi.ZI;

      // Act
      final results = await repository.getByDiZhi(testDiZhi);

      // Assert
      expect(results, isNotEmpty, reason: '地支"子"应该有对应的条文');
      for (final tiaoWen in results) {
        expect(tiaoWen.setName, equals(testDiZhi), reason: '所有结果的地支都应该是"子"');
      }

      print('✓ 地支"${testDiZhi.name}"的条文数量: ${results.length}');

      // 显示前3个
      for (int i = 0; i < results.length && i < 3; i++) {
        final tiaoWen = results[i];
        print('✓ ${tiaoWen.id}: ${tiaoWen.content1}');
      }
    });

    test('获取总条文数量 - getCount', () async {
      // Act
      final totalCount = await repository.getCount();

      // Assert
      expect(totalCount, greaterThan(0), reason: '总条文数量应该大于 0');
      expect(totalCount, isA<int>(), reason: '总数应该是整数');

      print('✓ 总条文数量: $totalCount');
    });

    test('按地支统计条文数量 - statistics by DiZhi', () async {
      // Act
      final Map<DiZhi, int> diZhiCounts = {};
      int totalFromDiZhi = 0;

      for (final diZhi in DiZhi.values) {
        final results = await repository.getByDiZhi(diZhi);
        diZhiCounts[diZhi] = results.length;
        totalFromDiZhi += results.length;
      }

      final totalCount = await repository.getCount();

      // Assert
      expect(diZhiCounts, isNotEmpty, reason: '应该有地支统计数据');
      expect(totalFromDiZhi, equals(totalCount), reason: '各地支条文总数应该等于总条文数');

      print('✓ 各地支条文数量:');
      diZhiCounts.forEach((diZhi, count) {
        expect(count, greaterThanOrEqualTo(0), reason: '每个地支的条文数量应该 >= 0');
        print('  ${diZhi.name}: $count');
      });
    });

    group('高级查询功能测试', () {
      test('按 ID 列表获取条文 - getByIdList', () async {
        // Arrange
        final List<int> idList = [1001, 1003, 1005, 1007, 1009];

        // Act
        final results = await repository.getByIdList(
          queryList: idList,
          preserveOrder: true,
          skipNotFound: true,
        );

        // Assert
        expect(results, isNotEmpty, reason: '应该能找到指定 ID 的条文');
        expect(
          results.length,
          lessThanOrEqualTo(idList.length),
          reason: '结果数量不应超过查询列表长度',
        );

        // 验证顺序保持
        int lastFoundIndex = -1;
        for (final tiaoWen in results) {
          final currentIndex = idList.indexOf(tiaoWen.id);
          expect(
            currentIndex,
            greaterThan(lastFoundIndex),
            reason: '结果应该保持输入顺序',
          );
          lastFoundIndex = currentIndex;
        }

        print('✓ 按 ID 列表获取的条文数量: ${results.length}');
      });

      test('间隔查询条文 - getByIntervalAroundId', () async {
        // Arrange
        const int centerId = 1010;
        const int interval = 5;
        const int minCount = 4;

        // Act
        final results = await repository.getByIntervalAroundId(
          centerId: centerId,
          interval: interval,
          minCount: minCount,
          includeCenterItem: true,
        );

        // Assert
        expect(results.length, greaterThanOrEqualTo(1), reason: '至少应该有中心条文');

        // 验证间隔
        final centerItem = results.firstWhere((item) => item.id == centerId);
        expect(centerItem.id, equals(centerId), reason: '应该包含中心条文');

        print('✓ 间隔查询的条文数量: ${results.length}');
        for (final tiaoWen in results) {
          print('✓ ${tiaoWen.id}: ${tiaoWen.content1}');
        }
      });

      test('分页查询条文 - getByIdsWithPageRange', () async {
        // Arrange
        final List<int> allIds = List.generate(20, (index) => 1001 + index);
        final List<int> pageRange = [0, 9]; // 前10个
        const int steps = 1;

        // Act
        final results = await repository.getByIdsWithPageRange(
          ids: allIds,
          pageRange: pageRange,
          steps: steps,
        );

        // Assert
        expect(results.length, lessThanOrEqualTo(10), reason: '分页结果不应超过页面大小');

        print('✓ 分页查询的条文数量: ${results.length}');
      });
    });

    group('错误处理和边界测试', () {
      test('空搜索条件 - search with empty conditions', () async {
        // Act
        final results = await repository.search();

        // Assert
        expect(results, isNotEmpty, reason: '无搜索条件应该返回所有条文');

        final totalCount = await repository.getCount();
        expect(results.length, equals(totalCount), reason: '应该返回所有条文');
      });

      test('缓存机制测试 - cache mechanism', () async {
        // 第一次调用
        final stopwatch1 = Stopwatch()..start();
        await repository.getCount();
        stopwatch1.stop();

        // 第二次调用（应该使用缓存）
        final stopwatch2 = Stopwatch()..start();
        await repository.getCount();
        stopwatch2.stop();

        // 第二次调用应该更快（使用缓存）
        expect(
          stopwatch2.elapsedMicroseconds,
          lessThan(stopwatch1.elapsedMicroseconds),
          reason: '第二次调用应该更快（使用缓存）',
        );

        print('✓ 第一次调用耗时: ${stopwatch1.elapsedMicroseconds} 微秒');
        print('✓ 第二次调用耗时: ${stopwatch2.elapsedMicroseconds} 微秒');
      });

      test('清除缓存功能 - clearCache', () async {
        // 先加载数据
        await repository.getCount();

        // 清除缓存
        TiaoWenRepositoryImpl.clearCache();

        // 重新加载应该重新读取数据
        final count = await repository.getCount();
        expect(count, greaterThan(0), reason: '清除缓存后应该能重新加载数据');

        print('✓ 缓存清除后重新加载成功，条文数量: $count');
      });
    });

    group('数据完整性测试', () {
      test('验证 CSV 数据格式 - validate CSV data format', () async {
        // Act
        final allTiaoWen = await repository.listAll();

        // Assert
        expect(allTiaoWen, isNotEmpty, reason: 'CSV 文件应该包含数据');

        for (final tiaoWen in allTiaoWen.take(10)) {
          // 验证基本字段
          expect(tiaoWen.id, isA<int>(), reason: 'ID 应该是整数');
          expect(tiaoWen.id, greaterThan(0), reason: 'ID 应该大于 0');
          expect(tiaoWen.setName, isA<DiZhi>(), reason: '地支应该是有效枚举');
          expect(tiaoWen.content1, isNotEmpty, reason: '内容1不应为空');

          // 验证年龄集合格式（如果存在）
          if (tiaoWen.ageSet1 != null) {
            expect(tiaoWen.ageSet1, isA<List<int>>(), reason: '年龄集合应该是整数列表');
            for (final age in tiaoWen.ageSet1!) {
              expect(age, greaterThan(0), reason: '年龄应该大于 0');
              expect(age, lessThan(100), reason: '年龄应该小于 100');
            }
          }
        }

        print('✓ CSV 数据格式验证通过，总条文数: ${allTiaoWen.length}');
      });

      test('验证地支分布 - validate DiZhi distribution', () async {
        // Act
        final Map<DiZhi, int> distribution = {};
        for (final diZhi in DiZhi.values) {
          final results = await repository.getByDiZhi(diZhi);
          distribution[diZhi] = results.length;
        }

        // Assert
        expect(
          distribution.keys.length,
          equals(DiZhi.values.length),
          reason: '应该覆盖所有地支',
        );

        final totalFromDistribution = distribution.values.reduce(
          (a, b) => a + b,
        );
        final totalCount = await repository.getCount();
        expect(
          totalFromDistribution,
          equals(totalCount),
          reason: '分布统计总数应该等于总条文数',
        );

        print('✓ 地支分布验证通过:');
        distribution.forEach((diZhi, count) {
          print('  ${diZhi.name}: $count 条');
        });
      });
    });
  });
}
