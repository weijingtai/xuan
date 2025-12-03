import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

/// PaletteEntry
/// 描述：表示一条来自 JSON 配色的颜色条目（含名称与颜色）
/// 参数：name（条目名）、color（解析后的颜色）
/// 返回：不可变对象
class PaletteEntry {
  final String name;
  final Color color;
  const PaletteEntry(this.name, this.color);

  /// 从 JSON 对象构造
  /// 参数：json（包含 meta.name 与 schema.hex）
  /// 返回：PaletteEntry；无法解析时抛出格式异常
  static PaletteEntry fromJson(Map<String, dynamic> json) {
    final name = (json['meta']?['name'] ?? '').toString();
    final hex = (json['schema']?['hex'] ?? '').toString();
    return PaletteEntry(name, _parseHexColor(hex));
  }

  /// 解析十六进制颜色（#RRGGBB 或 #AARRGGBB）
  /// 参数：hex（字符串）
  /// 返回：Color；无法解析时抛出格式异常
  static Color _parseHexColor(String hex) {
    var v = hex.trim().toUpperCase();
    if (v.startsWith('#')) v = v.substring(1);
    if (v.length == 6) v = 'FF$v';
    final n = int.parse(v, radix: 16);
    return Color(n);
  }
}

/// 读取 JSON 颜色列表
/// 描述：从 assets 路径加载并解析为 PaletteEntry 列表
/// 参数：assetPath（资产路径）
/// 返回：Future<List<PaletteEntry>>
Future<List<PaletteEntry>> _loadPalette(String assetPath) async {
  final txt = await rootBundle.loadString(assetPath);
  final data = jsonDecode(txt);
  if (data is! List) return const [];
  return data
      .whereType<Map<String, dynamic>>()
      .map((e) => PaletteEntry.fromJson(e))
      .toList(growable: false);
}

/// 显示“应用配色选择对话框”
/// 描述：提供中华色、故宫色、色轮三种选择通道；点击颜色直接返回选择值
/// 参数：
/// - context：构建上下文
/// - initialColor：初始颜色（用于色轮与选中态）
/// - title：对话框标题（可选）
/// 返回：Future<Color?>（用户选择的颜色或取消）
Future<Color?> showAppPalettePickerDialog(
  BuildContext context, {
  required Color initialColor,
  String? title,
}) async {
  final zhongguose = await _loadPalette('assets/colors/zhongguose_color.json');
  final forbidden =
      await _loadPalette('assets/colors/forbidden_city_color.json');

  Color selected = initialColor;

  return showDialog<Color?>(
    context: context,
    builder: (ctx) {
      return DefaultTabController(
        length: 3,
        child: AlertDialog(
          title: Text(title ?? '选择颜色'),
          content: SizedBox(
            width: 520,
            height: 420,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: '中华色'),
                    Tab(text: '故宫色'),
                    Tab(text: '色轮'),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    children: [
                      _PaletteGrid(
                          entries: zhongguose,
                          onTap: (c) {
                            selected = c;
                            Navigator.of(ctx).pop(c);
                          }),
                      _PaletteGrid(
                          entries: forbidden,
                          onTap: (c) {
                            selected = c;
                            Navigator.of(ctx).pop(c);
                          }),
                      ColorPicker(
                        color: selected,
                        pickersEnabled: const {
                          ColorPickerType.wheel: true,
                          ColorPickerType.primary: false,
                          ColorPickerType.accent: false,
                          ColorPickerType.custom: false,
                        },
                        onColorChanged: (c) {
                          selected = c;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(selected),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    },
  );
}

/// Palette 网格组件
/// 描述：以网格形式展示 PaletteEntry 列表，点击项返回颜色
/// 参数：
/// - entries：颜色条目列表
/// - onTap：点击颜色时回调
/// 返回：Widget
class _PaletteGrid extends StatelessWidget {
  final List<PaletteEntry> entries;
  final ValueChanged<Color> onTap;
  const _PaletteGrid({required this.entries, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (ctx, i) {
        final e = entries[i];
        return InkWell(
          onTap: () => onTap(e.color),
          child: Container(
            decoration: BoxDecoration(
              color: e.color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white30
                    : Colors.black26,
              ),
            ),
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Text(
                e.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
