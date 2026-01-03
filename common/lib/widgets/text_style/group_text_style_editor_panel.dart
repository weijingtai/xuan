import 'package:flutter/material.dart';

import '../editable_fourzhu_card/text_groups.dart';
import '../style_editor/colorful_text_style_editor_widget.dart';

/// 分组文本样式编辑面板（统一导出组件）
///
/// 通过 `isColorful` 参数控制编辑器呈现策略：
/// - 当 `isColorful = true` 时，天干/地支使用彩色编辑器，其余分组使用普通编辑器；
/// - 当 `isColorful = false` 时，所有分组均使用普通编辑器。
///
/// 对外契约保持一致：
/// - `onChanged(Map<TextGroup, TextStyle>)` 在任一分组样式变化时发出当前合并映射。
class GroupTextStyleEditorPanel extends StatefulWidget {
  /// 初始分组样式映射，可为空；为空时内部使用空映射。
  final Map<TextGroup, TextStyle>? initial;

  /// 分组样式变化回调，传出当前 `Map<TextGroup, TextStyle>` 合并结果。
  final ValueChanged<Map<TextGroup, TextStyle>> onChanged;

  /// 是否启用彩色编辑器策略（天干/地支彩色，其余普通）。
  final bool isColorful;

  /// 构造分组文本样式编辑面板。
  ///
  /// 参数：
  /// - [initial]：可选初始映射；若为空将使用空映射。
  /// - [onChanged]：样式变更回调，传出当前所有分组的合并样式。
  /// - [isColorful]：是否启用彩色编辑策略（默认 false）。
  const GroupTextStyleEditorPanel({
    super.key,
    this.initial,
    required this.onChanged,
    this.isColorful = false,
  });

  @override
  State<GroupTextStyleEditorPanel> createState() =>
      _GroupTextStyleEditorPanelState();
}

class _GroupTextStyleEditorPanelState extends State<GroupTextStyleEditorPanel> {
  late Map<TextGroup, TextStyle> _styles;

  /// 初始化状态：加载初始样式映射。
  ///
  /// 行为：将 `widget.initial` 拷贝为内部可变映射，若为空则使用空映射。
  @override
  void initState() {
    super.initState();
    _styles = Map<TextGroup, TextStyle>.of(widget.initial ?? {});
  }

  /// 更新指定分组的样式并触发回调。
  ///
  /// 参数：
  /// - [g]：待更新的文本分组标识。
  /// - [s]：新的 `TextStyle`。
  ///
  /// 返回：
  /// - `void`：同时通过 `setState` 刷新 UI 并调用 `widget.onChanged` 通知外部。
  void _update(TextGroup g, TextStyle s) {
    setState(() => _styles[g] = s);
    widget.onChanged(_styles);
  }

  /// 构建面板布局：根据 `isColorful` 选择具体编辑器组件。
  ///
  /// 参数：
  /// - [context]：Flutter 构建上下文。
  ///
  /// 返回：
  /// - `Widget`：包含六个分组编辑器的纵向列表。
  @override
  Widget build(BuildContext context) {
    // 强制天干/地支使用彩色编辑器组件，不受 isColorful 开关影响。
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 天干
        ColorfulTextStyleEditorWidget(
          label: '天干',
          initialStyle: _styles[TextGroup.tianGan],
          onChanged: (s) => _update(TextGroup.tianGan, s),
          showInlineWheel: false,
        ),
        // 地支
        ColorfulTextStyleEditorWidget(
          label: '地支',
          initialStyle: _styles[TextGroup.diZhi],
          onChanged: (s) => _update(TextGroup.diZhi, s),
          showInlineWheel: false,
        ),
        // // 纳音
        // TextStyleEditorWidget(
        //   label: '纳音',
        //   initialStyle: _styles[TextGroup.naYin],
        //   onChanged: (s) => _update(TextGroup.naYin, s),
        //   showInlineWheel: false,
        // ),
        // // 空亡
        // TextStyleEditorWidget(
        //   label: '空亡',
        //   initialStyle: _styles[TextGroup.kongWang],
        //   onChanged: (s) => _update(TextGroup.kongWang, s),
        //   showInlineWheel: false,
        // ),
        // // 柱标题
        // TextStyleEditorWidget(
        //   label: '柱标题',
        //   initialStyle: _styles[TextGroup.columnTitle],
        //   onChanged: (s) => _update(TextGroup.columnTitle, s),
        //   showInlineWheel: false,
        // ),
        // // 行标题
        // TextStyleEditorWidget(
        //   label: '行标题',
        //   initialStyle: _styles[TextGroup.rowTitle],
        //   onChanged: (s) => _update(TextGroup.rowTitle, s),
        //   showInlineWheel: false,
        // ),
      ],
    );
  }
}
