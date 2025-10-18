import 'package:common/models/eight_chars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constant/kao_ke_constants.dart';
import 'kao_ke_session_models.dart';
import 'kao_ke_view_model.dart';
import 'widgets/ke_selection_table.dart';
import 'widgets/tiao_wen_detail_dialog.dart';
import 'widgets/gua_display_widget.dart';
import 'widgets/method_selector_widget.dart';
import 'widgets/final_result_display_widget.dart';

/// 考刻交互主页面
///
/// 整合所有Widget和ViewModel,提供完整的考刻功能交互流程
class KaoKeInteractivePage extends StatefulWidget {
  /// 用户八字
  final EightChars eightChars;

  /// 会话名称(可选)
  final String? sessionName;

  const KaoKeInteractivePage({
    super.key,
    required this.eightChars,
    this.sessionName,
  });

  @override
  State<KaoKeInteractivePage> createState() => _KaoKeInteractivePageState();
}

class _KaoKeInteractivePageState extends State<KaoKeInteractivePage> {
  @override
  void initState() {
    super.initState();
    // 页面加载时初始化会话
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final viewModel = context.read<KaoKeViewModel>();
    await viewModel.initialize(
      eightChars: widget.eightChars,
      sessionName: widget.sessionName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('八刻秘数表考刻'),
        actions: [
          // 回滚按钮
          Consumer<KaoKeViewModel>(
            builder: (context, viewModel, child) {
              if (!viewModel.canRollback) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.undo),
                tooltip: '回滚到上一阶段',
                onPressed: () => _handleRollback(viewModel),
              );
            },
          ),
        ],
      ),
      body: Consumer<KaoKeViewModel>(
        builder: (context, viewModel, child) {
          // 加载状态
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('加载中...'),
                ],
              ),
            );
          }

          // 错误状态
          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '出错了: ${viewModel.error}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      viewModel.clearError();
                      _initialize();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          // 根据当前阶段显示不同内容
          return _buildPhaseContent(viewModel);
        },
      ),
    );
  }

  Widget _buildPhaseContent(KaoKeViewModel viewModel) {
    final phase = viewModel.currentPhase;

    if (phase == null) {
      return const Center(child: Text('会话未初始化'));
    }

    switch (phase) {
      case KaoKeSessionPhase.initialized:
        return const Center(child: Text('正在初始化...'));

      case KaoKeSessionPhase.keSelectionReady:
        return _buildKeSelectionPhase(viewModel);

      case KaoKeSessionPhase.keSelected:
      case KaoKeSessionPhase.baseNumberCalculated:
        return _buildGuaAndMethodSelectionPhase(viewModel);

      case KaoKeSessionPhase.finalCalculationComplete:
        return _buildFinalResultsPhase(viewModel);
    }
  }

  /// 刻选择阶段
  Widget _buildKeSelectionPhase(KaoKeViewModel viewModel) {
    final keData = viewModel.keSelectionData;
    final birthShiChen = viewModel.birthShiChen;

    if (keData == null || birthShiChen == null) {
      return const Center(child: Text('数据加载失败'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明卡片
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '选择刻数',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '您的出生时辰是: ${birthShiChen.name}\n'
                      '请从下表中选择最符合实际情况的条文。\n'
                      '出生时辰所在行使用黑色字体高亮显示。',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 刻选择表格
            KeSelectionTable(
              keData: keData,
              birthShiChen: birthShiChen,
              onKeSelected: (keNumber) => _handleKeSelected(viewModel, keNumber),
            ),
          ],
        ),
      ),
    );
  }

  /// 卦象和方法选择阶段
  Widget _buildGuaAndMethodSelectionPhase(KaoKeViewModel viewModel) {
    final guaResult = viewModel.guaResult;
    final keSelection = viewModel.keSelection;

    if (guaResult == null || keSelection == null) {
      return const Center(child: Text('数据加载失败'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 已选择的刻信息
            _buildSelectedKeCard(keSelection),
            const SizedBox(height: 16),

            // 卦象展示
            GuaDisplayWidget(
              guaResult: guaResult,
              baseNumber: keSelection.tiaoWenNumber,
            ),
            const SizedBox(height: 16),

            // 计算方法选择
            MethodSelectorWidget(
              selectedMethods: viewModel.selectedMethods,
              onMethodToggled: (method) => _handleMethodToggled(viewModel, method),
            ),
            const SizedBox(height: 24),

            // 计算按钮
            FilledButton.icon(
              onPressed: () => _handleCalculateFinalResults(viewModel),
              icon: const Icon(Icons.calculate),
              label: const Text('计算最终条文'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 最终结果阶段
  Widget _buildFinalResultsPhase(KaoKeViewModel viewModel) {
    final finalResults = viewModel.finalResults;

    if (finalResults == null || finalResults.isEmpty) {
      return const Center(child: Text('暂无计算结果'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: FinalResultDisplayWidget(
        finalResults: finalResults,
      ),
    );
  }

  Widget _buildSelectedKeCard(KeSelectionRecord keSelection) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  '已选择的刻',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '时辰: ${keSelection.shiChen.name} ${keSelection.ke.name}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            Text(
              '条文编号: ${keSelection.tiaoWenNumber}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            Text(
              '密文: ${keSelection.cipherText}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            Text(
              '原文: ${keSelection.originalText}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Event Handlers ====================

  Future<void> _handleKeSelected(
    KaoKeViewModel viewModel,
    KaoEigthKeNumber keNumber,
  ) async {
    // 显示详情对话框
    final confirmed = await showTiaoWenDetailDialog(context, keNumber);

    if (confirmed == true && mounted) {
      // 用户确认选择
      await viewModel.selectKe(keNumber);
    }
  }

  Future<void> _handleMethodToggled(
    KaoKeViewModel viewModel,
    KaoKeCalculationMethod method,
  ) async {
    await viewModel.toggleCalculationMethod(method);
  }

  Future<void> _handleCalculateFinalResults(KaoKeViewModel viewModel) async {
    await viewModel.calculateFinalResults();
  }

  Future<void> _handleRollback(KaoKeViewModel viewModel) async {
    // 显示回滚选项对话框
    final targetPhase = await showDialog<KaoKeSessionPhase>(
      context: context,
      builder: (context) => _RollbackDialog(
        currentPhase: viewModel.currentPhase!,
      ),
    );

    if (targetPhase != null && mounted) {
      await viewModel.rollbackToPhase(targetPhase);
    }
  }
}

/// 回滚对话框
class _RollbackDialog extends StatelessWidget {
  final KaoKeSessionPhase currentPhase;

  const _RollbackDialog({
    required this.currentPhase,
  });

  @override
  Widget build(BuildContext context) {
    final availablePhases = _getAvailableRollbackPhases();

    return AlertDialog(
      title: const Text('选择回滚阶段'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: availablePhases.map((phase) {
          return ListTile(
            leading: const Icon(Icons.undo),
            title: Text(_getPhaseDisplayName(phase)),
            onTap: () => Navigator.of(context).pop(phase),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }

  List<KaoKeSessionPhase> _getAvailableRollbackPhases() {
    final phases = <KaoKeSessionPhase>[];

    switch (currentPhase) {
      case KaoKeSessionPhase.finalCalculationComplete:
        phases.add(KaoKeSessionPhase.baseNumberCalculated);
        phases.add(KaoKeSessionPhase.keSelected);
        phases.add(KaoKeSessionPhase.keSelectionReady);
        break;
      case KaoKeSessionPhase.baseNumberCalculated:
        phases.add(KaoKeSessionPhase.keSelected);
        phases.add(KaoKeSessionPhase.keSelectionReady);
        break;
      case KaoKeSessionPhase.keSelected:
        phases.add(KaoKeSessionPhase.keSelectionReady);
        break;
      default:
        break;
    }

    return phases;
  }

  String _getPhaseDisplayName(KaoKeSessionPhase phase) {
    switch (phase) {
      case KaoKeSessionPhase.initialized:
        return '初始化';
      case KaoKeSessionPhase.keSelectionReady:
        return '选择刻';
      case KaoKeSessionPhase.keSelected:
        return '已选择刻';
      case KaoKeSessionPhase.baseNumberCalculated:
        return '卦象计算完成';
      case KaoKeSessionPhase.finalCalculationComplete:
        return '最终计算完成';
    }
  }
}
