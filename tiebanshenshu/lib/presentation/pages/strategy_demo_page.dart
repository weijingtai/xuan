import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:common/dev_constant.dart';
import '../viewmodels/day_gan_zhi_gua_view_model.dart';
import '../viewmodels/four_zhu_tian_gan_view_model.dart';
import '../viewmodels/tai_xuan_four_zhu_view_model.dart';
import '../viewmodels/ba_gua_jia_ze_view_model.dart';
import '../viewmodels/yuan_tang_view_model.dart';
import '../widgets/strategy_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/ba_gua_jia_ze_card.dart';
import '../widgets/tai_xuan_dual_method_card.dart';
import '../widgets/yuan_tang_card.dart';
import '../models/ba_gua_jia_ze_ui_model.dart';
import '../models/yuan_tang_ui_model.dart';
import '../../domain/four_zhu.dart';

/// Strategy演示页面
///
/// 展示四个Strategy的计算结果，支持刷新和交互
class StrategyDemoPage extends StatefulWidget {
  const StrategyDemoPage({super.key});

  @override
  State<StrategyDemoPage> createState() => _StrategyDemoPageState();
}

class _StrategyDemoPageState extends State<StrategyDemoPage> {
  final PageController _pageController = PageController();
  bool _isInitialized = false;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeViewModels();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 初始化所有ViewModel
  Future<void> _initializeViewModels() async {
    if (_isInitialized) return;

    try {
      final dayGanZhiGuaViewModel = context.read<DayGanZhiGuaViewModel>();
      final fourZhuTianGanViewModel = context.read<FourZhuTianGanViewModel>();
      final taiXuanFourZhuViewModel = context.read<TaiXuanFourZhuViewModel>();
      final baGuaJiaZeViewModel = context.read<BaGuaJiaZeViewModel>();
      final yuanTangViewModel = context.read<YuanTangViewModel>();

      // 使用DevConstant.dev_usa的八字数据
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      // 创建FourZhu对象供元堂卦使用
      final fourZhu = FourZhu(
        yearGanzhi: eightChars.year.name,
        monthGanzhi: eightChars.month.name,
        dayGanzhi: eightChars.day.name,
        timeGanzhi: eightChars.time.name,
      );

      // 并行初始化所有ViewModel
      await Future.wait([
        dayGanZhiGuaViewModel.setFromEightChars(eightChars),
        fourZhuTianGanViewModel.setEightChars(eightChars),
        taiXuanFourZhuViewModel.setEightChars(eightChars),
        baGuaJiaZeViewModel.setEightChars(eightChars),
        yuanTangViewModel.setYuanTangParams(
          fourZhu: fourZhu,
          gender: "男",
          threeYuan: "上",
          birthAfterZhi: "夏至",
        ),
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
      final baGuaJiaZeViewModel = context.read<BaGuaJiaZeViewModel>();
      final yuanTangViewModel = context.read<YuanTangViewModel>();

      await Future.wait([
        dayGanZhiGuaViewModel.refresh(),
        fourZhuTianGanViewModel.refresh(),
        taiXuanFourZhuViewModel.refresh(),
        baGuaJiaZeViewModel.refresh(),
        yuanTangViewModel.refresh(),
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
    print("------ build  ---- $_isInitialized");
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        actions: [
          IconButton(
            onPressed: _refreshCurrent,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新当前',
          ),
          IconButton(
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh_outlined),
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
      bottomNavigationBar: _isInitialized ? _buildBottomNavigationBar() : null,
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    print("------ _buildLoadingState");
    return const Center(child: LargeLoadingWidget(message: '正在初始化Strategy...'));
  }

  /// 构建主要内容
  Widget _buildContent() {
    print("------ _buildContent");
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      children: [
        // 数据源信息页面
        _buildDataSourcePage(),

        // 日干支卦页面
        _buildStrategyPage(
          child: Consumer<DayGanZhiGuaViewModel>(
            builder: (context, viewModel, child) {
              return StrategyCard(
                title: '日干支卦',
                viewModel: viewModel,
                initiallyExpanded: true,
              );
            },
          ),
        ),

        // 四柱天干页面
        _buildStrategyPage(
          child: Consumer<FourZhuTianGanViewModel>(
            builder: (context, viewModel, child) {
              return StrategyCard(
                title: '四柱天干',
                viewModel: viewModel,
                initiallyExpanded: true,
              );
            },
          ),
        ),

        // 太玄四柱页面
        _buildStrategyPage(
          child: Consumer<TaiXuanFourZhuViewModel>(
            builder: (context, viewModel, child) {
              return TaiXuanDualMethodCard(
                viewModel: viewModel,
                initiallyExpanded: true,
              );
            },
          ),
        ),

        // 八卦加则页面
        _buildStrategyPage(
          child: Consumer<BaGuaJiaZeViewModel>(
            builder: (context, viewModel, child) {
              return _buildBaGuaJiaZeContent(viewModel);
            },
          ),
        ),

        // 元堂卦页面
        _buildStrategyPage(
          child: Consumer<YuanTangViewModel>(
            builder: (context, viewModel, child) {
              return _buildYuanTangContent(viewModel);
            },
          ),
        ),
      ],
    );
  }

  /// 获取当前页面标题
  String _getPageTitle() {
    switch (_currentPageIndex) {
      case 0:
        return 'Strategy演示 - 数据源';
      case 1:
        return 'Strategy演示 - 日干支卦';
      case 2:
        return 'Strategy演示 - 四柱天干';
      case 3:
        return 'Strategy演示 - 太玄四柱';
      case 4:
        return 'Strategy演示 - 八卦加则';
      case 5:
        return 'Strategy演示 - 元堂卦';
      default:
        return 'Strategy演示';
    }
  }

  /// 刷新当前页面
  Future<void> _refreshCurrent() async {
    try {
      switch (_currentPageIndex) {
        case 1:
          await context.read<DayGanZhiGuaViewModel>().refresh();
          break;
        case 2:
          await context.read<FourZhuTianGanViewModel>().refresh();
          break;
        case 3:
          await context.read<TaiXuanFourZhuViewModel>().refresh();
          break;
        case 4:
          await context.read<BaGuaJiaZeViewModel>().refresh();
          break;
        case 5:
          await context.read<YuanTangViewModel>().refresh();
          break;
        default:
          // 数据源页面不需要刷新
          break;
      }

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

  /// 构建数据源信息页面
  Widget _buildDataSourcePage() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataSourceInfo(),
            const SizedBox(height: 24.0),
            _buildPageInstructions(),
          ],
        ),
      ),
    );
  }

  /// 构建策略页面
  Widget _buildStrategyPage({required Widget child}) {
    return RefreshIndicator(
      onRefresh: _refreshCurrent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  /// 构建页面说明
  Widget _buildPageInstructions() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: theme.colorScheme.primary,
                size: 20.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                '使用说明',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            '• 左右滑动切换不同的策略页面\n'
            '• 使用底部导航栏快速跳转\n'
            '• 下拉刷新当前页面数据\n'
            '• 点击右上角按钮刷新所有数据',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentPageIndex,
      onTap: (index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.data_object), label: '数据源'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: '日干支卦',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.view_column), label: '四柱天干'),
        BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: '太玄四柱'),
        BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: '八卦加则'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: '元堂卦'),
      ],
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

  /// 构建八卦加则内容
  Widget _buildBaGuaJiaZeContent(BaGuaJiaZeViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: LargeLoadingWidget(message: '计算中...'),
      );
    }

    if (viewModel.hasError) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomErrorWidget(
          message: '计算失败：${viewModel.errorMessage ?? "未知错误"}',
          onRetry: viewModel.refresh,
        ),
      );
    }

    if (!viewModel.hasResult || viewModel.resultCount == 0) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('暂无结果')),
      );
    }

    // 转换为UI模型
    final uiModels = <BaGuaJiaZeUIModel>[];
    for (final item in viewModel.allResults) {
      // allResults returns BaseNumberTiaoWenListModel which has tiaoWenDataList
      // We need to get the BaGuaJiaZeBaseNumberModel from the domain result
      // Since we can't access it directly, we'll use the fromDomain factory method
      uiModels.add(BaGuaJiaZeUIModel.fromDomain(item));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和摘要
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '八卦加则取数法',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '共 ${viewModel.resultCount} 个结果（4柱 × 2方法）',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ],
          ),
        ),

        // 结果列表
        BaGuaJiaZeResultsList(
          models: uiModels,
          groupByPillar: true,
          expandFirst: true,
        ),
      ],
    );
  }

  /// 构建元堂卦内容
  Widget _buildYuanTangContent(YuanTangViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: LargeLoadingWidget(message: '计算中...'),
      );
    }

    if (viewModel.hasError) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomErrorWidget(
          message: '计算失败：${viewModel.errorMessage ?? "未知错误"}',
          onRetry: viewModel.refresh,
        ),
      );
    }

    if (!viewModel.hasResult) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('暂无结果')),
      );
    }

    // 从ViewModel获取YuanTangBaseNumberModel
    final yuanTangModel = viewModel.yuanTangModel;
    if (yuanTangModel == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('数据格式错误')),
      );
    }

    // 创建UI模型
    final uiModel = YuanTangUIModel.fromYuanTangModel(
      yuanTangModel,
      tiaoWenDataList: viewModel.result!.tiaoWenEntities,
    );

    return YuanTangCard(
      model: uiModel,
      initiallyExpanded: true,
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
              Text('本页面演示了五种不同的Strategy计算方法：'),
              SizedBox(height: 12.0),
              Text('• 日干支卦：基于日柱干支计算'),
              Text('• 四柱天干：基于四柱天干计算'),
              Text('• 太玄四柱：基于太玄理论计算'),
              Text('• 八卦加则：基于八卦装配地支加则法'),
              Text('• 元堂卦：基于元堂卦取数法，包含8种条文计算方法'),
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
