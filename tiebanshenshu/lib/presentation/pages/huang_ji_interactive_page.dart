/// 皇极取数法交互式页面
///
/// 提供皇极取数法的交互式计算界面
library;

import 'package:common/dev_constant.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/four_zhu.dart';
import '../../domain/models/huang_ji_interactive_step.dart';
import '../../domain/models/interactive_strategy_config.dart';
import '../../domain/models/multi_base_number_selection.dart';
import '../viewmodels/huang_ji_interactive_view_model.dart';
import '../widgets/candidate_selection_widget.dart';
import '../widgets/huang_ji_interactive_widget.dart';
import '../widgets/huang_ji_session_header.dart';
import '../widgets/huang_ji_step_indicator.dart';
import '../widgets/huang_ji_result_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/multi_base_number_selection_widget.dart';

/// 皇极取数法交互式页面
class HuangJiInteractivePage extends StatefulWidget {
  /// 四柱信息
  final EightChars? eightChars;

  /// 可选的策略配置
  final InteractiveStrategyConfig? config;

  const HuangJiInteractivePage({super.key, this.eightChars, this.config});

  @override
  State<HuangJiInteractivePage> createState() => _HuangJiInteractivePageState();
}

class _HuangJiInteractivePageState extends State<HuangJiInteractivePage> {
  @override
  void initState() {
    super.initState();

    // 页面加载后自动启动会话
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSession();
    });
  }

  /// 启动交互式会话
  void _startSession() {
    context.read<HuangJiInteractiveViewModel>().startSession(
      widget.eightChars ?? DevConstant.dev_usa.standeredChineseInfo.eightChars,
      config: widget.config,
    );
  }

  /// 选择候选项
  void _selectCandidate(candidate) {
    context.read<HuangJiInteractiveViewModel>().selectCandidate(candidate);
  }

  /// 撤销操作
  void _undo() {
    context.read<HuangJiInteractiveViewModel>().undo();
  }

  /// 跳转到指定步骤
  void _jumpToStep(int stepIndex) {
    context.read<HuangJiInteractiveViewModel>().jumpToStep(stepIndex);
  }

  /// 重新开始
  void _restart() {
    context.read<HuangJiInteractiveViewModel>().reset();
    _startSession();
  }

  /// 构建主要内容
  Widget _buildMainContent(HuangJiInteractiveViewModel provider) {
    if (kDebugMode) {
      print('🎨 HuangJiInteractivePage: 构建主要内容');
      print('🔍 UI状态检查:');
      print('   - isLoading: ${provider.isLoading}');
      print('   - hasError: ${provider.hasError}');
      print('   - isCompleted: ${provider.isCompleted}');
      print('   - needsUserSelection: ${provider.needsUserSelection}');
      print(
        '   - currentCandidates.isNotEmpty: ${provider.currentCandidates.isNotEmpty}',
      );
      print('   - hasSession: ${provider.hasSession}');
      print('   - currentStep: ${provider.currentStep}');
      print('   - state: ${provider.state}');
    }

    if (provider.isLoading) {
      if (kDebugMode) {
        print('🎨 HuangJiInteractivePage: 显示加载内容');
      }
      return _buildLoadingContent(provider);
    }

    if (provider.hasError) {
      if (kDebugMode) {
        print('🎨 HuangJiInteractivePage: 显示错误内容');
      }
      return _buildErrorContent(provider);
    }

    if (provider.isCompleted) {
      if (kDebugMode) {
        print('🎨 HuangJiInteractivePage: 显示完成内容');
      }
      return _buildCompletedContent(provider);
    }

    if ((provider.needsUserSelection ||
            provider.currentStep == HuangJiInteractiveStep.initialization) &&
        provider.currentCandidates.isNotEmpty) {
      if (kDebugMode) {
        print('🎨 HuangJiInteractivePage: 显示交互内容');
      }
      return Consumer<HuangJiInteractiveViewModel>(
        // builder 有三个参数: context, viewModel 实例, 和一个可选的 child
        builder: (context, viewModel, child) {
          // 当 viewModel.notifyListeners() 被调用时，只有这个 Text Widget 会被重建
          return _buildInteractiveContent(viewModel);
        },
      );

      // return context.read<HuangJiInteractiveViewModel>().selectionManager
    }

    // 默认显示等待状态
    if (kDebugMode) {
      print('🎨 HuangJiInteractivePage: 显示等待内容（默认状态）');
      print('⚠️ 这可能是问题所在 - 所有条件都不满足');
    }
    return _buildWaitingContent(provider);
  }

  /// 构建加载内容
  Widget _buildLoadingContent(HuangJiInteractiveViewModel provider) {
    String message = '处理中...';

    if (provider.isStartingSession) {
      message = '正在启动皇极取数法会话...';
    } else if (provider.isLoadingCandidates) {
      message = '正在生成基础数选项...';
    } else if (provider.isProcessingSelection) {
      message = '正在处理您的选择...';
    } else if (provider.isCalculating) {
      message = '正在计算最终条文数...';
    }

    return Center(child: LargeLoadingWidget(message: message));
  }

  /// 构建错误内容
  Widget _buildErrorContent(HuangJiInteractiveViewModel provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.0,
              color: Theme.of(context).colorScheme.error,
            ),

            const SizedBox(height: 16.0),

            Text(
              '计算出现错误',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),

            const SizedBox(height: 8.0),

            Text(
              provider.getUserFriendlyErrorMessage(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24.0),

            ElevatedButton.icon(
              onPressed: _restart,
              icon: const Icon(Icons.refresh),
              label: const Text('重新开始'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建完成内容
  Widget _buildCompletedContent(HuangJiInteractiveViewModel provider) {
    return HuangJiResultWidget(provider: provider);
  }

  /// 构建交互内容
  Widget _buildInteractiveContent(HuangJiInteractiveViewModel provider) {
    print("??????");
    final manager = provider.selectionManager;
    print("??????");
    if (manager == null) {
      // 当没有 manager 时，直接使用 CandidateSelectionWidget
      return CandidateSelectionWidget(
        candidates: provider.currentCandidates,
        onCandidateSelected: _selectCandidate,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MultiBaseNumberSelectionWidget(
                    manager: manager,
                    onSelectionChanged: (type, candidate) {
                      _selectCandidate(candidate);
                    },
                    showDetails: true,
                    enableAnimations: true,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          if (provider.canUndo) ...[
            const SizedBox(height: 16.0),
            _buildActionButtons(provider),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('皇极取数法'),
        elevation: 0,
        actions: [
          // 重新开始按钮
          Consumer<HuangJiInteractiveViewModel>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: provider.hasSession && !provider.isLoading
                    ? _restart
                    : null,
                icon: const Icon(Icons.refresh),
                tooltip: '重新开始',
              );
            },
          ),
        ],
      ),
      body: Consumer<HuangJiInteractiveViewModel>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // 会话头部信息
              if (provider.hasSession) HuangJiSessionHeader(provider: provider),

              // 步骤指示器
              if (provider.hasSession) HuangJiStepIndicator(provider: provider),

              // 主要内容区域
              Expanded(child: _buildMainContent(provider)),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// 底部进度与操作栏
  Widget? _buildBottomBar(BuildContext context) {
    return Consumer<HuangJiInteractiveViewModel>(
      builder: (context, provider, child) {
        if (!provider.hasSession) return const SizedBox.shrink();

        final theme = Theme.of(context);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // 进度信息
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.isCompleted ? '计算完成' : '当前进度',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 4),

                      if (!provider.isCompleted) ...[
                        LinearProgressIndicator(
                          value: _getBottomProgressValue(provider.currentStep),
                          backgroundColor: theme.colorScheme.outline
                              .withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '${provider.getCurrentStepDisplayText()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '可以查看结果',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // 操作按钮
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: provider.isLoading ? null : _undo,
                      child: const Text('撤销'),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton(
                      onPressed: provider.isLoading ? null : _restart,
                      child: const Text('重新开始'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 计算底部进度值
  double _getBottomProgressValue(HuangJiInteractiveStep step) {
    switch (step) {
      case HuangJiInteractiveStep.initialization:
        return 0.15;
      case HuangJiInteractiveStep.secondaryCalculation:
        return 0.35;
      case HuangJiInteractiveStep.userSelection:
        return 0.6;
      case HuangJiInteractiveStep.finalCalculation:
        return 0.85;
      case HuangJiInteractiveStep.completed:
        return 1.0;
    }
  }

  /// 构建等待内容
  Widget _buildWaitingContent(HuangJiInteractiveViewModel provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 64.0,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 16.0),

            Text('准备中', style: Theme.of(context).textTheme.headlineSmall),

            const SizedBox(height: 8.0),

            Text(
              '正在准备皇极取数法计算...',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建当前步骤信息
  Widget _buildCurrentStepInfo(HuangJiInteractiveViewModel provider) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20.0,
              ),

              const SizedBox(width: 8.0),

              Text(
                provider.getCurrentStepDisplayText(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8.0),

          Text(
            _getStepDescription(provider),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),

          // 显示计算信息
          if (provider.initialNumber != null ||
              provider.secondaryNumber != null) ...[
            const SizedBox(height: 12.0),
            _buildCalculationInfo(provider, theme),
          ],
        ],
      ),
    );
  }

  /// 构建计算信息
  Widget _buildCalculationInfo(
    HuangJiInteractiveViewModel provider,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.dividerColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.initialNumber != null) ...[
            _buildInfoRow('初刻数', provider.initialNumber.toString(), theme),
          ],

          if (provider.secondaryNumber != null) ...[
            if (provider.initialNumber != null) const SizedBox(height: 4.0),
            _buildInfoRow('次条文数', provider.secondaryNumber.toString(), theme),
          ],

          if (provider.selectedBaseNumber != null) ...[
            const SizedBox(height: 4.0),
            _buildInfoRow(
              '选择的基础数',
              provider.selectedBaseNumber.toString(),
              theme,
            ),
          ],
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),

        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(HuangJiInteractiveViewModel provider) {
    return Row(
      children: [
        // 撤销按钮
        if (provider.canUndo)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: provider.isLoading ? null : _undo,
              icon: const Icon(Icons.undo),
              label: const Text('撤销'),
            ),
          ),
      ],
    );
  }

  /// 获取步骤描述
  String _getStepDescription(HuangJiInteractiveViewModel provider) {
    switch (provider.currentStep) {
      case HuangJiInteractiveStep.initialization:
        return '正在初始化皇极取数法计算，准备四柱数据...';
      case HuangJiInteractiveStep.secondaryCalculation:
        return '已完成初刻数计算，正在计算次条文数...';
      case HuangJiInteractiveStep.userSelection:
        return '请从下方选择一个基础数作为最终计算的依据。您可以选择次条文数或调整后的数值。';
      case HuangJiInteractiveStep.finalCalculation:
        return '正在基于您选择的基础数计算最终的条文数列表...';
      case HuangJiInteractiveStep.completed:
        return '皇极取数法计算已完成，您可以查看最终的条文结果。';
    }
  }
}
