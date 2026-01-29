import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/kao_ding_liu_qin/models/liu_qin_type.dart';
import '../../features/kao_ding_liu_qin/services/kao_ding_liu_qin_strategy.dart';
import '../viewmodels/kao_ding_liu_qin_view_model.dart';

/// 考订六亲结果卡片
///
/// 展示考订六亲的计算结果，包括所有可能的条文编号
class KaoDingLiuQinCard extends StatefulWidget {
  final KaoDingLiuQinViewModel viewModel;
  final bool initiallyExpanded;

  const KaoDingLiuQinCard({
    super.key,
    required this.viewModel,
    this.initiallyExpanded = false,
  });

  @override
  State<KaoDingLiuQinCard> createState() => _KaoDingLiuQinCardState();
}

class _KaoDingLiuQinCardState extends State<KaoDingLiuQinCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Consumer<KaoDingLiuQinViewModel>(
        builder: (context, viewModel, child) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, viewModel),
                if (_isExpanded) ...[
                  const Divider(),
                  _buildContent(context, viewModel),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, KaoDingLiuQinViewModel viewModel) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '考订六亲',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  if (viewModel.hasResult)
                    Text(
                      '${viewModel.currentResult!.liuQinType.displayName} - ${viewModel.currentResult!.pillar.name}',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Row(
              children: [
                // 撤销按钮
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: viewModel.canUndo ? () => viewModel.undo() : null,
                  tooltip: '撤销',
                ),
                // 重做按钮
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: viewModel.canRedo ? () => viewModel.redo() : null,
                  tooltip: '重做',
                ),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, KaoDingLiuQinViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.hasError) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          viewModel.errorMessage ?? '未知错误',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    if (!viewModel.hasResult) {
      return const Padding(padding: EdgeInsets.all(16.0), child: Text('暂无结果'));
    }

    final result = viewModel.currentResult!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfo(context, result, viewModel),
          const SizedBox(height: 16.0),
          _buildTiaoWenResults(context, result, viewModel),
          const SizedBox(height: 16.0),
          _buildCalculationDetail(context, result),
          const SizedBox(height: 16.0),
          _buildHistorySection(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(
    BuildContext context,
    KaoDingLiuQinResult result,
    KaoDingLiuQinViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final gua64 = viewModel.getGua64(result.liuQinType);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '基本信息',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow('六亲类型', result.liuQinType.displayName),
          _buildInfoRow('选择柱', result.pillar.name),
          _buildInfoRow(
            '起卦结果',
            '${result.qiGuaResult.shangGua.name}${result.qiGuaResult.xiaGua.name}',
          ),
          if (result.targetYao != null)
            _buildInfoRow(
              '目标爻',
              '${result.targetYao!.order.name}爻 - ${result.targetYao!.ganZhi?.name ?? ""}',
            ),
          if (result.targetEntry != null) ...[
            _buildInfoRow(
              '流度密码',
              '${result.targetEntry!.chiperText} (${result.targetEntry!.chiperNumber})',
            ),
          ],
          if (gua64 != null) _buildInfoRow('化卦', gua64.name),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 80.0,
            child: Text('$label:', style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTiaoWenResults(
    BuildContext context,
    KaoDingLiuQinResult result,
    KaoDingLiuQinViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '条文结果（共${result.allTiaoWenNumbers.length}个）',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: result.allTiaoWenNumbers.map((number) {
              final isSelected =
                  viewModel.getSelectedTiaoWenNumber(result.liuQinType) ==
                  number;
              return ActionChip(
                label: Text('$number'),
                backgroundColor: isSelected ? theme.colorScheme.primary : null,
                labelStyle: isSelected
                    ? TextStyle(color: theme.colorScheme.onPrimary)
                    : null,
                onPressed: () {
                  viewModel.selectTiaoWenForType(result.liuQinType, number);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationDetail(
    BuildContext context,
    KaoDingLiuQinResult result,
  ) {
    final theme = Theme.of(context);

    return ExpansionTile(
      title: Text(
        '计算详情',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            result.calculationDetail,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    KaoDingLiuQinViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final history = viewModel.history;

    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return ExpansionTile(
      title: Text(
        '历史记录 (${history.length})',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final state = history[index];
            final isCurrentState = viewModel.currentSessionState == state;

            return ListTile(
              dense: true,
              selected: isCurrentState,
              leading: Icon(
                state.hasSelection ? Icons.check_circle : Icons.circle_outlined,
                size: 20,
              ),
              title: Text(state.shortDescription),
              subtitle: Text(
                '${state.timestamp.hour}:${state.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: isCurrentState
                  ? const Icon(Icons.arrow_right, size: 20)
                  : null,
              onTap: () => viewModel.jumpToHistory(index),
            );
          },
        ),
      ],
    );
  }
}
