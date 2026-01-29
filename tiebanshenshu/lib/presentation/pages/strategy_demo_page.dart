import 'package:common/enums.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/models/jie_qi_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:common/dev_constant.dart';
import '../viewmodels/day_gan_zhi_gua_view_model.dart';
import '../viewmodels/four_zhu_tian_gan_view_model.dart';
import '../viewmodels/tai_xuan_four_zhu_view_model.dart';
import '../viewmodels/ba_gua_jia_ze_view_model.dart';
import '../viewmodels/yuan_tang_view_model.dart';
import '../viewmodels/xian_houtian_jia_ze_view_model.dart';
import '../viewmodels/liu_yao_gan_zhi_he_view_model.dart';
import '../viewmodels/gua_yao_gan_zhi_he_view_model.dart';
import '../viewmodels/xian_houtian_qu_shu_view_model.dart';
import '../viewmodels/qian_hou_gua_view_model.dart';
import '../viewmodels/gua_zhong_view_model.dart';
import '../widgets/strategy_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/ba_gua_jia_ze_card.dart';
import '../widgets/tai_xuan_dual_method_card.dart';
import '../widgets/yuan_tang_card.dart';
import '../widgets/xian_houtian_jia_ze_card.dart';
import '../widgets/liu_yao_gan_zhi_he_card.dart';
import '../widgets/gua_yao_gan_zhi_he_card.dart';
import '../widgets/xian_houtian_qu_shu_card.dart';
import '../widgets/qian_hou_gua_card.dart';
import '../widgets/gua_zhong_card.dart';
import '../models/ba_gua_jia_ze_ui_model.dart';
import '../models/yuan_tang_ui_model.dart';
import '../../service/strategy/yuan_tang_strategy.dart';

/// Strategy演示页面
///
/// 展示四个Strategy的计算结果，支持刷新和交互
class StrategyDemoPage extends StatefulWidget {
  const StrategyDemoPage({super.key});

  @override
  State<StrategyDemoPage> createState() => _StrategyDemoPageState();
}

class _StrategyDemoPageState extends State<StrategyDemoPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late TabController _tabController;
  bool _isInitialized = false;

  // Tab配置列表
  final List<_TabConfig> _tabs = [
    _TabConfig(label: '数据源', icon: Icons.data_object),
    _TabConfig(label: '日干支卦', icon: Icons.calendar_today),
    _TabConfig(label: '四柱天干', icon: Icons.view_column),
    _TabConfig(label: '太玄四柱', icon: Icons.auto_awesome),
    _TabConfig(label: '八卦加则', icon: Icons.auto_graph),
    _TabConfig(label: '元堂卦', icon: Icons.account_balance),
    _TabConfig(label: '先后天', icon: Icons.shuffle),
    _TabConfig(label: '六爻干支', icon: Icons.hexagon_outlined),
    _TabConfig(label: '卦爻干支', icon: Icons.vertical_align_center),
    _TabConfig(label: '先后天取数', icon: Icons.calculate_outlined),
    _TabConfig(label: '前后卦', icon: Icons.switch_left_outlined),
    _TabConfig(label: '卦中取数', icon: Icons.apps),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeViewModels();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// 处理Tab切换
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
      final xianHoutianJiaZeViewModel = context
          .read<XianHoutianJiaZeViewModel>();
      final liuYaoGanZhiHeViewModel = context.read<LiuYaoGanZhiHeViewModel>();
      final guaYaoGanZhiHeViewModel = context.read<GuaYaoGanZhiHeViewModel>();
      final xianHoutianQuShuViewModel = context
          .read<XianHoutianQuShuViewModel>();
      final qianHouGuaViewModel = context.read<QianHouGuaViewModel>();
      final guaZhongViewModel = context.read<GuaZhongViewModel>();

      // 使用DevConstant.dev_usa的八字数据
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      // 并行初始化所有ViewModel
      await Future.wait([
        dayGanZhiGuaViewModel.setFromEightChars(eightChars),
        fourZhuTianGanViewModel.setEightChars(eightChars),
        taiXuanFourZhuViewModel.setEightChars(eightChars),
        baGuaJiaZeViewModel.setEightChars(eightChars),
        yuanTangViewModel.setYuanTangParams(
          eightChars: eightChars,
          gender: Gender.male,
          threeYuan: YuanYunOrder.upper,
          birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
        ),
        xianHoutianJiaZeViewModel.setEightChars(
          eightChars: eightChars,
          gender: Gender.male,
          threeYuan: YuanYunOrder.upper,
          birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
        ),
        liuYaoGanZhiHeViewModel.setParams(
          eightChars: eightChars,
          gender: Gender.male,
          threeYuan: YuanYunOrder.upper,
          birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
        ),
        guaYaoGanZhiHeViewModel.setParams(eightChars: eightChars),
        xianHoutianQuShuViewModel.setParams(
          eightChars: eightChars,
          gender: Gender.male,
          threeYuan: YuanYunOrder.upper,
          birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
        ),
        qianHouGuaViewModel.setParams(
          eightChars: eightChars,
          gender: Gender.male,
          threeYuan: YuanYunOrder.upper,
          birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
        ),
        guaZhongViewModel.setParams(eightChars: eightChars),
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
      final xianHoutianJiaZeViewModel = context
          .read<XianHoutianJiaZeViewModel>();
      final liuYaoGanZhiHeViewModel = context.read<LiuYaoGanZhiHeViewModel>();
      final guaYaoGanZhiHeViewModel = context.read<GuaYaoGanZhiHeViewModel>();
      final xianHoutianQuShuViewModel = context
          .read<XianHoutianQuShuViewModel>();
      final qianHouGuaViewModel = context.read<QianHouGuaViewModel>();
      final guaZhongViewModel = context.read<GuaZhongViewModel>();

      await Future.wait([
        dayGanZhiGuaViewModel.refresh(),
        fourZhuTianGanViewModel.refresh(),
        taiXuanFourZhuViewModel.refresh(),
        baGuaJiaZeViewModel.refresh(),
        yuanTangViewModel.refresh(),
        xianHoutianJiaZeViewModel.refresh(),
        liuYaoGanZhiHeViewModel.refresh(),
        guaYaoGanZhiHeViewModel.refresh(),
        xianHoutianQuShuViewModel.refresh(),
        qianHouGuaViewModel.refresh(),
        guaZhongViewModel.refresh(),
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
        bottom: _isInitialized
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _tabs
                    .map(
                      (config) =>
                          Tab(icon: Icon(config.icon), text: config.label),
                    )
                    .toList(),
              )
            : null,
      ),
      body: _isInitialized ? _buildContent() : _buildLoadingState(),
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
        // 同步TabController的索引，但不触发动画
        if (_tabController.index != index) {
          _tabController.animateTo(index);
        }
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

        // 先后天八卦加则法页面
        _buildStrategyPage(
          child: Consumer<XianHoutianJiaZeViewModel>(
            builder: (context, viewModel, child) {
              return _buildXianHoutianJiaZeContent(viewModel);
            },
          ),
        ),

        // 先后天卦六爻干支和数法页面
        _buildStrategyPage(
          child: Consumer<LiuYaoGanZhiHeViewModel>(
            builder: (context, viewModel, child) {
              return _buildLiuYaoGanZhiHeContent(viewModel);
            },
          ),
        ),

        // 卦爻干支和数法页面
        _buildStrategyPage(
          child: Consumer<GuaYaoGanZhiHeViewModel>(
            builder: (context, viewModel, child) {
              return _buildGuaYaoGanZhiHeContent(viewModel);
            },
          ),
        ),

        // 先后天卦取数页面
        _buildStrategyPage(
          child: Consumer<XianHoutianQuShuViewModel>(
            builder: (context, viewModel, child) {
              return _buildXianHoutianQuShuContent(viewModel);
            },
          ),
        ),

        // 前后卦取数法页面
        _buildStrategyPage(
          child: Consumer<QianHouGuaViewModel>(
            builder: (context, viewModel, child) {
              return _buildQianHouGuaContent(viewModel);
            },
          ),
        ),

        // 卦中取数法页面
        _buildStrategyPage(
          child: Consumer<GuaZhongViewModel>(
            builder: (context, viewModel, child) {
              return _buildGuaZhongContent(viewModel);
            },
          ),
        ),
      ],
    );
  }

  /// 获取当前页面标题
  String _getPageTitle() {
    if (!_isInitialized) return 'Strategy演示';

    switch (_tabController.index) {
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
      case 6:
        return 'Strategy演示 - 先后天八卦加则法';
      case 7:
        return 'Strategy演示 - 先后天卦六爻干支和数法';
      case 8:
        return 'Strategy演示 - 卦爻干支和数法';
      case 9:
        return 'Strategy演示 - 先后天卦取数';
      case 10:
        return 'Strategy演示 - 前后卦取数法';
      case 11:
        return 'Strategy演示 - 卦中取数法';
      default:
        return 'Strategy演示';
    }
  }

  /// 刷新当前页面
  Future<void> _refreshCurrent() async {
    try {
      switch (_tabController.index) {
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
        case 6:
          await context.read<XianHoutianJiaZeViewModel>().refresh();
          break;
        case 7:
          await context.read<LiuYaoGanZhiHeViewModel>().refresh();
          break;
        case 8:
          await context.read<GuaYaoGanZhiHeViewModel>().refresh();
          break;
        case 9:
          await context.read<XianHoutianQuShuViewModel>().refresh();
          break;
        case 10:
          await context.read<QianHouGuaViewModel>().refresh();
          break;
        case 11:
          await context.read<GuaZhongViewModel>().refresh();
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
            '• 点击顶部标签栏快速跳转\n'
            '• 下拉刷新当前页面数据\n'
            '• 点击右上角按钮刷新所有数据',
            style: theme.textTheme.bodyMedium,
          ),
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

    // 从ViewModel获取先天卦和后天卦的条文编号列表
    final baseNumberList = viewModel.baseNumberTiaoWenList;
    List<int>? xiantianTiaoWenNumbers;
    List<int>? houtianTiaoWenNumbers;

    if (baseNumberList.length >= 2) {
      // 第一个是先天卦，第二个是后天卦
      xiantianTiaoWenNumbers = baseNumberList[0].tiaoWenNumbers;
      houtianTiaoWenNumbers = baseNumberList[1].tiaoWenNumbers;
    }

    // 创建UI模型
    final uiModel = YuanTangUIModel.fromYuanTangModel(
      yuanTangModel,
      tiaoWenDataList: viewModel.result!.tiaoWenEntities,
      xiantianTiaoWenNumbers: xiantianTiaoWenNumbers,
      houtianTiaoWenNumbers: houtianTiaoWenNumbers,
    );

    // 为流运系统准备参数：基础模型、出生年份、策略实例
    final birthYear = DevConstant.dev_usa.standeredDatetime.year;
    final strategy = YuanTangStrategy();

    return YuanTangCard(
      model: uiModel,
      initiallyExpanded: true,
      baseNumberModel: yuanTangModel,
      birthYear: birthYear,
      strategy: strategy,
    );
  }

  /// 构建先后天八卦加则法内容
  Widget _buildXianHoutianJiaZeContent(XianHoutianJiaZeViewModel viewModel) {
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

    return XianHoutianJiaZeCard(viewModel: viewModel, initiallyExpanded: true);
  }

  /// 构建先后天卦六爻干支和数法内容
  Widget _buildLiuYaoGanZhiHeContent(LiuYaoGanZhiHeViewModel viewModel) {
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

    return LiuYaoGanZhiHeCard(viewModel: viewModel, initiallyExpanded: true);
  }

  /// 构建卦爻干支和数法内容
  Widget _buildGuaYaoGanZhiHeContent(GuaYaoGanZhiHeViewModel viewModel) {
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

    return GuaYaoGanZhiHeCard(viewModel: viewModel, initiallyExpanded: true);
  }

  /// 构建先后天卦取数内容
  Widget _buildXianHoutianQuShuContent(XianHoutianQuShuViewModel viewModel) {
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

    return XianHoutianQuShuCard(viewModel: viewModel, initiallyExpanded: true);
  }

  /// 构建前后卦取数法内容
  Widget _buildQianHouGuaContent(QianHouGuaViewModel viewModel) {
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

    return QianHouGuaCard(viewModel: viewModel, initiallyExpanded: true);
  }

  /// 构建卦中取数法内容
  Widget _buildGuaZhongContent(GuaZhongViewModel viewModel) {
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

    // GuaZhongCard需要EightChars参数
    if (viewModel.currentEightChars == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('参数错误')),
      );
    }

    return GuaZhongCard(eightChars: viewModel.currentEightChars!);
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
              Text('本页面演示了十种不同的Strategy计算方法：'),
              SizedBox(height: 12.0),
              Text('• 日干支卦：基于日柱干支计算'),
              Text('• 四柱天干：基于四柱天干计算'),
              Text('• 太玄四柱：基于太玄理论计算'),
              Text('• 八卦加则：基于八卦装配地支加则法'),
              Text('• 元堂卦：基于元堂卦取数法，包含8种条文计算方法'),
              Text('• 先后天八卦加则法：基于先后天八卦加则法，先天卦递增96四次，后天卦递减96四次'),
              Text('• 先后天卦六爻干支和数法：基于六爻纳甲配置，计算干支太玄数之和，先后天卦各递增减96四次'),
              Text('• 卦爻干支和数法：基于卦爻干支和数法，支持年干阴阳纳甲法和传统内外卦法两种纳甲方式'),
              Text('• 先后天卦取数：基于六爻纳甲配置，计算干支太玄数之和，先后天卦各使用±48×倍数[2,4,8,16]扩展'),
              Text('• 前后卦取数法：基于元堂卦法取先天卦和后天卦，前卦递增96四次，后卦递减96四次'),
              Text('• 卦中取数法：基于四柱干支太玄数，年月卦和日时卦各产生主卦和互卦条文编号，总计4个条文'),
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

/// Tab配置类
class _TabConfig {
  final String label;
  final IconData icon;

  const _TabConfig({required this.label, required this.icon});
}
