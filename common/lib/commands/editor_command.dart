import 'package:common/models/layout_template.dart';

/// Command接口 - 所有编辑器操作命令的基类
///
/// 实现Command模式，支持撤销/重做功能
/// 每个Command封装一个具体的编辑操作及其逆操作
abstract class EditorCommand {
  /// 命令描述，用于调试和日志
  String get description;

  /// 执行命令，修改模板并返回新模板
  ///
  /// [currentTemplate] 当前模板状态
  /// 返回修改后的新模板状态
  LayoutTemplate execute(LayoutTemplate currentTemplate);

  /// 撤销命令，恢复到执行前的状态
  ///
  /// [currentTemplate] 当前模板状态
  /// 返回撤销后的模板状态
  LayoutTemplate undo(LayoutTemplate currentTemplate);

  /// 命令是否可以与前一个命令合并
  /// 用于优化撤销栈（例如连续的文本输入可以合并为一个命令）
  bool canMergeWith(EditorCommand other) => false;

  /// 与另一个命令合并
  /// 只有在 canMergeWith 返回 true 时才会调用
  EditorCommand mergeWith(EditorCommand other) => this;
}

/// 命令历史管理器
///
/// 管理编辑器的撤销/重做栈
class CommandHistory {
  CommandHistory({this.maxHistorySize = 50});

  /// 最大历史记录数量
  final int maxHistorySize;

  /// 撤销栈 - 存储已执行的命令
  final List<EditorCommand> _undoStack = [];

  /// 重做栈 - 存储已撤销的命令
  final List<EditorCommand> _redoStack = [];

  /// 当前是否可以撤销
  bool get canUndo => _undoStack.isNotEmpty;

  /// 当前是否可以重做
  bool get canRedo => _redoStack.isNotEmpty;

  /// 撤销栈大小
  int get undoCount => _undoStack.length;

  /// 重做栈大小
  int get redoCount => _redoStack.length;

  /// 执行一个命令
  ///
  /// [command] 要执行的命令
  /// [currentTemplate] 当前模板状态
  /// 返回执行后的新模板状态
  LayoutTemplate executeCommand(
    EditorCommand command,
    LayoutTemplate currentTemplate,
  ) {
    // 尝试与最后一个命令合并
    if (_undoStack.isNotEmpty) {
      final lastCommand = _undoStack.last;
      if (lastCommand.canMergeWith(command)) {
        _undoStack.removeLast();
        final mergedCommand = lastCommand.mergeWith(command);
        _undoStack.add(mergedCommand);
        _redoStack.clear();
        return mergedCommand.execute(currentTemplate);
      }
    }

    // 执行新命令
    final newTemplate = command.execute(currentTemplate);

    // 添加到撤销栈
    _undoStack.add(command);

    // 清空重做栈（新操作后不能重做之前撤销的操作）
    _redoStack.clear();

    // 限制历史记录大小
    if (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }

    return newTemplate;
  }

  /// 撤销最后一个命令
  ///
  /// [currentTemplate] 当前模板状态
  /// 返回撤销后的模板状态，如果无法撤销则返回 null
  LayoutTemplate? undo(LayoutTemplate currentTemplate) {
    if (!canUndo) return null;

    final command = _undoStack.removeLast();
    _redoStack.add(command);

    return command.undo(currentTemplate);
  }

  /// 重做最后一个被撤销的命令
  ///
  /// [currentTemplate] 当前模板状态
  /// 返回重做后的模板状态，如果无法重做则返回 null
  LayoutTemplate? redo(LayoutTemplate currentTemplate) {
    if (!canRedo) return null;

    final command = _redoStack.removeLast();
    _undoStack.add(command);

    return command.execute(currentTemplate);
  }

  /// 清空所有历史记录
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  /// 获取撤销栈的描述（用于调试）
  List<String> getUndoDescriptions() {
    return _undoStack.map((cmd) => cmd.description).toList();
  }

  /// 获取重做栈的描述（用于调试）
  List<String> getRedoDescriptions() {
    return _redoStack.map((cmd) => cmd.description).toList();
  }
}
