import 'package:common/models/pillar_data.dart';
import 'package:common/models/pillar_group.dart';
import 'package:flutter/foundation.dart';
import 'package:common/widgets/card_row.dart';
import 'package:common/domain/usecases/load_layout_use_case.dart';
import 'package:common/domain/usecases/save_layout_use_case.dart';
import 'package:common/enums/enum_jia_zi.dart';

import '../enums/layout_template_enums.dart';

class BaziCardViewModel extends ChangeNotifier {
  final LoadLayoutUseCase loadLayoutUseCase;
  final SaveLayoutUseCase saveLayoutUseCase;

  BaziCardViewModel({
    required this.loadLayoutUseCase,
    required this.saveLayoutUseCase,
  }) {
    // loadLayout();
    _initializeDefaultGroups();
  }

  // --- STATE VARIABLES ---

  List<PillarGroup> pillarGroups = [];

  // Edit Mode State
  bool isEditMode = false;
  bool isColumnReorderMode = false;

  void _initializeDefaultGroups() {
    pillarGroups = [
      PillarGroup(
        title: '本命',
        isBenMing: true,
        pillars: [
          PillarData(
              pillarId: 'year',
              label: '年',
              pillarType: PillarType.year,
              jiaZi: JiaZi.JIA_ZI),
          PillarData(
              pillarId: 'month',
              label: '月',
              pillarType: PillarType.month,
              jiaZi: JiaZi.JIA_ZI),
          PillarData(
              pillarId: 'day',
              label: '日',
              pillarType: PillarType.day,
              jiaZi: JiaZi.JIA_ZI),
          PillarData(
              pillarId: 'time',
              label: '时',
              pillarType: PillarType.hour,
              jiaZi: JiaZi.JIA_ZI),
        ],
      ),
      PillarGroup(
        title: '流运',
        pillars: [
          PillarData(
              pillarId: 'dayun',
              pillarType: PillarType.luckCycle,
              label: '大运',
              jiaZi: JiaZi.JIA_ZI),
          PillarData(
              pillarId: 'liunian',
              pillarType: PillarType.annual,
              label: '流年',
              jiaZi: JiaZi.JIA_ZI),
          PillarData(
              pillarId: 'liuqi',
              pillarType: PillarType.monthly,
              label: '流月',
              jiaZi: JiaZi.JIA_ZI),
          PillarData(
              pillarId: 'liuji',
              pillarType: PillarType.daily,
              label: '流日',
              jiaZi: JiaZi.JIA_ZI),
          PillarData(
              pillarId: 'liujin',
              pillarType: PillarType.hourly,
              label: '流时',
              jiaZi: JiaZi.JIA_ZI),
          PillarData(
              pillarId: 'liujin',
              pillarType: PillarType.hourly,
              label: '流时',
              jiaZi: JiaZi.JIA_ZI),
        ],
      ),
    ];
    notifyListeners();
  }

  // Future<void> loadLayout() async {
  //   // TODO: Refactor LoadLayoutUseCase to return List<PillarGroup>
  //   // final layoutData = await loadLayoutUseCase.call();
  //   // pillarGroups = layoutData.pillarGroups;
  //   // notifyListeners();
  // }

  // --- PUBLIC METHODS / ACTIONS ---

  void addGroup(String title) {
    pillarGroups.add(PillarGroup(title: title, pillars: []));
    notifyListeners();
    // _saveLayout();
  }

  void removeGroup(String groupId) {
    pillarGroups.removeWhere((group) => group.id == groupId);
    notifyListeners();
    // _saveLayout();
  }

  void toggleEditMode() {
    isEditMode = !isEditMode;
    if (!isEditMode) {
      isColumnReorderMode = false;
    }
    notifyListeners();
  }

  void toggleColumnReorderMode() {
    isColumnReorderMode = !isColumnReorderMode;
    notifyListeners();
  }

  void togglePillarInGroup(
      String groupId, String pillarId, String label, bool isVisible) {
    final groupIndex = pillarGroups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    var group = pillarGroups[groupIndex];
    var pillars = List<PillarData>.from(group.pillars);

    if (isVisible) {
      if (pillars.every((p) => p.pillarId != pillarId)) {
        // Assuming JiaZi.JIA_ZI is a placeholder
        pillars.add(PillarData(
            pillarId: pillarId,
            pillarType: PillarType.daily,
            label: label,
            jiaZi: JiaZi.JIA_ZI));
      }
    } else {
      pillars.removeWhere((p) => p.pillarId == pillarId);
    }

    pillarGroups[groupIndex] = group.copyWith(pillars: pillars);
    notifyListeners();
    // _saveLayout();
  }

  void toggleRow(String row, bool isVisible) {
    for (var i = 0; i < pillarGroups.length; i++) {
      var group = pillarGroups[i];
      var rowOrder = List<String>.from(group.rowOrder);
      if (isVisible) {
        if (!rowOrder.contains(row)) {
          // Simplified insertion logic, you might want to restore the predecessor logic
          rowOrder.add(row);
        }
      } else {
        rowOrder.remove(row);
      }
      pillarGroups[i] = group.copyWith(rowOrder: rowOrder);
    }
    notifyListeners();
    // _saveLayout();
  }

  void reorderRow(String groupId, int oldIndex, int newIndex) {
    final groupIndex = pillarGroups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    var group = pillarGroups[groupIndex];
    var rowOrder = List<String>.from(group.rowOrder);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = rowOrder.removeAt(oldIndex);
    rowOrder.insert(newIndex, item);

    pillarGroups[groupIndex] = group.copyWith(rowOrder: rowOrder);
    notifyListeners();
    // _saveLayout();
  }

  void reorderPillar(String groupId, int oldIndex, int newIndex) {
    final groupIndex = pillarGroups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    var group = pillarGroups[groupIndex];
    var pillarOrder = List<String>.from(group.pillarOrder);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = pillarOrder.removeAt(oldIndex);
    pillarOrder.insert(newIndex, item);

    pillarGroups[groupIndex] = group.copyWith(pillarOrder: pillarOrder);
    notifyListeners();
    // _saveLayout();
  }

  void updateGroup(PillarGroup group) {
    final index = pillarGroups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      pillarGroups[index] = group;
      notifyListeners();
      // _saveLayout();
    }
  }

  // --- PRIVATE HELPERS ---

  // Future<void> _saveLayout() async {
  //   // TODO: Refactor SaveLayoutUseCase to accept List<PillarGroup>
  //   // final params = SaveLayoutParams(pillarGroups: pillarGroups);
  //   // await saveLayoutUseCase.call(params);
  //   // print("Layout Saved!");
  // }
}
