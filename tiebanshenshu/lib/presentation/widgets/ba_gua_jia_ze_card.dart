import 'package:flutter/material.dart';
import '../models/ba_gua_jia_ze_ui_model.dart';

/// 八卦加则结果卡片组件
///
/// 展示单个八卦加则计算结果，包含卦象、六爻详情、条文内容等信息
/// 支持展开/收起功能，展开后显示详细计算过程
class BaGuaJiaZeCard extends StatelessWidget {
  /// UI模型数据
  final BaGuaJiaZeUIModel model;

  /// 是否默认展开
  final bool initiallyExpanded;

  /// 卡片边距
  final EdgeInsets? margin;

  const BaGuaJiaZeCard({
    super.key,
    required this.model,
    this.initiallyExpanded = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: 1.0,
        child: ExpansionTile(
          title: Text(
            model.fullTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          subtitle: Text(
            '条文: ${model.tiaoWenNumber}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14.0,
            ),
          ),
          initiallyExpanded: initiallyExpanded,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 卦象信息
                  _buildGuaInfo(context),
                  const SizedBox(height: 16.0),

                  // 计算公式
                  _buildFormula(context),
                  const SizedBox(height: 16.0),

                  // 六爻详情（如果有）
                  if (model.hasYaoDetails) ...[
                    _buildYaoDetails(context),
                    const SizedBox(height: 16.0),
                  ],

                  // 条文内容
                  _buildTiaoWenContent(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建卦象信息
  Widget _buildGuaInfo(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.grain,
                  size: 20.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '卦象信息',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 16.0),
            _buildInfoRow('上卦', model.upperGuaDisplayText, context),
            const SizedBox(height: 4.0),
            _buildInfoRow('下卦', model.lowerGuaDisplayText, context),
            const SizedBox(height: 4.0),
            _buildInfoRow('六爻总和', model.yaoSum.toString(), context),
          ],
        ),
      ),
    );
  }

  /// 构建计算公式
  Widget _buildFormula(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  size: 20.0,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '计算公式',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const Divider(height: 16.0),
            Text(
              model.formula,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade900,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建六爻详情
  Widget _buildYaoDetails(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  size: 20.0,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '六爻详情',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const Divider(height: 16.0),
            // 显示六爻，从上到下（索引从5到0）
            ...model.yaoList.reversed.map((yao) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50.0,
                        child: Text(
                          '${yao.positionLabel}爻',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: yao.yinYang == '阳'
                              ? Colors.orange.shade100
                              : Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          yao.yinYang,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: yao.yinYang == '阳'
                                ? Colors.orange.shade900
                                : Colors.purple.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Text(
                        '${yao.diZhi}(${yao.number})',
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// 构建条文内容
  Widget _buildTiaoWenContent(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  size: 20.0,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '条文内容',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const Divider(height: 16.0),
            if (model.hasTiaoWenContent) ...[
              Text(
                model.tiaoWenDisplayText,
                style: const TextStyle(
                  fontSize: 14.0,
                  height: 1.5,
                ),
              ),
              if (model.tiaoWenAgeInfo != null) ...[
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14.0,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      model.tiaoWenAgeInfo!,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ] else ...[
              Text(
                '条文编号: ${model.tiaoWenNumber}\n(暂无条文内容)',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Theme.of(context).colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建信息行（通用）
  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80.0,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// 八卦加则结果列表Widget
///
/// 展示所有八卦加则计算结果，支持按柱分组显示
class BaGuaJiaZeResultsList extends StatelessWidget {
  /// UI模型列表
  final List<BaGuaJiaZeUIModel> models;

  /// 是否按柱分组显示
  final bool groupByPillar;

  /// 是否默认展开第一个
  final bool expandFirst;

  const BaGuaJiaZeResultsList({
    super.key,
    required this.models,
    this.groupByPillar = true,
    this.expandFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('暂无结果'),
        ),
      );
    }

    if (groupByPillar) {
      return _buildGroupedList(context);
    } else {
      return _buildFlatList(context);
    }
  }

  /// 构建分组列表
  Widget _buildGroupedList(BuildContext context) {
    // 按柱名分组
    final grouped = <String, List<BaGuaJiaZeUIModel>>{};
    for (final model in models) {
      grouped.putIfAbsent(model.pillarName, () => []).add(model);
    }

    // 柱顺序
    const pillarOrder = ['年柱', '月柱', '日柱', '时柱'];
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final indexA = pillarOrder.indexOf(a);
        final indexB = pillarOrder.indexOf(b);
        if (indexA == -1 && indexB == -1) return a.compareTo(b);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final pillarName = sortedKeys[index];
        final pillarModels = grouped[pillarName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 柱名标题
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                pillarName,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            // 该柱的结果卡片
            ...pillarModels.asMap().entries.map((entry) {
              final isFirst = index == 0 && entry.key == 0 && expandFirst;
              return BaGuaJiaZeCard(
                model: entry.value,
                initiallyExpanded: isFirst,
              );
            }),
          ],
        );
      },
    );
  }

  /// 构建平铺列表
  Widget _buildFlatList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: models.length,
      itemBuilder: (context, index) {
        return BaGuaJiaZeCard(
          model: models[index],
          initiallyExpanded: index == 0 && expandFirst,
        );
      },
    );
  }
}
