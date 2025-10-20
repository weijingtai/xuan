import 'package:flutter/material.dart';

import 'pillar_preset_card.dart';
import 'package:provider/provider.dart';
import '../viewmodels/four_zhu_editor_view_model.dart';
import '../enums/layout_template_enums.dart';
import '../viewmodels/pillar_preset_view_model.dart';

class PillarPresetList extends StatelessWidget {
  const PillarPresetList({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PillarPresetViewModel()..initialize(),
      child: Consumer<PillarPresetViewModel>(
        builder: (context, vm, _) {
          final presets = vm.presets;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Toolbar(viewModel: vm),
              const SizedBox(height: 8),
              if (presets.isEmpty)
                const Center(child: Text('暂无柱模板'))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presets
                      .map((p) => PillarPresetCard(
                            preset: p,
                            onTap: () {
                              final vm = context.read<FourZhuEditorViewModel>();
                              final groups = vm.currentTemplate?.chartGroups ?? const [];
                              if (groups.isEmpty) return;
                              // 优先使用选中分组；否则回退到第一个分组
                              final selectedId = vm.selectedGroupId;
                              final current = selectedId == null
                                  ? groups.first
                                  : (groups.firstWhere(
                                        (g) => g.id == selectedId,
                                        orElse: () => groups.first,
                                      ));
                              for (final id in p.pillarIds) {
                                final type = _mapPillarIdToType(id);
                                if (type != null) {
                                  vm.addPillarToGroup(groupId: current.id, pillar: type);
                                }
                              }
                            },
                          ))
                      .toList(),
                ),
            ],
          );
        },
      ),
    );
  }
}

// 简单的 ID->PillarType 映射以便点击模板卡快速添加到当前分组
PillarType? _mapPillarIdToType(String id) {
  switch (id) {
    case 'year':
      return PillarType.year;
    case 'month':
      return PillarType.month;
    case 'day':
      return PillarType.day;
    case 'time':
      return PillarType.hour;
    case 'taiyuan':
      return PillarType.taiMeta;
    case 'dayun':
      return PillarType.luckCycle;
    case 'liunian':
      return PillarType.annual;
  }
  return null;
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.viewModel});
  final PillarPresetViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 220,
          child: TextField(
            onChanged: viewModel.updateKeyword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: '搜索柱模板',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<PillarPresetCategory>(
          value: viewModel.filter.category,
          items: const [
            DropdownMenuItem(value: PillarPresetCategory.all, child: Text('全部')),
            DropdownMenuItem(value: PillarPresetCategory.benming, child: Text('本命')),
            DropdownMenuItem(value: PillarPresetCategory.yunshi, child: Text('运势')),
          ],
          onChanged: (v) => v == null ? null : viewModel.updateCategory(v),
        ),
        const Spacer(),
        DropdownButton<PillarPresetSort>(
          value: viewModel.filter.sort,
          items: const [
            DropdownMenuItem(value: PillarPresetSort.nameAsc, child: Text('名称')),
            DropdownMenuItem(value: PillarPresetSort.updatedDesc, child: Text('更新时间')),
            DropdownMenuItem(value: PillarPresetSort.pillarCountDesc, child: Text('柱位数量')),
          ],
          onChanged: (v) => v == null ? null : viewModel.updateSort(v),
        ),
      ],
    );
  }
}
