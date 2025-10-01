/// 多基础数选择页面
///
/// 提供同时选择多个基础数的用户界面
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/huang_ji_number.dart';
import '../../domain/models/multi_base_number_selection.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/models/yuan_hui_yun_shi.dart';
import '../viewmodels/multi_base_number_selection_view_model.dart';
import '../widgets/multi_base_number_selection_widget.dart';

/// 多基础数选择页面
class MultiBaseNumberSelectionPage extends StatefulWidget {
  /// 元会运世数据
  final YuanHuiYunShi yuanHuiYunShi;

  /// 必需的选择类型
  final List<BaseNumberSelectionType> requiredTypes;

  /// 可选的选择类型
  final List<BaseNumberSelectionType> optionalTypes;

  /// 完成回调
  final Function(Map<BaseNumberSelectionType, HuangJiBaseNumber>)? onCompleted;

  /// 取消回调
  final VoidCallback? onCancelled;

  const MultiBaseNumberSelectionPage({
    super.key,
    required this.yuanHuiYunShi,
    required this.requiredTypes,
    this.optionalTypes = const [],
    this.onCompleted,
    this.onCancelled,
  });

  @override
  State<MultiBaseNumberSelectionPage> createState() =>
      _MultiBaseNumberSelectionPageState();
}

class _MultiBaseNumberSelectionPageState
    extends State<MultiBaseNumberSelectionPage> {
  late MultiBaseNumberSelectionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<MultiBaseNumberSelectionViewModel>();

    // 初始化选择
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelection();
    });
  }

  Future<void> _initializeSelection() async {
    await _viewModel.initialize(
      requiredTypes: widget.requiredTypes,
      optionalTypes: widget.optionalTypes,
      yuanHuiYunShi: widget.yuanHuiYunShi,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: const Text('多基础数选择'),
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundColor: theme.colorScheme.onPrimaryContainer,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          _handleCancel(context);
        },
      ),
      actions: [
        Consumer<MultiBaseNumberSelectionViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.hasError) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  viewModel.reinitialize();
                },
                tooltip: '重新初始化',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// 构建主体内容
  Widget _buildBody(BuildContext context) {
    return Consumer<MultiBaseNumberSelectionViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isInitializing) {
          return _buildLoadingContent(context);
        }

        if (viewModel.hasError) {
          return _buildErrorContent(context, viewModel);
        }

        if (viewModel.selectionManager == null) {
          return _buildEmptyContent(context);
        }

        return _buildSelectionContent(context, viewModel);
      },
    );
  }

  /// 构建加载内容
  Widget _buildLoadingContent(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            '正在初始化多基础数选择...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误内容
  Widget _buildErrorContent(
    BuildContext context,
    MultiBaseNumberSelectionViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),

            const SizedBox(height: 16),

            Text(
              '初始化失败',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              viewModel.errorMessage ?? '发生未知错误',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _handleCancel(context);
                  },
                  child: const Text('返回'),
                ),

                const SizedBox(width: 16),

                ElevatedButton(
                  onPressed: () {
                    viewModel.reinitialize();
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空内容
  Widget _buildEmptyContent(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),

          const SizedBox(height: 16),

          Text(
            '暂无选择内容',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建选择内容
  Widget _buildSelectionContent(
    BuildContext context,
    MultiBaseNumberSelectionViewModel viewModel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 页面说明
          _buildPageDescription(context),

          const SizedBox(height: 24),

          // 多基础数选择组件
          MultiBaseNumberSelectionWidget(
            manager: viewModel.selectionManager!,
            onSelectionChanged: (type, candidate) {
              _handleSelection(viewModel, type, candidate);
            },
            showDetails: true,
            enableAnimations: true,
          ),

          // 底部间距
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  /// 构建页面说明
  Widget _buildPageDescription(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),

              const SizedBox(width: 8),

              Text(
                '多基础数选择说明',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '本功能支持同时选择多个基础数，包括：\n'
            '• 第一阶段：选择主基础数（元会基础数、运世基础数）\n'
            '• 第二阶段：基于主基础数选择派生基础数（元会基础数一、运世基础数一等）\n'
            '• 每个基础数都提供 ±30、±60、±90 的调整选项\n'
            '• 派生基础数的候选项基于对应的主基础数生成',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部栏
  Widget? _buildBottomBar(BuildContext context) {
    return Consumer<MultiBaseNumberSelectionViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.canSelect && !viewModel.isCompleted) {
          return Container(
            child: Center(
              child: Text(
                " !viewModel.canSelect && !viewModel.isCompleted => ${!viewModel.canSelect && !viewModel.isCompleted}",
              ),
            ),
          );
        }

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
                        viewModel.isCompleted ? '所有选择已完成' : '选择进度',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 4),

                      if (!viewModel.isCompleted) ...[
                        LinearProgressIndicator(
                          value: viewModel.progress,
                          backgroundColor: theme.colorScheme.outline
                              .withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '${viewModel.completedSelections.length}/${viewModel.selectionManager?.selections.length ?? 0} 已完成',
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
                              '可以继续下一步',
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
                      onPressed: () {
                        _handleCancel(context);
                      },
                      child: const Text('取消'),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton(
                      onPressed: viewModel.isCompleted
                          ? () {
                              _handleComplete(context, viewModel);
                            }
                          : null,
                      child: const Text('完成'),
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

  /// 处理选择
  void _handleSelection(
    MultiBaseNumberSelectionViewModel viewModel,
    BaseNumberSelectionType type,
    TiaoWenCandidate candidate,
  ) {
    viewModel.selectBaseNumber(type, candidate);
  }

  /// 处理完成
  void _handleComplete(
    BuildContext context,
    MultiBaseNumberSelectionViewModel viewModel,
  ) {
    final completedSelections = viewModel.completedSelections;

    if (widget.onCompleted != null) {
      widget.onCompleted!(completedSelections);
    }

    Navigator.of(context).pop(completedSelections);
  }

  /// 处理取消
  void _handleCancel(BuildContext context) {
    if (widget.onCancelled != null) {
      widget.onCancelled!();
    }

    Navigator.of(context).pop();
  }
}
