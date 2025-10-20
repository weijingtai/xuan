import 'package:flutter/material.dart';

import '../models/pillar_preset.dart';

enum PillarPresetCategory { all, benming, yunshi }
enum PillarPresetSort { nameAsc, updatedDesc, pillarCountDesc }

@immutable
class PillarPresetFilterState {
  const PillarPresetFilterState({
    this.keyword = '',
    this.category = PillarPresetCategory.all,
    this.sort = PillarPresetSort.updatedDesc,
  });

  final String keyword;
  final PillarPresetCategory category;
  final PillarPresetSort sort;

  PillarPresetFilterState copyWith({
    String? keyword,
    PillarPresetCategory? category,
    PillarPresetSort? sort,
  }) => PillarPresetFilterState(
        keyword: keyword ?? this.keyword,
        category: category ?? this.category,
        sort: sort ?? this.sort,
      );
}

class PillarPresetViewModel extends ChangeNotifier {
  PillarPresetFilterState _filter = const PillarPresetFilterState();
  List<PillarPreset> _presets = const [];

  PillarPresetFilterState get filter => _filter;
  List<PillarPreset> get presets => _applyFilter(_presets);

  void initialize() {
    _presets = [
      PillarPreset(
        id: 'p1',
        name: '本命四柱',
        scene: '本命',
        pillarIds: const ['year', 'month', 'day', 'time'],
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        favorite: true,
      ),
      PillarPreset(
        id: 'p2',
        name: '大运流年',
        scene: '运势',
        pillarIds: const ['dayun', 'liunian'],
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      PillarPreset(
        id: 'p3',
        name: '年月时',
        scene: '快速',
        pillarIds: const ['year', 'month', 'time'],
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
    notifyListeners();
  }

  void updateKeyword(String keyword) {
    final k = keyword.trim();
    if (k == _filter.keyword) return;
    _filter = _filter.copyWith(keyword: k);
    notifyListeners();
  }

  void updateCategory(PillarPresetCategory category) {
    if (category == _filter.category) return;
    _filter = _filter.copyWith(category: category);
    notifyListeners();
  }

  void updateSort(PillarPresetSort sort) {
    if (sort == _filter.sort) return;
    _filter = _filter.copyWith(sort: sort);
    notifyListeners();
  }

  List<PillarPreset> _applyFilter(List<PillarPreset> source) {
    Iterable<PillarPreset> filtered = source;
    if (_filter.category != PillarPresetCategory.all) {
      filtered = filtered.where((p) => p.scene ==
          (_filter.category == PillarPresetCategory.benming ? '本命' : '运势'));
    }
    var result = filtered.toList();
    if (_filter.keyword.isNotEmpty) {
      final kw = _filter.keyword.toLowerCase();
      result = result
          .where((p) => p.name.toLowerCase().contains(kw) || p.scene.toLowerCase().contains(kw))
          .toList();
    }
    switch (_filter.sort) {
      case PillarPresetSort.nameAsc:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case PillarPresetSort.updatedDesc:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case PillarPresetSort.pillarCountDesc:
        result.sort((a, b) => b.pillarIds.length.compareTo(a.pillarIds.length));
        break;
    }
    return result;
  }
}

