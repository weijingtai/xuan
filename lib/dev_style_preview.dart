import 'package:flutter/material.dart';
import 'package:common/widgets/text_style/group_text_style_editor_panel.dart';
import 'package:common/widgets/editable_fourzhu_card/text_groups.dart';
import 'package:common/utils/style_resolver.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:common/enums/enum_di_zhi.dart';

/// 开发预览入口：集中化样式解析 + 分组编辑面板联动
///
/// - 功能：演示 `GroupTextStyleEditorPanel.onChanged` 输出的 `groupTextStyles` 如何在集中化解析中生效。
/// - 交互：编辑分组样式（字号/颜色等），观察 Gan/Zhi/NaYin/KongWang 文本的最终样式。
/// - 运行：`flutter run -d web-server -t lib/dev_style_preview.dart`
void main() {
  runApp(const DevStylePreviewApp());
}

/// 预览应用的根组件。
///
/// 构建一个包含分组编辑面板与演示区的界面，通过状态联动验证样式优先级：
/// 默认 < 全局 < 彩色元素色（Gan/Zhi） < 分组覆盖（最终）。
class DevStylePreviewApp extends StatelessWidget {
  const DevStylePreviewApp({super.key});

  /// 构建基础主题与首页。
  ///
  /// 返回：`MaterialApp`，首页为 `DevStylePreviewHomePage`。
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: DevStylePreviewHomePage());
  }
}

/// 预览首页，维护分组样式映射与全局样式开关。
class DevStylePreviewHomePage extends StatefulWidget {
  const DevStylePreviewHomePage({super.key});

  @override
  State<DevStylePreviewHomePage> createState() => _DevStylePreviewHomePageState();
}

class _DevStylePreviewHomePageState extends State<DevStylePreviewHomePage> {
  Map<TextGroup, TextStyle> _groupTextStyles = const {
    TextGroup.naYin: TextStyle(fontSize: 18),
    TextGroup.kongWang: TextStyle(color: Colors.blue),
  };
  bool _colorfulMode = true;
  String? _globalFontFamily;
  double? _globalFontSize;
  Color? _globalFontColor;
  final ElementColorResolver _resolver = const DefaultElementColorResolver();

  /// 默认样式：按 TextGroup 提供基础 TextStyle（字号/字重/默认色）。
  TextStyle _defaultTextStyleForGroup(TextGroup group) {
    switch (group) {
      case TextGroup.rowTitle:
      case TextGroup.columnTitle:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87);
      case TextGroup.naYin:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.amber);
      case TextGroup.kongWang:
      case TextGroup.tenGod:
      case TextGroup.xunShou:
      case TextGroup.hiddenStems:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black87);
      case TextGroup.tianGan:
        return const TextStyle(fontSize: 24, fontWeight: FontWeight.w400);
      case TextGroup.diZhi:
        return const TextStyle(fontSize: 24, fontWeight: FontWeight.w500);
      default:
        return const TextStyle();
    }
  }

  /// 集中化解析：默认 → 全局 → 彩色（Gan/Zhi） → 分组覆盖（最终）。
  ///
  /// 参数：
  /// - group：文本所属分组
  /// - gan/zhi：用于彩色模式下计算元素色（二者择一）
  /// 返回：最终 `TextStyle`
  TextStyle _resolveTextStyle(TextGroup group, {TianGan? gan, DiZhi? zhi}) {
    var style = _defaultTextStyleForGroup(group);

    // 全局 family/size/color
    if (_globalFontFamily != null && _globalFontFamily!.isNotEmpty) {
      style = style.copyWith(fontFamily: _globalFontFamily);
    }
    if (_globalFontSize != null && _globalFontSize! > 0) {
      style = style.copyWith(fontSize: _globalFontSize);
    }
    final bool isGanZhi = group == TextGroup.tianGan || group == TextGroup.diZhi;
    final bool suppressGlobalColor = _colorfulMode && isGanZhi;
    if (_globalFontColor != null && !suppressGlobalColor) {
      style = style.copyWith(color: _globalFontColor);
    }

    // 彩色模式：Gan/Zhi 元素色（若分组未覆盖）
    if (_colorfulMode && isGanZhi) {
      final Color tokenColor = gan != null
          ? _resolver.colorForGan(gan, context)
          : _resolver.colorForZhi(zhi!, context);
      style = style.copyWith(color: tokenColor);
    }

    // 分组覆盖：最终生效
    final override = _groupTextStyles[group];
    if (override != null) {
      if (override.fontFamily != null && override.fontFamily!.isNotEmpty) {
        style = style.copyWith(fontFamily: override.fontFamily);
      }
      if (override.fontSize != null && override.fontSize! > 0) {
        style = style.copyWith(fontSize: override.fontSize);
      }
      if (override.fontWeight != null) {
        style = style.copyWith(fontWeight: override.fontWeight);
      }
      if (override.shadows != null && override.shadows!.isNotEmpty) {
        style = style.copyWith(shadows: override.shadows);
      }
      if (override.color != null) {
        style = style.copyWith(color: override.color);
      }
    }

    // 非彩色 Gan/Zhi 的默认色
    if (isGanZhi && !_colorfulMode && style.color == null) {
      style = style.copyWith(color: Colors.black87);
    }
    return style;
  }

  /// 构建 UI：左侧编辑器，右侧演示区。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('样式集中化 · 联动预览')),
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('启用彩色模式（Gan/Zhi 元素色）'),
                    value: _colorfulMode,
                    onChanged: (v) => setState(() => _colorfulMode = v),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(labelText: '全局字体家族（可留空）'),
                    onChanged: (v) => setState(() => _globalFontFamily = v.isEmpty ? null : v),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(labelText: '全局字号（数字，可留空）'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => _globalFontSize = double.tryParse(v)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('全局颜色：'),
                      Wrap(spacing: 8, children: [
                        for (final c in [Colors.black, Colors.red, Colors.green, Colors.blue, Colors.purple, Colors.amber])
                          GestureDetector(
                            onTap: () => setState(() => _globalFontColor = c),
                            child: Container(width: 22, height: 22, color: c),
                          ),
                        GestureDetector(
                          onTap: () => setState(() => _globalFontColor = null),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ),
                      ]),
                    ],
                  ),
                  const Divider(height: 24),
                  GroupTextStyleEditorPanel(
                    initial: _groupTextStyles,
                    isColorful: _colorfulMode,
                    onChanged: (m) => setState(() => _groupTextStyles = Map<TextGroup, TextStyle>.of(m)),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('演示区（最终样式）：'),
                  const SizedBox(height: 16),
                  Text('甲（Gan）', style: _resolveTextStyle(TextGroup.tianGan, gan: TianGan.JIA)),
                  const SizedBox(height: 8),
                  Text('子（Zhi）', style: _resolveTextStyle(TextGroup.diZhi, zhi: DiZhi.ZI)),
                  const SizedBox(height: 16),
                  Text('海中金（NaYin）', style: _resolveTextStyle(TextGroup.naYin)),
                  const SizedBox(height: 8),
                  Text('戌亥（KongWang）', style: _resolveTextStyle(TextGroup.kongWang)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}