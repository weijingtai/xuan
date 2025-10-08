import 'package:common/models/eight_chars.dart';
import 'huang_ji_formula_v2.dart';
import 'huang_ji_formula_data_v2.dart';
import '../../domain/models/yuan_hui_yun_shi.dart';
import '../../domain/models/base_number_selection_record.dart';
import '../../domain/models/base_number_selection_batch.dart';
import '../../domain/models/tiao_wen_result.dart';
import './huang_ji_v2_session_models.dart';
import './huang_ji_session_manager.dart';
import './huang_ji_v2_calculation_strategy.dart';
import '../../repository/tiao_wen_repository.dart';

/// UseCase - 核心业务逻辑编排
///
/// 负责协调 Manager、Strategy 和 Repository，完成完整的业务流程
class HuangJiV2UseCase {
  final HuangJiSessionManager _sessionManager;
  final HuangJiV2CalculationStrategy _calculationStrategy;
  final TiaoWenRepository _tiaoWenRepository;

  HuangJiV2UseCase({
    required HuangJiSessionManager sessionManager,
    required HuangJiV2CalculationStrategy calculationStrategy,
    required TiaoWenRepository tiaoWenRepository,
  }) : _sessionManager = sessionManager,
       _calculationStrategy = calculationStrategy,
       _tiaoWenRepository = tiaoWenRepository;

  /// 1. 初始化 Session 并计算元会运世
  ///
  /// [eightChars] 八字
  /// [formulas] 要使用的公式列表（通常包含所有可用公式）
  /// [sessionName] 会话名称
  Future<HuangJiSession> initializeSession({
    required EightChars eightChars,
    required List<HuangJiCalculationFormula> formulas,
    String? sessionName,
  }) async {
    // 创建 Session
    var session = await _sessionManager.createSession(
      eightChars: eightChars,
      formulas: formulas,
      sessionName: sessionName,
    );

    // 计算元会运世
    final yuanHuiYunShi = _calculationStrategy.calculateYuanHuiYunShi(
      eightChars,
    );

    // 更新 Session
    session = session.copyWith(yuanHuiYunShi: yuanHuiYunShi);
    await _sessionManager.saveSession(session);

    // 推进到下一阶段
    session = await _sessionManager.advanceToPhase(
      session: session,
      targetPhase: SessionPhase.yuanHuiYunShiCalculated,
    );

    return session;
  }

  /// 2. 准备基础数选择（核心去重逻辑）
  Future<HuangJiSession> prepareBaseNumberSelection(
    HuangJiSession session,
  ) async {
    print('🔧 UseCase.prepareBaseNumberSelection 开始');
    print('🔧 session.formulas.length: ${session.formulas.length}');

    if (session.yuanHuiYunShi == null) {
      throw Exception('YuanHuiYunShi not calculated yet');
    }

    final yuanHuiYunShi = session.yuanHuiYunShi!;
    final uniqueDefinitions = <String, BaseNumberSelectionItem>{};
    final definitionToGroups = <String, List<String>>{};

    // 遍历所有公式组
    for (final formula in session.formulas) {
      print('🔧 处理公式: ${formula.name}, 组数: ${formula.groups.length}');
      for (final group in formula.groups) {
        final baseNumDef = group.baseNumberDefinition;
        print('🔧 检查组: ${group.groupId}, 基础数定义: ${baseNumDef.name}');

        // 只处理需要用户选择的定义
        if (!_requiresUserSelection(baseNumDef)) {
          print('🔧   -> 不需要用户选择，跳过');
          continue;
        }

        print('🔧   -> 需要用户选择');

        // 关键：使用 name 作为唯一标识进行去重
        final definitionId = baseNumDef.name;

        // 记录该定义被哪些组使用
        definitionToGroups
            .putIfAbsent(definitionId, () => [])
            .add(group.groupId);

        // 如果已经处理过该定义，跳过
        if (uniqueDefinitions.containsKey(definitionId)) {
          continue;
        }

        // 转换为数据层类型
        final dataBaseNumDef = _toDataDefinition(baseNumDef, yuanHuiYunShi);

        // 构建推导链
        final derivationChain = _calculationStrategy.buildDerivationChain(
          definition: dataBaseNumDef,
          yhys: yuanHuiYunShi,
        );

        // 计算初始基础数
        final initialNumber = _calculationStrategy.calculateDerivedBaseNumber(
          baseDefinition: dataBaseNumDef,
          yhys: yuanHuiYunShi,
        );

        // 生成候选数（不含条文内容）
        final config = CandidateGenerationConfig(
          initialNumber: initialNumber,
          offset: 30,
          count: 10,
          minValue: 1000,
          maxValue: 13000,
        );

        final candidatesWithoutContent = _calculationStrategy
            .generateCandidates(initialNumber: initialNumber, config: config);

        // 批量获取条文内容
        final candidateNumbers = candidatesWithoutContent
            .map((c) => c.number)
            .toList();
        final tiaoWenContentMap = await _tiaoWenRepository
            .getTiaoWenContentByNumbers(candidateNumbers);

        // 补充条文内容
        final candidatesWithContent = candidatesWithoutContent.map((candidate) {
          final content = tiaoWenContentMap[candidate.number] ?? '（条文缺失）';
          return candidate.copyWith(tiaoWenContent: content);
        }).toList();

        // 创建选择项
        final selectionItem = BaseNumberSelectionItem(
          definitionId: definitionId,
          name: baseNumDef.name,
          description: baseNumDef.description,
          derivationChain: derivationChain,
          candidates: candidatesWithContent,
          relatedGroupIds: definitionToGroups[definitionId]!,
        );

        uniqueDefinitions[definitionId] = selectionItem;
      }
    }

    print('🔧 去重后的唯一定义数: ${uniqueDefinitions.length}');

    // 创建批量选择对象
    final batch = BaseNumberSelectionBatch(
      items: uniqueDefinitions.values.toList(),
      definitionToGroupsMap: definitionToGroups,
    );

    // 初始化 BaseNumberSelectionRecord
    final selectionRecords = <String, BaseNumberSelectionRecord>{};
    for (final item in batch.items) {
      selectionRecords[item.definitionId] = BaseNumberSelectionRecord(
        baseNumberDefinitionId: item.definitionId,
        name: item.name,
        derivationChain: item.derivationChain,
        candidateConfig: CandidateGenerationConfig(
          initialNumber: item.derivationChain.finalValue,
          offset: 30,
          count: 10,
          minValue: 1000,
          maxValue: 13000,
        ),
        candidates: item.candidates,
        selectedCandidate: null,
        status: SelectionStatus.pending,
        relatedGroupIds: item.relatedGroupIds,
      );
    }

    // 更新 Session
    var updatedSession = session.copyWith(
      baseNumberSelections: selectionRecords,
    );
    await _sessionManager.saveSession(updatedSession);

    // 推进到下一阶段
    updatedSession = await _sessionManager.advanceToPhase(
      session: updatedSession,
      targetPhase: SessionPhase.baseNumberSelectionReady,
    );

    return updatedSession;
  }

  /// 3. 提交用户的基础数选择
  Future<HuangJiSession> submitBaseNumberSelections({
    required HuangJiSession session,
    required Map<String, int>
    selections, // definitionId -> selectedCandidateNumber
  }) async {
    if (session.currentPhase != SessionPhase.baseNumberSelectionReady) {
      throw Exception('Session is not ready for base number selection');
    }

    final updatedSelections = <String, BaseNumberSelectionRecord>{};

    // 验证并更新每个选择
    for (final entry in selections.entries) {
      final definitionId = entry.key;
      final selectedNumber = entry.value;

      final record = session.baseNumberSelections[definitionId];
      if (record == null) {
        throw Exception('Unknown definition ID: $definitionId');
      }

      // 查找选中的候选
      final selectedCandidate = record.candidates.firstWhere(
        (c) => c.number == selectedNumber,
        orElse: () => throw Exception(
          'Invalid candidate number $selectedNumber for definition $definitionId',
        ),
      );

      // 更新记录
      updatedSelections[definitionId] = record.copyWith(
        selectedCandidate: selectedCandidate,
        status: SelectionStatus.completed,
      );
    }

    // 检查是否所有必需的选择都已完成
    for (final entry in session.baseNumberSelections.entries) {
      if (!updatedSelections.containsKey(entry.key)) {
        throw Exception('Missing selection for: ${entry.value.name}');
      }
    }

    // 更新 Session
    var updatedSession = session.copyWith(
      baseNumberSelections: updatedSelections,
    );
    await _sessionManager.saveSession(updatedSession);

    // 推进到下一阶段
    updatedSession = await _sessionManager.advanceToPhase(
      session: updatedSession,
      targetPhase: SessionPhase.baseNumberSelected,
    );

    return updatedSession;
  }

  /// 4. 计算最终条文列表
  Future<HuangJiSession> calculateFinalTiaoWenList(
    HuangJiSession session,
  ) async {
    if (session.currentPhase != SessionPhase.baseNumberSelected) {
      throw Exception('Base numbers not selected yet');
    }

    print('📊 开始计算最终条文列表');
    print('📊 公式数量: ${session.formulas.length}');

    final results = <TiaoWenResult>[];

    // 遍历所有公式组
    for (final formula in session.formulas) {
      print('📊 处理公式: ${formula.name}');
      print('📊   组数量: ${formula.groups.length}');

      for (final group in formula.groups) {
        print('📊   处理组: ${group.groupId}');

        // 获取该组使用的基础数定义
        final baseNumDef = group.baseNumberDefinition;
        final definitionId = baseNumDef.name;

        // 从用户选择中获取基础数
        // V2架构中，所有基础数都需要用户选择
        final selectionRecord = session.baseNumberSelections[definitionId];
        if (selectionRecord?.selectedCandidate == null) {
          throw Exception('No selection found for: ${baseNumDef.name}');
        }
        final baseNumber = selectionRecord!.selectedCandidate!.number;
        print('📊     使用基础数: $definitionId = $baseNumber');
        print('📊     该组的条文公式数: ${group.formulas.length}');

        // 遍历该组的所有条文公式
        for (final tiaoWenFormula in group.formulas) {
          // 转换为数据层公式
          final dataFormula = tiaoWenFormula.toData(session.yuanHuiYunShi!);

          // 计算条文数
          final tiaoWenNumber = _calculationStrategy.calculateTiaoWenNumber(
            baseNumber: baseNumber,
            formula: dataFormula,
          );

          print('📊       条文: ${tiaoWenFormula.name} → $tiaoWenNumber');

          // 获取条文内容
          final tiaoWenContent = await _tiaoWenRepository
              .getTiaoWenContentByNumber(tiaoWenNumber);

          // 创建结果
          final result = TiaoWenResult(
            groupId: group.groupId,
            formulaName: tiaoWenFormula.name,
            baseNumber: baseNumber,
            tiaoWenNumber: tiaoWenNumber,
            tiaoWenContent: tiaoWenContent ?? '（条文缺失）',
            calculationDetail: _buildCalculationDetail(
              baseNumber: baseNumber,
              formula: tiaoWenFormula,
              tiaoWenNumber: tiaoWenNumber,
            ),
          );

          results.add(result);
        }
      }
    }

    print('📊 计算完成，共生成 ${results.length} 条结果');

    // 更新 Session
    var updatedSession = session.copyWith(
      finalTiaoWenList: results,
      status: HuangJiSessionStatus.completed,
    );
    await _sessionManager.saveSession(updatedSession);

    // 推进到最终阶段
    updatedSession = await _sessionManager.advanceToPhase(
      session: updatedSession,
      targetPhase: SessionPhase.finalCalculationComplete,
    );

    return updatedSession;
  }

  /// 5. 回滚到指定阶段
  Future<HuangJiSession> rollbackToPhase({
    required HuangJiSession session,
    required SessionPhase targetPhase,
  }) async {
    // 查找目标阶段的快照
    final targetSnapshot = session.phaseHistory.lastWhere(
      (snapshot) => snapshot.phase == targetPhase,
      orElse: () =>
          throw Exception('No snapshot found for phase: $targetPhase'),
    );

    // 使用 SessionManager 回滚
    return await _sessionManager.rollbackToSnapshot(
      session: session,
      snapshotId: targetSnapshot.snapshotId,
    );
  }

  /// 辅助方法：判断是否需要用户选择
  ///
  /// V2架构的选择逻辑:
  /// - PredefinedBaseNumber: 需要选择(虽然有预定义值，但仍提供候选列表)
  /// - DerivedBaseNumber: 需要选择(用户从候选数列表中选择)
  /// - SelectableBaseNumber: 需要选择
  ///
  /// 所有类型的基础数都需要用户选择，以符合传统铁板神数的使用方式
  bool _requiresUserSelection(BaseNumberDefinition definition) {
    print(
      '🔍 _requiresUserSelection: ${definition.name}, 类型: ${definition.runtimeType}',
    );

    // V2架构: 所有类型都需要用户选择
    // PredefinedBaseNumber 也需要选择(提供以预定义值为中心的候选列表)
    if (definition is PredefinedBaseNumber) {
      print('🔍   -> PredefinedBaseNumber, 返回 true (V2架构提供候选列表)');
      return true;
    }

    // DerivedBaseNumber 总是需要选择
    if (definition is DerivedBaseNumber) {
      print('🔍   -> DerivedBaseNumber, 返回 true');
      return true;
    }

    // SelectableBaseNumber 总是需要选择
    if (definition is SelectableBaseNumber) {
      print('🔍   -> SelectableBaseNumber, 返回 true');
      return true;
    }

    print('🔍   -> 未知类型, 返回 false');
    return false;
  }

  /// 辅助方法：构建计算详情
  String _buildCalculationDetail({
    required int baseNumber,
    required TiaoWenFormula formula,
    required int tiaoWenNumber,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('基础数: $baseNumber');
    buffer.writeln('公式: ${formula.name}');
    buffer.writeln('描述: ${formula.description}');
    buffer.writeln('结果: $tiaoWenNumber');
    return buffer.toString();
  }

  /// 获取批量选择数据（用于UI展示）
  BaseNumberSelectionBatch? getSelectionBatch(HuangJiSession session) {
    if (session.baseNumberSelections.isEmpty) {
      return null;
    }

    final items = session.baseNumberSelections.values.map((record) {
      return BaseNumberSelectionItem(
        definitionId: record.baseNumberDefinitionId,
        name: record.name,
        description: record.derivationChain.finalDefinition.description,
        derivationChain: record.derivationChain,
        candidates: record.candidates,
        relatedGroupIds: record.relatedGroupIds,
      );
    }).toList();

    final definitionToGroupsMap = <String, List<String>>{};
    for (final record in session.baseNumberSelections.values) {
      definitionToGroupsMap[record.baseNumberDefinitionId] =
          record.relatedGroupIds;
    }

    return BaseNumberSelectionBatch(
      items: items,
      definitionToGroupsMap: definitionToGroupsMap,
    );
  }

  /// 辅助方法：转换为数据层定义
  DataBaseNumberDefinition _toDataDefinition(
    BaseNumberDefinition definition,
    YuanHuiYunShi yhys,
  ) {
    if (definition is PredefinedBaseNumber) {
      return definition.toData(yhys);
    } else if (definition is DerivedBaseNumber) {
      return definition.toData(yhys);
    } else if (definition is SelectableBaseNumber) {
      return definition.toData(yhys);
    } else {
      throw Exception(
        'Unknown BaseNumberDefinition type: ${definition.runtimeType}',
      );
    }
  }
}
