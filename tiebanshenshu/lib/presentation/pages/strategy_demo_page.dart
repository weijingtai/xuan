import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:common/dev_constant.dart';
import '../viewmodels/day_gan_zhi_gua_view_model.dart';
import '../viewmodels/four_zhu_tian_gan_view_model.dart';
import '../viewmodels/tai_xuan_four_zhu_view_model.dart';
import '../widgets/strategy_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

/// Strategy演示页面
///
/// 展示三个Strategy的计算结果，支持刷新和交互
class StrategyDemoPage extends StatefulWidget {
  const StrategyDemoPage({super.key});

  @override
  State<StrategyDemoPage> createState() => _StrategyDemoPageState();
}

class _StrategyDemoPageState extends State<StrategyDemoPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeViewModels();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 初始化所有ViewModel
  Future<void> _initializeViewModels() async {
    if (_isInitialized) return;

    try {
      final dayGanZhiGuaViewModel = context.read<DayGanZhiGuaViewModel>();
      final fourZhuTianGanViewModel = context.read<FourZhuTianGanViewModel>();
      final taiXuanFourZhuViewModel = context.read<TaiXuanFourZhuViewModel>();

      // 使用DevConstant.dev_usa的八字数据
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      // 并行初始化所有ViewModel
      await Future.wait([
        dayGanZhiGuaViewModel.setFromEightChars(eightChars),
        fourZhuTianGanViewModel.setEightChars(eightChars),
        taiXuanFourZhuViewModel.setEightChars(eightChars),
      ]);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('初始化失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// 刷新所有Strategy
  Future<void> _refreshAll() async {
    try {
      final dayGanZhiGuaViewModel = context.read<DayGanZhiGuaViewModel>();
      final fourZhuTianGanViewModel = context.read<FourZhuTianGanViewModel>();
      final taiXuanFourZhuViewModel = context.read<TaiXuanFourZhuViewModel>();

      await Future.wait([
        dayGanZhiGuaViewModel.refresh(),
        fourZhuTianGanViewModel.refresh(),
        taiXuanFourZhuViewModel.refresh(),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('刷新完成'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('刷新失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strategy演示'),
        actions: [
          IconButton(
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新所有',
          ),
          IconButton(
            onPressed: () => _showInfoDialog(context),
            icon: const Icon(Icons.info_outline),
            tooltip: '信息',
          ),
        ],
      ),
      body: _isInitialized ? _buildContent() : _buildLoadingState(),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return const Center(child: LargeLoadingWidget(message: '正在初始化Strategy...'));
  }

  /// 构建主要内容
  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          // 数据源信息
          _buildDataSourceInfo(),

          const SizedBox(height: 16.0),

          // Strategy卡片列表
          Consumer<DayGanZhiGuaViewModel>(
            builder: (context, viewModel, child) {
              return StrategyCard(
                title: '日干支卦',
                viewModel: viewModel,
                initiallyExpanded: true,
              );
            },
          ),

          Consumer<FourZhuTianGanViewModel>(
            builder: (context, viewModel, child) {
              return StrategyCard(title: '四柱天干', viewModel: viewModel);
            },
          ),

          Consumer<TaiXuanFourZhuViewModel>(
            builder: (context, viewModel, child) {
              return StrategyCard(title: '太玄四柱', viewModel: viewModel);
            },
          ),

          // 底部间距
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  /// 构建数据源信息
  Widget _buildDataSourceInfo() {
    final theme = Theme.of(context);
    final devData = DevConstant.dev_usa;
    final eightChars = devData.standeredChineseInfo.eightChars;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.data_object,
                color: theme.colorScheme.primary,
                size: 20.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                '数据源信息',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          _buildInfoRow('时间', '${devData.standeredDatetime}'),
          _buildInfoRow('时区', devData.timezoneStr),
          _buildInfoRow('年柱', eightChars.year.name),
          _buildInfoRow('月柱', eightChars.month.name),
          _buildInfoRow('日柱', eightChars.day.name),
          _buildInfoRow('时柱', eightChars.time.name),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 60.0,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示信息对话框
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Strategy演示说明'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('本页面演示了三种不同的Strategy计算方法：'),
              SizedBox(height: 12.0),
              Text('• 日干支卦：基于日柱干支计算'),
              Text('• 四柱天干：基于四柱天干计算'),
              Text('• 太玄四柱：基于太玄理论计算'),
              SizedBox(height: 12.0),
              Text('所有计算都使用DevConstant.dev_usa作为数据源，展示完整的条文列表信息。'),
              SizedBox(height: 12.0),
              Text('点击卡片头部可以展开/收起详细内容，点击刷新按钮可以重新计算。'),
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
