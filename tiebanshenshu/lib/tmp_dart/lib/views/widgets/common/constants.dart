import 'package:flutter/material.dart';

import '../../../models/atom_operation.dart';

// 应用常量
class AppConstants {
  // 应用信息
  static const String appName = '铁板神数算法编辑器';
  static const String appVersion = '1.0.0';

  // 布局常量
  static const double sidebarWidth = 320.0;
  static const double sidebarMinWidth = 280.0;
  static const double sidebarMaxWidth = 400.0;

  static const double dataPanelHeight = 300.0;
  static const double dataPanelMinHeight = 200.0;
  static const double dataPanelMaxHeight = 600.0;

  static const double flowNodeWidth = 224.0;
  static const double flowNodeHeight = 80.0;
  static const double flowNodeBorderRadius = 8.0;

  // 动画常量
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  static const Curve animationCurve = Curves.easeInOut;
  static const Curve fastAnimationCurve = Curves.easeOut;

  // 缩放常量
  static const double minZoomLevel = 0.25;
  static const double maxZoomLevel = 3.0;
  static const double defaultZoomLevel = 1.0;
  static const double zoomStep = 0.25;

  // 拖拽常量
  static const double dragThreshold = 10.0;
  static const Duration longPressDelay = Duration(milliseconds: 500);
  static const double dropZonePadding = 20.0;

  // 网格常量
  static const double gridSize = 20.0;
  static const Color gridColor = Color(0xFFE5E7EB);
  static const double gridOpacity = 0.5;

  // 连接线常量
  static const double connectionStrokeWidth = 2.0;
  static const double activeConnectionStrokeWidth = 2.5;
  static const double connectionControlPointOffset = 50.0;

  // 阴影常量
  static const List<BoxShadow> panelShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  // 边距常量
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  static const EdgeInsets largePadding = EdgeInsets.all(24.0);

  static const EdgeInsets cardPadding = EdgeInsets.all(12.0);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 8.0,
  );

  // 间距常量
  static const double smallSpacing = 8.0;
  static const double defaultSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // 圆角常量
  static const double smallBorderRadius = 4.0;
  static const double defaultBorderRadius = 8.0;
  static const double largeBorderRadius = 12.0;
  static const double extraLargeBorderRadius = 16.0;

  // 字体大小常量
  static const double smallFontSize = 12.0;
  static const double defaultFontSize = 14.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 18.0;
  static const double extraLargeFontSize = 20.0;
  static const double titleFontSize = 24.0;

  // 图标大小常量
  static const double smallIconSize = 16.0;
  static const double defaultIconSize = 20.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 48.0;

  // 透明度常量
  static const double lowOpacity = 0.1;
  static const double mediumOpacity = 0.3;
  static const double highOpacity = 0.7;
  static const double disabledOpacity = 0.5;

  // 响应式断点
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1200.0;

  // Toast 常量
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration errorToastDuration = Duration(seconds: 4);
  static const double toastBorderRadius = 8.0;

  // 键盘快捷键
  static const String saveShortcut = 'Ctrl+S';
  static const String undoShortcut = 'Ctrl+Z';
  static const String redoShortcut = 'Ctrl+Y';
  static const String copyShortcut = 'Ctrl+C';
  static const String pasteShortcut = 'Ctrl+V';
  static const String deleteShortcut = 'Delete';

  // 文件扩展名
  static const String projectFileExtension = '.tbss';
  static const String exportFileExtension = '.json';

  // API 常量
  static const int apiTimeout = 30; // 秒
  static const int maxRetryAttempts = 3;

  // 本地存储键
  static const String lastProjectKey = 'last_project';
  static const String userPreferencesKey = 'user_preferences';
  static const String recentProjectsKey = 'recent_projects';
  static const String windowStateKey = 'window_state';

  // 原子操作常量
  static const List<AtomOperation> timeOperations = [
    AtomOperation(
      id: 'get_current_time',
      type: 'time',
      name: '获取当前时间',
      description: '获取当前系统时间',
      category: AtomOperationCategory.time,
      input: '无',
      output: '时间对象',
      icon: 'access_time',
    ),
    AtomOperation(
      id: 'parse_time_string',
      type: 'time',
      name: '解析时间字符串',
      description: '将时间字符串解析为时间对象',
      category: AtomOperationCategory.logic,
      input: '时间字符串',
      output: '时间对象',
      icon: 'schedule',
    ),
    AtomOperation(
      id: 'get_year',
      type: 'time',
      name: '获取年份',
      description: '从时间对象中提取年份',
      category: AtomOperationCategory.logic,
      input: '时间对象',
      output: '年份数值',
      icon: 'calendar_today',
    ),
    AtomOperation(
      id: 'get_month',
      type: 'time',
      name: '获取月份',
      description: '从时间对象中提取月份',
      category: AtomOperationCategory.logic,
      input: '时间对象',
      output: '月份数值',
      icon: 'calendar_month',
    ),
    AtomOperation(
      id: 'get_day',
      type: 'time',
      name: '获取日期',
      description: '从时间对象中提取日期',
      category: AtomOperationCategory.logic,
      input: '时间对象',
      output: '日期数值',
      icon: 'today',
    ),
    AtomOperation(
      id: 'get_hour',
      type: 'time',
      name: '获取小时',
      description: '从时间对象中提取小时',
      category: AtomOperationCategory.logic,
      input: '时间对象',
      output: '小时数值',
      icon: 'access_time',
    ),
    AtomOperation(
      id: 'convert_to_ganzhi',
      type: 'time',
      name: '转换为干支',
      description: '将时间转换为干支纪年法',
      category: AtomOperationCategory.logic,
      input: '时间对象',
      output: '干支字符串',
      icon: 'transform',
    ),
  ];

  static const List<AtomOperation> numberOperations = [
    AtomOperation(
      id: 'add_numbers',
      type: 'calculation',
      name: '数值相加',
      description: '计算两个数值的和',
      category: AtomOperationCategory.logic,
      input: '数值A, 数值B',
      output: '和值',
      icon: 'add',
    ),
    AtomOperation(
      id: 'subtract_numbers',
      type: 'calculation',
      name: '数值相减',
      description: '计算两个数值的差',
      category: AtomOperationCategory.logic,
      input: '数值A, 数值B',
      output: '差值',
      icon: 'remove',
    ),
    AtomOperation(
      id: 'multiply_numbers',
      type: 'calculation',
      name: '数值相乘',
      description: '计算两个数值的积',
      category: AtomOperationCategory.logic,
      input: '数值A, 数值B',
      output: '积值',
      icon: 'close',
    ),
    AtomOperation(
      id: 'divide_numbers',
      type: 'calculation',
      name: '数值相除',
      description: '计算两个数值的商',
      category: AtomOperationCategory.logic,
      input: '数值A, 数值B',
      output: '商值',
      icon: 'horizontal_rule',
    ),
    AtomOperation(
      id: 'modulo_operation',
      type: 'calculation',
      name: '取模运算',
      description: '计算数值的模',
      category: AtomOperationCategory.logic,
      input: '数值A, 数值B',
      output: '余数',
      icon: 'percent',
    ),
    AtomOperation(
      id: 'power_operation',
      type: 'calculation',
      name: '幂运算',
      description: '计算数值的幂',
      category: AtomOperationCategory.logic,
      input: '底数, 指数',
      output: '幂值',
      icon: 'functions',
    ),
    AtomOperation(
      id: 'absolute_value',
      type: 'calculation',
      name: '绝对值',
      description: '计算数值的绝对值',
      category: AtomOperationCategory.logic,
      input: '数值',
      output: '绝对值',
      icon: 'straighten',
    ),
  ];

  static const List<AtomOperation> logicOperations = [
    AtomOperation(
      id: 'equal_comparison',
      type: 'logic',
      name: '等于比较',
      description: '判断两个值是否相等',
      category: AtomOperationCategory.logic,
      input: '值A, 值B',
      output: '布尔值',
      icon: 'drag_handle',
    ),
    AtomOperation(
      id: 'not_equal_comparison',
      type: 'logic',
      name: '不等于比较',
      description: '判断两个值是否不相等',
      category: AtomOperationCategory.logic,
      input: '值A, 值B',
      output: '布尔值',
      icon: 'not_equal',
    ),
    AtomOperation(
      id: 'greater_than',
      type: 'logic',
      name: '大于比较',
      description: '判断A是否大于B',
      category: AtomOperationCategory.logic,
      input: '数值A, 数值B',
      output: '布尔值',
      icon: 'keyboard_arrow_right',
    ),
    AtomOperation(
      id: 'less_than',
      type: 'logic',
      name: '小于比较',
      description: '判断A是否小于B',
      category: AtomOperationCategory.logic,
      input: '数值A, 数值B',
      output: '布尔值',
      icon: 'keyboard_arrow_left',
    ),
    AtomOperation(
      id: 'greater_equal',
      type: 'logic',
      name: '大于等于',
      description: '判断A是否大于等于B',
      category: AtomOperationCategory.logic,
      input: '数值A, 数值B',
      output: '布尔值',
      icon: 'keyboard_double_arrow_right',
    ),
    AtomOperation(
      id: 'less_equal',
      type: 'logic',
      name: '小于等于',
      description: '判断A是否小于等于B',
      category: AtomOperationCategory.logic,
      input: '数值A, 数值B',
      output: '布尔值',
      icon: 'keyboard_double_arrow_left',
    ),
    AtomOperation(
      id: 'logical_and',
      type: 'logic',
      name: '逻辑与',
      description: '执行逻辑与运算',
      category: AtomOperationCategory.logic,
      input: '布尔值A, 布尔值B',
      output: '布尔值',
      icon: 'and',
    ),
    AtomOperation(
      id: 'logical_or',
      type: 'logic',
      name: '逻辑或',
      description: '执行逻辑或运算',
      category: AtomOperationCategory.logic,
      input: '布尔值A, 布尔值B',
      output: '布尔值',
      icon: 'or',
    ),
    AtomOperation(
      id: 'logical_not',
      type: 'logic',
      name: '逻辑非',
      description: '执行逻辑非运算',
      category: AtomOperationCategory.logic,
      input: '布尔值',
      output: '布尔值',
      icon: 'not',
    ),
  ];

  static const List<AtomOperation> formatOperations = [
    AtomOperation(
      id: 'format_number',
      type: 'output',
      name: '格式化数字',
      description: '将数字格式化为指定格式',
      category: AtomOperationCategory.output,
      input: '数值, 格式字符串',
      output: '格式化字符串',
      icon: 'format_list_numbered',
    ),
    AtomOperation(
      id: 'format_text',
      type: 'output',
      name: '格式化文本',
      description: '将文本格式化为指定格式',
      category: AtomOperationCategory.output,
      input: '文本, 格式字符串',
      output: '格式化字符串',
      icon: 'text_format',
    ),
    AtomOperation(
      id: 'concatenate_strings',
      type: 'output',
      name: '字符串拼接',
      description: '将多个字符串拼接为一个',
      category: AtomOperationCategory.output,
      input: '字符串列表',
      output: '拼接后字符串',
      icon: 'link',
    ),
    AtomOperation(
      id: 'format_date',
      type: 'output',
      name: '格式化日期',
      description: '将日期格式化为指定格式',
      category: AtomOperationCategory.output,
      input: '日期对象, 格式字符串',
      output: '格式化日期字符串',
      icon: 'date_range',
    ),
    AtomOperation(
      id: 'format_ganzhi',
      type: 'output',
      name: '格式化干支',
      description: '将干支信息格式化输出',
      category: AtomOperationCategory.output,
      input: '干支对象',
      output: '格式化干支字符串',
      icon: 'format_quote',
    ),
    AtomOperation(
      id: 'format_result',
      type: 'output',
      name: '格式化结果',
      description: '将计算结果格式化为最终输出',
      category: AtomOperationCategory.output,
      input: '结果对象',
      output: '格式化结果字符串',
      icon: 'output',
    ),
  ];
}

// 原子操作类别配置
class AtomOperationConfig {
  static const Map<String, Color> categoryColors = {
    'time': Color(0xFF10B981),
    'calculation': Color(0xFF3B82F6),
    'transformation': Color(0xFF8B5CF6),
    'analysis': Color(0xFFF59E0B),
    'output': Color(0xFFEF4444),
  };

  static const Map<String, IconData> categoryIcons = {
    'time': Icons.access_time,
    'calculation': Icons.calculate,
    'transformation': Icons.transform,
    'analysis': Icons.analytics,
    'output': Icons.output,
  };

  static const Map<String, String> categoryNames = {
    'time': '时间处理',
    'calculation': '数值计算',
    'transformation': '数据转换',
    'analysis': '数据分析',
    'output': '结果输出',
  };
}

// 错误消息常量
class ErrorMessages {
  static const String networkError = '网络连接错误，请检查网络设置';
  static const String fileNotFound = '文件未找到';
  static const String invalidFileFormat = '文件格式不正确';
  static const String saveError = '保存失败，请重试';
  static const String loadError = '加载失败，请重试';
  static const String unknownError = '未知错误，请联系技术支持';

  static const String dragDropError = '拖拽操作失败';
  static const String nodeConnectionError = '节点连接失败';
  static const String invalidNodePosition = '节点位置无效';
  static const String duplicateNodeId = '节点ID重复';
}

// 成功消息常量
class SuccessMessages {
  static const String fileSaved = '文件保存成功';
  static const String fileLoaded = '文件加载成功';
  static const String nodeAdded = '节点添加成功';
  static const String nodeDeleted = '节点删除成功';
  static const String nodeConnected = '节点连接成功';
  static const String projectExported = '项目导出成功';
  static const String settingsSaved = '设置保存成功';
}

// 确认消息常量
class ConfirmMessages {
  static const String deleteNode = '确定要删除这个节点吗？';
  static const String clearAll = '确定要清空所有节点吗？';
  static const String discardChanges = '确定要放弃未保存的更改吗？';
  static const String overwriteFile = '文件已存在，确定要覆盖吗？';
}
