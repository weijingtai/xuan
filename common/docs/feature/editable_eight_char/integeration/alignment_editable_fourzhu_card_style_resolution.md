# EditableFourZhuCard 样式解析优先级对齐说明

创建日期：2025-11-10

## 目标
- 与项目“TextStyleConfig‑first”统一策略保持一致，明确 `EditableFourZhuCard` 渲染路径的样式优先级：分组覆盖优先于全局设置，调用端入参用于临时覆写并具有最高优先级。

## 适用范围
- 文件：`common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart`
- 方法：`_resolveTextStyle(...)`、`_defaultTextStyleForGroup(...)`

## 优先级规则
1. 分组默认样式：`_defaultTextStyleForGroup(group)` 作为基线；
2. 全局设置：应用 `globalFontFamily/globalFontSize/globalFontColor`；
   - 彩色模式（`colorfulMode`）下的天干/地支抑制全局颜色，避免覆盖字符映射颜色；
3. 分组覆写：`groupTextStyles[group]`（类型为 `TextStyle`）等同于“配置优先”，覆盖家族/字号/字重/阴影与颜色；
4. 入参临时覆写：调用端提供的 `fontSize/weight/color` 最终应用，用于局部强化或特殊渲染。

## 兼容与备注
- 本组件当前使用 `Map<TextGroup, TextStyle>` 而非 `TextStyleConfig`。在统一策略下视为“配置层”，保持优先级语义一致；未来如迁移到 `TextStyleConfig`，仅替换数据类型与注入方式，优先级不变。
- 天干/地支颜色：
  - 彩色模式：颜色来自字符映射，除非分组或入参显式提供颜色；
  - 非彩色模式：默认黑色（`Colors.black87`），可被分组或入参覆盖。

## 验收标准
- 分组编辑面板调整 `groupTextStyles` 后，渲染按分组设置优先生效；
- 全局字号/字体家族在未设置分组时生效；
- 入参提供的临时 `fontSize/weight/color` 能覆盖最终样式；
- 编译通过并能在预览中验证视觉一致性（当前预览启动受非相关编译错误阻塞，修复后验证）。

## 影响范围
- 仅影响 `EditableFourZhuCard` 的渲染路径；
- 不更改 `RowConfig` 与集中化解析器（`StyleResolver`）的实现；
- 不修改分组编辑器的契约与数据流。