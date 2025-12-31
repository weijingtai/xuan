import 'dart:convert';
import 'dart:typed_data';
import 'package:common/datasource/loca_binary/color.pb.dart' as pb;
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
  final String hex;
  final String rgb;

  const PaletteEntry({
    required this.name,
    required this.color,
    required this.hex,
    required this.rgb,
  });

  static PaletteEntry fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    final schema = json['schema'];

    final name = (meta is Map ? meta['name'] : '')?.toString() ?? '';
    final hexRaw = (schema is Map ? schema['hex'] : '')?.toString() ?? '';
    final rgbRaw = (schema is Map ? schema['rgb'] : '')?.toString() ?? '';

    final parsed = _tryParseHexColor(hexRaw);
    final color = parsed ?? Colors.black;

    return PaletteEntry(
      name: name,
      color: color,
      hex: _formatHex(color),
      rgb: rgbRaw.isNotEmpty ? rgbRaw : _formatRgb(color),
    );
  }

  static Color? _tryParseHexColor(String hex) {
    var v = hex.trim().toUpperCase();
    if (v.startsWith('#')) v = v.substring(1);
    if (v.length == 6) v = 'FF$v';
    if (v.length != 8) return null;
    try {
      final n = int.parse(v, radix: 16);
      return Color(n);
    } catch (_) {
      return null;
    }
  }

  static String _formatHex(Color c) {
    final a = c.alpha;
    final r = c.red;
    final g = c.green;
    final b = c.blue;
    if (a == 0xFF) {
      return '#${_hex2(r)}${_hex2(g)}${_hex2(b)}';
    }
    return '#${_hex2(a)}${_hex2(r)}${_hex2(g)}${_hex2(b)}';
  }

  static String _hex2(int v) =>
      v.toRadixString(16).padLeft(2, '0').toUpperCase();

  static String _formatRgb(Color c) {
    return 'RGB(${c.red}, ${c.green}, ${c.blue})';
  }
}

final Map<String, Future<List<PaletteEntry>>> _paletteCache = {};
Future<Set<String>>? _assetKeysFuture;

final ValueNotifier<int> paletteNameIndexVersion = ValueNotifier<int>(0);
Map<int, String>? _paletteNameIndex;
Future<void>? _paletteNameIndexFuture;

void warmupPaletteNameIndex() {
  _paletteNameIndexFuture ??= () async {
    final zhongguose = await _loadPaletteByAny(
      'zhongguose',
      const [
        'assets/colors/zhongguose.pb',
        'packages/common/assets/colors/zhongguose.pb',
        '../assets/colors/zhongguose.pb',
      ],
    );
    final forbidden = await _loadPaletteByAny(
      'forbidden_city',
      const [
        'assets/colors/forbidden_city.pb',
        'packages/common/assets/colors/forbidden_city.pb',
        '../assets/colors/forbidden_city.pb',
      ],
    );

    final map = <int, String>{};
    void addAll(List<PaletteEntry> entries) {
      for (final e in entries) {
        final argb = e.color.toARGB32();
        final name = e.name.trim();
        if (name.isEmpty) continue;
        final prev = map[argb];
        if (prev == null || prev.isEmpty) {
          map[argb] = name;
          continue;
        }
        if (prev == name) continue;
        map[argb] = '$prev / $name';
      }
    }

    addAll(zhongguose);
    addAll(forbidden);

    _paletteNameIndex = map;
    paletteNameIndexVersion.value = paletteNameIndexVersion.value + 1;
  }();
}

String? lookupPaletteName(Color color) {
  return _paletteNameIndex?[color.toARGB32()];
}

Future<List<PaletteEntry>> _loadPaletteByAny(
  String cacheKey,
  List<String> assetPaths,
) {
  return _paletteCache.putIfAbsent(cacheKey, () async {
    _assetKeysFuture ??= () async {
      final manifestTxt = await rootBundle.loadString('AssetManifest.json');
      final manifest = jsonDecode(manifestTxt);
      if (manifest is Map<String, dynamic>) {
        return manifest.keys.toSet();
      }
      if (manifest is Map) {
        return manifest.keys.map((e) => e.toString()).toSet();
      }
      return <String>{};
    }();

    Set<String>? assetKeys;
    try {
      assetKeys = await _assetKeysFuture;
    } catch (_) {
      assetKeys = null;
    }

    String? resolved;
    if (assetKeys != null) {
      for (final p in assetPaths) {
        if (assetKeys.contains(p)) {
          resolved = p;
          break;
        }
      }
    }

    ByteData? data;
    if (resolved != null) {
      try {
        data = await rootBundle.load(resolved);
      } catch (_) {
        data = null;
      }
    } else {
      for (final p in assetPaths) {
        try {
          data = await rootBundle.load(p);
          break;
        } catch (_) {
          data = null;
        }
      }
    }

    if (data == null) return const [];

    final Uint8List bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final dataset = pb.ColorDataset.fromBuffer(bytes);

    final out = <PaletteEntry>[];
    for (final e in dataset.entries) {
      final c = Color(e.argb);
      out.add(
        PaletteEntry(
          name: e.name,
          color: c,
          hex: PaletteEntry._formatHex(c),
          rgb: PaletteEntry._formatRgb(c),
        ),
      );
    }
    return out.toList(growable: false);
  });
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
  final zhongguose = await _loadPaletteByAny(
    'zhongguose',
    const [
      'assets/colors/zhongguose.pb',
      'packages/common/assets/colors/zhongguose.pb',
      '../assets/colors/zhongguose.pb',
    ],
  );
  final forbidden = await _loadPaletteByAny(
    'forbidden_city',
    const [
      'assets/colors/forbidden_city.pb',
      'packages/common/assets/colors/forbidden_city.pb',
      '../assets/colors/forbidden_city.pb',
    ],
  );

  final searchController = TextEditingController();
  Color selected = initialColor;
  PaletteEntry? selectedEntry;

  bool matches(PaletteEntry e, String q) {
    final qq = q.trim().toLowerCase();
    if (qq.isEmpty) return true;
    return e.name.toLowerCase().contains(qq) ||
        e.hex.toLowerCase().contains(qq) ||
        e.rgb.toLowerCase().contains(qq);
  }

  PaletteEntry currentInfo() {
    return selectedEntry ??
        PaletteEntry(
          name: '自定义',
          color: selected,
          hex: PaletteEntry._formatHex(selected),
          rgb: PaletteEntry._formatRgb(selected),
        );
  }

  void showDetails(BuildContext ctx, PaletteEntry e) {
    showDialog<void>(
      context: ctx,
      builder: (dctx) {
        return AlertDialog(
          title: Text(e.name.isEmpty ? '颜色信息' : e.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 72,
                decoration: BoxDecoration(
                  color: e.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(dctx).brightness == Brightness.dark
                        ? Colors.white24
                        : Colors.black12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('HEX: ${e.hex}'),
              const SizedBox(height: 6),
              Text('RGB: ${e.rgb}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: e.hex));
                if (dctx.mounted) Navigator.of(dctx).pop();
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('已复制 HEX')),
                );
              },
              child: const Text('复制 HEX'),
            ),
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: e.rgb));
                if (dctx.mounted) Navigator.of(dctx).pop();
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('已复制 RGB')),
                );
              },
              child: const Text('复制 RGB'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  return showDialog<Color?>(
    context: context,
    builder: (ctx) {
      return DefaultTabController(
        length: 3,
        child: StatefulBuilder(
          builder: (ctx, setState) {
            final query = searchController.text;
            final z = query.trim().isEmpty
                ? zhongguose
                : zhongguose
                    .where((e) => matches(e, query))
                    .toList(growable: false);
            final f = query.trim().isEmpty
                ? forbidden
                : forbidden
                    .where((e) => matches(e, query))
                    .toList(growable: false);

            final info = currentInfo();
            final opacity = selected.alpha / 255.0;

            Widget searchBar() {
              return TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '搜索：名称 / HEX / RGB',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              );
            }

            Widget selectedBar() {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                ),
                child: Row(
                  children: [
                    Tooltip(
                      message:
                          '${info.name.isEmpty ? '未命名' : info.name}\n${info.hex}\n${info.rgb}',
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: info.color,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Theme.of(ctx).brightness == Brightness.dark
                                ? Colors.white24
                                : Colors.black12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.name.isEmpty ? '未命名' : info.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(ctx).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${info.hex} · ${info.rgb}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(ctx).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => showDetails(ctx, info),
                      icon: const Icon(Icons.info_outline),
                      tooltip: '详情',
                    ),
                  ],
                ),
              );
            }

            return AlertDialog(
              title: Text(title ?? '选择颜色'),
              content: SizedBox(
                width: 560,
                height: 460,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: '中华色'),
                        Tab(text: '故宫色'),
                        Tab(text: '色轮'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Column(
                            children: [
                              searchBar(),
                              const SizedBox(height: 10),
                              Expanded(
                                child: _PaletteGrid(
                                  entries: z,
                                  selectedColor: selected,
                                  onSelect: (e) {
                                    setState(() {
                                      selected = e.color;
                                      selectedEntry = e;
                                    });
                                  },
                                  onDoubleTap: (e) {
                                    Navigator.of(ctx).pop(e.color);
                                  },
                                  onShowDetails: (e) => showDetails(ctx, e),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              searchBar(),
                              const SizedBox(height: 10),
                              Expanded(
                                child: _PaletteGrid(
                                  entries: f,
                                  selectedColor: selected,
                                  onSelect: (e) {
                                    setState(() {
                                      selected = e.color;
                                      selectedEntry = e;
                                    });
                                  },
                                  onDoubleTap: (e) {
                                    Navigator.of(ctx).pop(e.color);
                                  },
                                  onShowDetails: (e) => showDetails(ctx, e),
                                ),
                              ),
                            ],
                          ),
                          ColorPicker(
                            color: selected,
                            pickersEnabled: const {
                              ColorPickerType.wheel: true,
                              ColorPickerType.primary: false,
                              ColorPickerType.accent: false,
                              ColorPickerType.custom: false,
                            },
                            onColorChanged: (c) {
                              setState(() {
                                selected = c;
                                selectedEntry = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    selectedBar(),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const SizedBox(width: 56, child: Text('透明度')),
                        Expanded(
                          child: Slider(
                            value: opacity,
                            min: 0,
                            max: 1,
                            divisions: 100,
                            label: '${(opacity * 100).round()}%',
                            onChanged: (v) {
                              setState(() {
                                selected = selected.withAlpha(
                                  (v * 255).round().clamp(0, 255),
                                );
                                selectedEntry = null;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '${(opacity * 100).round()}%',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
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
            );
          },
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
  final Color selectedColor;
  final ValueChanged<PaletteEntry> onSelect;
  final ValueChanged<PaletteEntry>? onDoubleTap;
  final ValueChanged<PaletteEntry>? onShowDetails;

  const _PaletteGrid({
    required this.entries,
    required this.selectedColor,
    required this.onSelect,
    this.onDoubleTap,
    this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (ctx, i) {
        final e = entries[i];
        final isSelected = e.color.value == selectedColor.value;
        final fg =
            ThemeData.estimateBrightnessForColor(e.color) == Brightness.dark
                ? Colors.white
                : Colors.black87;
        final infoBg =
            ThemeData.estimateBrightnessForColor(e.color) == Brightness.dark
                ? Colors.black.withOpacity(0.20)
                : Colors.white.withOpacity(0.72);

        return GestureDetector(
          onDoubleTap: onDoubleTap == null ? null : () => onDoubleTap!(e),
          onLongPress: onShowDetails == null ? null : () => onShowDetails!(e),
          child: InkWell(
            onTap: () => onSelect(e),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white30
                          : Colors.black26),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Tooltip(
                              message:
                                  '${e.name.isEmpty ? '未命名' : e.name}\n${e.hex}\n${e.rgb}',
                              child: Container(color: e.color),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Positioned(
                            left: 4,
                            top: 2,
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              onPressed: onShowDetails == null
                                  ? null
                                  : () => onShowDetails!(e),
                              icon: Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.white.withOpacity(0.92),
                              ),
                              tooltip: '详情',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 7),
                      decoration: BoxDecoration(color: infoBg),
                      child: DefaultTextStyle(
                        style: TextStyle(color: fg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              e.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              e.hex,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              e.rgb,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
