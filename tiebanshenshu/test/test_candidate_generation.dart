import 'package:flutter/foundation.dart';
import '../lib/application/services/candidate_generation_service.dart';
import '../lib/repository/repository_factory.dart';

void main() async {
  print('🧪 测试候选项生成服务 - 基于条文数和步长30');

  // 初始化服务
  final candidateService = CandidateGenerationServiceImpl();

  // 测试场景1：有计算结果的情况
  print('\n📊 测试场景1：有计算结果的情况');
  final contextWithResult = {
    'params': {
      'initialNumber': 150, // 模拟计算得到的初始条文数
      'secondaryNumber': 200, // 模拟计算得到的次条文数
    },
  };

  try {
    final candidatesWithResult = await candidateService
        .generateBaseNumberCandidates(contextWithResult);

    print('✅ 生成候选项数量: ${candidatesWithResult.length}');
    print('📋 候选项详情:');
    for (int i = 0; i < candidatesWithResult.length && i < 5; i++) {
      final candidate = candidatesWithResult[i];
      print(
        '  ${i + 1}. 数字: ${candidate.number}, 偏移: ${candidate.offset}, 显示: ${candidate.displayName}',
      );
    }
  } catch (e) {
    print('❌ 测试失败: $e');
  }

  // 测试场景2：没有计算结果的情况
  print('\n📊 测试场景2：没有计算结果的情况');
  final contextWithoutResult = <String, dynamic>{};

  try {
    final candidatesWithoutResult = await candidateService
        .generateBaseNumberCandidates(contextWithoutResult);

    print('✅ 生成候选项数量: ${candidatesWithoutResult.length}');
    print('📋 候选项详情:');
    for (int i = 0; i < candidatesWithoutResult.length && i < 5; i++) {
      final candidate = candidatesWithoutResult[i];
      print(
        '  ${i + 1}. 数字: ${candidate.number}, 偏移: ${candidate.offset}, 显示: ${candidate.displayName}',
      );
    }
  } catch (e) {
    print('❌ 测试失败: $e');
  }

  // 测试场景3：边界情况 - 接近1的条文数
  print('\n📊 测试场景3：边界情况 - 接近1的条文数');
  final contextNearBoundary = {
    'params': {
      'initialNumber': 50, // 接近边界的条文数
    },
  };

  try {
    final candidatesNearBoundary = await candidateService
        .generateBaseNumberCandidates(contextNearBoundary);

    print('✅ 生成候选项数量: ${candidatesNearBoundary.length}');
    print('📋 候选项详情:');
    for (int i = 0; i < candidatesNearBoundary.length; i++) {
      final candidate = candidatesNearBoundary[i];
      print(
        '  ${i + 1}. 数字: ${candidate.number}, 偏移: ${candidate.offset}, 步数: ${candidate.stepCount}',
      );
    }
  } catch (e) {
    print('❌ 测试失败: $e');
  }

  print('\n🎯 测试完成');
}
