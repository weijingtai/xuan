// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '节点编辑器示例';

  @override
  String get saveProjectDialogTitle => '保存项目';

  @override
  String get unsavedChangesTitle => '未保存的更改';

  @override
  String get unsavedChangesMsg => '您有未保存的更改。要在不保存的情况下继续吗？';

  @override
  String get cancel => '取消';

  @override
  String get proceed => '继续';

  @override
  String get failedToLoadSampleProject => '无法加载示例项目。请检查您的网络连接。';

  @override
  String get searchNodesTooltip => '按名称搜索节点';

  @override
  String get toggleHierarchyTooltip => '切换层级面板';

  @override
  String get toggleSnapToGridTooltip => '切换对齐网格';

  @override
  String get executeGraphTooltip => '执行图表';

  @override
  String get touchCommandsTitle => '触控操作：';

  @override
  String get touchTap => '- 点击：选择节点';

  @override
  String get touchDoubleTap => '- 双击：清除选择';

  @override
  String get touchLongPress => '- 长按：打开上下文菜单';

  @override
  String get touchDrag => '- 拖动：开始连接 / 选择节点';

  @override
  String get touchPinch => '- 捏合：缩放';

  @override
  String get touchAdditionalGestures => '其他手势：';

  @override
  String get touchTwoFingerDrag => '- 双指拖动：平移';

  @override
  String get mouseCommandsTitle => '鼠标操作：';

  @override
  String get mouseLeftClick => '- 左键单击：选择节点/连接';

  @override
  String get mouseRightClick => '- 右键单击：打开上下文菜单';

  @override
  String get mouseScroll => '- 滚轮：缩放';

  @override
  String get mouseMiddleClick => '- 中键单击：平移';

  @override
  String get keyboardCommandsTitle => '键盘操作：';

  @override
  String keyboardSave(String comboKey) {
    return '- $comboKey + S：保存项目';
  }

  @override
  String keyboardOpen(String comboKey) {
    return '- $comboKey + O：打开项目';
  }

  @override
  String keyboardNew(String comboKey) {
    return '- $comboKey + Shift + N：新建项目';
  }

  @override
  String keyboardCopy(String comboKey) {
    return '- $comboKey + C：复制节点';
  }

  @override
  String keyboardPaste(String comboKey) {
    return '- $comboKey + V：粘贴节点';
  }

  @override
  String keyboardCut(String comboKey) {
    return '- $comboKey + X：剪切节点';
  }

  @override
  String get keyboardDelete => '- Delete | Backspace：删除节点';

  @override
  String keyboardUndo(String comboKey) {
    return '- $comboKey + Z：撤销';
  }

  @override
  String keyboardRedo(String comboKey) {
    return '- $comboKey + Y：重做';
  }

  @override
  String get searching => '正在搜索...';

  @override
  String get noResults => '未找到结果';

  @override
  String get nextResult => '下一个结果';

  @override
  String get previousResult => '上一个结果';

  @override
  String resultsCount(int count) {
    return '$count 个结果';
  }

  @override
  String resultPosition(int current, int total) {
    return '$current / $total';
  }

  @override
  String get numericValueNodeName => '数值';

  @override
  String get booleanValueNodeName => '布尔值';

  @override
  String get stringValueNodeName => '字符串值';

  @override
  String get numericListValueNodeName => '数值列表';

  @override
  String get booleanListValueNodeName => '布尔列表';

  @override
  String get stringListValueNodeName => '字符串列表';

  @override
  String valueNodeDescription(String type) {
    return '保存一个常量 $type 值。';
  }

  @override
  String get completedPortName => '完成';

  @override
  String get valuePortName => '值';

  @override
  String get valueFieldName => '值';

  @override
  String get operatorNodeName => '运算符';

  @override
  String get operatorNodeDescription => '对两个数字应用所选的运算。';

  @override
  String get execPortName => '执行';

  @override
  String get resultPortName => '结果';

  @override
  String get operationPortName => '运算';

  @override
  String get addFieldOption => '加';

  @override
  String get subtractFieldOption => '减';

  @override
  String get multiplyFieldOption => '乘';

  @override
  String get divideFieldOption => '除';

  @override
  String get randomNodeName => '随机数';

  @override
  String get randomNodeDescription => '输出 0 到 1 之间的随机数。';

  @override
  String get ifNodeName => '条件';

  @override
  String get ifNodeDescription => '根据条件执行一个分支。';

  @override
  String get conditionPortName => '条件';

  @override
  String get truePortName => '真';

  @override
  String get falsePortName => '假';

  @override
  String get comparatorNodeName => '比较器';

  @override
  String get comparatorNodeDescription => '根据选择的比较器比较两个数字。';

  @override
  String get comparatorPortName => '比较器';

  @override
  String get equalFieldOption => '==';

  @override
  String get notEqualFieldOption => '!=';

  @override
  String get greaterFieldOption => '>';

  @override
  String get greaterEqualFieldOption => '>=';

  @override
  String get lessFieldOption => '<';

  @override
  String get lessEqualFieldOption => '<=';

  @override
  String get printNodeName => '打印';

  @override
  String get printNodeDescription => '将值打印到控制台。';

  @override
  String printNodeSnackbarMessage(String value) {
    return '值: $value';
  }

  @override
  String get roundNodeName => '四舍五入';

  @override
  String get roundNodeDescription => '将数字四舍五入到指定的小数位数。';

  @override
  String get roundedPortName => '取整';

  @override
  String get decimalsFieldName => '小数位数';

  @override
  String get forEachLoopNodeName => '遍历循环';

  @override
  String get forEachLoopNodeDescription => '对列表中的每个元素执行循环操作。';

  @override
  String get listPortName => '列表';

  @override
  String get loopBodyPortName => '循环体';

  @override
  String get listElementPortName => '列表元素';

  @override
  String get listIndexPortName => '列表索引';

  @override
  String get cycleLocaleTooltip => '更改语言';
}
