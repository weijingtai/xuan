/// 太玄四柱交互式计算页面
///
/// 提供用户参与式的太玄四柱计算体验
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:common/dev_constant.dart';
import 'package:common/models/eight_chars.dart';

import '../viewmodels/tai_xuan_four_zhu_interactive_view_model.dart';
import '../../domain/models/interactive_strategy_config.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../widgets/interactive_session_header.dart';
import '../widgets/interactive_step_indicator.dart';
import '../widgets/candidate_selection_widget.dart';
import '../widgets/interactive_result_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

/// 太玄四柱交互式计算页面
class TaiXuanInteractivePage extends StatefulWidget {
  /// 初始八字（可选）
  final EightChars? initialEightChars;

  /// 交互式配置（可选）
  final InteractiveStrategyConfig? config;

  const TaiXuanInteractivePage({
    super.key,
    this.initialEightChars,
    this.config,
  });

  @override
  State<TaiXuanInteractivePage> createState() => _TaiXuanInteractivePageState();
}

class _TaiXuanInteractivePageState extends State<TaiXuanInteractivePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isInitialized = false;
  EightChars? _selectedEightChars;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _selectedEightChars =
        widget.initialEightChars ??
        DevConstant.dev_usa.standeredChineseInfo.eightChars;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSession();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// 初始化动画
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
  }

  /// 初始化会话
  Future<void> _initializeSession() async {
    if (_selectedEightChars == null) return;

    final provider = context.read<TaiXuanFourZhuInteractiveViewModel>();

    await provider.startSession(
      _selectedEightChars!,
      config: widget.config ?? InteractiveStrategyConfig.defaultConfig(),
    );

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      _fadeController.forward();
      _slideController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<TaiXuanFourZhuInteractiveViewModel>(
        builder: (context, provider, child) {
          return _buildBody(provider);
        },
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('太玄四柱交互式计算'),
      elevation: 0,
      actions: [
        Consumer<TaiXuanFourZhuInteractiveViewModel>(
          builder: (context, provider, child) {
            return PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, provider),
              itemBuilder: (context) => [
                if (provider.canUndo)
                  const PopupMenuItem(
                    value: 'undo',
                    child: ListTile(
                      leading: Icon(Icons.undo),
                      title: Text('撤销'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                if (provider.hasSession)
                  const PopupMenuItem(
                    value: 'restart',
                    child: ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('重新开始'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                const PopupMenuItem(
                  value: 'help',
                  child: ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('帮助'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// 构建主体内容
  Widget _buildBody(TaiXuanFourZhuInteractiveViewModel provider) {
    if (!_isInitialized) {
      return const Center(child: LargeLoadingWidget(message: '正在初始化交互式会话...'));
    }

    if (provider.hasError) {
      return _buildErrorState(provider);
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildMainContent(provider),
          ),
        );
      },
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(TaiXuanFourZhuInteractiveViewModel provider) {
    return Column(
      children: [
        // 会话头部信息
        InteractiveSessionHeader(provider: provider),

        // 步骤指示器
        if (provider.hasSession) InteractiveStepIndicator(provider: provider),

        // 主要内容区域
        Expanded(child: _buildContentArea(provider)),

        // 底部操作栏
        _buildBottomActionBar(provider),
      ],
    );
  }

  /// 构建内容区域
  Widget _buildContentArea(TaiXuanFourZhuInteractiveViewModel provider) {
    if (provider.isLoading) {
      return _buildLoadingContent(provider);
    }

    if (provider.isCompleted) {
      return _buildCompletedContent(provider);
    }

    if (provider.canInteract) {
      return _buildInteractiveContent(provider);
    }

    return const Center(child: Text('等待用户操作...'));
  }

  /// 构建加载内容
  Widget _buildLoadingContent(TaiXuanFourZhuInteractiveViewModel provider) {
    String message = '处理中...';

    if (provider.isStartingSession) {
      message = '正在启动会话...';
    } else if (provider.isLoadingCandidates) {
      message = '正在加载选项...';
    } else if (provider.isProcessingSelection) {
      message = '正在处理您的选择...';
    } else if (provider.isCalculating) {
      message = '正在计算最终结果...';
    }

    return Center(child: LargeLoadingWidget(message: message));
  }

  /// 构建交互内容
  Widget _buildInteractiveContent(TaiXuanFourZhuInteractiveViewModel provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前步骤信息
          _buildCurrentStepInfo(provider),

          const SizedBox(height: 16.0),

          // 候选项选择
          Expanded(
            child: CandidateSelectionWidget(
              candidates: provider.currentCandidates,
              onCandidateSelected: (candidate) =>
                  _selectCandidate(provider, candidate),
              isLoading: provider.isProcessingSelection,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建当前步骤信息
  Widget _buildCurrentStepInfo(TaiXuanFourZhuInteractiveViewModel provider) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.currentStepName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (provider.currentStepDescription.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              Text(
                provider.currentStepDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建完成内容
  Widget _buildCompletedContent(TaiXuanFourZhuInteractiveViewModel provider) {
    return InteractiveResultWidget(
      provider: provider,
      onRestart: () => _restartSession(provider),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(TaiXuanFourZhuInteractiveViewModel provider) {
    return Center(
      child: CustomErrorWidget(
        message: provider.errorMessage ?? '发生未知错误',
        onRetry: () => _retryOperation(provider),
        showDetails: true,
        details: provider.lastException?.toString(),
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomActionBar(TaiXuanFourZhuInteractiveViewModel provider) {
    if (!provider.hasSession || provider.hasError) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // 撤销按钮
          if (provider.canUndo)
            IconButton(
              onPressed: provider.isLoading ? null : () => _undoStep(provider),
              icon: const Icon(Icons.undo),
              tooltip: '撤销',
            ),

          const Spacer(),

          // 进度信息
          Text(
            '步骤 ${provider.getStepProgressText()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const SizedBox(width: 16.0),

          // 会话时长
          Text(
            provider.getSessionDurationText(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理菜单操作
  void _handleMenuAction(
    String action,
    TaiXuanFourZhuInteractiveViewModel provider,
  ) {
    switch (action) {
      case 'undo':
        _undoStep(provider);
        break;
      case 'restart':
        _restartSession(provider);
        break;
      case 'help':
        _showHelpDialog();
        break;
    }
  }

  /// 选择候选项
  Future<void> _selectCandidate(
    TaiXuanFourZhuInteractiveViewModel provider,
    TiaoWenCandidate candidate,
  ) async {
    try {
      await provider.selectCandidate(candidate.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择失败: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// 撤销步骤
  Future<void> _undoStep(TaiXuanFourZhuInteractiveViewModel provider) async {
    try {
      await provider.undoStep();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('撤销失败: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// 重新开始会话
  Future<void> _restartSession(
    TaiXuanFourZhuInteractiveViewModel provider,
  ) async {
    final confirmed = await _showConfirmDialog(
      '重新开始',
      '确定要重新开始交互式计算吗？当前进度将会丢失。',
    );

    if (confirmed && mounted) {
      try {
        await provider.restart();
        _fadeController.reset();
        _slideController.reset();
        _fadeController.forward();
        _slideController.forward();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('重新开始失败: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  /// 重试操作
  Future<void> _retryOperation(
    TaiXuanFourZhuInteractiveViewModel provider,
  ) async {
    if (provider.inputEightChars != null) {
      await _initializeSession();
    }
  }

  /// 显示确认对话框
  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示帮助对话框
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('交互式计算帮助'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('太玄四柱交互式计算允许您参与计算过程：'),
              SizedBox(height: 12.0),
              Text('• 确认或修改四柱信息'),
              Text('• 选择计算方法'),
              Text('• 选择卦象映射（如果启用）'),
              SizedBox(height: 12.0),
              Text('您可以随时撤销到上一步，或重新开始整个过程。'),
              SizedBox(height: 12.0),
              Text('完成所有步骤后，系统将计算最终的条文列表。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
