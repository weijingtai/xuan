import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../commands/commands.dart';
import '../domain/usecases/layout_templates/delete_template_use_case.dart';
import '../domain/usecases/layout_templates/get_all_templates_use_case.dart';
import '../domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import '../domain/usecases/layout_templates/save_template_use_case.dart';
import '../enums/enum_ten_gods.dart';
import '../enums/enum_tian_gan.dart';
import '../const_resources_mapper.dart';
import '../enums/enum_di_zhi.dart';
import '../enums/enum_gender.dart';
import '../enums/enum_jia_zi.dart';
import '../enums/layout_template_enums.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/internal/card_size_manager.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/models/base_style_config.dart';
import '../features/shared_card_template/usecase/install_market_template_usecase.dart';
import '../models/layout_template.dart';
import '../models/text_style_config.dart';
import '../models/eight_chars.dart';
import '../models/template_preset.dart';
import '../models/drag_payloads.dart';
import '../models/pillar_content.dart';
import '../models/row_strategy.dart';
import '../features/tai_yuan/tai_yuan_model.dart';
import '../database/daos/card_template_meta_dao.dart';
import '../database/daos/card_template_skill_usage_dao.dart';
import '../database/daos/card_template_setting_dao.dart';
import '../services/card_template_setting_overlay.dart';
import '../themes/editable_four_zhu_card_theme.dart';

enum EditorViewMode { canvas, table, preview }

enum TemplateGalleryCategory { all, favorites, recent }

enum TemplateSortOrder { updatedDesc, nameAsc }

abstract interface class LayoutTemplateTelemetry {
  void debug(String event, {Map<String, Object?>? data});
  void info(String event, {Map<String, Object?>? data});
  void warn(String event, {Map<String, Object?>? data, Object? error});
  void error(
    String event, {
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  });

  factory LayoutTemplateTelemetry.noop() => _NoopLayoutTemplateTelemetry();
  factory LayoutTemplateTelemetry.logger() => _LoggerLayoutTemplateTelemetry();
}

class _NoopLayoutTemplateTelemetry implements LayoutTemplateTelemetry {
  @override
  void debug(String event, {Map<String, Object?>? data}) {}

  @override
  void info(String event, {Map<String, Object?>? data}) {}

  @override
  void warn(String event, {Map<String, Object?>? data, Object? error}) {}

  @override
  void error(
    String event, {
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {}
}

class _LoggerLayoutTemplateTelemetry implements LayoutTemplateTelemetry {
  _LoggerLayoutTemplateTelemetry()
      : _logger = Logger(
          level: kReleaseMode ? Level.info : Level.debug,
          printer: kReleaseMode
              ? SimplePrinter(printTime: false)
              : PrettyPrinter(
                  methodCount: 1,
                  errorMethodCount: 8,
                  lineLength: 140,
                  colors: true,
                  printEmojis: true,
                ),
        );

  final Logger _logger;

  String _fmt(String event, Map<String, Object?>? data) {
    if (data == null || data.isEmpty) return '[layout_template] $event';
    return '[layout_template] $event $data';
  }

  @override
  void debug(String event, {Map<String, Object?>? data}) {
    if (kReleaseMode) return;
    _logger.d(_fmt(event, data));
  }

  @override
  void info(String event, {Map<String, Object?>? data}) {
    _logger.i(_fmt(event, data));
  }

  @override
  void warn(String event, {Map<String, Object?>? data, Object? error}) {
    _logger.w(_fmt(event, data), error: error);
  }

  @override
  void error(
    String event, {
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(_fmt(event, data), error: error, stackTrace: stackTrace);
  }
}

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
    this.installMarketTemplateUseCase,
    this.cardTemplateMetaDao,
    this.cardTemplateSettingDao,
    this.cardTemplateSkillUsageDao,
    LayoutTemplateTelemetry? templateTelemetry,
  }) : _templateTelemetry = templateTelemetry ?? LayoutTemplateTelemetry.logger() {
    _initRuntimeNotifiers();
  }

  /// Card尺寸管理器，用于清除缓存和触发尺寸重新计算
  CardSizeManager? cardSizeManager;

  final GetAllTemplatesUseCase getAllTemplatesUseCase;
  final GetTemplateByIdUseCase getTemplateByIdUseCase;
  final SaveTemplateUseCase saveTemplateUseCase;
  final DeleteTemplateUseCase deleteTemplateUseCase;
  final InstallMarketTemplateUseCase? installMarketTemplateUseCase;
  final CardTemplateMetaDao? cardTemplateMetaDao;
  final CardTemplateSettingDao? cardTemplateSettingDao;
  final CardTemplateSkillUsageDao? cardTemplateSkillUsageDao;

  final Uuid _uuid = const Uuid();
  final CommandHistory _commandHistory = CommandHistory(maxHistorySize: 50);
  final LayoutTemplateTelemetry _templateTelemetry;

  late final Map<RowType, RowComputationStrategy> rowStrategyMapper;
  late final Map<PillarType, PillarComputationStrategy> pillarStrategyMapper;
  late final ValueNotifier<EditableFourZhuCardTheme> editableThemeNotifier;
  late final ValueNotifier<Brightness> cardBrightnessNotifier;
  late final ValueNotifier<ColorPreviewMode> colorPreviewModeNotifier;
  late final ValueNotifier<EdgeInsets> paddingNotifier;
  late final ValueNotifier<CardPayload> cardPayloadNotifier;

  static const _themePreferenceKey = 'four_zhu_editor:dark_mode';
  static const String _publicTemplatesCollectionId = '__public_default__';

  bool _isLoading = false;
  bool _isBootstrappingTemplates = false;
  bool _bootstrapInFlight = false;
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
  String? _selectedPresetId; // 当前选中的预设ID

  String? _usageQueryUuid;
  int? _usageSkillId;

  bool get isLoading => _isLoading || _isBootstrappingTemplates;
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
  List<String> get recentTemplateIds => List.unmodifiable(_recentTemplateIds);

  Set<String> get selectedTemplateIds => Set.unmodifiable(_selectedTemplateIds);
  bool get hasSelection => _selectedTemplateIds.isNotEmpty;
  bool isTemplateSelected(String templateId) =>
      _selectedTemplateIds.contains(templateId);
  String? get selectedPresetId => _selectedPresetId;

  bool get canSave =>
      !isLoading && hasUnsavedChanges && _currentTemplate != null;

  // 撤销/重做支持
  bool get canUndo => _commandHistory.canUndo;
  bool get canRedo => _commandHistory.canRedo;
  int get undoCount => _commandHistory.undoCount;
  int get redoCount => _commandHistory.redoCount;

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

  // 临时逐字颜色覆盖（不持久化）：用于在编辑器中实时预览用户修改的单个字符颜色
  Map<TianGan, Color>? _perGanColorOverrides;
  Map<DiZhi, Color>? _perZhiColorOverrides;
  Map<TianGan, Color>? get perGanColorOverrides => _perGanColorOverrides;
  Map<DiZhi, Color>? get perZhiColorOverrides => _perZhiColorOverrides;

  void updatePreviewData({EightChars? eightChars, TaiYuanModel? taiYuan}) {
    var changed = false;
    if (eightChars != null && eightChars != _previewEightChars) {
      _previewEightChars = eightChars;
      cardPayloadNotifier.value = _buildDefaultCardPayload(
        eightChars: eightChars,
        gender: cardPayloadNotifier.value.gender,
      );
      changed = true;
    }
    if (taiYuan != null && taiYuan != _previewTaiYuan) {
      _previewTaiYuan = taiYuan;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void setUsageContext({String? queryUuid, int? skillId}) {
    _usageQueryUuid = queryUuid;
    _usageSkillId = skillId;
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

  void reorderPillarsInGroup(String groupId, int oldIndex, int newIndex) {
    if (_currentTemplate == null) return;

    // 适配 ReorderableListView 的行为：如果向下拖动，newIndex 会包含被移动项原本的空间
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    reorderPillar(
      groupId: groupId,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
  }

  void updatePillarOrderInGroup(String groupId, List<PillarType> newOrder) {
    final template = _currentTemplate;
    if (template == null) return;

    final oldGroup = _findGroupById(template, groupId);
    if (oldGroup == null) return;

    final newGroup = oldGroup.copyWith(pillarOrder: newOrder);

    // M4.3.2 - 使用Command模式
    final command = UpdateGroupCommand(
      groupId: groupId,
      oldGroup: oldGroup,
      newGroup: newGroup,
      customDescription: '更新分组排序',
    );
    _executeCommand(command);
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
    cardBrightnessNotifier.value =
        _isDarkMode ? Brightness.dark : Brightness.light;

    await _withLoading(() async {
      final templates =
          await getAllTemplatesUseCase(collectionId: collectionId);
      if (templates.isEmpty) {
        _templates = const [];
        _currentTemplate = null;
        _isBootstrappingTemplates = true;
      } else {
        _templates = List.of(templates);
        var current = _templates.first;
        final migrated = await _migrateLegacyDefaultTemplate(current);
        if (migrated != current) {
          _templates[0] = migrated;
          current = migrated;
        }
        _currentTemplate = current;
        _isBootstrappingTemplates = false;
      }
      _hasUnsavedChanges = false;
      _errorMessage = null;
      _resetRecentTemplates();
    });

    if (_currentTemplate == null) {
      await _bootstrapFromPublicTemplatesIfNeeded();
    }

    final template = _currentTemplate;
    if (template != null) {
      _syncRuntimeStateFromTemplate(template);
      await _loadAndApplyTemplateSetting(
        templateUuid: template.id,
        skillId: _usageSkillId,
      );
    }
  }

  Future<void> refreshTemplates() async {
    final collectionId = _collectionId;
    if (collectionId.isEmpty) return;

    await _withLoading(() async {
      final templates =
          await getAllTemplatesUseCase(collectionId: collectionId);
      if (templates.isEmpty) {
        _templates = const [];
        _currentTemplate = null;
        _isBootstrappingTemplates = true;
        return;
      }

      final currentId = _currentTemplate?.id;
      _templates = List.of(templates);
      _isBootstrappingTemplates = false;

      if (_hasUnsavedChanges) return;

      if (currentId == null || currentId.isEmpty) {
        _currentTemplate = _templates.first;
        return;
      }

      _currentTemplate = _templates.firstWhere(
        (t) => t.id == currentId,
        orElse: () => _templates.first,
      );
    });

    if (_currentTemplate == null) {
      await _bootstrapFromPublicTemplatesIfNeeded();
    }

    final template = _currentTemplate;
    if (template != null && !_hasUnsavedChanges) {
      _syncRuntimeStateFromTemplate(template);
    }
  }

  Future<void> installMarketTemplate({
    required String marketTemplateId,
    required String marketVersionId,
    String? nameOverride,
    bool switchToInstalled = false,
  }) async {
    final useCase = installMarketTemplateUseCase;
    if (useCase == null) {
      _errorMessage = '未配置模板市场能力';
      notifyListeners();
      return;
    }

    final collectionId = _collectionId;
    if (collectionId.isEmpty) return;

    LayoutTemplate? installed;
    await _withLoading(() async {
      installed = await useCase(
        collectionId: collectionId,
        marketTemplateId: marketTemplateId,
        marketVersionId: marketVersionId,
        nameOverride: nameOverride,
      );
    });

    await refreshTemplates();

    if (!switchToInstalled) return;

    final installedTemplate = installed;
    if (installedTemplate == null) return;

    if (_hasUnsavedChanges) {
      _errorMessage = '已安装模板，但当前有未保存更改，未自动切换';
      notifyListeners();
      return;
    }

    await selectTemplate(installedTemplate.id);
  }

  Future<void> _bootstrapFromPublicTemplatesIfNeeded() async {
    if (!_isBootstrappingTemplates) return;
    if (_bootstrapInFlight) return;

    _bootstrapInFlight = true;
    try {
      await _withLoading(() async {
        final publicTemplates = await getAllTemplatesUseCase(
          collectionId: _publicTemplatesCollectionId,
        );
        if (publicTemplates.isEmpty) {
          return;
        }

        final now = DateTime.now();
        for (final template in publicTemplates) {
          final imported = template.copyWith(
            id: _uuid.v4(),
            collectionId: _collectionId,
            name: _generateTemplateName(template.name),
            version: 0,
            updatedAt: now,
          );
          await saveTemplateUseCase(template: imported);
        }

        final refreshed =
            await getAllTemplatesUseCase(collectionId: _collectionId);
        if (refreshed.isEmpty) {
          return;
        }

        final metaDao = cardTemplateMetaDao;
        if (metaDao != null) {
          for (final template in refreshed) {
            await metaDao.touchModifiedAt(
              templateUuid: template.id,
              modifiedAt: template.updatedAt,
              isCustomized: false,
            );
          }
        }

        _templates = refreshed;
        _currentTemplate = refreshed.first;
        _isBootstrappingTemplates = false;
        _hasUnsavedChanges = false;
        _errorMessage = null;
        _resetRecentTemplates();
      });
    } finally {
      _bootstrapInFlight = false;
    }

    final template = _currentTemplate;
    if (template != null && !_hasUnsavedChanges) {
      _syncRuntimeStateFromTemplate(template);
      await _loadAndApplyTemplateSetting(
        templateUuid: template.id,
        skillId: _usageSkillId,
      );
    }
  }

  void toggleTheme(bool value) {
    if (value == _isDarkMode) return;
    _isDarkMode = value;
    cardBrightnessNotifier.value =
        _isDarkMode ? Brightness.dark : Brightness.light;
    notifyListeners();
    unawaited(_persistThemePreference(value));
  }

  void setViewMode(EditorViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }

  Future<void> selectTemplate(
    String templateId, {
    String source = 'unknown',
  }) async {
    if (_currentTemplate?.id == templateId) {
      return;
    }

    final prevId = _currentTemplate?.id;
    _templateTelemetry.info(
      'gallery.active_change_request',
      data: <String, Object?>{
        'source': source,
        'from': prevId,
        'to': templateId,
      },
    );

    await _withLoading(() async {
      final template = await getTemplateByIdUseCase(
        collectionId: _collectionId,
        templateId: templateId,
      );
      if (template != null) {
        final migrated = await _migrateLegacyDefaultTemplate(template);
        _currentTemplate = migrated;
        _hasUnsavedChanges = false;
        _commandHistory.clear();
        _markRecent(migrated.id);
        unawaited(_tryLogTemplateUsage(migrated.id));
      } else {
        _errorMessage = '模板不存在($templateId)';
      }
    });

    final template = _currentTemplate;
    if (template != null) {
      _syncRuntimeStateFromTemplate(template);
      await _loadAndApplyTemplateSetting(
        templateUuid: template.id,
        skillId: _usageSkillId,
      );
    }

    final nextId = _currentTemplate?.id;
    if (prevId != nextId) {
      _templateTelemetry.info(
        'gallery.active_changed',
        data: <String, Object?>{
          'source': source,
          'from': prevId,
          'to': nextId,
        },
      );
    }
  }

  Future<void> _tryLogTemplateUsage(String templateUuid) async {
    final dao = cardTemplateSkillUsageDao;
    final queryUuid = _usageQueryUuid;
    final skillId = _usageSkillId;
    if (dao == null || queryUuid == null || skillId == null) return;

    await dao.insertUsage(
      queryUuid: queryUuid,
      templateUuid: templateUuid,
      skillId: skillId,
      usedAt: CardTemplateSkillUsageDao.formatUsedAt(DateTime.now()),
    );
  }

  Future<void> _loadAndApplyTemplateSetting({
    required String templateUuid,
    int? skillId,
  }) async {
    final dao = cardTemplateSettingDao;
    if (dao == null) return;

    final setting = await dao.findByTemplateUuid(templateUuid);
    if (setting == null) return;

    final baseTheme = editableThemeNotifier.value;
    final nextTheme = CardTemplateSettingOverlay.applyToTheme(
      baseTheme: baseTheme,
      setting: setting,
      skillId: skillId,
    );

    final nextMode = CardTemplateSettingOverlay.effectiveColorMode(
      setting: setting,
      skillId: skillId,
    );

    final prevMode = colorPreviewModeNotifier.value;
    if (nextMode != null && nextMode != prevMode) {
      colorPreviewModeNotifier.value = nextMode;
    }

    if (nextTheme != baseTheme) {
      editableThemeNotifier.value = nextTheme;
      paddingNotifier.value = nextTheme.card.padding;
    }

    if (nextMode != prevMode || nextTheme != baseTheme) {
      _templateTelemetry.debug(
        'layout_template.setting_overlay_applied',
        data: <String, Object?>{
          'templateId': templateUuid,
          'skillId': skillId,
          'modeChanged': nextMode != prevMode,
          'themeChanged': nextTheme != baseTheme,
        },
      );
    }
  }

  Future<void> selectTemplateByTab(String templateId) async {
    await selectTemplate(templateId, source: 'tab');
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
    final base = _currentTemplate;
    if (base == null) return;

    final trimmed = name?.trim();
    final nextName =
        trimmed?.isNotEmpty == true ? trimmed! : _generateTemplateName();

    final template = base.copyWith(
      id: _uuid.v4(),
      name: nextName,
      version: 0,
      updatedAt: DateTime.now(),
    );
    _applyCurrentTemplate(template);
    await saveCurrentTemplate(isCustomized: true);
  }

  Future<void> applyTemplate(String templateId) async {
    await selectTemplate(templateId);
  }

  /// Task 2.1.6 - 应用预设配置
  /// 根据预设创建新的模板配置(不保存,仅应用到当前编辑状态)
  Future<void> applyPreset(TemplatePreset preset) async {
    final template = _currentTemplate;
    if (template == null) return;

    // 创建新分组,使用预设柱位
    final newGroup = ChartGroup(
      id: _uuid.v4(),
      title: preset.name,
      pillarOrder: List<PillarType>.from(preset.defaultPillars),
      locked: false,
      colorHex: null,
      expanded: true,
    );

    // 更新行配置可见性
    List<RowConfig> updatedRowConfigs = template.rowConfigs;
    if (preset.defaultVisibleRows != null) {
      updatedRowConfigs = template.rowConfigs.map((config) {
        final isVisible = preset.defaultVisibleRows!.contains(config.type);
        return config.copyWith(isVisible: isVisible);
      }).toList(growable: false);
    }

    // M4.3.2 - 使用Command模式
    final command = ApplyPresetCommand(
      oldGroups: template.chartGroups,
      newGroups: [newGroup],
      oldRowConfigs: template.rowConfigs,
      newRowConfigs: updatedRowConfigs,
      presetName: preset.name,
    );
    _executeCommand(command);

    _selectedPresetId = preset.id;
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
    await saveCurrentTemplate(isCustomized: true);
  }

  /// Task 2.2.3 - 另存为新模板
  /// 复制当前模板并使用新名称保存
  Future<void> saveTemplateAs(String newName) async {
    final template = _currentTemplate;
    if (template == null) return;

    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    await _withLoading(() async {
      // 复制当前模板
      final newTemplate = template.copyWith(
        id: _uuid.v4(),
        name: trimmed,
        version: 0,
        updatedAt: DateTime.now(),
      );

      // 保存新模板
      await saveTemplateUseCase(template: newTemplate);

      // 刷新模板列表
      final refreshed =
          await getAllTemplatesUseCase(collectionId: _collectionId);
      _templates = refreshed;

      // 切换到新模板
      final saved = _findTemplateInList(refreshed, newTemplate.id) ?? newTemplate;
      _currentTemplate = saved;
      _hasUnsavedChanges = false;
      _markRecent(newTemplate.id);

      final dao = cardTemplateMetaDao;
      if (dao != null) {
        await dao.touchModifiedAt(
          templateUuid: saved.id,
          modifiedAt: saved.updatedAt,
          isCustomized: true,
        );
      }
    });
  }

  void updateTemplateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final template = _currentTemplate;
    if (template == null || template.name == trimmed) {
      return;
    }

    // M4.3.2 - 使用Command模式
    final command = UpdateTemplateNameCommand(
      oldName: template.name,
      newName: trimmed,
    );
    _executeCommand(command);
  }

  void updateTemplateDescription(String? description) {
    final normalized = () {
      final raw = description;
      if (raw == null) return null;
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return null;
      return trimmed;
    }();
    final template = _currentTemplate;
    if (template == null || template.description == normalized) {
      return;
    }

    final command = UpdateTemplateDescriptionCommand(
      oldDescription: template.description,
      newDescription: normalized,
    );
    _executeCommand(command);
  }

  void updateDividerType(BorderType type) {
    final template = _currentTemplate;
    if (template == null) return;
    if (template.cardStyle.dividerType == type) return;

    final command = UpdateDividerTypeCommand(
      oldType: template.cardStyle.dividerType,
      newType: type,
    );
    _executeCommand(command);
  }

  void updateDividerColor(String colorHex) {
    final template = _currentTemplate;
    if (template == null) return;
    if (template.cardStyle.dividerColorHex == colorHex) return;

    final command = UpdateDividerColorCommand(
      oldColorHex: template.cardStyle.dividerColorHex,
      newColorHex: colorHex,
    );
    _executeCommand(command);
  }

  void updateDividerThickness(double thickness) {
    final template = _currentTemplate;
    if (template == null) return;
    final next = thickness.clamp(0.5, 8.0);
    if (template.cardStyle.dividerThickness == next) return;

    final command = UpdateDividerThicknessCommand(
      oldThickness: template.cardStyle.dividerThickness,
      newThickness: next,
    );
    _executeCommand(command);
  }

  void updateRowVisibility(RowType type, bool isVisible) {
    final template = _currentTemplate;
    if (template == null) return;

    // 获取旧的可见性状态
    final oldConfig = template.rowConfigs.firstWhere(
      (config) => config.type == type,
      orElse: () => RowConfig(
        type: type,
        isVisible: !isVisible,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig.defaultConfig,
      ),
    );

    if (oldConfig.isVisible == isVisible) return;

    // M4.3.2 - 使用Command模式
    final command = UpdateRowVisibilityCommand(
      rowType: type,
      oldVisibility: oldConfig.isVisible,
      newVisibility: isVisible,
    );
    _executeCommand(command);
  }

  void updateRowTitleVisibility(RowType type, bool isVisible) {
    final template = _currentTemplate;
    if (template == null) return;
    final oldConfig = template.rowConfigs.firstWhere(
      (c) => c.type == type,
      orElse: () => RowConfig(
        type: type,
        isVisible: true,
        isTitleVisible: !isVisible,
        textStyleConfig: TextStyleConfig.defaultConfig,
      ),
    );

    if (oldConfig.isTitleVisible == isVisible) return;

    final command = UpdateRowTitleVisibilityCommand(
      rowType: type,
      oldVisibility: oldConfig.isTitleVisible,
      newVisibility: isVisible,
    );
    _executeCommand(command);
  }

  /// 更新指定 `RowType` 的文本样式与相关展示属性。
  ///
  /// 参数说明：
  /// - `type`：要更新的行类型。
  /// - `textStyleConfig`：统一的文本样式配置对象，若提供将优先于旧字段。
  /// - `fontFamily`：字体族名称，兼容旧字段更新。
  /// - `fontSize`：字号，兼容旧字段更新。
  /// - `colorHex`：文本颜色的十六进制字符串（如 `#RRGGBB`）。
  /// - `fontWeight`：字体粗细（如 `w400`），兼容旧字段更新。
  /// - `textAlign`：文本对齐方式。
  /// - `padding`：行内容的内边距。
  /// - `borderType`：边框类型。
  /// - `borderColorHex`：边框颜色的十六进制字符串。
  /// - `shadowColorHex`：阴影颜色十六进制字符串。
  /// - `shadowOffsetX`：阴影 X 轴偏移量。
  /// - `shadowOffsetY`：阴影 Y 轴偏移量。
  /// - `shadowBlurRadius`：阴影模糊半径。
  ///
  /// 返回值：无。会将更新后的模板应用到当前视图模型。
  void updateRowStyle(
    RowType type, {
    TextStyleConfig? textStyleConfig,
    String? fontFamily,
    double? fontSize,
    String? colorHex,
    String? fontWeight,
    RowTextAlign? textAlign,
    double? padding,
    double? marginVertical,
    double? marginHorizontal,
    double? paddingHorizontal,
    BorderType? borderType,
    String? borderColorHex,
    // 阴影参数
    String? shadowColorHex,
    double? shadowOffsetX,
    double? shadowOffsetY,
    double? shadowBlurRadius,
  }) {
    final template = _currentTemplate;
    if (template == null) return;

    // 查找现有配置
    final exists = template.rowConfigs.any((c) => c.type == type);
    if (!exists) return;

    final oldConfig = template.rowConfigs.firstWhere((c) => c.type == type);
    final newConfig = oldConfig.copyWith(
      // 新版样式优先：同步 TextStyleConfig
      textStyleConfig: textStyleConfig ?? oldConfig.textStyleConfig,
      // 同步旧字段,确保向后兼容
      textAlign: textAlign ?? oldConfig.textAlign,
      padding: padding ?? oldConfig.paddingVertical,
      marginVertical: marginVertical ?? oldConfig.marginVertical,
      marginHorizontal: marginHorizontal ?? oldConfig.marginHorizontal,
      paddingHorizontal: paddingHorizontal ?? oldConfig.paddingHorizontal,
      borderType: borderType ?? oldConfig.borderType,
      borderColorHex: borderColorHex ?? oldConfig.borderColorHex,
    );

    if (oldConfig == newConfig) return;

    // M4.3.2 - 使用Command模式
    final command = UpdateRowConfigCommand(
      rowType: type,
      oldConfig: oldConfig,
      newConfig: newConfig,
    );
    _executeCommand(command);
  }

  void resetRowConfigs() {
    final template = _currentTemplate;
    if (template == null) return;

    final defaults = _defaultRowConfigs();

    final command = ReplaceRowConfigsCommand(
      oldConfigs: template.rowConfigs,
      newConfigs: defaults,
    );
    _executeCommand(command);
  }

  void ensureRowConfig(RowType type) {
    final template = _currentTemplate;
    if (template == null) return;
    if (template.rowConfigs.any((c) => c.type == type)) return;

    final cfg = RowConfig(
      type: type,
      isVisible: true,
      isTitleVisible: true,
      textStyleConfig: TextStyleConfig.defaultConfig,
    );
    final list = List<RowConfig>.of(template.rowConfigs)..add(cfg);

    // M4.3.2 - 使用Command模式
    final command = ReplaceRowConfigsCommand(
      oldConfigs: template.rowConfigs,
      newConfigs: list,
    );
    _executeCommand(command);
  }

  // Task 1.3.2 - 全局字体方法
  /// 更新当前模板的全局字体家族。
  ///
  /// 参数：
  /// - [family]：字体家族名称（例如 `NotoSansSC-Regular`）。
  ///
  /// 行为：
  /// - 基于当前模板的 `cardStyle` 生成新副本并替换 `globalFontFamily` 字段；
  /// - 通过 `_applyCurrentTemplate` 通知视图层刷新；
  /// - 与分组/行级样式的优先级：分组/行样式优先于全局字体家族。
  void updateGlobalFontFamily(String family) {
    final template = _currentTemplate;
    if (template == null) return;

    final oldStyle = template.cardStyle;
    final newStyle = oldStyle.copyWith(globalFontFamily: family);

    if (oldStyle == newStyle) return;

    // M4.3.2 - 使用Command模式
    final command = UpdateCardStyleCommand(
      oldStyle: oldStyle,
      newStyle: newStyle,
    );
    _executeCommand(command);
  }

  /// 更新当前模板的全局字号。
  ///
  /// 参数：
  /// - [size]：字号（逻辑像素）。
  ///
  /// 行为：
  /// - 将传入字号按 [10, 32] 进行约束（clamp），避免异常值；
  /// - 基于当前模板的 `cardStyle` 生成新副本并替换 `globalFontSize`；
  /// - 通过 `_applyCurrentTemplate` 通知视图层刷新；
  /// - 与分组/行级样式的优先级：分组/行样式优先于全局字号。
  void updateGlobalFontSize(double size) {
    final template = _currentTemplate;
    if (template == null) return;

    final oldStyle = template.cardStyle;
    final newStyle = oldStyle.copyWith(globalFontSize: size.clamp(10, 32));

    if (oldStyle == newStyle) return;

    // M4.3.2 - 使用Command模式
    final command = UpdateCardStyleCommand(
      oldStyle: oldStyle,
      newStyle: newStyle,
    );
    _executeCommand(command);
  }

  /// 更新当前模板的全局字体颜色（十六进制字符串）。
  ///
  /// 参数：
  /// - [colorHex]：颜色字符串（格式 `#AARRGGBB`，大写），例如 `#FF112233`。
  ///
  /// 行为：
  /// - 基于当前模板的 `cardStyle` 生成新副本并替换 `globalFontColorHex`；
  /// - 通过 `_applyCurrentTemplate` 通知视图层刷新；
  /// - 优先级：在彩色模式下对天干/地支会抑制全局颜色；分组/行级颜色覆写优先于全局颜色。
  void updateGlobalFontColor(String colorHex) {
    final template = _currentTemplate;
    if (template == null) return;

    final oldStyle = template.cardStyle;
    final newStyle = oldStyle.copyWith(globalFontColorHex: colorHex);

    if (oldStyle == newStyle) return;

    // M4.3.2 - 使用Command模式
    final command = UpdateCardStyleCommand(
      oldStyle: oldStyle,
      newStyle: newStyle,
    );
    _executeCommand(command);
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

    final command = ReorderRowConfigsCommand(
      oldRowConfigs: template.rowConfigs,
      newRowConfigs: list,
    );
    _executeCommand(command);
  }

  /// Reorders rows based on a list of types, preserving the position of types not in the list (e.g. separators).
  /// Uses a "Slot Filling" strategy:
  /// 1. Identifies "slots" in the current config list that correspond to the types in [orderedTypes].
  /// 2. Fills these slots sequentially with the configs corresponding to [orderedTypes].
  /// 3. Leaves other configs (e.g. separators) in their original positions.
  void reorderRowsByTypes(List<RowType> orderedTypes) {
    final template = _currentTemplate;
    if (template == null) return;

    final currentConfigs = template.rowConfigs;
    final reorderedConfigs = <RowConfig>[];
    final typesSet = orderedTypes.toSet();
    int orderedIndex = 0;

    for (final config in currentConfigs) {
      if (typesSet.contains(config.type)) {
        if (orderedIndex < orderedTypes.length) {
          final nextType = orderedTypes[orderedIndex++];
          final nextConfig = currentConfigs.firstWhere(
            (c) => c.type == nextType,
            orElse: () => config,
          );
          reorderedConfigs.add(nextConfig);
        } else {
          reorderedConfigs.add(config);
        }
      } else {
        reorderedConfigs.add(config);
      }
    }

    final command = ReorderRowConfigsCommand(
      oldRowConfigs: template.rowConfigs,
      newRowConfigs: reorderedConfigs,
    );
    _executeCommand(command);
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

    // M4.3.2 - 使用Command模式
    final command = ReorderPillarCommand(
      groupId: groupId,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
    _executeCommand(command);
  }

  void reorderGroups({
    required int oldIndex,
    required int newIndex,
  }) {
    final template = _currentTemplate;
    if (template == null) return;
    if (oldIndex == newIndex) return;

    // M4.3.2 - 使用Command模式
    final command = ReorderGroupsCommand(
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
    _executeCommand(command);
  }

  void addPillarToGroup({
    required String groupId,
    required PillarType pillar,
  }) {
    final template = _currentTemplate;
    if (template == null) return;

    final group = _findGroupById(template, groupId);
    if (group == null) return;

    // 去重：如已存在则跳过
    if (group.pillarOrder.contains(pillar)) return;

    // M4.3.2 - 使用Command模式
    final command = AddPillarToGroupCommand(
      groupId: groupId,
      pillar: pillar,
      index: group.pillarOrder.length, // Add to end
    );
    _executeCommand(command);
  }

  void addPillarToGroupAtIndex({
    required String groupId,
    required PillarType pillar,
    required int index,
  }) {
    final template = _currentTemplate;
    if (template == null) return;

    // 检查是否已存在（去重）
    final group = template.chartGroups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => ChartGroup(
        id: '',
        title: '',
        pillarOrder: const [],
      ),
    );
    if (group.id.isEmpty || group.pillarOrder.contains(pillar)) return;

    // M4.3.2 - 使用Command模式
    final command = AddPillarToGroupCommand(
      groupId: groupId,
      pillar: pillar,
      index: index,
    );
    _executeCommand(command);
  }

  void removePillarFromGroup({
    required String groupId,
    required int index,
  }) {
    final template = _currentTemplate;
    if (template == null) return;

    // 获取要移除的柱位（用于Command）
    final group = template.chartGroups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => ChartGroup(
        id: '',
        title: '',
        pillarOrder: const [],
      ),
    );
    if (group.id.isEmpty || index < 0 || index >= group.pillarOrder.length)
      return;

    final removedPillar = group.pillarOrder[index];

    // M4.3.2 - 使用Command模式
    final command = RemovePillarFromGroupCommand(
      groupId: groupId,
      index: index,
      removedPillar: removedPillar,
    );
    _executeCommand(command);
  }

  void insertSeparator({
    required String groupId,
    required int index,
  }) {
    final template = _currentTemplate;
    if (template == null) return;

    final oldGroup = _findGroupById(template, groupId);
    if (oldGroup == null) return;

    final list = List<PillarType>.of(oldGroup.pillarOrder);
    final clamped = index.clamp(0, list.length);
    list.insert(clamped, PillarType.separator);

    final newGroup = oldGroup.copyWith(pillarOrder: list);

    // M4.3.2 - 使用Command模式
    final command = UpdateGroupCommand(
      groupId: groupId,
      oldGroup: oldGroup,
      newGroup: newGroup,
      customDescription: '插入分隔符',
    );
    _executeCommand(command);
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

    final oldGroup = _findGroupById(template, groupId);
    if (oldGroup == null) return;

    if (oldGroup.locked == locked) return;

    final newGroup = oldGroup.copyWith(locked: locked);

    // M4.3.2 - 使用Command模式
    final command = UpdateGroupCommand(
      groupId: groupId,
      oldGroup: oldGroup,
      newGroup: newGroup,
      customDescription: locked ? '锁定分组' : '解锁分组',
    );
    _executeCommand(command);
  }

  void toggleGroupExpanded({required String groupId}) {
    final template = _currentTemplate;
    if (template == null) return;

    // M4.3.2 - 使用Command模式
    final command = ToggleGroupExpandedCommand(groupId: groupId);
    _executeCommand(command);
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

    // M4.3.2 - 使用Command模式
    final command = AddGroupCommand(group: newGroup);
    _executeCommand(command);

    _selectedGroupId = newGroup.id;
    // notifyListeners() is called by _executeCommand
  }

  void removeGroup(String groupId) {
    final template = _currentTemplate;
    if (template == null) return;

    // 查找要删除的分组
    final index = template.chartGroups.indexWhere((g) => g.id == groupId);
    if (index < 0) return;

    // 至少保留一个分组
    if (template.chartGroups.length <= 1) return;

    final removedGroup = template.chartGroups[index];

    // M4.3.2 - 使用Command模式
    final command = RemoveGroupCommand(
      groupId: groupId,
      removedGroup: removedGroup,
      groupIndex: index,
    );
    _executeCommand(command);

    if (_selectedGroupId == groupId) {
      // 这里的逻辑有点问题，因为command执行后，groupId已经不在了。
      // _executeCommand会更新 _currentTemplate
      // 我们需要更新 _selectedGroupId
      final updated = _currentTemplate?.chartGroups ?? [];
      if (updated.isNotEmpty) {
        _selectedGroupId = updated.first.id;
      }
    }
    // notifyListeners() is called by _executeCommand
  }

  void setGroupTitle({
    required String groupId,
    required String title,
  }) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final template = _currentTemplate;
    if (template == null) return;

    // 获取旧标题
    final group = template.chartGroups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => ChartGroup(
        id: '',
        title: '',
        pillarOrder: const [],
      ),
    );
    if (group.id.isEmpty || group.title == trimmed) return;

    // M4.3.2 - 使用Command模式
    final command = UpdateGroupTitleCommand(
      groupId: groupId,
      oldTitle: group.title,
      newTitle: trimmed,
    );
    _executeCommand(command);
  }

  void setGroupColor({
    required String groupId,
    required String colorHex,
  }) {
    final template = _currentTemplate;
    if (template == null) return;

    final oldGroup = _findGroupById(template, groupId);
    if (oldGroup == null) return;

    if (oldGroup.colorHex == colorHex) return;

    final newGroup = oldGroup.copyWith(colorHex: colorHex);

    // M4.3.2 - 使用Command模式
    final command = UpdateGroupCommand(
      groupId: groupId,
      oldGroup: oldGroup,
      newGroup: newGroup,
      customDescription: '设置分组颜色',
    );
    _executeCommand(command);
  }

  void resetGroupLayout({
    required String groupId,
  }) {
    final template = _currentTemplate;
    if (template == null) return;

    final oldGroup = _findGroupById(template, groupId);
    if (oldGroup == null) return;

    if (oldGroup.pillarOrder.isEmpty) return;

    final newGroup = oldGroup.copyWith(pillarOrder: const []);

    // M4.3.2 - 使用Command模式
    final command = UpdateGroupCommand(
      groupId: groupId,
      oldGroup: oldGroup,
      newGroup: newGroup,
      customDescription: '清空分组',
    );
    _executeCommand(command);
  }

  void clearGroup({required String groupId}) {
    resetGroupLayout(groupId: groupId);
  }

  void duplicateGroup({required String groupId}) {
    final template = _currentTemplate;
    if (template == null) return;

    final source = _findGroupById(template, groupId);
    if (source == null) return;

    final index = template.chartGroups.indexOf(source);
    if (index < 0) return;

    final copy = ChartGroup(
      id: _uuid.v4(),
      title: _generateGroupName(source.title),
      pillarOrder: List<PillarType>.of(source.pillarOrder),
      locked: source.locked,
      colorHex: source.colorHex,
      expanded: source.expanded,
    );

    // M4.3.2 - 使用Command模式
    final command = AddGroupCommand(
      group: copy,
      index: index + 1,
    );
    _executeCommand(command);

    _selectedGroupId = copy.id;
    notifyListeners();
  }

  /// Task M3.3.4 - 跨分组移动柱位
  /// 将柱位从源分组移动到目标分组
  void movePillarBetweenGroups({
    required String sourceGroupId,
    required int sourceIndex,
    required String targetGroupId,
    required int targetIndex,
  }) {
    final template = _currentTemplate;
    if (template == null) return;

    // 查找源分组和目标分组
    final sourceGroup = _findGroupById(template, sourceGroupId);
    final targetGroup = _findGroupById(template, targetGroupId);
    if (sourceGroup == null || targetGroup == null) return;

    // 验证源索引
    if (sourceIndex < 0 || sourceIndex >= sourceGroup.pillarOrder.length)
      return;

    // 获取要移动的柱位
    final pillar = sourceGroup.pillarOrder[sourceIndex];

    // 如果是同一分组，使用reorderPillar
    if (sourceGroupId == targetGroupId) {
      reorderPillar(
        groupId: sourceGroupId,
        oldIndex: sourceIndex,
        newIndex: targetIndex,
      );
      return;
    }

    // 检查目标分组是否已存在该柱位（去重）
    if (targetGroup.pillarOrder.contains(pillar)) {
      // 如果目标分组已存在，仅从源分组移除
      removePillarFromGroup(groupId: sourceGroupId, index: sourceIndex);
      return;
    }

    // 跨分组移动：从源移除，向目标添加
    // M4.3.2 - 使用Command模式
    final command = MovePillarBetweenGroupsCommand(
      sourceGroupId: sourceGroupId,
      targetGroupId: targetGroupId,
      sourceIndex: sourceIndex,
      targetIndex: targetIndex,
      pillar: pillar,
    );
    _executeCommand(command);
  }

  String _generateGroupName(String base) {
    final prefix = base.isNotEmpty ? base : '新分组';
    final existing =
        (_currentTemplate?.chartGroups ?? const []).map((g) => g.title).toSet();
    if (!existing.contains('$prefix (副本)')) return '$prefix (副本)';
    var i = 2;
    while (existing.contains('$prefix (副本 $i)')) {
      i += 1;
    }
    return '$prefix (副本 $i)';
  }

  Future<void> saveCurrentTemplate({bool? isCustomized}) async {
    final template = _currentTemplate;
    if (template == null) return;

    _templateTelemetry.info(
      'layout_template.save_start',
      data: <String, Object?>{
        'templateId': template.id,
        'collectionId': template.collectionId,
        'version': template.version,
        'isCustomized': isCustomized,
      },
    );

    await _withLoading(() async {
      await saveTemplateUseCase(template: template);
      _hasUnsavedChanges = false;
      _commandHistory.clear();
      final refreshed =
          await getAllTemplatesUseCase(collectionId: _collectionId);
      _templates = refreshed;
      _currentTemplate =
          _findTemplateInList(refreshed, template.id) ?? template;

      final dao = cardTemplateMetaDao;
      final current = _currentTemplate;
      if (dao != null && current != null && isCustomized != null) {
        await dao.touchModifiedAt(
          templateUuid: current.id,
          modifiedAt: current.updatedAt,
          isCustomized: isCustomized,
        );
      }
    });

    final ok = _errorMessage == null;
    _templateTelemetry.info(
      ok ? 'layout_template.save_ok' : 'layout_template.save_failed',
      data: <String, Object?>{
        'templateId': template.id,
        'collectionId': template.collectionId,
        'error': _errorMessage,
      },
    );
  }

  Future<void> deleteCurrentTemplate() async {
    final template = _currentTemplate;
    if (template == null) return;

    _templateTelemetry.info(
      'layout_template.delete_start',
      data: <String, Object?>{
        'templateId': template.id,
        'collectionId': template.collectionId,
      },
    );

    await _withLoading(() async {
      await deleteTemplateUseCase(
        collectionId: template.collectionId,
        templateId: template.id,
      );
      final refreshed =
          await getAllTemplatesUseCase(collectionId: _collectionId);
      _templates = refreshed;
      _currentTemplate = refreshed.isEmpty ? null : refreshed.first;
      _isBootstrappingTemplates = refreshed.isEmpty;
      _hasUnsavedChanges = false;
    });

    final ok = _errorMessage == null;
    _templateTelemetry.info(
      ok ? 'layout_template.delete_ok' : 'layout_template.delete_failed',
      data: <String, Object?>{
        'templateId': template.id,
        'collectionId': template.collectionId,
        'nextTemplateId': _currentTemplate?.id,
        'error': _errorMessage,
      },
    );

    if (_currentTemplate == null) {
      await _bootstrapFromPublicTemplatesIfNeeded();
    }
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
    await saveCurrentTemplate(isCustomized: true);
  }

  Future<void> deleteSelectedTemplates() async {
    if (_selectedTemplateIds.isEmpty) {
      return;
    }
    final targets = List<String>.from(_selectedTemplateIds);

    _templateTelemetry.info(
      'layout_template.bulk_delete_start',
      data: <String, Object?>{
        'collectionId': _collectionId,
        'count': targets.length,
      },
    );

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

      final currentId = _currentTemplate?.id;
      _templates = refreshed;

      final nextCurrent = currentId == null
          ? (refreshed.isEmpty ? null : refreshed.first)
          : (_findTemplateInList(refreshed, currentId) ??
              (refreshed.isEmpty ? null : refreshed.first));
      _currentTemplate = nextCurrent;

      _isBootstrappingTemplates = refreshed.isEmpty;
      _hasUnsavedChanges = false;
      _errorMessage = null;
      _resetRecentTemplates();
    });

    final ok = _errorMessage == null;
    _templateTelemetry.info(
      ok ? 'layout_template.bulk_delete_ok' : 'layout_template.bulk_delete_failed',
      data: <String, Object?>{
        'collectionId': _collectionId,
        'count': targets.length,
        'nextTemplateId': _currentTemplate?.id,
        'error': _errorMessage,
      },
    );

    if (_currentTemplate == null) {
      await _bootstrapFromPublicTemplatesIfNeeded();
    }

    clearSelection();
  }

  Future<void> resetTemplatesToDefault() async {
    _templateTelemetry.info(
      'layout_template.reset_to_default_start',
      data: <String, Object?>{
        'collectionId': _collectionId,
      },
    );

    await _withLoading(() async {
      final existing =
          await getAllTemplatesUseCase(collectionId: _collectionId);
      for (final template in existing) {
        await deleteTemplateUseCase(
          collectionId: _collectionId,
          templateId: template.id,
        );
      }

      final refreshed =
          await getAllTemplatesUseCase(collectionId: _collectionId);
      _templates = refreshed;
      _currentTemplate = refreshed.isEmpty ? null : refreshed.first;
      _isBootstrappingTemplates = refreshed.isEmpty;
      _hasUnsavedChanges = false;
      _errorMessage = null;
      _favoriteTemplateIds.clear();
      _selectedTemplateIds.clear();
      _selectedPresetId = null;
      _resetRecentTemplates();
    });

    final ok = _errorMessage == null;
    _templateTelemetry.info(
      ok
          ? 'layout_template.reset_to_default_ok'
          : 'layout_template.reset_to_default_failed',
      data: <String, Object?>{
        'collectionId': _collectionId,
        'nextTemplateId': _currentTemplate?.id,
        'error': _errorMessage,
      },
    );

    if (_currentTemplate == null) {
      await _bootstrapFromPublicTemplatesIfNeeded();
    }

    final template = _currentTemplate;
    if (template != null) {
      _syncRuntimeStateFromTemplate(template);
    }
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
      _templates = refreshed;
      if (refreshed.isEmpty) {
        _currentTemplate = null;
        _isBootstrappingTemplates = true;
      } else {
        _currentTemplate = refreshed.firstWhere(
          (item) => item.id == (_currentTemplate?.id ?? updated.id),
          orElse: () => refreshed.first,
        );
        _isBootstrappingTemplates = false;
      }
      _hasUnsavedChanges = false;
      _errorMessage = null;
      _resetRecentTemplates();
    });

    if (_currentTemplate == null) {
      await _bootstrapFromPublicTemplatesIfNeeded();
    }
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
      _commandHistory.clear(); // M4.3.2 - 撤销所有更改时清空历史
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

  /// M4.3.2 - 撤销最后一个操作
  void undoLastChange() {
    final template = _currentTemplate;
    if (template == null || !canUndo) return;

    final newTemplate = _commandHistory.undo(template);
    if (newTemplate != null) {
      _currentTemplate = newTemplate;
      _hasUnsavedChanges = true;
      _templates = List<LayoutTemplate>.of(_templates);
      final index = _templates.indexWhere((item) => item.id == newTemplate.id);
      if (index >= 0) {
        _templates[index] = newTemplate;
      }
      _markRecent(newTemplate.id);
      _syncRuntimeStateFromTemplate(newTemplate);
      notifyListeners();
    }
  }

  /// M4.3.2 - 重做最后一个被撤销的操作
  void redoLastChange() {
    final template = _currentTemplate;
    if (template == null || !canRedo) return;

    final newTemplate = _commandHistory.redo(template);
    if (newTemplate != null) {
      _currentTemplate = newTemplate;
      _hasUnsavedChanges = true;
      _templates = List<LayoutTemplate>.of(_templates);
      final index = _templates.indexWhere((item) => item.id == newTemplate.id);
      if (index >= 0) {
        _templates[index] = newTemplate;
      }
      _markRecent(newTemplate.id);
      _syncRuntimeStateFromTemplate(newTemplate);
      notifyListeners();
    }
  }

  /// M4.3.2 - 执行一个命令（内部方法）
  void _executeCommand(EditorCommand command) {
    final template = _currentTemplate;
    if (template == null) return;

    _templateTelemetry.debug(
      'editor.command_execute',
      data: <String, Object?>{
        'templateId': template.id,
        'command': command.runtimeType.toString(),
        'undo': _commandHistory.undoCount,
        'redo': _commandHistory.redoCount,
      },
    );

    final newTemplate = _commandHistory.executeCommand(command, template);
    _currentTemplate = newTemplate;
    _hasUnsavedChanges = true;
    _templates = List<LayoutTemplate>.of(_templates);
    final index = _templates.indexWhere((item) => item.id == newTemplate.id);
    if (index >= 0) {
      _templates[index] = newTemplate;
    }
    _markRecent(newTemplate.id);
    _syncRuntimeStateFromTemplate(newTemplate);
    notifyListeners();
  }

  List<RowConfig> _defaultRowConfigs() {
    return [
      RowConfig(
        type: RowType.columnHeaderRow,
        isVisible: true,
        isTitleVisible: false,
        textStyleConfig: TextStyleConfig.defaultConfig,
      ),
      RowConfig(
        type: RowType.tenGod,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig.defaultTenGodsConfig,
      ),
      RowConfig(
        type: RowType.heavenlyStem,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig.defaultGanConfig,
      ),
      RowConfig(
        type: RowType.earthlyBranch,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig.defaultZhiConfig,
      ),
      RowConfig(
        type: RowType.xunShou,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig.defaultConfig,
      ),
      RowConfig(
        type: RowType.kongWang,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig.defaultConfig,
      ),
      RowConfig(
        type: RowType.naYin,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig.defaultConfig,
      ),
      RowConfig(
        type: RowType.hiddenStems,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig.defaultConfig,
      ),
    ];
  }

  /// 检查并迁移旧版默认模版（修复样式跳变问题）
  Future<LayoutTemplate> _migrateLegacyDefaultTemplate(
      LayoutTemplate template) async {
    // 修复：确保十神和藏干神行包含 singleName 的颜色配置
    // 修复：确保主气/中气/余气行包含天干颜色配置
    var updatedRowConfigs = List<RowConfig>.of(template.rowConfigs);
    bool changed = false;

    for (int i = 0; i < updatedRowConfigs.length; i++) {
      final row = updatedRowConfigs[i];
      if (_isTenGodOrHiddenStemGodRow(row.type)) {
        final newTextStyle = _fixTenGodsColorConfig(row.textStyleConfig);
        if (newTextStyle != row.textStyleConfig) {
          updatedRowConfigs[i] = row.copyWith(textStyleConfig: newTextStyle);
          changed = true;
        }
      } else if (_isTianGanRow(row.type)) {
        final newTextStyle = _fixTianGanColorConfig(row.textStyleConfig);
        if (newTextStyle != row.textStyleConfig) {
          updatedRowConfigs[i] = row.copyWith(textStyleConfig: newTextStyle);
          changed = true;
        }
      }
    }

    if (changed) {
      final migrated = template.copyWith(
        rowConfigs: updatedRowConfigs,
        updatedAt: DateTime.now(),
      );
      await saveTemplateUseCase(template: migrated);
      return migrated;
    }

    return template;
  }

  bool _isTenGodOrHiddenStemGodRow(RowType type) {
    return type == RowType.tenGod ||
        type == RowType.hiddenStemsPrimaryGods ||
        type == RowType.hiddenStemsSecondaryGods ||
        type == RowType.hiddenStemsTertiaryGods ||
        type == RowType.hiddenStemsTenGod;
  }

  bool _isTianGanRow(RowType type) {
    return type == RowType.heavenlyStem ||
        type == RowType.hiddenStemsPrimary ||
        type == RowType.hiddenStemsSecondary ||
        type == RowType.hiddenStemsTertiary;
  }

  TextStyleConfig _fixTenGodsColorConfig(TextStyleConfig config) {
    final colorMapper = config.colorMapperDataModel;
    final defaultTenGods =
        TextStyleConfig.defaultTenGodsConfig.colorMapperDataModel;

    // Helper to merge default Ten Gods config if keys are missing
    Map<String, Color> mergeDefaults(
        Map<String, Color> current, Map<String, Color> defaults) {
      final newMap = Map<String, Color>.of(current);
      bool modified = false;

      // Check if we are missing Ten God keys (using BiJian as a proxy)
      // If missing, it implies this row was using generic config, so we should apply defaults
      final hasTenGods = newMap.containsKey(EnumTenGods.BiJian.name);

      if (!hasTenGods) {
        // Apply all defaults
        for (final entry in defaults.entries) {
          newMap[entry.key] = entry.value;
        }
        modified = true;
      }

      // Also ensure singleName exists for all keys
      for (final tenGod in EnumTenGods.values) {
        if (!newMap.containsKey(tenGod.singleName)) {
          // Try to find full name color, otherwise use default from config or fallback
          final fullNameColor = newMap[tenGod.name];
          if (fullNameColor != null) {
            newMap[tenGod.singleName] = fullNameColor;
            modified = true;
          } else if (defaults.containsKey(tenGod.singleName)) {
            newMap[tenGod.singleName] = defaults[tenGod.singleName]!;
            modified = true;
          }
        }
      }

      return modified ? newMap : current;
    }

    final newPureLight = mergeDefaults(
        colorMapper.pureLightMapper, defaultTenGods.pureLightMapper);
    final newColorfulLight = mergeDefaults(
        colorMapper.colorfulLightMapper, defaultTenGods.colorfulLightMapper);
    final newPureDark = mergeDefaults(
        colorMapper.pureDarkMapper, defaultTenGods.pureDarkMapper);
    final newColorfulDark = mergeDefaults(
        colorMapper.colorfulDarkMapper, defaultTenGods.colorfulDarkMapper);

    if (newPureLight == colorMapper.pureLightMapper &&
        newColorfulLight == colorMapper.colorfulLightMapper &&
        newPureDark == colorMapper.pureDarkMapper &&
        newColorfulDark == colorMapper.colorfulDarkMapper) {
      return config;
    }

    return config.copyWith(
      colorMapperDataModel: colorMapper.copyWith(
        pureLightMapper: newPureLight,
        colorfulLightMapper: newColorfulLight,
        pureDarkMapper: newPureDark,
        colorfulDarkMapper: newColorfulDark,
      ),
    );
  }

  TextStyleConfig _fixTianGanColorConfig(TextStyleConfig config) {
    final colorMapper = config.colorMapperDataModel;

    // Helper to fill missing keys from a source map
    Map<String, Color> fillMissing(
        Map<String, Color> target, Map<String, Color> source) {
      final newMap = Map<String, Color>.of(target);
      bool modified = false;
      for (final entry in source.entries) {
        if (!newMap.containsKey(entry.key)) {
          newMap[entry.key] = entry.value;
          modified = true;
        }
      }
      return modified ? newMap : target;
    }

    // Default maps
    final defaultColorful = ConstResourcesMapper.zodiacGanColors.map(
      (k, v) => MapEntry(k.name, v),
    );

    final defaultPureLight = Map.fromEntries(
      TianGan.values.take(10).map((g) => MapEntry(g.name, Colors.black87)),
    );
    final defaultPureDark = Map.fromEntries(
      TianGan.values.take(10).map((g) => MapEntry(g.name, Colors.white70)),
    );

    final newColorfulLight =
        fillMissing(colorMapper.colorfulLightMapper, defaultColorful);
    final newColorfulDark =
        fillMissing(colorMapper.colorfulDarkMapper, defaultColorful);
    final newPureLight =
        fillMissing(colorMapper.pureLightMapper, defaultPureLight);
    final newPureDark =
        fillMissing(colorMapper.pureDarkMapper, defaultPureDark);

    if (newColorfulLight == colorMapper.colorfulLightMapper &&
        newColorfulDark == colorMapper.colorfulDarkMapper &&
        newPureLight == colorMapper.pureLightMapper &&
        newPureDark == colorMapper.pureDarkMapper) {
      return config;
    }

    return config.copyWith(
      colorMapperDataModel: colorMapper.copyWith(
        colorfulLightMapper: newColorfulLight,
        colorfulDarkMapper: newColorfulDark,
        pureLightMapper: newPureLight,
        pureDarkMapper: newPureDark,
      ),
    );
  }

  /// 应用当前模板
  ///
  /// **注意**：此方法仅用于模板切换、创建、复制等“整套模板替换”的场景。
  /// 对于模板内容的编辑（如修改分组、行配置等），**必须**使用 [EditorCommand] 及其子类，
  /// 并通过 [_executeCommand] 执行，以支持撤销/重做功能。
  ///
  /// 此方法会：
  /// 1. 更新 [_currentTemplate]
  /// 2. 更新 [_templates] 列表
  /// 3. 标记为最近使用
  /// 4. 同步运行时状态 [_syncRuntimeStateFromTemplate]
  /// 5. 通知监听器
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
    _syncRuntimeStateFromTemplate(template);
    notifyListeners();
  }

  /// 更新卡片内容区内边距（统一作用于卡片容器的 Padding）。
  /// 参数：insets 四向内边距。
  /// 返回：无；通过 _applyCurrentTemplate 触发刷新。
  void updateCardContentInsets(EdgeInsets insets) {
    final template = _currentTemplate;
    if (template == null) return;

    final oldStyle = template.cardStyle;
    final newStyle = oldStyle.copyWith(contentPadding: insets);

    if (oldStyle == newStyle) return;

    // M4.3.2 - 使用Command模式
    final command = UpdateCardStyleCommand(
      oldStyle: oldStyle,
      newStyle: newStyle,
    );
    _executeCommand(command);
  }

  void updateEditableFourZhuCardTheme(EditableFourZhuCardTheme newTheme) {
    _templateTelemetry.debug(
      'layout_template.edit_theme',
      data: <String, Object?>{
        'templateId': _currentTemplate?.id,
        'padding': newTheme.card.padding.toString(),
        'displayHeaderRow': newTheme.displayHeaderRow,
        'displayRowTitleColumn': newTheme.displayRowTitleColumn,
        'displayCellTitle': newTheme.displayCellTitle,
      },
    );

    editableThemeNotifier.value = newTheme;
    paddingNotifier.value = newTheme.card.padding;

    _executeCommand(UpdateThemeCommand(newTheme));
  }

  void updatePillarOrderFromTypes(List<PillarType> types) {
    final template = _currentTemplate;
    if (template == null) return;

    // Reconstruct groups with new order, preserving group membership
    final newGroups = template.chartGroups.map((group) {
      // Find pillars in this group
      final groupPillars = group.pillarOrder.toSet();

      // Filter the input types to find ones belonging to this group, in their new order
      final newGroupOrder =
          types.where((t) => groupPillars.contains(t)).toList();

      // Append any missing pillars (if any were not in input types) to avoid data loss
      for (final p in group.pillarOrder) {
        if (!newGroupOrder.contains(p)) {
          newGroupOrder.add(p);
        }
      }

      return group.copyWith(pillarOrder: newGroupOrder);
    }).toList();

    // Use command to update
    _executeCommand(UpdateChartGroupsCommand(
      oldGroups: template.chartGroups,
      newGroups: newGroups,
    ));
  }

  void reorderRow(int oldVisibleIndex, int newVisibleIndex) {
    final template = _currentTemplate;
    if (template == null) return;

    // Helper to find config index from visible index
    int configIndex(int visibleIndex) {
      int visibleCount = 0;
      for (int i = 0; i < template.rowConfigs.length; i++) {
        if (template.rowConfigs[i].isVisible) {
          if (visibleCount == visibleIndex) return i;
          visibleCount++;
        }
      }
      return -1;
    }

    final oldConfigIdx = configIndex(oldVisibleIndex);
    if (oldConfigIdx == -1) return;

    int targetConfigIdx;
    final visibleRowsCount =
        template.rowConfigs.where((c) => c.isVisible).length;

    if (newVisibleIndex >= visibleRowsCount) {
      // Insert after the last visible row
      int lastVisibleIdx = -1;
      for (int i = template.rowConfigs.length - 1; i >= 0; i--) {
        if (template.rowConfigs[i].isVisible) {
          lastVisibleIdx = i;
          break;
        }
      }
      targetConfigIdx = lastVisibleIdx + 1;
    } else {
      targetConfigIdx = configIndex(newVisibleIndex);
    }

    if (targetConfigIdx == -1) targetConfigIdx = template.rowConfigs.length;

    // Fix for disordered sequence: adjust index if moving downwards
    if (oldConfigIdx < targetConfigIdx) {
      targetConfigIdx -= 1;
    }

    _executeCommand(ReorderRowCommand(
      oldIndex: oldConfigIdx,
      newIndex: targetConfigIdx,
    ));
  }

  void insertRow(int visibleIndex, RowPayload payload) {
    final template = _currentTemplate;
    if (template == null) return;

    RowConfig config;
    if (payload is RowSeparatorPayload) {
      config = RowConfig(
        type: RowType.separator,
        isVisible: true,
        isTitleVisible: false,
        textStyleConfig: TextStyleConfig.defaultConfig,
      );
    } else {
      config = RowConfig(
        type: payload.rowType,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig.defaultConfig,
      );
    }

    // Map visibleIndex to configIndex
    int targetConfigIdx;
    final visibleRowsCount =
        template.rowConfigs.where((c) => c.isVisible).length;

    if (visibleIndex >= visibleRowsCount) {
      int lastVisibleIdx = -1;
      for (int i = template.rowConfigs.length - 1; i >= 0; i--) {
        if (template.rowConfigs[i].isVisible) {
          lastVisibleIdx = i;
          break;
        }
      }
      targetConfigIdx = lastVisibleIdx + 1;
    } else {
      int visibleCount = 0;
      targetConfigIdx = template.rowConfigs.length; // Default to end
      for (int i = 0; i < template.rowConfigs.length; i++) {
        if (template.rowConfigs[i].isVisible) {
          if (visibleCount == visibleIndex) {
            targetConfigIdx = i;
            break;
          }
          visibleCount++;
        }
      }
    }

    _executeCommand(InsertRowCommand(
      rowConfig: config,
      index: targetConfigIdx,
    ));
  }

  void deleteRow(int visibleIndex) {
    final template = _currentTemplate;
    if (template == null) return;

    int configIndex = -1;
    int visibleCount = 0;
    for (int i = 0; i < template.rowConfigs.length; i++) {
      if (template.rowConfigs[i].isVisible) {
        if (visibleCount == visibleIndex) {
          configIndex = i;
          break;
        }
        visibleCount++;
      }
    }

    if (configIndex == -1) return;

    final config = template.rowConfigs[configIndex];
    _executeCommand(DeleteRowCommand(
      index: configIndex,
      rowConfig: config,
    ));
  }

  /// 计算实际的数据索引（考虑 UI 上可能存在的额外 Title Column）
  /// 如果 UI 有 Title Column 但 ChartGroups 没有，则 index - 1
  int _adjustPillarIndex(LayoutTemplate template, int uiIndex) {
    return uiIndex;
  }

  void reorderPillarGlobal(int oldGlobalIndex, int newGlobalIndex) {
    final template = _currentTemplate;
    if (template == null) return;

    final adjOldIndex = _adjustPillarIndex(template, oldGlobalIndex);
    final adjNewIndex = _adjustPillarIndex(template, newGlobalIndex);

    if (adjOldIndex < 0 || adjNewIndex < 0) return; // 试图移动不存在的标题列

    String? sourceGroupId;
    int sourceLocalIndex = -1;
    PillarType? sourcePillar;

    String? targetGroupId;
    int targetLocalIndex = -1;

    // Find source
    int currentIndex = 0;
    for (final group in template.chartGroups) {
      if (adjOldIndex < currentIndex + group.pillarOrder.length) {
        sourceGroupId = group.id;
        sourceLocalIndex = adjOldIndex - currentIndex;
        sourcePillar = group.pillarOrder[sourceLocalIndex];
        break;
      }
      currentIndex += group.pillarOrder.length;
    }

    if (sourceGroupId == null || sourcePillar == null) return;

    // Find target
    currentIndex = 0;
    for (final group in template.chartGroups) {
      // Allow target to be at the end of the group
      if (adjNewIndex <= currentIndex + group.pillarOrder.length) {
        targetGroupId = group.id;
        targetLocalIndex = adjNewIndex - currentIndex;
        break;
      }
      currentIndex += group.pillarOrder.length;
    }

    // Fallback to last group if target is at end
    if (targetGroupId == null && template.chartGroups.isNotEmpty) {
      targetGroupId = template.chartGroups.last.id;
      targetLocalIndex = template.chartGroups.last.pillarOrder.length;
    }

    if (targetGroupId == null) return;

    if (sourceGroupId == targetGroupId) {
      // Fix for disordered sequence in same group
      if (sourceLocalIndex < targetLocalIndex) {
        targetLocalIndex -= 1;
      }
      reorderPillar(
        groupId: sourceGroupId,
        oldIndex: sourceLocalIndex,
        newIndex: targetLocalIndex,
      );
    } else {
      // Cross-group move: Use atomic command
      _executeCommand(MovePillarBetweenGroupsCommand(
        sourceGroupId: sourceGroupId,
        targetGroupId: targetGroupId,
        sourceIndex: sourceLocalIndex,
        targetIndex: targetLocalIndex,
        pillar: sourcePillar,
      ));
    }
  }

  void insertPillarGlobal(int globalIndex, PillarType type) {
    final template = _currentTemplate;
    if (template == null) return;

    final adjIndex = _adjustPillarIndex(template, globalIndex);
    if (adjIndex < 0) return;

    int currentIndex = 0;
    for (final group in template.chartGroups) {
      final groupLen = group.pillarOrder.length;
      if (adjIndex <= currentIndex + groupLen) {
        final localIndex = adjIndex - currentIndex;
        addPillarToGroupAtIndex(
          groupId: group.id,
          pillar: type,
          index: localIndex,
        );
        return;
      }
      currentIndex += groupLen;
    }

    if (template.chartGroups.isNotEmpty) {
      final lastGroup = template.chartGroups.last;
      addPillarToGroupAtIndex(
        groupId: lastGroup.id,
        pillar: type,
        index: lastGroup.pillarOrder.length,
      );
    }
  }

  void deletePillarGlobal(int globalIndex) {
    final template = _currentTemplate;
    if (template == null) return;

    final adjIndex = _adjustPillarIndex(template, globalIndex);
    if (adjIndex < 0) return;

    int currentIndex = 0;
    for (final group in template.chartGroups) {
      final groupLen = group.pillarOrder.length;
      if (adjIndex < currentIndex + groupLen) {
        final localIndex = adjIndex - currentIndex;
        removePillarFromGroup(
          groupId: group.id,
          index: localIndex,
        );
        return;
      }
      currentIndex += groupLen;
    }
  }

  void updateRowOrderFromTypes(List<RowType> orderedTypes) {
    final template = _currentTemplate;
    if (template == null) return;

    final oldConfigs = template.rowConfigs;
    final newConfigs = <RowConfig>[];

    // Create a list of remaining configs to pick from
    final remaining = List<RowConfig>.of(oldConfigs);

    for (final type in orderedTypes) {
      final index = remaining.indexWhere((c) => c.type == type);
      if (index != -1) {
        newConfigs.add(remaining.removeAt(index));
      }
    }

    // Add any remaining configs (those not in orderedTypes)
    newConfigs.addAll(remaining);

    // Use command to update
    if (!_areRowConfigsEqual(oldConfigs, newConfigs)) {
      _executeCommand(ReorderRowConfigsCommand(
        oldRowConfigs: oldConfigs,
        newRowConfigs: newConfigs,
      ));
    }
  }

  bool _areRowConfigsEqual(List<RowConfig> a, List<RowConfig> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    editableThemeNotifier.dispose();
    cardBrightnessNotifier.dispose();
    colorPreviewModeNotifier.dispose();
    paddingNotifier.dispose();
    cardPayloadNotifier.dispose();
    super.dispose();
  }

  void _initRuntimeNotifiers() {
    rowStrategyMapper = {
      RowType.tenGod: TenGodRowStrategy(),
      RowType.hiddenStemsTenGod: HiddenStemsTenGodsRowStrategy(),
      RowType.hiddenStems: HiddenStemsRowStrategy(),
      RowType.kongWang: KongWangRowStrategy(),
      RowType.gu: GuRowStrategy(),
      RowType.xu: XuRowStrategy(),
      RowType.naYin: NaYinRowStrategy(),
      RowType.xunShou: XunShouRowStrategy(),
      RowType.yiMa: YiMaRowStrategy(),
      RowType.hiddenStemsPrimary: HiddenStemsPrimaryRowStrategy(),
      RowType.hiddenStemsSecondary: HiddenStemsSecondaryRowStrategy(),
      RowType.hiddenStemsTertiary: HiddenStemsTertiaryRowStrategy(),
      RowType.hiddenStemsPrimaryGods: HiddenStemsPrimaryGodsRowStrategy(),
      RowType.hiddenStemsSecondaryGods: HiddenStemsSecondaryGodsRowStrategy(),
      RowType.hiddenStemsTertiaryGods: HiddenStemsTertiaryGodsRowStrategy(),
      RowType.starYun: StarYunRowStrategy(),
      RowType.selfSiting: SelfSitingRowStrategy(),
    };

    pillarStrategyMapper = {
      PillarType.lifeHouse: const LifeHousePillarStrategy(),
      PillarType.bodyHouse: const BodyHousePillarStrategy(),
    };

    final theme = EditableCardThemeBuilder.createDefaultTheme();
    editableThemeNotifier = ValueNotifier<EditableFourZhuCardTheme>(theme);
    cardBrightnessNotifier = ValueNotifier<Brightness>(Brightness.light);
    colorPreviewModeNotifier =
        ValueNotifier<ColorPreviewMode>(ColorPreviewMode.colorful);
    paddingNotifier = ValueNotifier<EdgeInsets>(theme.card.padding);
    cardPayloadNotifier = ValueNotifier<CardPayload>(
      _buildDefaultCardPayload(
        eightChars: EightChars(
          year: JiaZi.JIA_ZI,
          month: JiaZi.YI_CHOU,
          day: JiaZi.BING_YIN,
          time: JiaZi.DING_MAO,
        ),
        gender: Gender.male,
      ),
    );
  }

  CardPayload _buildDefaultCardPayload({
    required EightChars eightChars,
    required Gender gender,
  }) {
    final yearUuid = _uuid.v4();
    final monthUuid = _uuid.v4();
    final dayUuid = _uuid.v4();
    final hourUuid = _uuid.v4();

    final heavenlyStemUuid = _uuid.v4();
    final earthlyBranchUuid = _uuid.v4();
    final naYinUuid = _uuid.v4();
    final kongWangUuid = _uuid.v4();
    final tenGodUuid = _uuid.v4();

    return CardPayload(
      gender: gender,
      pillarMap: {
        yearUuid: ContentPillarPayload(
          uuid: yearUuid,
          pillarLabel: '年',
          pillarType: PillarType.year,
          pillarContent: PillarContent(
            id: 'pillar-year',
            pillarType: PillarType.year,
            label: '年',
            jiaZi: eightChars.year,
            description: '示例年柱',
            version: '1',
            sourceKind: PillarSourceKind.userInput,
          ),
        ),
        monthUuid: ContentPillarPayload(
          uuid: monthUuid,
          pillarLabel: '月',
          pillarType: PillarType.month,
          pillarContent: PillarContent(
            id: 'pillar-month',
            pillarType: PillarType.month,
            label: '月',
            jiaZi: eightChars.month,
            description: '示例月柱',
            version: '1',
            sourceKind: PillarSourceKind.userInput,
          ),
        ),
        dayUuid: ContentPillarPayload(
          uuid: dayUuid,
          pillarLabel: '日',
          pillarType: PillarType.day,
          pillarContent: PillarContent(
            id: 'pillar-day',
            pillarType: PillarType.day,
            label: '日',
            jiaZi: eightChars.day,
            description: '示例日柱',
            version: '1',
            sourceKind: PillarSourceKind.userInput,
          ),
        ),
        hourUuid: ContentPillarPayload(
          uuid: hourUuid,
          pillarLabel: '时',
          pillarType: PillarType.hour,
          pillarContent: PillarContent(
            id: 'pillar-hour',
            pillarType: PillarType.hour,
            label: '时',
            jiaZi: eightChars.time,
            description: '示例时柱',
            version: '1',
            sourceKind: PillarSourceKind.userInput,
          ),
        ),
      },
      pillarOrderUuid: [yearUuid, monthUuid, dayUuid, hourUuid],
      rowMap: {
        tenGodUuid: TextRowPayload(
          rowType: RowType.tenGod,
          rowLabel: '十神',
          uuid: tenGodUuid,
          titleInCell: false,
        ),
        heavenlyStemUuid: TextRowPayload(
          rowType: RowType.heavenlyStem,
          rowLabel: '天干',
          uuid: heavenlyStemUuid,
          titleInCell: false,
        ),
        earthlyBranchUuid: TextRowPayload(
          rowType: RowType.earthlyBranch,
          rowLabel: '地支',
          uuid: earthlyBranchUuid,
          titleInCell: false,
        ),
        naYinUuid: TextRowPayload(
          rowType: RowType.naYin,
          rowLabel: '纳音',
          uuid: naYinUuid,
          titleInCell: false,
        ),
        kongWangUuid: TextRowPayload(
          rowType: RowType.kongWang,
          rowLabel: '空亡',
          uuid: kongWangUuid,
          titleInCell: false,
        ),
      },
      rowOrderUuid: [
        tenGodUuid,
        heavenlyStemUuid,
        earthlyBranchUuid,
        naYinUuid,
        kongWangUuid,
      ],
    );
  }

  void _syncRuntimeStateFromTemplate(LayoutTemplate template) {
    final theme = editableThemeNotifier.value;
    var nextTheme = theme;

    final rawTheme = template.editableTheme;
    if (rawTheme != null) {
      try {
        nextTheme = EditableFourZhuCardTheme.fromJson(rawTheme);
      } catch (_) {}
    }

    final cardStyle = template.cardStyle;

    if (theme.card.padding != cardStyle.contentPadding) {
      nextTheme = nextTheme.copyWith(
        card: nextTheme.card.copyWith(padding: cardStyle.contentPadding),
      );
    }

    // Sync Divider Styles (Border)
    final currentBorder = theme.card.border;
    final targetThickness = cardStyle.dividerThickness;
    // Helper to parse hex color safely
    Color parseColor(String hex) {
      var v = hex.trim().toUpperCase();
      if (v.startsWith('0X')) v = v.substring(2);
      if (v.startsWith('#')) v = v.substring(1);
      if (v.length == 6) v = 'FF$v';
      final val = int.tryParse(v, radix: 16) ?? 0xFF000000;
      return Color(val);
    }

    final targetColor = parseColor(cardStyle.dividerColorHex);
    final targetEnabled = cardStyle.dividerType != BorderType.none;

    // Check if border needs update
    if (currentBorder == null ||
        currentBorder.width != targetThickness ||
        currentBorder.lightColor != targetColor ||
        currentBorder.enabled != targetEnabled) {
      final newBorder = (currentBorder ??
              BoxBorderStyle(
                  enabled: true,
                  width: 1,
                  lightColor: Colors.black,
                  darkColor: Colors.white,
                  radius: 0))
          .copyWith(
        width: targetThickness,
        lightColor: targetColor,
        // Syncing only light color for now as per template limitation
        enabled: targetEnabled,
      );
      nextTheme = nextTheme.copyWith(
        card: nextTheme.card.copyWith(border: newBorder),
      );
    }

    final family = (cardStyle.globalFontFamily.trim().isEmpty)
        ? 'System'
        : cardStyle.globalFontFamily;
    final size = cardStyle.globalFontSize;
    final currentTypography = nextTheme.typography;
    final currentFont = currentTypography.globalContent.fontStyleDataModel;

    var updatedTypography = currentTypography;
    bool typographyChanged = false;

    if (currentFont.fontFamily != family || currentFont.fontSize != size) {
      final updatedGlobalContent = currentTypography.globalContent.copyWith(
        fontStyleDataModel: currentFont.copyWith(
          fontFamily: family,
          fontSize: size,
        ),
      );
      updatedTypography =
          updatedTypography.copyWith(globalContent: updatedGlobalContent);
      typographyChanged = true;
    }

    // Sync Row Styles
    final mapper =
        Map<RowType, TextStyleConfig>.of(updatedTypography.cellContentMapper);
    bool mapperChanged = false;

    for (final config in template.rowConfigs) {
      if (mapper[config.type] != config.textStyleConfig) {
        mapper[config.type] = config.textStyleConfig;
        mapperChanged = true;
      }
    }

    if (mapperChanged) {
      updatedTypography = updatedTypography.copyWith(cellContentMapper: mapper);
      typographyChanged = true;
    }

    if (typographyChanged) {
      nextTheme = nextTheme.copyWith(typography: updatedTypography);
    }

    if (nextTheme != theme) {
      editableThemeNotifier.value = nextTheme;
      paddingNotifier.value = nextTheme.card.padding;
    }

    _syncStructureFromTemplate(template);
  }

  void _syncStructureFromTemplate(LayoutTemplate template) {
    final currentPayload = cardPayloadNotifier.value;
    var nextPayload = currentPayload;
    bool payloadChanged = false;

    // 1. Sync Row Order
    // Map RowType to existing UUIDs
    final typeToUuidMap = <RowType, String>{};
    currentPayload.rowMap.forEach((uuid, payload) {
      if (payload is TextRowPayload) {
        typeToUuidMap[payload.rowType] = uuid;
      }
    });

    final newRowOrderUuid = <String>[];
    final newRowMap = Map<String, RowPayload>.from(currentPayload.rowMap);

    for (final config in template.rowConfigs) {
      if (!config.isVisible) continue;

      final type = config.type;
      if (type == RowType.separator) {
        // Always create new UUID for separators or try to reuse?
        // Separators don't have unique type identity, they are structural.
        // For now, let's create new to avoid complexity of tracking multiple separators.
        // Or better: we can't easily map old separators to new ones without IDs.
        // But CardPayload doesn't strictly require reusing UUIDs if we rebuild the list.
        final newUuid = _uuid.v4();
        final newRowPayload = RowSeparatorPayload(uuid: newUuid);
        newRowMap[newUuid] = newRowPayload;
        newRowOrderUuid.add(newUuid);
      } else if (typeToUuidMap.containsKey(type)) {
        final uuid = typeToUuidMap[type]!;
        newRowOrderUuid.add(uuid);

        // Update existing payload if properties changed
        final existingPayload = newRowMap[uuid];
        if (existingPayload is TextRowPayload) {
          if (existingPayload.tenGodLabelType != config.tenGodLabelType ||
              existingPayload.titleInCell != !config.isTitleVisible) {
            newRowMap[uuid] = existingPayload.copyWith(
              tenGodLabelType: config.tenGodLabelType,
              titleInCell: !config.isTitleVisible,
            );
          }
        }
      } else {
        // Create new payload for this row type
        final newUuid = _uuid.v4();
        if (type == RowType.columnHeaderRow) {
          final newRowPayload = ColumnHeaderRowPayload(
            gender: currentPayload.gender,
            uuid: newUuid,
          );
          newRowMap[newUuid] = newRowPayload;
          newRowOrderUuid.add(newUuid);
        } else {
          final label = _getRowLabel(type);
          final newRowPayload = TextRowPayload(
            rowType: type,
            rowLabel: label,
            uuid: newUuid,
            titleInCell: !config.isTitleVisible,
            tenGodLabelType: config.tenGodLabelType,
          );
          newRowMap[newUuid] = newRowPayload;
          newRowOrderUuid.add(newUuid);
        }
      }
    }

    if (!_areListsEqual(currentPayload.rowOrderUuid, newRowOrderUuid) ||
        newRowMap.length != currentPayload.rowMap.length) {
      nextPayload = nextPayload.copyWith(
        rowOrderUuid: newRowOrderUuid,
        rowMap: newRowMap,
      );
      payloadChanged = true;
    }

    // 2. Sync Pillar Order (Flattened from Groups)
    final flattenedPillars = <PillarType>[];
    for (final group in template.chartGroups) {
      flattenedPillars.addAll(group.pillarOrder);
    }

    final pillarTypeToUuidMap = <PillarType, String>{};
    currentPayload.pillarMap.forEach((uuid, payload) {
      pillarTypeToUuidMap[payload.pillarType] = uuid;
    });

    final newPillarOrderUuid = <String>[];
    final newPillarMap =
        Map<String, PillarPayload>.from(currentPayload.pillarMap);

    for (final type in flattenedPillars) {
      var uuid = pillarTypeToUuidMap[type];
      if (uuid == null) {
        uuid = _uuid.v4();
        final String label;
        switch (type) {
          case PillarType.year:
            label = '年';
            break;
          case PillarType.month:
            label = '月';
            break;
          case PillarType.day:
            label = '日';
            break;
          case PillarType.hour:
            label = '时';
            break;
          default:
            label = type.name;
            break;
        }

        final PillarPayload payload;
        if (type == PillarType.rowTitleColumn) {
          payload = RowTitleColumnPayload(uuid: uuid);
        } else if (type == PillarType.separator) {
          payload = SeparatorPillarPayload(uuid: uuid);
        } else {
          payload = ContentPillarPayload(
            uuid: uuid,
            pillarLabel: label,
            pillarType: type,
            pillarContent: PillarContent(
              id: 'pillar-$uuid',
              pillarType: type,
              label: label,
              jiaZi: JiaZi.JIA_ZI,
              description: '占位柱',
              version: '1',
              sourceKind: PillarSourceKind.userInput,
            ),
          );
        }

        newPillarMap[uuid] = payload;
        pillarTypeToUuidMap[type] = uuid;
      }
      newPillarOrderUuid.add(uuid);
    }

    if (!_areListsEqual(currentPayload.pillarOrderUuid, newPillarOrderUuid)) {
      nextPayload = nextPayload.copyWith(
        pillarOrderUuid: newPillarOrderUuid,
        pillarMap: newPillarMap,
      );
      payloadChanged = true;
    }

    if (payloadChanged) {
      cardPayloadNotifier.value = nextPayload;
    }
  }

  bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String _getRowLabel(RowType type) {
    switch (type) {
      case RowType.tenGod:
        return '十神';
      case RowType.heavenlyStem:
        return '天干';
      case RowType.earthlyBranch:
        return '地支';
      case RowType.naYin:
        return '纳音';
      case RowType.kongWang:
        return '空亡';
      case RowType.gu:
        return '孤';
      case RowType.xu:
        return '虚';
      case RowType.xunShou:
        return '旬首';
      case RowType.yiMa:
        return '驿马';
      case RowType.hiddenStems:
        return '藏干';
      case RowType.hiddenStemsTenGod:
        return '藏干十神';
      case RowType.hiddenStemsPrimary:
        return '藏干(主)';
      case RowType.hiddenStemsSecondary:
        return '藏干(中)';
      case RowType.hiddenStemsTertiary:
        return '藏干(余)';
      case RowType.hiddenStemsPrimaryGods:
        return '藏干十神(主)';
      case RowType.hiddenStemsSecondaryGods:
        return '藏干十神(中)';
      case RowType.hiddenStemsTertiaryGods:
        return '藏干十神(余)';
      case RowType.starYun:
        return '星运';
      case RowType.selfSiting:
        return '自坐';
      default:
        return type.name;
    }
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
    } catch (error, st) {
      _errorMessage = error.toString();
      _templateTelemetry.error(
        'editor.flow_error',
        data: <String, Object?>{
          'templateId': _currentTemplate?.id,
          'collectionId': _collectionId,
        },
        error: error,
        stackTrace: st,
      );
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