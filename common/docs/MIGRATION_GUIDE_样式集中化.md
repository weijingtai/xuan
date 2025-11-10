# 样式集中化迁移指引

## 背景
- 为解决卡片整卡渲染测试不稳定与样式分散的问题，已引入集中化样式解析与可测试的探针组件（StyleProbeWidget）。
- 通过组级样式映射（`groupTextStyles`）与全局样式（字体、字号、颜色）实现统一的样式控制与优先级。

## 迁移目标
- 将散落在各组件中的样式逻辑收敛到“默认样式 + 全局覆盖 + 分组覆盖 + 彩色模式”的统一解析序列。
- 保证在 `colorfulMode` 下，天干/地支的元素色（五行色）可被分组覆盖替代；在非彩色模式下，全局颜色生效，但仍被分组覆盖所替代。

## 优先级规则（由低到高）
1. 默认样式：按 `TextGroup` 提供基础 `TextStyle`（字号、字重、默认色）。
2. 全局覆盖：`globalFontFamily`、`globalFontSize`、`globalFontColor`。
3. 彩色模式（仅 Gan/Zhi）：当 `colorfulMode == true` 且组为天干/地支时，按 `ElementColorResolver` 计算元素色；若有分组颜色覆盖则被替代。
4. 分组覆盖：`groupTextStyles[group]` 中的 `fontFamily/fontSize/fontWeight/shadows/color`，最终覆盖生效。

> 额外规则：在非彩色模式下，Gan/Zhi 若无颜色设置，默认使用 `Colors.black87`。

## 集成步骤
- 管理层：使用 `GroupTextStyleEditorPanel`（或等效编辑器）产出 `Map<TextGroup, TextStyle>` 的分组样式映射，并在业务卡片构建时传入集中化解析。
- 显示层：卡片/控件通过统一的解析函数或组件，将上面的优先级应用到最终 `TextStyle`。
- 颜色解析：如启用 `colorfulMode`，传入对应的 `TianGan` / `DiZhi` 实例以供 `ElementColorResolver` 计算；组级颜色存在时优先生效。

### 工程示例（lib/dev_style_preview.dart）
如下示例展示如何在根工程 `lib` 下创建预览入口并进行端到端联动：

```dart
// 运行：flutter run -d web-server -t lib/dev_style_preview.dart
import 'package:flutter/material.dart';
import 'package:common/widgets/text_style/group_text_style_editor_panel.dart';
import 'package:common/widgets/editable_fourzhu_card/text_groups.dart';
import 'package:common/utils/style_resolver.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:common/enums/enum_di_zhi.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatefulWidget { const Demo({super.key}); @override State<Demo> createState() => _DemoState(); }
class _DemoState extends State<Demo> {
  Map<TextGroup, TextStyle> groupTextStyles = const { TextGroup.naYin: TextStyle(fontSize: 18) };
  bool colorfulMode = true; final resolver = const DefaultElementColorResolver();
  String? globalFamily; double? globalSize; Color? globalColor;

  TextStyle _default(TextGroup g) => g == TextGroup.tianGan
      ? const TextStyle(fontSize: 24) : g == TextGroup.diZhi
      ? const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)
      : g == TextGroup.naYin ? const TextStyle(fontSize: 14, color: Colors.amber)
      : const TextStyle(fontSize: 14, color: Colors.black87);

  TextStyle resolve(TextGroup g, {TianGan? gan, DiZhi? zhi}) {
    var s = _default(g); final isGZ = g == TextGroup.tianGan || g == TextGroup.diZhi;
    if (globalFamily?.isNotEmpty == true) s = s.copyWith(fontFamily: globalFamily);
    if ((globalSize ?? 0) > 0) s = s.copyWith(fontSize: globalSize);
    final suppressGlobal = colorfulMode && isGZ; if (globalColor != null && !suppressGlobal) s = s.copyWith(color: globalColor);
    if (colorfulMode && isGZ) s = s.copyWith(color: gan != null ? resolver.colorForGan(gan, context) : resolver.colorForZhi(zhi!, context));
    final o = groupTextStyles[g]; if (o != null) s = s.copyWith(fontFamily: o.fontFamily, fontSize: o.fontSize, fontWeight: o.fontWeight, color: o.color, shadows: o.shadows);
    if (isGZ && !colorfulMode && s.color == null) s = s.copyWith(color: Colors.black87); return s;
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('集中化样式预览')),
    body: Row(children: [
      Expanded(child: GroupTextStyleEditorPanel(initial: groupTextStyles, isColorful: colorfulMode, onChanged: (m) => setState(() => groupTextStyles = Map.of(m)))),
      const VerticalDivider(width: 1),
      Expanded(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('甲', style: resolve(TextGroup.tianGan, gan: TianGan.JIA)),
        Text('子', style: resolve(TextGroup.diZhi, zhi: DiZhi.ZI)),
        Text('海中金', style: resolve(TextGroup.naYin)),
      ]))),
    ]));
}
```

## 测试策略
- 使用 `StyleProbeWidget` 在 Widget 测试中验证：
  - NaYin/KongWang 默认样式与分组覆盖的字号/颜色效果；
  - `colorfulMode` 下 Gan/Zhi 的元素色可被分组颜色替代；
  - 全局样式在非彩色模式下生效，但被分组覆盖优先。
- 面板联动测试：通过轻量 Fake Panel 或直接使用 `GroupTextStyleEditorPanel.onChanged` 输出，将映射传递给探针验证优先级。

## 回滚与兼容
- 若某组件尚未迁移，可保持原样式逻辑；迁移后组件通过集中化解析实现一致性。
- 若遇到第三方组件 API 变化（如 `InteractiveToast.slide` 参数变更），建议以轻量 Fake 组件替代进行测试，避免无关异常影响迁移验证。

## 常见问题
- 问：`colorfulMode` 开启后全局颜色不生效？
  - 答：Gan/Zhi 在彩色模式下优先取元素色；若同时存在分组颜色，分组颜色最终生效。其他组不受影响。
- 问：未设置颜色导致文本颜色为空？
  - 答：Gan/Zhi 在非彩色模式下会回退到 `Colors.black87`；其他组默认色按各组定义。

## 迁移检查清单
- [ ] 组件内样式逻辑移除分散覆盖，改用集中化解析路径。
- [ ] 统一传入 `groupTextStyles` 与全局样式（如有）。
- [ ] 在 `colorfulMode` 下，确保 Gan/Zhi 提供 `TianGan/DiZhi` 以支持元素色计算。
- [ ] 编写/更新对应的 Widget 测试，覆盖默认、全局、分组、彩色模式场景。
- [ ] 更新项目文档的进度记录与验收说明。