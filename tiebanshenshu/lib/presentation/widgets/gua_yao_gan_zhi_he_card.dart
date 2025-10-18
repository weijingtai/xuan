import 'package:flutter/material.dart';
import '../../domain/models/gua_yao_gan_zhi_he_base_number_model.dart';
import '../viewmodels/gua_yao_gan_zhi_he_view_model.dart';

/// 卦爻干支和数法条文列表卡片
///
/// 展示卦爻干支和数法的计算结果，包含纳甲方法切换功能
class GuaYaoGanZhiHeCard extends StatefulWidget {
  final GuaYaoGanZhiHeViewModel viewModel;
  final bool initiallyExpanded;

  const GuaYaoGanZhiHeCard({
    super.key,
    required this.viewModel,
    this.initiallyExpanded = false,
  });

  @override
  State<GuaYaoGanZhiHeCard> createState() => _GuaYaoGanZhiHeCardState();
}

class _GuaYaoGanZhiHeCardState extends State<GuaYaoGanZhiHeCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区域
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '卦爻干支和数法',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            PopupMenuButton<GuaYaoGanZhiHeNaJiaMethod>(
                              tooltip: '切换纳甲方法',
                              icon: Icon(
                                Icons.swap_horiz,
                                color: theme.colorScheme.primary,
                                size: 20.0,
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value:
                                      GuaYaoGanZhiHeNaJiaMethod.yearGanYinYang,
                                  child: Row(
                                    children: [
                                      if (widget.viewModel.currentNaJiaMethod ==
                                          GuaYaoGanZhiHeNaJiaMethod
                                              .yearGanYinYang)
                                        const Icon(Icons.check, size: 16.0),
                                      if (widget.viewModel.currentNaJiaMethod !=
                                          GuaYaoGanZhiHeNaJiaMethod
                                              .yearGanYinYang)
                                        const SizedBox(width: 16.0),
                                      const SizedBox(width: 8.0),
                                      const Text('年干阴阳纳甲法'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value:
                                      GuaYaoGanZhiHeNaJiaMethod.innerOuterGua,
                                  child: Row(
                                    children: [
                                      if (widget.viewModel.currentNaJiaMethod ==
                                          GuaYaoGanZhiHeNaJiaMethod
                                              .innerOuterGua)
                                        const Icon(Icons.check, size: 16.0),
                                      if (widget.viewModel.currentNaJiaMethod !=
                                          GuaYaoGanZhiHeNaJiaMethod
                                              .innerOuterGua)
                                        const SizedBox(width: 16.0),
                                      const SizedBox(width: 8.0),
                                      const Text('传统内外卦纳甲法'),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (method) {
                                // widget.viewModel.switchNaJiaMethod(method);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '当前方法：${widget.viewModel.currentNaJiaMethod.displayName}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),

          // 可展开内容
          if (_isExpanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildContent(theme),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final domainResult = widget.viewModel.domainResult;

    if (domainResult == null) {
      return const Center(child: Text('无计算结果'));
    }

    // 获取所有GuaYaoGanZhiHeBaseNumberModel
    final baseNumberModels = domainResult.baseNumberTiaoWenList
        .whereType<GuaYaoGanZhiHeBaseNumberModel>()
        .toList();

    if (baseNumberModels.isEmpty) {
      return const Center(child: Text('无计算结果'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 统计信息
        _buildStatistics(theme, domainResult),
        const SizedBox(height: 16.0),

        // 四柱结果列表
        ...baseNumberModels.map((model) => _buildPillarCard(theme, model)),
      ],
    );
  }

  Widget _buildStatistics(ThemeData theme, dynamic result) {
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
            '计算统计',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          _buildStatRow(
            '纳甲方法',
            widget.viewModel.currentNaJiaMethod.displayName,
            theme,
          ),
          _buildStatRow('四柱数量', '4', theme),
          _buildStatRow('条文总数', '${result.tiaoWenEntities.length}', theme),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 80.0,
            child: Text('$label:', style: theme.textTheme.bodySmall),
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

  Widget _buildPillarCard(
    ThemeData theme,
    GuaYaoGanZhiHeBaseNumberModel model,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ExpansionTile(
        title: Text(
          '${model.pillarName} - ${model.ganzhi.name}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '基础数: ${model.baseNumber} | ${model.gua64.name}',
          style: theme.textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 卦象信息
                _buildGuaInfo(theme, model),
                const Divider(height: 24.0),

                // 爻位详情
                _buildYaoDetails(theme, model),
                const Divider(height: 24.0),

                // 计算公式
                _buildFormula(theme, model),

                // 条文内容列表
                if (model.tiaoWenDataList.isNotEmpty) ...[
                  const Divider(height: 24.0),
                  _buildTiaoWenList(theme, model),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuaInfo(ThemeData theme, GuaYaoGanZhiHeBaseNumberModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '卦象信息',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        _buildInfoRow('64卦', model.gua64.name, theme),
        _buildInfoRow('上卦', model.upperGua.name, theme),
        _buildInfoRow('下卦', model.lowerGua.name, theme),
      ],
    );
  }

  Widget _buildYaoDetails(
    ThemeData theme,
    GuaYaoGanZhiHeBaseNumberModel model,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '爻位详情（由下至上）',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        ...model.yaoDetails.map((detail) => _buildYaoRow(theme, detail)),
        const Divider(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '下卦和数：${model.lowerGuaSum}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              '上卦和数：${model.upperGuaSum}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildYaoRow(ThemeData theme, GuaYaoGanZhiHeYaoDetail detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 60.0,
            child: Text(
              '${detail.yaoPositionName}:',
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              '${detail.naTianGan.name}${detail.naDiZhi.name} = ${detail.ganTaiXuanNumber}+${detail.zhiTaiXuanNumber} = ${detail.yaoSum}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: detail.isFiltered
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                    : null,
                decoration: detail.isFiltered
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          if (detail.isFiltered)
            Icon(
              Icons.filter_alt_off,
              size: 16.0,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
        ],
      ),
    );
  }

  Widget _buildFormula(ThemeData theme, GuaYaoGanZhiHeBaseNumberModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '计算公式',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8.0),
          ),
          width: double.infinity,
          child: Text(
            model.formula,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 60.0,
            child: Text('$label:', style: theme.textTheme.bodySmall),
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

  /// 构建条文内容列表
  Widget _buildTiaoWenList(
    ThemeData theme,
    GuaYaoGanZhiHeBaseNumberModel model,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '条文内容（共${model.tiaoWenDataList.length}条）',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12.0),
        ...model.tiaoWenDataList.map((tiaowen) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 条文编号和标签
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        '编号: ${tiaowen.id}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        tiaowen.setName.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),

                // 条文内容
                Text(tiaowen.content1, style: theme.textTheme.bodyMedium),
                if (tiaowen.content2 != null &&
                    tiaowen.content2!.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    tiaowen.content2!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
