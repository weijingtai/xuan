import 'package:common/enums.dart';
import 'package:common/dev_constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/si_men_fa_view_model.dart';
import '../viewmodels/ba_gua_gun_view_model.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

// 辅助：条文来源与公式（顶层类，避免嵌套类错误）
class _TiaoWenSourceAndFormula {
  final String source;
  final String formula;
  const _TiaoWenSourceAndFormula(this.source, this.formula);
}

/// 四门法 & 八卦滚法演示页面
///
/// 展示四门法V2和八卦滚法两种算法的计算结果
class FourDoorsAndGunFaPage extends StatefulWidget {
  const FourDoorsAndGunFaPage({super.key});

  @override
  State<FourDoorsAndGunFaPage> createState() => _FourDoorsAndGunFaPageState();
}

class _FourDoorsAndGunFaPageState extends State<FourDoorsAndGunFaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeViewModels();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 使用策略生成的 tiaoWenSourceList 来构建来源与公式映射（四门法）
  Map<int, _TiaoWenSourceAndFormula> _computeSiMenFaSourceMap(
    SiMenFaViewModel viewModel,
  ) {
    final model = viewModel.siMenFaModel;
    if (model == null) return {};

    final result = <int, _TiaoWenSourceAndFormula>{};
    for (final info in model.tiaoWenSourceList) {
      final sourceDesc =
          '第${info.guaIndex}卦(${info.sourceGua?.fullname ?? '未知'})';
      final formulaText = info.calculationFormula ?? '';
      result[info.tiaoWenNumber] = _TiaoWenSourceAndFormula(
        sourceDesc,
        formulaText,
      );
    }
    return result;
  }

  // 使用策略生成的 tiaoWenSourceList 来构建来源与公式映射（八卦滚法）
  Map<int, _TiaoWenSourceAndFormula> _computeBaGuaGunSourceMap(
    BaGuaGunViewModel viewModel,
  ) {
    final model = viewModel.baGuaGunModel;
    if (model == null) return {};

    final result = <int, _TiaoWenSourceAndFormula>{};
    for (final info in model.tiaoWenSourceList) {
      final sourceDesc =
          '第${info.guaIndex}卦(${info.sourceGua?.fullname ?? '未知'})';
      final formulaText = info.calculationFormula ?? '';
      result[info.tiaoWenNumber] = _TiaoWenSourceAndFormula(
        sourceDesc,
        formulaText,
      );
    }
    return result;
  }

  /// 初始化ViewModels
  Future<void> _initializeViewModels() async {
    if (_isInitialized) return;

    try {
      final siMenFaViewModel = context.read<SiMenFaViewModel>();
      final baGuaGunViewModel = context.read<BaGuaGunViewModel>();

      // 使用DevConstant.dev_usa的八字数据
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      // 并行初始化两个ViewModel
      await Future.wait([
        siMenFaViewModel.setEightChars(
          eightChars: eightChars,
          gender: Gender.male,
          threeYuan: YuanYunOrder.upper,
        ),
        baGuaGunViewModel.setEightChars(
          eightChars: eightChars,
          gender: Gender.male,
          threeYuan: YuanYunOrder.upper,
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

  /// 刷新所有数据
  Future<void> _refreshAll() async {
    try {
      final siMenFaViewModel = context.read<SiMenFaViewModel>();
      final baGuaGunViewModel = context.read<BaGuaGunViewModel>();

      await Future.wait([
        siMenFaViewModel.refresh(),
        baGuaGunViewModel.refresh(),
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

  /// 刷新当前Tab
  Future<void> _refreshCurrent() async {
    try {
      if (_tabController.index == 0) {
        await context.read<SiMenFaViewModel>().refresh();
      } else {
        await context.read<BaGuaGunViewModel>().refresh();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('四门法 & 八卦滚法'),
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
                tabs: const [
                  Tab(icon: Icon(Icons.looks_4), text: '四门法V2'),
                  Tab(icon: Icon(Icons.looks_6), text: '八卦滚法'),
                ],
              )
            : null,
      ),
      body: _isInitialized ? _buildContent() : _buildLoadingState(),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return const Center(child: LargeLoadingWidget(message: '正在初始化...'));
  }

  /// 构建主要内容
  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        // 四门法V2页面
        _buildSiMenFaPage(),
        // 八卦滚法页面
        _buildBaGuaGunPage(),
      ],
    );
  }

  /// 构建四门法V2页面
  Widget _buildSiMenFaPage() {
    return Consumer<SiMenFaViewModel>(
      builder: (context, viewModel, child) {
        return RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildSiMenFaContent(viewModel),
          ),
        );
      },
    );
  }

  /// 构建四门法内容
  Widget _buildSiMenFaContent(SiMenFaViewModel viewModel) {
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

    if (!viewModel.hasResult || !viewModel.hasUIModel) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('暂无结果')),
      );
    }

    final uiModel = viewModel.uiModel!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  uiModel.fullTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  viewModel.fourZhuDisplayText,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4.0),
                Text(
                  uiModel.basicGuaDisplayText,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4.0),
                Text(
                  uiModel.variationBaseDisplayText,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16.0),

        // 四卦信息
        Text(
          '四卦序列',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        ...uiModel.fourGuaList.asMap().entries.map((entry) {
          final gua = entry.value;
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${entry.key + 1}')),
              title: Text(gua.displayText),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (gua.secretNumber != null)
                    Text(gua.secretNumberDisplayText),
                  if (gua.xiantianNumber != null)
                    Text(gua.xiantianNumberDisplayText),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16.0),

        // 条文统计
        Card(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '条文统计',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text('总计：${uiModel.tiaoWenTotalCount} 个条文'),
                const SizedBox(height: 4.0),
                Text('计算摘要：${uiModel.calculationSummary}'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16.0),

        // 新增：条文内容列表（含来源与公式）
        _buildSiMenFaTiaoWenListSection(viewModel),
      ],
    );
  }

  Widget _buildSiMenFaTiaoWenListSection(SiMenFaViewModel viewModel) {
    final uiModel = viewModel.uiModel!;
    final theme = Theme.of(context);
    if (uiModel.tiaoWenDataList.isEmpty) {
      return const SizedBox.shrink();
    }

    final sourceMap = _computeSiMenFaSourceMap(viewModel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '条文内容列表',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        ...uiModel.tiaoWenDataList.map((t) {
          final info = sourceMap[t.id];
          final source = info?.source ?? '来源未知';
          final formula = info?.formula ?? '公式未知';
          final subtitle = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('来源：$source'),
              const SizedBox(height: 2.0),
              Text('公式：$formula'),
            ],
          );
          return Card(
            child: ListTile(
              title: Text(
                '#${t.id} ${t.content1}${t.content2 != null ? ' ${t.content2}' : ''}',
              ),
              subtitle: subtitle,
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 构建八卦滚法页面
  Widget _buildBaGuaGunPage() {
    return Consumer<BaGuaGunViewModel>(
      builder: (context, viewModel, child) {
        return RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildBaGuaGunContent(viewModel),
          ),
        );
      },
    );
  }

  /// 构建八卦滚法内容
  Widget _buildBaGuaGunContent(BaGuaGunViewModel viewModel) {
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

    if (!viewModel.hasResult || !viewModel.hasUIModel) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('暂无结果')),
      );
    }

    final uiModel = viewModel.uiModel!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  uiModel.fullTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  viewModel.fourZhuDisplayText,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4.0),
                Text(
                  uiModel.basicGuaDisplayText,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4.0),
                Text(
                  uiModel.variationBaseDisplayText,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16.0),

        // 前四卦
        Text(
          '前四卦',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        ...uiModel.firstFourGua.asMap().entries.map((entry) {
          final gua = entry.value;
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${entry.key + 1}')),
              title: Text(gua.displayText),
              subtitle: gua.threeNumbers != null
                  ? Text(gua.threeNumbers!.displayText)
                  : null,
            ),
          );
        }),

        const SizedBox(height: 16.0),

        // 后四卦
        Text(
          '后四卦',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        ...uiModel.lastFourGua.asMap().entries.map((entry) {
          final gua = entry.value;
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${entry.key + 5}')),
              title: Text(gua.displayText),
              subtitle: gua.threeNumbers != null
                  ? Text(gua.threeNumbers!.displayText)
                  : null,
            ),
          );
        }),

        const SizedBox(height: 16.0),

        // 卦象生成流程说明
        Card(
          color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '卦象生成流程',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(uiModel.guaGenerationFlow),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16.0),

        // 三基数计算说明
        Card(
          color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '三基数计算',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(uiModel.threeNumbersDescription),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16.0),

        // 条文统计
        Card(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '条文统计',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text('总计：${uiModel.tiaoWenTotalCount} 个条文 (8卦 × 6条文)'),
                const SizedBox(height: 4.0),
                Text('计算摘要：${uiModel.calculationSummary}'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16.0),
        // 新增：条文内容列表（含来源与公式）
        _buildBaGuaGunTiaoWenListSection(viewModel),
      ],
    );
  }

  Widget _buildBaGuaGunTiaoWenListSection(BaGuaGunViewModel viewModel) {
    final uiModel = viewModel.uiModel!;
    final theme = Theme.of(context);
    if (uiModel.tiaoWenDataList.isEmpty) {
      return const SizedBox.shrink();
    }

    final sourceMap = _computeBaGuaGunSourceMap(viewModel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '条文内容列表',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        ...uiModel.tiaoWenDataList.map((t) {
          final info = sourceMap[t.id];
          final source = info?.source ?? '来源未知';
          final formula = info?.formula ?? '公式未知';
          final subtitle = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('来源：$source'),
              const SizedBox(height: 2.0),
              Text('公式：$formula'),
            ],
          );
          return Card(
            child: ListTile(
              title: Text(
                '#${t.id} ${t.content1}${t.content2 != null ? ' ${t.content2}' : ''}',
              ),
              subtitle: subtitle,
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 显示信息对话框
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('四门法 & 八卦滚法说明'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('四门法V2', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8.0),
              Text('• 使用后天卦配置和干支数映射'),
              Text('• 生成4个卦：互卦→变爻错卦→第一卦互卦→第二卦互卦'),
              Text('• 计算秘数和先天数'),
              Text('• 生成完整条文列表'),
              SizedBox(height: 16.0),
              Text('八卦滚法', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8.0),
              Text('• 使用先天卦配置和太玄数映射'),
              Text('• 生成8个卦（前四卦+后四卦）'),
              Text('• 计算三基数：先天顺序数、先天洛书数、后天洛书数'),
              Text('• 生成48个条文（8卦 × 6条文）'),
              SizedBox(height: 16.0),
              Text('所有计算都使用DevConstant.dev_usa作为数据源。'),
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
