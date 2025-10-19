import 'package:common/pages/edit_group_page.dart';
import 'dart:async';

import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/features/tai_yuan/tai_yuan_model.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/themes/gan_zhi_gua_colors.dart';
import 'package:common/widgets/card_row.dart';
import 'package:common/widgets/eight_chars_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../enums/enum_gender.dart';
import '../enums/enum_tian_gan.dart';
import '../models/pillar_data.dart';
import '../repositories/eight_chars_info_repository_impl.dart';
import '../domain/usecases/load_layout_use_case.dart';
import '../domain/usecases/save_layout_use_case.dart';
import '../viewmodels/bazi_card_view_model.dart';
import 'generic_pillar_card.dart';

class BaziDisplayPage extends StatelessWidget {
  final EightChars eightChars;
  final TaiYuanModel taiYuan;
  final JiaZi? keZhu;
  final Gender? gender;

  const BaziDisplayPage({
    Key? key,
    required this.eightChars,
    required this.taiYuan,
    this.keZhu,
    this.gender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final repository = EightCharsInfoRepositoryImpl();
        final loadLayoutUseCase = LoadLayoutUseCase(repository);
        final saveLayoutUseCase = SaveLayoutUseCase(repository);
        return BaziCardViewModel(
          loadLayoutUseCase: loadLayoutUseCase,
          saveLayoutUseCase: saveLayoutUseCase,
        );
      },
      child: Consumer<BaziCardViewModel>(
        builder: (context, viewModel, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.pillarGroups.length,
                  itemBuilder: (context, index) {
                    final group = viewModel.pillarGroups[index];
                    return Stack(
                      children: [
                        GenericPillarCard(
                          title: group.title,
                          pillars: group.pillars,
                          dayMaster: eightChars.dayTianGan,
                          isBenMing: group.isBenMing,
                          gender: gender,
                          showTenGods: group.rowOrder.contains(CardRow.tenGods),
                          showCangGanMain: group.rowOrder.contains(CardRow.cangGanMain),
                          showCangGanMainTenGods: group.rowOrder.contains(CardRow.cangGanMainTenGods),
                          showCangGanZhong: group.rowOrder.contains(CardRow.cangGanZhong),
                          showCangGanZhongTenGods: group.rowOrder.contains(CardRow.cangGanZhongTenGods),
                          showCangGanYu: group.rowOrder.contains(CardRow.cangGanYu),
                          showCangGanYuTenGods: group.rowOrder.contains(CardRow.cangGanYuTenGods),
                          showXunShou: group.rowOrder.contains(CardRow.xunShou),
                          showNaYin: group.rowOrder.contains(CardRow.naYin),
                          showKongWang: group.rowOrder.contains(CardRow.kongWang),
                          isEditMode: viewModel.isEditMode,
                          isColumnReorderMode: viewModel.isColumnReorderMode,
                          onRowReorder: (oldIndex, newIndex) => viewModel.reorderRow(group.id, oldIndex, newIndex),
                          onPillarReorder: (oldIndex, newIndex) => viewModel.reorderPillar(group.id, oldIndex, newIndex),
                        ),
                        if (viewModel.isEditMode)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => viewModel.removeGroup(group.id),
                            ),
                          ),
                        if (viewModel.isEditMode)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider.value(
                                      value: viewModel,
                                      child: EditGroupPage(groupId: group.id),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
                if (viewModel.isEditMode)
                  ElevatedButton(
                    onPressed: () {
                      // Show a dialog to get the new group title
                      showDialog(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController();
                          return AlertDialog(
                            title: const Text('新建分组'),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(hintText: '分组标题'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (controller.text.isNotEmpty) {
                                    viewModel.addGroup(controller.text);
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('确定'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('添加分组'),
                  ),
                // ... OptionChip panel ...
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.center,
                    children: [
                      // Edit Mode Toggle
                      ActionChip(
                        avatar: Icon(viewModel.isEditMode ? Icons.done : Icons.edit_outlined),
                        label: Text(viewModel.isEditMode ? '完成' : '调整顺序'),
                        onPressed: () => viewModel.toggleEditMode(),
                      ),
                      if (viewModel.isEditMode)
                        ActionChip(
                          avatar: Icon(viewModel.isColumnReorderMode ? Icons.view_stream_outlined : Icons.view_column_outlined),
                          label: Text(viewModel.isColumnReorderMode ? '调整柱' : '调整行'),
                          onPressed: () => viewModel.toggleColumnReorderMode(),
                        ),
                      
                      // Toggles for rows
                      _buildOptionChip(context, '十神', viewModel.pillarGroups.any((g) => g.rowOrder.contains(CardRow.tenGods)), (val) => viewModel.toggleRow(CardRow.tenGods, val)),
                      _buildOptionChip(context, '纳音', viewModel.pillarGroups.any((g) => g.rowOrder.contains(CardRow.naYin)), (val) => viewModel.toggleRow(CardRow.naYin, val)),
                      _buildOptionChip(context, '空亡', viewModel.pillarGroups.any((g) => g.rowOrder.contains(CardRow.kongWang)), (val) => viewModel.toggleRow(CardRow.kongWang, val)),
                      _buildOptionChip(context, '旬首', viewModel.pillarGroups.any((g) => g.rowOrder.contains(CardRow.xunShou)), (val) => viewModel.toggleRow(CardRow.xunShou, val)),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionChip(BuildContext context, String label, bool isSelected, ValueChanged<bool> onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}