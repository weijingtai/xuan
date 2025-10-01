/// 多基础数选择服务
///
/// 负责管理多个基础数的同时选择逻辑
library;

import 'package:flutter/foundation.dart';
import '../../domain/models/multi_base_number_selection.dart';
import '../../domain/models/huang_ji_number.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/models/yuan_hui_yun_shi.dart';
import 'candidate_generation_service.dart';

/// 多基础数选择服务
class MultiBaseNumberSelectionService {
  final CandidateGenerationService _candidateService;

  MultiBaseNumberSelectionService(this._candidateService);

  /// 获取候选项生成服务
  CandidateGenerationService get _candidateGenerationService =>
      _candidateService;

  /// 获取候选项生成服务
  // CandidateGenerationService get _candidateGenerationService => _candidateService;

  // /// 获取候选项生成服务
  // CandidateGenerationService get _candidateGenerationService => _candidateService;

  /// 创建多基础数选择管理器
  MultiBaseNumberSelectionManager createSelectionManager({
    required List<BaseNumberSelectionType> requiredTypes,
    List<BaseNumberSelectionType> optionalTypes = const [],
  }) {
    if (kDebugMode) {
      print('🚀 创建多基础数选择管理器');
      print('📊 必需类型: ${requiredTypes.map((t) => t.displayName).join(', ')}');
      print('📊 可选类型: ${optionalTypes.map((t) => t.displayName).join(', ')}');
    }

    return MultiBaseNumberSelectionManager.create(
      requiredTypes: requiredTypes,
      optionalTypes: optionalTypes,
    );
  }

  /// 初始化主基础数的候选项
  Future<MultiBaseNumberSelectionManager> initializePrimarySelections(
    MultiBaseNumberSelectionManager manager,
    YuanHuiYunShi yuanHuiYunShi,
  ) async {
    if (kDebugMode) {
      print('🔄 初始化主基础数候选项');
    }

    MultiBaseNumberSelectionManager updatedManager = manager;

    // 为每个主基础数生成候选项
    for (final selection in manager.primarySelections) {
      try {
        final candidates = await _generatePrimaryCandidates(
          selection.type,
          yuanHuiYunShi,
        );

        final updatedSelection = selection.copyWith(
          candidates: candidates,
          status: BaseNumberSelectionStatus.ready,
        );

        updatedManager = updatedManager.updateSelection(
          selection.type,
          updatedSelection,
        );

        if (kDebugMode) {
          print(
            '✅ ${selection.type.displayName} 候选项生成完成: ${candidates.length}个',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ ${selection.type.displayName} 候选项生成失败: $e');
        }

        final errorSelection = selection.copyWith(
          status: BaseNumberSelectionStatus.error,
          errorMessage: '候选项生成失败: $e',
        );

        updatedManager = updatedManager.updateSelection(
          selection.type,
          errorSelection,
        );
      }
    }

    return updatedManager;
  }

  /// 处理主基础数选择
  Future<MultiBaseNumberSelectionManager> selectPrimaryNumber(
    MultiBaseNumberSelectionManager manager,
    BaseNumberSelectionType type,
    TiaoWenCandidate selectedCandidate,
  ) async {
    if (kDebugMode) {
      print('🎯 选择主基础数: ${type.displayName}');
      print('📊 选择的候选项: ${selectedCandidate.description}');
    }

    final selection = manager.getSelection(type);
    if (selection == null) {
      throw ArgumentError('选择类型不存在: $type');
    }

    // 创建基础数对象
    final baseNumber = HuangJiBaseNumber(
      name: type.displayName,
      description: selectedCandidate.description,
      orinialNumber: selectedCandidate.value,
      baseNumberType: _getBaseNumberType(type),
      numberSource: _getNumberSource(type),
    );

    // 更新选择状态
    final updatedSelection = selection.copyWith(
      selectedNumber: baseNumber,
      status: BaseNumberSelectionStatus.completed,
    );

    var updatedManager = manager.updateSelection(type, updatedSelection);

    // 如果主基础数阶段完成，初始化派生基础数
    if (updatedManager.isPrimaryPhaseCompleted) {
      updatedManager = await _initializeDerivedSelections(updatedManager);
    }

    return updatedManager;
  }

  /// 处理派生基础数选择
  Future<MultiBaseNumberSelectionManager> selectDerivedNumber(
    MultiBaseNumberSelectionManager manager,
    BaseNumberSelectionType type,
    TiaoWenCandidate selectedCandidate,
  ) async {
    if (kDebugMode) {
      print('🎯 选择派生基础数: ${type.displayName}');
      print('📊 选择的候选项: ${selectedCandidate.description}');
    }

    final selection = manager.getSelection(type);
    if (selection == null) {
      throw ArgumentError('选择类型不存在: $type');
    }

    // 创建基础数对象
    final baseNumber = HuangJiBaseNumber(
      name: type.displayName, // 使用选择类型的显示名称
      description: selectedCandidate.description, // 使用候选项的描述
      orinialNumber: selectedCandidate.value, // 使用候选项的数值
      baseNumberType: _getBaseNumberType(type), // 通过辅助方法获取基础数类型
      numberSource: _getNumberSource(type), // 通过辅助方法获取数字来源
    );

    // 更新选择状态
    final updatedSelection = selection.copyWith(
      selectedNumber: baseNumber,
      status: BaseNumberSelectionStatus.completed,
    );

    return manager.updateSelection(type, updatedSelection);
  }

  /// 生成主基础数候选项
  Future<List<TiaoWenCandidate>> _generatePrimaryCandidates(
    BaseNumberSelectionType type,
    YuanHuiYunShi yuanHuiYunShi,
  ) async {
    switch (type) {
      case BaseNumberSelectionType.yuanHui:
        return _generateYuanHuiCandidates(yuanHuiYunShi);
      case BaseNumberSelectionType.yunShi:
        return _generateYunShiCandidates(yuanHuiYunShi);
      default:
        throw ArgumentError('不支持的主基础数类型: $type');
    }
  }

  /// 生成元会基础数候选项
  Future<List<TiaoWenCandidate>> _generateYuanHuiCandidates(
    YuanHuiYunShi yuanHuiYunShi,
  ) async {
    final baseNumber = yuanHuiYunShi.yuanHuiMergeNumber.number;
    return _generateCandidatesAroundNumber(baseNumber, '元会基础数');
  }

  /// 生成运世基础数候选项
  Future<List<TiaoWenCandidate>> _generateYunShiCandidates(
    YuanHuiYunShi yuanHuiYunShi,
  ) async {
    final baseNumber = yuanHuiYunShi.yunShiMergeNumber.number;
    return _generateCandidatesAroundNumber(baseNumber, '运世基础数');
  }

  /// 在指定数字周围生成候选项
  Future<List<TiaoWenCandidate>> _generateCandidatesAroundNumber(
    int baseNumber,
    String prefix,
  ) async {
    final List<TiaoWenCandidate> candidates = [];

    // 生成 ±30, ±60, ±90 的候选项
    final adjustments = [-90, -60, -30, 0, 30, 60, 90];

    for (final adjustment in adjustments) {
      final number = baseNumber + adjustment;
      final adjustmentText = adjustment == 0
          ? ''
          : adjustment > 0
          ? '+$adjustment'
          : '$adjustment';

      // 尝试获取条文内容
      String displayName;
      String description;

      try {
        final tiaoWen = await _candidateGenerationService.tiaoWenRepository
            .getById(number);
        if (tiaoWen != null) {
          // 使用真实的条文内容
          displayName = '条文$number: ${tiaoWen.content1}';
          description = adjustment == 0
              ? '原始$prefix (条文$number)'
              : '$prefix 调整$adjustmentText (条文$number)';

          // 如果有第二部分内容，添加到描述中
          if (tiaoWen.content2 != null && tiaoWen.content2!.isNotEmpty) {
            description += '\n${tiaoWen.content2}';
          }
        } else {
          // 如果没有找到条文数据，使用默认格式
          displayName = '条文$number (未找到内容)';
          description = adjustment == 0
              ? '原始$prefix (条文$number)'
              : '$prefix 调整$adjustmentText (条文$number)';
        }
      } catch (e) {
        // 如果获取条文失败，使用默认格式
        displayName = '条文$number (获取失败)';
        description = adjustment == 0
            ? '原始$prefix (条文$number)'
            : '$prefix 调整$adjustmentText (条文$number)';
      }

      candidates.add(
        TiaoWenCandidate(
          id: '${prefix}_${number}',
          displayName: displayName,
          description: description,
          isEnabled: true,
          metadata: {
            'baseNumber': baseNumber,
            'adjustment': adjustment,
            'type': prefix,
            'tiaoWenNumber': number,
          },
          type: TiaoWenCandidateType.baseNumber,
          value: number,
        ),
      );
    }

    return candidates;
  }

  /// 初始化派生基础数选择
  Future<MultiBaseNumberSelectionManager> _initializeDerivedSelections(
    MultiBaseNumberSelectionManager manager,
  ) async {
    if (kDebugMode) {
      print('🔄 初始化派生基础数选择');
    }

    MultiBaseNumberSelectionManager updatedManager = manager;

    for (final selection in manager.derivedSelections) {
      try {
        // 检查依赖是否满足
        final parentType = selection.dependsOn;
        if (parentType != null) {
          final parentSelection = manager.getSelection(parentType);
          if (parentSelection?.isCompleted != true) {
            // 依赖未满足，设置为等待状态
            final waitingSelection = selection.copyWith(
              status: BaseNumberSelectionStatus.waitingForDependency,
            );
            updatedManager = updatedManager.updateSelection(
              selection.type,
              waitingSelection,
            );
            continue;
          }

          // 基于父基础数生成候选项
          final parentNumber = parentSelection!.selectedNumber!.orinialNumber;
          final candidates = await _generateDerivedCandidates(
            selection.type,
            parentNumber,
          );

          final readySelection = selection.copyWith(
            candidates: candidates,
            status: BaseNumberSelectionStatus.ready,
          );

          updatedManager = updatedManager.updateSelection(
            selection.type,
            readySelection,
          );

          if (kDebugMode) {
            print(
              '✅ ${selection.type.displayName} 候选项生成完成: ${candidates.length}个',
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ ${selection.type.displayName} 候选项生成失败: $e');
        }

        final errorSelection = selection.copyWith(
          status: BaseNumberSelectionStatus.error,
          errorMessage: '候选项生成失败: $e',
        );

        updatedManager = updatedManager.updateSelection(
          selection.type,
          errorSelection,
        );
      }
    }

    return updatedManager;
  }

  /// 生成派生基础数候选项
  Future<List<TiaoWenCandidate>> _generateDerivedCandidates(
    BaseNumberSelectionType type,
    int parentNumber,
  ) async {
    final prefix = type.displayName;
    return _generateCandidatesAroundNumber(parentNumber, prefix);
  }

  /// 获取基础数类型
  BaseNumberType _getBaseNumberType(BaseNumberSelectionType selectionType) {
    switch (selectionType) {
      case BaseNumberSelectionType.yuanHui:
      case BaseNumberSelectionType.yuanHuiOne:
      case BaseNumberSelectionType.yuanHuiTwo:
        return BaseNumberType.tiaoWen;
      case BaseNumberSelectionType.yunShi:
      case BaseNumberSelectionType.yunShiOne:
      case BaseNumberSelectionType.yunShiTwo:
        return BaseNumberType.tiaoWen;
    }
  }

  /// 获取数字来源
  NumberSource _getNumberSource(BaseNumberSelectionType selectionType) {
    switch (selectionType) {
      case BaseNumberSelectionType.yuanHui:
      case BaseNumberSelectionType.yuanHuiOne:
      case BaseNumberSelectionType.yuanHuiTwo:
        return NumberSource.yuanHui;
      case BaseNumberSelectionType.yunShi:
      case BaseNumberSelectionType.yunShiOne:
      case BaseNumberSelectionType.yunShiTwo:
        return NumberSource.yunShi;
    }
  }
}
