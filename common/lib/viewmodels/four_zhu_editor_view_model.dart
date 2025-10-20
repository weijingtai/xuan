import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/usecases/layout_templates/delete_template_use_case.dart';
import '../domain/usecases/layout_templates/get_all_templates_use_case.dart';
import '../domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import '../domain/usecases/layout_templates/save_template_use_case.dart';
import '../enums/layout_template_enums.dart';
import '../models/layout_template.dart';
import '../models/eight_chars.dart';
import '../features/tai_yuan/tai_yuan_model.dart';

enum EditorViewMode { canvas, table, preview }

enum TemplateGalleryCategory { all, favorites, recent }

enum TemplateSortOrder { updatedDesc, nameAsc }

@immutable
class EditorUiState {
  const EditorUiState({
    required this.isLoading,
    required this.isDarkMode,
    required this.canSave,
    required this.canRevert,
    required this.hasUnsavedChanges,
    required this.viewMode,
  });

  final bool isLoading;
  final bool isDarkMode;
  final bool canSave;
  final bool canRevert;
  final bool hasUnsavedChanges;
  final EditorViewMode viewMode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditorUiState &&
        other.isLoading == isLoading &&
        other.isDarkMode == isDarkMode &&
        other.canSave == canSave &&
        other.canRevert == canRevert &&
        other.hasUnsavedChanges == hasUnsavedChanges &&
        other.viewMode == viewMode;
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        isDarkMode,
        canSave,
        canRevert,
        hasUnsavedChanges,
        viewMode,
      );
}

class FourZhuEditorViewModel extends ChangeNotifier {
  FourZhuEditorViewModel({
    required this.getAllTemplatesUseCase,
    required this.getTemplateByIdUseCase,
    required this.saveTemplateUseCase,
    required this.deleteTemplateUseCase,
  });

  final GetAllTemplatesUseCase getAllTemplatesUseCase;
  final GetTemplateByIdUseCase getTemplateByIdUseCase;
  final SaveTemplateUseCase saveTemplateUseCase;
  final DeleteTemplateUseCase deleteTemplateUseCase;

  final Uuid _uuid = const Uuid();

  static const _themePreferenceKey = 'four_zhu_editor:dark_mode';

  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  bool _isDarkMode = false;
  EditorViewMode _viewMode = EditorViewMode.canvas;
  String? _errorMessage;
  String _collectionId = 'default';
  TemplateFilterState _filterState = const TemplateFilterState();

  List<LayoutTemplate> _templates = const [];
  LayoutTemplate? _currentTemplate;
  final Set<String> _favoriteTemplateIds = <String>{};
  final List<String> _recentTemplateIds = <String>[];
  final Set<String> _selectedTemplateIds = <String>{};

  bool get isLoading => _isLoading;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get isDarkMode => _isDarkMode;
  EditorViewMode get viewMode => _viewMode;
  String? get errorMessage => _errorMessage;
  String get collectionId => _collectionId;

  bool get canRevert =>
      !isLoading && _currentTemplate != null && _hasUnsavedChanges;

  List<LayoutTemplate> get templates => _templates;
  LayoutTemplate? get currentTemplate => _currentTemplate;
  CardStyle? get cardStyle => _currentTemplate?.cardStyle;
  List<ChartGroup> get chartGroups => _currentTemplate?.chartGroups ?? const [];
  String? _selectedGroupId;
  String? get selectedGroupId => _selectedGroupId;
  List<RowConfig> get rowConfigs => _currentTemplate?.rowConfigs ?? const [];
  List<LayoutTemplate> get templateTabs => _templates;
  TemplateFilterState get filterState => _filterState;

  Set<String> get selectedTemplateIds => Set.unmodifiable(_selectedTemplateIds);
  bool get hasSelection => _selectedTemplateIds.isNotEmpty;
  bool isTemplateSelected(String templateId) =>
      _selectedTemplateIds.contains(templateId);

  bool get canSave =>
      !isLoading && hasUnsavedChanges && _currentTemplate != null;

  EditorUiState get uiState => EditorUiState(
        isLoading: _isLoading,
        isDarkMode: _isDarkMode,
        canSave: canSave,
        canRevert: canRevert,
        hasUnsavedChanges: _hasUnsavedChanges,
        viewMode: _viewMode,
      );

  // Preview payload for card thumbnails
  EightChars? _previewEightChars;
  TaiYuanModel? _previewTaiYuan;
  EightChars? get previewEightChars => _previewEightChars;
  TaiYuanModel? get previewTaiYuan => _previewTaiYuan;

  void updatePreviewData({EightChars? eightChars, TaiYuanModel? taiYuan}) {
    var changed = false;
    if (eightChars != null && eightChars != _previewEightChars) {
      _previewEightChars = eightChars;
      changed = true;
    }
    if (taiYuan != null && taiYuan != _previewTaiYuan) {
      _previewTaiYuan = taiYuan;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  List<LayoutTemplate> get filteredTemplates =>
      List.unmodifiable(_applyTemplateFilters(_templates));

  bool isFavorite(String templateId) =>
      _favoriteTemplateIds.contains(templateId);

  void toggleFavorite(String templateId) {
    if (_favoriteTemplateIds.contains(templateId)) {
      _favoriteTemplateIds.remove(templateId);
    } else {
      _favoriteTemplateIds.add(templateId);
    }
    notifyListeners();
  }

  void toggleTemplateSelection(String templateId) {
    if (_selectedTemplateIds.contains(templateId)) {
      _selectedTemplateIds.remove(templateId);
    } else {
      _selectedTemplateIds.add(templateId);
    }
    notifyListeners();
  }

  void selectTemplateForBulk(String templateId) {
    if (_selectedTemplateIds.length == 1 &&
        _selectedTemplateIds.contains(templateId)) {
      return;
    }
    _selectedTemplateIds
      ..clear()
      ..add(templateId);
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedTemplateIds.isEmpty) {
      return;
    }
    _selectedTemplateIds.clear();
    notifyListeners();
  }

  void updateSearchKeyword(String keyword) {
    final normalized = keyword.trim();
    if (_filterState.searchKeyword == normalized) {
      return;
    }
    _filterState = _filterState.copyWith(searchKeyword: normalized);
    notifyListeners();
  }

  void updateGalleryCategory(TemplateGalleryCategory category) {
    if (_filterState.category == category) {
      return;
    }
    _filterState = _filterState.copyWith(category: category);
    notifyListeners();
  }

  void updateSortOrder(TemplateSortOrder sortOrder) {
    if (_filterState.sortOrder == sortOrder) {
      return;
    }
    _filterState = _filterState.copyWith(sortOrder: sortOrder);
    notifyListeners();
  }

  Future<void> initialize({required String collectionId}) async {
    _collectionId = collectionId;
    await _loadThemePreference();
    await _withLoading(() async {
      final templates =
          await getAllTemplatesUseCase(collectionId: collectionId);
      if (templates.isEmpty) {
        final template = _buildDefaultTemplate(collectionId: collectionId);
        await saveTemplateUseCase(template: template);
        _templates = [template];
        _currentTemplate = template;
      } else {
        _templates = templates;
        _currentTemplate = templates.first;
      }
      _hasUnsavedChanges = false;
      _errorMessage = null;
      _resetRecentTemplates();
    });
  }

  void toggleTheme(bool value) {
    if (value == _isDarkMode) return;
    _isDarkMode = value;
    notifyListeners();
    unawaited(_persistThemePreference(value));
  }

  void setViewMode(EditorViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }

  Future<void> selectTemplate(String templateId) async {
    if (_currentTemplate?.id == templateId) {
      return;
    }

    await _withLoading(() async {
      final template = await getTemplateByIdUseCase(
        collectionId: _collectionId,
        templateId: templateId,
      );
      if (template != null) {
        _currentTemplate = template;
        _hasUnsavedChanges = false;
        _markRecent(template.id);
      } else {
        _errorMessage = '模板不存在($templateId)';
      }
    });
  }

  Future<void> selectTemplateByTab(String templateId) async {
    await selectTemplate(templateId);
  }

  Future<void> selectTemplateByOffset(int offset) async {
    if (offset == 0 || _templates.isEmpty) {
      return;
    }
    final current = _currentTemplate;
    if (current == null) {
      return;
    }
    final currentIndex =
        _templates.indexWhere((template) => template.id == current.id);
    if (currentIndex == -1) {
      return;
    }
    final targetIndex = (currentIndex + offset).clamp(0, _templates.length - 1);
    if (targetIndex == currentIndex) {
      return;
    }
    await selectTemplate(_templates[targetIndex].id);
  }

  Future<void> createTemplate({String? name}) async {
    final template = _buildDefaultTemplate(
      collectionId: _collectionId,
      name: name?.trim().isNotEmpty == true
          ? name!.trim()
          : _generateTemplateName(),
    );
    _applyCurrentTemplate(template);
    await saveCurrentTemplate();
  }

  Future<void> applyTemplate(String templateId) async {
    await selectTemplate(templateId);
  }

  Future<void> duplicateTemplateAsNew(String templateId) async {
    final source = _findTemplateById(templateId);
    if (source == null) {
      _errorMessage = '模板不存在($templateId)';
      notifyListeners();
      return;
    }

    final duplicated = source.copyWith(
      id: _uuid.v4(),
      name: _generateTemplateName(source.name),
      version: 0,
      updatedAt: DateTime.now(),
    );
    _applyCurrentTemplate(duplicated);
    await saveCurrentTemplate();
  }

  void updateTemplateName(String name) {
    final template = _currentTemplate;
    if (template == null || template.name == name) {
      return;
    }

    final updated = template.copyWith(name: name);
    _applyCurrentTemplate(updated);
  }

  void updateDividerType(BorderType type) {
    final template = _currentTemplate;
    if (template == null) return;
    final updatedStyle = template.cardStyle.copyWith(dividerType: type);
    _applyCurrentTemplate(template.copyWith(cardStyle: updatedStyle));
  }

  void updateDividerColor(String colorHex) {
    final template = _currentTemplate;
    if (template == null) return;
    final updatedStyle = template.cardStyle.copyWith(dividerColorHex: colorHex);
    _applyCurrentTemplate(template.copyWith(cardStyle: updatedStyle));
  }

  void updateDividerThickness(double thickness) {
    final template = _currentTemplate;
    if (template == null) return;
    final updatedStyle =
        template.cardStyle.copyWith(dividerThickness: thickness.clamp(0.5, 8));
    _applyCurrentTemplate(template.copyWith(cardStyle: updatedStyle));
  }

  void updateRowVisibility(RowType type, bool isVisible) {
    final template = _currentTemplate;
    if (template == null) return;
    final configs = template.rowConfigs
        .map((config) => config.type == type
            ? config.copyWith(isVisible: isVisible)
            : config)
        .toList(growable: false);
    _applyCurrentTemplate(template.copyWith(rowConfigs: configs));
  }

  void updateRowTitleVisibility(RowType type, bool isVisible) {
    final template = _currentTemplate;
    if (template == null) return;
    final configs = template.rowConfigs
        .map((config) => config.type == type
            ? config.copyWith(isTitleVisible: isVisible)
            : config)
        .toList(growable: false);
    _applyCurrentTemplate(template.copyWith(rowConfigs: configs));
  }

  void updateRowStyle(
    RowType type, {
    String? fontFamily,
    double? fontSize,
    String? colorHex,
    RowTextAlign? textAlign,
    double? padding,
    BorderType? borderType,
    String? borderColorHex,
  }) {
    final template = _currentTemplate;
    if (template == null) return;
    final updated = template.rowConfigs
        .map((config) => config.type == type
            ? config.copyWith(
                fontFamily: fontFamily ?? config.fontFamily,
                fontSize: fontSize ?? config.fontSize,
                textColorHex: colorHex ?? config.textColorHex,
                textAlign: textAlign ?? config.textAlign,
                padding: padding ?? config.padding,
                borderType: borderType ?? config.borderType,
                borderColorHex: borderColorHex ?? config.borderColorHex,
              )
            : config)
        .toList(growable: false);
    _applyCurrentTemplate(template.copyWith(rowConfigs: updated));
  }

  void resetRowConfigs() {
    final template = _currentTemplate;
    if (template == null) return;
    final defaults =
        _buildDefaultTemplate(collectionId: template.collectionId).rowConfigs;
    _applyCurrentTemplate(template.copyWith(rowConfigs: defaults));
  }

  void updateRowOrder({
    required int oldIndex,
    required int newIndex,
  }) {
    final template = _currentTemplate;
    if (template == null) return;
    if (oldIndex == newIndex) return;

    final list = List<RowConfig>.of(template.rowConfigs);
    if (oldIndex < 0 || oldIndex >= list.length) return;
    final clampedNew = newIndex.clamp(0, list.length - 1);
    final item = list.removeAt(oldIndex);
    list.insert(clampedNew, item);

    _applyCurrentTemplate(template.copyWith(rowConfigs: list));
  }

  Future<void> refreshRowConfigs() async {
    final template = _currentTemplate;
    if (template == null) return;
    await _withLoading(() async {
      final latest = await getTemplateByIdUseCase(
        collectionId: _collectionId,
        templateId: template.id,
      );
      if (latest == null) {
        _errorMessage = '模板不存在(${template.id})';
        return;
      }
      _currentTemplate = latest;
      _templates = _templates
          .map((item) => item.id == latest.id ? latest : item)
          .toList(growable: false);
      _hasUnsavedChanges = false;
      _markRecent(latest.id);
    });
  }

  void reorderPillar({
    required String groupId,
    required int oldIndex,
    required int newIndex,
  }) {
    final template = _currentTemplate;
    if (template == null) return;
    if (oldIndex == newIndex) return;

    final group = _findGroupById(template, groupId);
    if (group == null) return;

    final pillars = List<PillarType>.of(group.pillarOrder);
    final item = pillars.removeAt(oldIndex);
    pillars.insert(newIndex.clamp(0, pillars.length), item);

    final updatedGroups = template.chartGroups
        .map((g) => g.id == groupId ? g.copyWith(pillarOrder: pillars) : g)
        .toList(growable: false);

    _applyCurrentTemplate(template.copyWith(chartGroups: updatedGroups));
  }

  void reorderGroups({
    required int oldIndex,
    required int newIndex,
  }) {
    final template = _currentTemplate;
    if (template == null) return;
    if (oldIndex == newIndex) return;
    final list = List<ChartGroup>.of(template.chartGroups);
    final item = list.removeAt(oldIndex);
    final target = newIndex.clamp(0, list.length);
    list.insert(target, item);
    _applyCurrentTemplate(template.copyWith(chartGroups: list));
  }

  void addPillarToGroup({
    required String groupId,
    required PillarType pillar,
  }) {
    final template = _currentTemplate;
    if (template == null) return;
    final updatedGroups = template.chartGroups.map((group) {
      if (group.id != groupId) return group;
      // 去重：如已存在则跳过
      if (group.pillarOrder.contains(pillar)) return group;
      return group.copyWith(
        pillarOrder: List<PillarType>.of(group.pillarOrder)..add(pillar),
      );
    }).toList(growable: false);
    _applyCurrentTemplate(template.copyWith(chartGroups: updatedGroups));
  }

  void addPillarToGroupAtIndex({
    required String groupId,
    required PillarType pillar,
    required int index,
  }) {
    final template = _currentTemplate;
    if (template == null) return;
    final updatedGroups = template.chartGroups.map((group) {
      if (group.id != groupId) return group;
      // 去重：如已存在则跳过
      if (group.pillarOrder.contains(pillar)) return group;
      final list = List<PillarType>.of(group.pillarOrder);
      final clamped = index.clamp(0, list.length);
      list.insert(clamped, pillar);
      return group.copyWith(pillarOrder: list);
    }).toList(growable: false);
    _applyCurrentTemplate(template.copyWith(chartGroups: updatedGroups));
  }

  void removePillarFromGroup({
    required String groupId,
    required int index,
  }) {
    final template = _currentTemplate;
    if (template == null) return;
    final updatedGroups = template.chartGroups
        .map((group) => group.id == groupId
            ? group.copyWith(
                pillarOrder: () {
                  final list = List<PillarType>.of(group.pillarOrder);
                  if (index >= 0 && index < list.length) {
                    list.removeAt(index);
                  }
                  return list;
                }(),
              )
            : group)
        .toList(growable: false);
    _applyCurrentTemplate(template.copyWith(chartGroups: updatedGroups));
  }

  void insertSeparator({
    required String groupId,
    required int index,
  }) {
    final template = _currentTemplate;
    if (template == null) return;
    final updatedGroups = template.chartGroups.map((group) {
      if (group.id != groupId) return group;
      final list = List<PillarType>.of(group.pillarOrder);
      final clamped = index.clamp(0, list.length);
      list.insert(clamped, PillarType.separator);
      return group.copyWith(pillarOrder: list);
    }).toList(growable: false);
    _applyCurrentTemplate(template.copyWith(chartGroups: updatedGroups));
  }

  void alignPillars(String groupId) {
    // 简单占位：当前不做实际宽度计算，未来可传布局信息
    // 触发一次通知即可
    notifyListeners();
  }

  void setGroupLocked({
    required String groupId,
    required bool locked,
  }) {
    final template = _currentTemplate;
    if (template == null) return;
    final updated = template.chartGroups
        .map((group) => group.id == groupId
            ? group.copyWith(locked: locked)
            : group)
        .toList(growable: false);
    _applyCurrentTemplate(template.copyWith(chartGroups: updated));
  }

  void toggleGroupExpanded({required String groupId}) {
    final template = _currentTemplate;
    if (template == null) return;
    final updated = template.chartGroups.map((group) {
      if (group.id != groupId) return group;
      return group.copyWith(expanded: !group.expanded);
    }).toList(growable: false);
    _applyCurrentTemplate(template.copyWith(chartGroups: updated));
  }

  void selectGroup(String groupId) {
    if (_selectedGroupId == groupId) return;
    _selectedGroupId = groupId;
    notifyListeners();
  }

  void addGroup({String? title}) {
    final template = _currentTemplate;
    if (template == null) return;
    final newGroup = ChartGroup(
      id: _uuid.v4(),
      title: title?.trim().isNotEmpty == true ? title!.trim() : '新分组',
      pillarOrder: const [],
      locked: false,
      colorHex: null,
      expanded: true,
    );
    final updated = List<ChartGroup>.of(template.chartGroups)..add(newGroup);
    _applyCurrentTemplate(template.copyWith(chartGroups: updated));
    _selectedGroupId = newGroup.id;
    notifyListeners();
  }

  void removeGroup(String groupId) {
    final template = _currentTemplate;
    if (template == null) return;
    final updated = template.chartGroups.where((g) => g.id != groupId).toList();
    if (updated.isEmpty) return; // 至少保留一个分组，以免破坏编辑器
    _applyCurrentTemplate(template.copyWith(chartGroups: updated));
    if (_selectedGroupId == groupId) {
      _selectedGroupId = updated.first.id;
    }
    notifyListeners();
  }

  void setGroupTitle({
    required String groupId,
    required String title,
  }) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final template = _currentTemplate;
    if (template == null) return;
    final updated = template.chartGroups
        .map((group) => group.id == groupId
            ? group.copyWith(title: trimmed)
            : group)
        .toList(growable: false);
    _applyCurrentTemplate(template.copyWith(chartGroups: updated));
  }

  void setGroupColor({
    required String groupId,
    required String colorHex,
  }) {
    final template = _currentTemplate;
    if (template == null) return;
    final updated = template.chartGroups
        .map((group) => group.id == groupId
            ? group.copyWith(colorHex: colorHex)
            : group)
        .toList(growable: false);
    _applyCurrentTemplate(template.copyWith(chartGroups: updated));
  }

  void resetGroupLayout({
    required String groupId,
  }) {
    final template = _currentTemplate;
    if (template == null) return;
    final updated = template.chartGroups
        .map((group) => group.id == groupId
            ? group.copyWith(pillarOrder: const [])
            : group)
        .toList(growable: false);
    _applyCurrentTemplate(template.copyWith(chartGroups: updated));
  }

  void clearGroup({required String groupId}) {
    resetGroupLayout(groupId: groupId);
  }

  void duplicateGroup({required String groupId}) {
    final template = _currentTemplate;
    if (template == null) return;
    final groups = List<ChartGroup>.of(template.chartGroups);
    final index = groups.indexWhere((g) => g.id == groupId);
    if (index < 0) return;
    final source = groups[index];
    final copy = ChartGroup(
      id: _uuid.v4(),
      title: _generateGroupName(source.title),
      pillarOrder: List<PillarType>.of(source.pillarOrder),
      locked: source.locked,
      colorHex: source.colorHex,
      expanded: source.expanded,
    );
    groups.insert(index + 1, copy);
    _applyCurrentTemplate(template.copyWith(chartGroups: groups));
    _selectedGroupId = copy.id;
    notifyListeners();
  }

  String _generateGroupName(String base) {
    final prefix = base.isNotEmpty ? base : '新分组';
    final existing = (_currentTemplate?.chartGroups ?? const [])
        .map((g) => g.title)
        .toSet();
    if (!existing.contains('$prefix (副本)')) return '$prefix (副本)';
    var i = 2;
    while (existing.contains('$prefix (副本 $i)')) {
      i += 1;
    }
    return '$prefix (副本 $i)';
  }

  Future<void> saveCurrentTemplate() async {
    final template = _currentTemplate;
    if (template == null) return;

    await _withLoading(() async {
      await saveTemplateUseCase(template: template);
      _hasUnsavedChanges = false;
      final refreshed =
          await getAllTemplatesUseCase(collectionId: _collectionId);
      _templates = refreshed;
      _currentTemplate =
          _findTemplateInList(refreshed, template.id) ?? template;
    });
  }

  Future<void> deleteCurrentTemplate() async {
    final template = _currentTemplate;
    if (template == null) return;

    await _withLoading(() async {
      await deleteTemplateUseCase(
        collectionId: template.collectionId,
        templateId: template.id,
      );
      final refreshed =
          await getAllTemplatesUseCase(collectionId: _collectionId);
      if (refreshed.isEmpty) {
        final fallback = _buildDefaultTemplate(collectionId: _collectionId);
        await saveTemplateUseCase(template: fallback);
        _templates = [fallback];
        _currentTemplate = fallback;
      } else {
        _templates = refreshed;
        _currentTemplate = refreshed.first;
      }
      _hasUnsavedChanges = false;
    });
  }

  Future<void> duplicateCurrentTemplate() async {
    final template = _currentTemplate;
    if (template == null) return;

    final duplicated = template.copyWith(
      id: _uuid.v4(),
      name: _generateTemplateName(template.name),
      version: 0,
      updatedAt: DateTime.now(),
    );
    _applyCurrentTemplate(duplicated);
    await saveCurrentTemplate();
  }

  Future<void> deleteSelectedTemplates() async {
    if (_selectedTemplateIds.isEmpty) {
      return;
    }
    final targets = List<String>.from(_selectedTemplateIds);
    await _withLoading(() async {
      for (final templateId in targets) {
        await deleteTemplateUseCase(
          collectionId: _collectionId,
          templateId: templateId,
        );
        _favoriteTemplateIds.remove(templateId);
        _recentTemplateIds.remove(templateId);
      }
      final refreshed =
          await getAllTemplatesUseCase(collectionId: _collectionId);
      if (refreshed.isEmpty) {
        final fallback = _buildDefaultTemplate(collectionId: _collectionId);
        await saveTemplateUseCase(template: fallback);
        _templates = [fallback];
        _currentTemplate = fallback;
      } else {
        final currentId = _currentTemplate?.id;
        _templates = refreshed;
        if (currentId != null) {
          _currentTemplate = refreshed.firstWhere(
            (item) => item.id == currentId,
            orElse: () => refreshed.first,
          );
        } else {
          _currentTemplate = refreshed.first;
        }
      }
      _hasUnsavedChanges = false;
      _errorMessage = null;
      _resetRecentTemplates();
    });
    clearSelection();
  }

  Future<void> duplicateSelectedTemplates() async {
    if (_selectedTemplateIds.isEmpty) {
      return;
    }
    final targets = List<String>.from(_selectedTemplateIds);
    for (final templateId in targets) {
      await duplicateTemplateAsNew(templateId);
    }
    clearSelection();
  }

  Future<void> renameTemplate(String templateId, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final template = _findTemplateById(templateId);
    if (template == null || template.name == trimmed) {
      return;
    }
    final updated = template.copyWith(
      name: trimmed,
      updatedAt: DateTime.now(),
      version: template.version + 1,
    );
    await _withLoading(() async {
      await saveTemplateUseCase(template: updated);
      final refreshed =
          await getAllTemplatesUseCase(collectionId: _collectionId);
      if (refreshed.isEmpty) {
        final fallback = _buildDefaultTemplate(collectionId: _collectionId);
        await saveTemplateUseCase(template: fallback);
        _templates = [fallback];
        _currentTemplate = fallback;
      } else {
        _templates = refreshed;
        _currentTemplate = refreshed.firstWhere(
          (item) => item.id == (_currentTemplate?.id ?? updated.id),
          orElse: () => refreshed.first,
        );
      }
      _hasUnsavedChanges = false;
      _errorMessage = null;
      _resetRecentTemplates();
    });
  }

  Future<void> revertChanges() async {
    final template = _currentTemplate;
    if (template == null) {
      return;
    }

    await _withLoading(() async {
      final latest = await getTemplateByIdUseCase(
        collectionId: _collectionId,
        templateId: template.id,
      );
      if (latest == null) {
        _errorMessage = '?????(${template.id})';
        return;
      }
      _currentTemplate = latest;
      _hasUnsavedChanges = false;
      _templates = _templates
          .map((item) => item.id == latest.id ? latest : item)
          .toList(growable: false);
      _markRecent(latest.id);
    });
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  LayoutTemplate _buildDefaultTemplate({
    required String collectionId,
    String? name,
  }) {
    final now = DateTime.now();
    return LayoutTemplate(
      id: _uuid.v4(),
      name: name ?? '默认模板',
      collectionId: collectionId,
      cardStyle: const CardStyle(
        dividerType: BorderType.solid,
        dividerColorHex: '#FF334155',
        dividerThickness: 1.0,
        globalFontFamily: 'NotoSans',
        globalFontSize: 14,
        globalFontColorHex: '#FF0F172A',
      ),
      chartGroups: [
        ChartGroup(
          id: _uuid.v4(),
          title: '流年盘',
          pillarOrder: const [
            PillarType.year,
            PillarType.month,
            PillarType.day,
            PillarType.hour,
          ],
        ),
      ],
      rowConfigs: const [
        RowConfig(
          type: RowType.heavenlyStem,
          isVisible: true,
          isTitleVisible: true,
        ),
        RowConfig(
          type: RowType.earthlyBranch,
          isVisible: true,
          isTitleVisible: true,
        ),
        RowConfig(
          type: RowType.tenGod,
          isVisible: true,
          isTitleVisible: true,
        ),
        RowConfig(
          type: RowType.hiddenStems,
          isVisible: true,
          isTitleVisible: true,
        ),
      ],
      version: 1,
      updatedAt: now,
    );
  }

  void _applyCurrentTemplate(LayoutTemplate template) {
    _currentTemplate = template;
    _hasUnsavedChanges = true;
    _templates = List<LayoutTemplate>.of(_templates);
    final index = _templates.indexWhere((item) => item.id == template.id);
    if (index >= 0) {
      _templates[index] = template;
    } else {
      _templates.add(template);
    }
    _markRecent(template.id);
    notifyListeners();
  }

  LayoutTemplate? _findTemplateById(String templateId) {
    for (final template in _templates) {
      if (template.id == templateId) {
        return template;
      }
    }
    return null;
  }

  ChartGroup? _findGroupById(LayoutTemplate template, String groupId) {
    for (final group in template.chartGroups) {
      if (group.id == groupId) {
        return group;
      }
    }
    return null;
  }

  LayoutTemplate? _findTemplateInList(
      List<LayoutTemplate> items, String templateId) {
    for (final template in items) {
      if (template.id == templateId) {
        return template;
      }
    }
    return null;
  }

  String _generateTemplateName([String? base]) {
    final prefix = base?.isNotEmpty == true ? base! : '新模板';
    final existingNames = _templates.map((template) => template.name).toSet();
    if (!existingNames.contains(prefix)) {
      return prefix;
    }
    var index = 1;
    while (existingNames.contains('$prefix $index')) {
      index += 1;
    }
    return '$prefix $index';
  }

  void _markRecent(String templateId) {
    _recentTemplateIds.remove(templateId);
    _recentTemplateIds.insert(0, templateId);
    if (_recentTemplateIds.length > 20) {
      _recentTemplateIds.removeRange(20, _recentTemplateIds.length);
    }
  }

  void _resetRecentTemplates() {
    _recentTemplateIds
      ..clear()
      ..addAll(_templates.map((template) => template.id));
  }

  List<LayoutTemplate> _applyTemplateFilters(List<LayoutTemplate> source) {
    final keyword = _filterState.searchKeyword.toLowerCase();
    Iterable<LayoutTemplate> filtered = source;

    switch (_filterState.category) {
      case TemplateGalleryCategory.all:
        break;
      case TemplateGalleryCategory.favorites:
        filtered = filtered.where(
          (template) => _favoriteTemplateIds.contains(template.id),
        );
        break;
      case TemplateGalleryCategory.recent:
        final order = _recentTemplateIds.toList();
        filtered = filtered
            .where((template) => order.contains(template.id))
            .toList()
          ..sort((a, b) => order.indexOf(a.id).compareTo(order.indexOf(b.id)));
        break;
    }

    var result = filtered.toList();

    if (keyword.isNotEmpty) {
      result = result
          .where(
            (template) => template.name.toLowerCase().contains(keyword),
          )
          .toList();
    }

    switch (_filterState.sortOrder) {
      case TemplateSortOrder.updatedDesc:
        result.sort(
          (a, b) => b.updatedAt.compareTo(a.updatedAt),
        );
        break;
      case TemplateSortOrder.nameAsc:
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
    }

    return result;
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getBool(_themePreferenceKey);
    if (stored != null && stored != _isDarkMode) {
      _isDarkMode = stored;
      notifyListeners();
    }
  }

  Future<void> _persistThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePreferenceKey, isDarkMode);
  }

  Future<void> _withLoading(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

@immutable
class TemplateFilterState {
  const TemplateFilterState({
    this.searchKeyword = '',
    this.category = TemplateGalleryCategory.all,
    this.sortOrder = TemplateSortOrder.updatedDesc,
  });

  final String searchKeyword;
  final TemplateGalleryCategory category;
  final TemplateSortOrder sortOrder;

  TemplateFilterState copyWith({
    String? searchKeyword,
    TemplateGalleryCategory? category,
    TemplateSortOrder? sortOrder,
  }) {
    return TemplateFilterState(
      searchKeyword: searchKeyword ?? this.searchKeyword,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemplateFilterState &&
        other.searchKeyword == searchKeyword &&
        other.category == category &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode => Object.hash(searchKeyword, category, sortOrder);
}
