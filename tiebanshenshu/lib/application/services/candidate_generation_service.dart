/// 候选项生成服务
///
/// 负责为交互式策略生成候选项
library;

import 'package:flutter/foundation.dart';

import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/models/huang_ji_candidate.dart';
import '../../repository/tiao_wen_repository.dart';

/// 候选项生成服务接口
abstract class CandidateGenerationService {
  /// 生成基础数选择候选项
  Future<List<TiaoWenCandidate>> generateBaseNumberCandidates({
    required String strategyName,
    Map<String, dynamic>? context,
  });

  /// 生成用户选择候选项
  Future<List<TiaoWenCandidate>> generateUserSelectionCandidates({
    required String strategyName,
    required Map<String, dynamic> selectionHistory,
    Map<String, dynamic>? context,
  });

  /// 生成调整候选项
  Future<List<TiaoWenCandidate>> generateAdjustmentCandidates({
    required String strategyName,
    required int currentValue,
    Map<String, dynamic>? context,
  });
}

/// 候选项生成服务实现
class CandidateGenerationServiceImpl implements CandidateGenerationService {
  final TiaoWenRepository _tiaoWenRepository;

  CandidateGenerationServiceImpl(this._tiaoWenRepository);
  @override
  Future<List<TiaoWenCandidate>> generateBaseNumberCandidates({
    required String strategyName,
    Map<String, dynamic>? context,
  }) async {
    switch (strategyName) {
      case 'HuangJiCalculationStrategy':
        return _generateHuangJiBaseNumberCandidates(context);
      default:
        return _generateDefaultBaseNumberCandidates(context);
    }
  }

  @override
  Future<List<TiaoWenCandidate>> generateUserSelectionCandidates({
    required String strategyName,
    required Map<String, dynamic> selectionHistory,
    Map<String, dynamic>? context,
  }) async {
    switch (strategyName) {
      case 'HuangJiCalculationStrategy':
        return _generateHuangJiUserSelectionCandidates(
          selectionHistory,
          context,
        );
      default:
        return _generateDefaultUserSelectionCandidates(
          selectionHistory,
          context,
        );
    }
  }

  @override
  Future<List<TiaoWenCandidate>> generateAdjustmentCandidates({
    required String strategyName,
    required int currentValue,
    Map<String, dynamic>? context,
  }) async {
    switch (strategyName) {
      case 'HuangJiCalculationStrategy':
        return _generateHuangJiAdjustmentCandidates(currentValue, context);
      default:
        return _generateDefaultAdjustmentCandidates(currentValue, context);
    }
  }

  /// 生成皇极取数法基础数候选项
  Future<List<TiaoWenCandidate>> _generateHuangJiBaseNumberCandidates(
    Map<String, dynamic>? context,
  ) async {
    final candidates = <HuangJiCandidate>[];

    if (kDebugMode) {
      print('🏭 CandidateGenerationService: 开始生成皇极基础数候选项');
      print('📊 上下文数据: $context');
    }

    // 尝试从上下文中获取计算结果
    int baseNumber = 1; // 默认基础数
    bool hasCalculationResult = false;

    if (context != null) {
      // 尝试从params中获取计算结果
      final paramsData = context['params'] as Map<String, dynamic>?;
      if (paramsData != null) {
        // 如果有初始计算结果，使用其初始条文数作为基础
        final initialNumber = paramsData['initialNumber'] as int?;
        final secondaryNumber = paramsData['secondaryNumber'] as int?;

        if (initialNumber != null) {
          baseNumber = initialNumber;
          hasCalculationResult = true;
          if (kDebugMode) {
            print('📊 从上下文获取到初始条文数: $baseNumber');
          }
        } else if (secondaryNumber != null) {
          baseNumber = secondaryNumber;
          hasCalculationResult = true;
          if (kDebugMode) {
            print('📊 从上下文获取到次条文数: $baseNumber');
          }
        }
      }
    }

    if (kDebugMode) {
      print('📊 使用基础条文数: $baseNumber');
      print('📊 是否有计算结果: $hasCalculationResult');
    }

    // 使用皇极计算策略生成候选数列表（基于步长30）
    final candidateNumbers = <int>[];

    if (hasCalculationResult) {
      // 使用HuangJiCalculationStrategy的generateCandidateNumbers方法
      // 生成基于条文数和步长30的候选项
      candidateNumbers.addAll([
        baseNumber, // 原始条文数
        baseNumber - 30, // -1步
        baseNumber + 30, // +1步
        baseNumber - 60, // -2步
        baseNumber + 60, // +2步
        baseNumber - 90, // -3步
        baseNumber + 90, // +3步
      ]);

      // 过滤掉无效的候选数（小于等于0或大于13000）
      candidateNumbers.removeWhere((num) => num <= 0 || num > 13000);

      if (kDebugMode) {
        print('📊 基于条文数$baseNumber和步长30生成的候选数: $candidateNumbers');
      }
    } else {
      // 如果没有计算结果，生成默认的候选项（1-20用于测试）
      candidateNumbers.addAll(List.generate(20, (index) => index + 1));

      if (kDebugMode) {
        print('📊 使用默认候选数列表: 1-20');
      }
    }

    // 为每个候选数生成候选项
    for (int i = 0; i < candidateNumbers.length; i++) {
      final number = candidateNumbers[i];

      // 获取对应的条文内容
      final tiaoWenData = await _tiaoWenRepository.getById(number);

      // 添加调试输出（仅前3个）
      if (kDebugMode && i < 3) {
        print('🔍 获取条文${number}: ${tiaoWenData != null ? '成功' : '失败'}');
        if (tiaoWenData != null) {
          print('   内容: ${tiaoWenData.content1}');
        }
      }

      String displayName;
      String description;

      if (tiaoWenData != null) {
        // 使用真实的条文内容
        displayName = '${number}. ${tiaoWenData.content1}';
        description =
            '条文${number}: ${tiaoWenData.content1}${tiaoWenData.content2 != null ? ' ${tiaoWenData.content2}' : ''}';
      } else {
        // 如果没有找到条文数据，使用默认格式
        displayName = '${number}. 条文${number}';
        description = '基础数 $number (条文数据未找到)';
      }

      // 计算相对于基础数的偏移
      final offset = number - baseNumber;
      final stepCount = (offset.abs() / 30).round();
      final adjustmentDirection = offset == 0 ? 0 : (offset > 0 ? 1 : -1);

      candidates.add(
        HuangJiCandidate(
          id: 'base_$number',
          displayName: displayName,
          description: description,
          type: TiaoWenCandidateType.baseNumber,
          value: number,
          number: number,
          offset: offset,
          stepCount: stepCount,
          isBase: true,
          isInitialSecondary: false,
          adjustmentDirection: adjustmentDirection,
          adjustmentCount: stepCount,
          isDefault: number == baseNumber, // 原始条文数为默认选项
          isEnabled: true,
        ),
      );
    }

    if (kDebugMode) {
      print('🏭 CandidateGenerationService: 皇极基础数候选项生成完成');
      print('📊 生成的候选项数量: ${candidates.length}');
      if (candidates.isNotEmpty) {
        print('📋 第一个候选项: ${candidates.first.displayName}');
        print('📋 第一个候选项描述: ${candidates.first.description}');
        print('📋 最后一个候选项: ${candidates.last.displayName}');
        print('📋 最后一个候选项描述: ${candidates.last.description}');

        // 显示前3个候选项的详细信息
        print('📋 前3个候选项详细信息:');
        for (int i = 0; i < 3 && i < candidates.length; i++) {
          final candidate = candidates[i];
          print(
            '  ${i + 1}. ID: ${candidate.id}, 显示: ${candidate.displayName}, 偏移: ${candidate.offset}',
          );
        }
      }
    }

    return candidates;
  }

  /// 生成皇极取数法用户选择候选项
  Future<List<TiaoWenCandidate>> _generateHuangJiUserSelectionCandidates(
    Map<String, dynamic> selectionHistory,
    Map<String, dynamic>? context,
  ) async {
    final candidates = <HuangJiCandidate>[];
    final baseNumber = selectionHistory['baseNumber'] as int? ?? 1;

    // 生成调整候选项（±1, ±2, ±3）
    final adjustments = [-3, -2, -1, 1, 2, 3];

    for (final adjustment in adjustments) {
      final adjustedValue = baseNumber + adjustment;
      if (adjustedValue > 0 && adjustedValue <= 13000) {
        candidates.add(
          HuangJiCandidate(
            id: 'adjust_${adjustment > 0 ? 'plus' : 'minus'}_${adjustment.abs()}',
            displayName:
                '${adjustment > 0 ? '+' : ''}$adjustment (=$adjustedValue)',
            description: '调整基础数 $adjustment，结果为 $adjustedValue',
            type: TiaoWenCandidateType.confirmation,
            value: adjustedValue,
            number: adjustedValue,
            offset: adjustment,
            stepCount: adjustment.abs(),
            isBase: false,
            isInitialSecondary: false,
            adjustmentDirection: adjustment > 0 ? 1 : -1,
            adjustmentCount: adjustment.abs(),
            isDefault: adjustment == 1,
            isEnabled: true,
          ),
        );
      }
    }

    // 添加保持原值选项
    candidates.add(
      HuangJiCandidate(
        id: 'keep_original',
        displayName: '保持原值 ($baseNumber)',
        description: '保持基础数不变',
        type: TiaoWenCandidateType.custom,
        value: baseNumber,
        number: baseNumber,
        offset: 0,
        stepCount: 0,
        isBase: true,
        isInitialSecondary: false,
        adjustmentDirection: 0,
        adjustmentCount: 0,
        isDefault: false,
        isEnabled: true,
      ),
    );

    return candidates;
  }

  /// 生成皇极取数法调整候选项
  Future<List<TiaoWenCandidate>> _generateHuangJiAdjustmentCandidates(
    int currentValue,
    Map<String, dynamic>? context,
  ) async {
    final candidates = <HuangJiCandidate>[];

    // 生成微调候选项（±1）
    final adjustments = [-1, 1];

    for (final adjustment in adjustments) {
      final adjustedValue = currentValue + adjustment;
      if (adjustedValue > 0 && adjustedValue <= 13000) {
        candidates.add(
          HuangJiCandidate(
            id: 'fine_adjust_${adjustment > 0 ? 'plus' : 'minus'}_${adjustment.abs()}',
            displayName:
                '${adjustment > 0 ? '+' : ''}$adjustment (=$adjustedValue)',
            description: '微调当前值 $adjustment，结果为 $adjustedValue',
            type: TiaoWenCandidateType.confirmation,
            value: adjustedValue,
            number: adjustedValue,
            offset: adjustment,
            stepCount: 1,
            isBase: false,
            isInitialSecondary: false,
            adjustmentDirection: adjustment > 0 ? 1 : -1,
            adjustmentCount: 1,
            isDefault: false,
            isEnabled: true,
          ),
        );
      }
    }

    // 添加确认当前值选项
    candidates.add(
      HuangJiCandidate(
        id: 'confirm_current',
        displayName: '确认当前值 ($currentValue)',
        description: '确认使用当前值进行计算',
        type: TiaoWenCandidateType.confirmation,
        value: currentValue,
        number: currentValue,
        offset: 0,
        stepCount: 0,
        isBase: false,
        isInitialSecondary: false,
        adjustmentDirection: 0,
        adjustmentCount: 0,
        isDefault: true,
        isEnabled: true,
      ),
    );

    return candidates;
  }

  /// 生成默认基础数候选项
  Future<List<TiaoWenCandidate>> _generateDefaultBaseNumberCandidates(
    Map<String, dynamic>? context,
  ) async {
    final candidates = <HuangJiCandidate>[];

    if (kDebugMode) {
      print('🏭 CandidateGenerationService: 开始生成默认基础数候选项');
      print('📊 上下文数据: $context');
    }

    // 尝试从上下文中获取计算结果
    int baseNumber = 1; // 默认基础数
    bool hasCalculationResult = false;

    if (context != null) {
      // 尝试从params中获取计算结果
      final paramsData = context['params'] as Map<String, dynamic>?;
      if (paramsData != null) {
        // 如果有初始计算结果，使用其初始条文数作为基础
        final initialNumber = paramsData['initialNumber'] as int?;
        final secondaryNumber = paramsData['secondaryNumber'] as int?;

        if (initialNumber != null) {
          baseNumber = initialNumber;
          hasCalculationResult = true;
          if (kDebugMode) {
            print('📊 从上下文获取到初始条文数: $baseNumber');
          }
        } else if (secondaryNumber != null) {
          baseNumber = secondaryNumber;
          hasCalculationResult = true;
          if (kDebugMode) {
            print('📊 从上下文获取到次条文数: $baseNumber');
          }
        }
      }
    }

    if (kDebugMode) {
      print('📊 使用基础条文数: $baseNumber');
      print('📊 是否有计算结果: $hasCalculationResult');
    }

    // 使用皇极计算策略生成候选数列表（基于步长30）
    final candidateNumbers = <int>[];

    if (hasCalculationResult) {
      // 生成基于条文数和步长30的候选项
      candidateNumbers.addAll([
        baseNumber, // 原始条文数
        baseNumber - 30, // -1步
        baseNumber + 30, // +1步
        baseNumber - 60, // -2步
        baseNumber + 60, // +2步
        baseNumber - 90, // -3步
        baseNumber + 90, // +3步
      ]);

      // 过滤掉无效的候选数（小于等于0或大于13000）
      candidateNumbers.removeWhere((num) => num <= 0 || num > 13000);

      if (kDebugMode) {
        print('📊 基于条文数$baseNumber和步长30生成的候选数: $candidateNumbers');
      }
    } else {
      // 如果没有计算结果，生成默认的候选项（1-20用于测试）
      candidateNumbers.addAll(List.generate(20, (index) => index + 1));

      if (kDebugMode) {
        print('📊 使用默认候选数列表: 1-20');
      }
    }

    // 为每个候选数生成候选项
    for (int i = 0; i < candidateNumbers.length; i++) {
      final number = candidateNumbers[i];

      // 获取对应的条文内容
      final tiaoWenData = await _tiaoWenRepository.getById(number);

      // 添加调试输出（仅前3个）
      if (kDebugMode && i < 3) {
        print('🔍 获取条文${number}: ${tiaoWenData != null ? '成功' : '失败'}');
        if (tiaoWenData != null) {
          print('   内容: ${tiaoWenData.content1}');
        }
      }

      String displayName;
      String description;

      if (tiaoWenData != null) {
        // 使用真实的条文内容
        displayName = '${number}. ${tiaoWenData.content1}';
        description =
            '条文${number}: ${tiaoWenData.content1}${tiaoWenData.content2 != null ? ' ${tiaoWenData.content2}' : ''}';
      } else {
        // 如果没有找到条文数据，使用默认格式
        displayName = '${number}. 条文${number}';
        description = '基础数 $number (条文数据未找到)';
      }

      // 计算相对于基础数的偏移
      final offset = number - baseNumber;
      final stepCount = (offset.abs() / 30).round();
      final adjustmentDirection = offset == 0 ? 0 : (offset > 0 ? 1 : -1);

      candidates.add(
        HuangJiCandidate(
          id: 'base_$number',
          displayName: displayName,
          description: description,
          type: TiaoWenCandidateType.baseNumber,
          value: number,
          number: number,
          offset: offset,
          stepCount: stepCount,
          isBase: true,
          isInitialSecondary: false,
          adjustmentDirection: adjustmentDirection,
          adjustmentCount: stepCount,
          isDefault: number == baseNumber, // 原始条文数为默认选项
          isEnabled: true,
        ),
      );
    }

    if (kDebugMode) {
      print('🏭 CandidateGenerationService: 默认基础数候选项生成完成');
      print('📊 生成的候选项数量: ${candidates.length}');
      if (candidates.isNotEmpty) {
        print('📋 第一个候选项: ${candidates.first.displayName}');
        print('📋 第一个候选项描述: ${candidates.first.description}');
        print('📋 最后一个候选项: ${candidates.last.displayName}');
        print('📋 最后一个候选项描述: ${candidates.last.description}');

        // 显示前3个候选项的详细信息
        print('📋 前3个候选项详细信息:');
        for (int i = 0; i < 3 && i < candidates.length; i++) {
          final candidate = candidates[i];
          print(
            '  ${i + 1}. ID: ${candidate.id}, 显示: ${candidate.displayName}, 偏移: ${candidate.offset}',
          );
        }
      }
    }

    return candidates;
  }

  /// 生成默认用户选择候选项
  Future<List<TiaoWenCandidate>> _generateDefaultUserSelectionCandidates(
    Map<String, dynamic> selectionHistory,
    Map<String, dynamic>? context,
  ) async {
    final candidates = <TiaoWenCandidate>[];
    final baseNumber = selectionHistory['baseNumber'] as int? ?? 1;

    // 生成简单的调整选项
    final options = [
      {'id': 'option_1', 'name': '选项一', 'value': baseNumber},
      {'id': 'option_2', 'name': '选项二', 'value': baseNumber + 1},
      {'id': 'option_3', 'name': '选项三', 'value': baseNumber + 2},
    ];

    for (final option in options) {
      candidates.add(
        TiaoWenCandidate(
          id: option['id'] as String,
          displayName: option['name'] as String,
          description: '${option['name']} (值: ${option['value']})',
          type: TiaoWenCandidateType.confirmation,
          value: option['value'],
          isDefault: option['id'] == 'option_1',
          isEnabled: true,
        ),
      );
    }

    return candidates;
  }

  /// 生成默认调整候选项
  Future<List<TiaoWenCandidate>> _generateDefaultAdjustmentCandidates(
    int currentValue,
    Map<String, dynamic>? context,
  ) async {
    final candidates = <TiaoWenCandidate>[];

    // 生成简单的调整选项
    candidates.addAll([
      TiaoWenCandidate(
        id: 'decrease',
        displayName: '减少 (${currentValue - 1})',
        description: '将当前值减少1',
        type: TiaoWenCandidateType.calculationMethod,
        value: currentValue - 1,
        isDefault: false,
        isEnabled: currentValue > 1,
      ),
      TiaoWenCandidate(
        id: 'keep',
        displayName: '保持 ($currentValue)',
        description: '保持当前值不变',
        type: TiaoWenCandidateType.calculationMethod,
        value: currentValue,
        isDefault: true,
        isEnabled: true,
      ),
      TiaoWenCandidate(
        id: 'increase',
        displayName: '增加 (${currentValue + 1})',
        description: '将当前值增加1',
        type: TiaoWenCandidateType.confirmation,
        value: currentValue + 1,
        isDefault: false,
        isEnabled: true,
      ),
    ]);

    return candidates;
  }
}
