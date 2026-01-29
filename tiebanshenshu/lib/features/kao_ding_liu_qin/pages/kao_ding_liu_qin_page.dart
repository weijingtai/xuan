import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/enums.dart';
import '../models/liu_qin_type.dart';
import '../widgets/liu_du_table_selection_widget.dart';
import '../../../presentation/viewmodels/kao_ding_liu_qin_view_model.dart';
import '../models/spouse_ordinal.dart';

/// 考订六亲页面
///
/// 并列展示所有六亲类型的流度表，用户可以为每个类型选择条文
class KaoDingLiuQinPage extends StatefulWidget {
  /// 八字（可选，默认使用测试数据）
  final EightChars? eightChars;

  const KaoDingLiuQinPage({
    super.key,
    this.eightChars,
  });

  @override
  State<KaoDingLiuQinPage> createState() => _KaoDingLiuQinPageState();
}

class _KaoDingLiuQinPageState extends State<KaoDingLiuQinPage> {
  late EightChars _currentEightChars;
  bool _isCalculated = false;

  @override
  void initState() {
    super.initState();
    // 使用传入的八字或默认测试数据
    _currentEightChars = widget.eightChars ??
        EightChars(
          year: JiaZi.GUI_WEI,
          month: JiaZi.REN_WU,
          day: JiaZi.WU_SHEN,
          time: JiaZi.WU_SHEN,
        );

    // 自动计算
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateAll();
    });
  }

  Future<void> _calculateAll() async {
    final viewModel = context.read<KaoDingLiuQinViewModel>();
    await viewModel.calculateAll(eightChars: _currentEightChars);
    setState(() {
      _isCalculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('考订六亲'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重新计算',
            onPressed: _calculateAll,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '使用说明',
            onPressed: _showHelp,
          ),
        ],
      ),
      body: Consumer<KaoDingLiuQinViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在计算所有六亲...'),
                ],
              ),
            );
          }

          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(viewModel.errorMessage ?? '计算失败'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calculateAll,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          if (!viewModel.isSuccess || !_isCalculated) {
            return const Center(
              child: Text('等待计算...'),
            );
          }

          return Column(
            children: [
              // 八字显示
              _buildEightCharsHeader(),

              // 流度表网格
              Expanded(
                child: _buildLiuDuTablesGrid(viewModel),
              ),

              // 确认按钮
              _buildConfirmButton(viewModel),
            ],
          );
        },
      ),
    );
  }

  /// 八字显示头部
  Widget _buildEightCharsHeader() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '八字',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPillarChip('年', _currentEightChars.year.name),
              _buildPillarChip('月', _currentEightChars.month.name),
              _buildPillarChip('日', _currentEightChars.day.name),
              _buildPillarChip('时', _currentEightChars.time.name),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillarChip(String label, String value) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  /// 流度表网格
  Widget _buildLiuDuTablesGrid(KaoDingLiuQinViewModel viewModel) {
    // 按照父母、夫妻、兄弟、子女的顺序分组
    final groupedTypes = [
      [LiuQinType.father, LiuQinType.mother],
      [LiuQinType.husband, LiuQinType.wife],
      [LiuQinType.sibling],
      [LiuQinType.son, LiuQinType.daughter],
    ];

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: groupedTypes.map((group) {
        return Column(
          children: [
            // 分组标题
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _getGroupTitle(group),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // 该分组的流度表
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (group.contains(LiuQinType.sibling)) ...[
                  Expanded(child: _buildSiblingTable(viewModel, isYi: false)),
                  Expanded(child: _buildSiblingTable(viewModel, isYi: true)),
                ],
                ...group
                    .where((type) => type != LiuQinType.sibling)
                    .map((type) => Expanded(child: _buildLiuDuTable(viewModel, type)))
                    .toList(),
              ],
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  String _getGroupTitle(List<LiuQinType> group) {
    if (group.contains(LiuQinType.father)) return '考父母';
    if (group.contains(LiuQinType.husband)) return '考夫妻';
    if (group.contains(LiuQinType.sibling)) return '考兄弟姐妹';
    if (group.contains(LiuQinType.son)) return '考子女';
    return '';
  }

  /// 构建单个流度表
  Widget _buildLiuDuTable(
    KaoDingLiuQinViewModel viewModel,
    LiuQinType liuQinType,
  ) {
    final entries = viewModel.allEntriesWithTiaoWen[liuQinType] ?? [];
    final selectedNumber = viewModel.getSelectedTiaoWenNumber(liuQinType);

    if (liuQinType.isSpouse) {
      final currentOrdinal = viewModel.getSpouseOrdinal(liuQinType);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('夫妻任次：'),
              const SizedBox(width: 8),
              DropdownButton<SpouseOrdinal>(
                value: currentOrdinal,
                items: SpouseOrdinal.values.map((o) {
                  return DropdownMenuItem<SpouseOrdinal>(
                    value: o,
                    child: Text(o.displayName),
                  );
                }).toList(),
                onChanged: (o) {
                  if (o != null) {
                    viewModel.setSpouseOrdinal(liuQinType, o);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          LiuDuTableSelectionWidget(
            liuQinType: liuQinType,
            entries: entries,
            selectedTiaoWenNumber: selectedNumber,
            onSelect: (number) {
              viewModel.selectTiaoWenForType(liuQinType, number);
            },
          ),
        ],
      );
    }

    if (liuQinType.isSibling) {
      // 兄弟姐妹：并列展示纳比卦甲表与乙表
      final selectedNumberSibling = viewModel.getSelectedTiaoWenNumber(LiuQinType.sibling);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('纳比卦（甲表）', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          LiuDuTableSelectionWidget(
            liuQinType: liuQinType,
            entries: entries,
            selectedTiaoWenNumber: selectedNumberSibling,
            onSelect: (number) {
              viewModel.selectTiaoWenForType(LiuQinType.sibling, number);
            },
          ),
          const SizedBox(height: 12),
          Text('纳比卦（乙表）', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          LiuDuTableSelectionWidget(
            liuQinType: liuQinType,
            entries: viewModel.siblingYiEntriesWithTiaoWen,
            selectedTiaoWenNumber: selectedNumberSibling,
            onSelect: (number) {
              viewModel.selectTiaoWenForType(LiuQinType.sibling, number);
            },
          ),
        ],
      );
    }

    return LiuDuTableSelectionWidget(
      liuQinType: liuQinType,
      entries: entries,
      selectedTiaoWenNumber: selectedNumber,
      onSelect: (number) {
        viewModel.selectTiaoWenForType(liuQinType, number);
      },
    );
  }

  /// 构建兄弟单个子表（甲/乙），用于行内并列展示
  Widget _buildSiblingTable(KaoDingLiuQinViewModel viewModel, {required bool isYi}) {
    final selectedNumber = viewModel.getSelectedTiaoWenNumber(LiuQinType.sibling);
    final entries = isYi
        ? viewModel.siblingYiEntriesWithTiaoWen
        : (viewModel.allEntriesWithTiaoWen[LiuQinType.sibling] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isYi ? '纳比卦（乙表）' : '纳比卦（甲表）', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        LiuDuTableSelectionWidget(
          liuQinType: LiuQinType.sibling,
          entries: entries,
          selectedTiaoWenNumber: selectedNumber,
          onSelect: (number) {
            viewModel.selectTiaoWenForType(LiuQinType.sibling, number);
          },
        ),
      ],
    );
  }

  /// 确认按钮
  Widget _buildConfirmButton(KaoDingLiuQinViewModel viewModel) {
    final theme = Theme.of(context);
    final selectedCount = viewModel.selectedTiaoWenNumbers.length;
    final totalCount = LiuQinType.values.length;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '已选择 $selectedCount / $totalCount 项',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedCount == totalCount
                  ? () => _confirmSelections(viewModel)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('确认选择，进行后续计算'),
            ),
          ),
        ],
      ),
    );
  }

  /// 确认选择
  void _confirmSelections(KaoDingLiuQinViewModel viewModel) {
    final selections = viewModel.confirmSelections();

    // 获取化卦结果（64卦）
    final gua64Results = viewModel.gua64Results;

    // 显示选择结果和化卦结果
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择完成'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '已选择的条文：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...selections.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '${entry.key.displayName}: ${entry.value}',
                  ),
                );
              }),
              if (gua64Results != null && gua64Results.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  '化卦结果：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...gua64Results.entries.map((entry) {
                  final gua64 = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${entry.key.displayName}: ${gua64?.name ?? "无"}',
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 进行后续计算
              _showNextStepDialog();
            },
            child: const Text('继续'),
          ),
        ],
      ),
    );
  }

  /// 显示下一步对话框
  void _showNextStepDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('后续计算'),
        content: const Text('这里可以继续进行后续的计算...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示帮助
  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用说明'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. 系统自动计算所有六亲类型的流度表'),
              SizedBox(height: 8),
              Text('2. 每个流度表显示12个地支对应的条文'),
              SizedBox(height: 8),
              Text('3. 带星标(⭐)的条目是系统推荐的目标条目'),
              SizedBox(height: 8),
              Text('4. 点击任意条目进行选择'),
              SizedBox(height: 8),
              Text('5. 选择完所有六亲类型后，点击"确认选择"继续'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
