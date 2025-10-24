# Code Review Checklist：定子时 & 定节气/物候（联动）

## 设计一致性
- [ ] 子时策略与“日界锚点”是否统一贯穿计算（八字、节气、物候）？
- [ ] 节气/物候策略是否通过统一入口（helper）读取运行期 Store，避免分散读取？
- [ ] UI 中两张设置卡是否放置在主卡片外侧，交互是否清晰？

## 逻辑正确性
- 子时
  - [ ] `ZiShiStrategy` 映射到 `FourZhuEngine` 的 `ZiBoundary/ChildHourMode` 正确无误。
  - [ ] `Day23BoundaryStrategy/Day0BoundaryStrategy` 产生的锚点与预期一致。
  - [ ] 小时策略（五鼠遁、固定子时、两小时一支）与现有实现一致。
- 节气
  - [ ] 定气法：`lunar.getPrev/Current/NextJieQi()` 的使用是否覆盖“当天正值节气”的 next 指针问题（加 2 天取 next）。
  - [ ] 平气法：固定间隔（回归年/24）计算方式是否清晰，起点是否明确（上一枚定气交节时刻）。
- 物候
  - [ ] 候序计算是否严格以“节气起点 + n×5 天”划分（n=0/1/2），并与所选节气基准一致。
  - [ ] 候列表是否从 `Phenology.phenologyList` 按节气筛选出 3 条，索引越界时有保护。

## 数据与状态
- [ ] `JieQiPhenologyStore` 与 `ZiStrategyStore` 的默认值与初始化时机（main.dart）正确。
- [ ] `SharedPreferences` Key 命名一致、读写健壮（解析 legacy 值时有保护）。

## UI/交互
- [ ] 节气与物候为“联动选项”两选一：
  - 平气法 + 传统固定物候
  - 定气法 + 现代精准物候
- [ ] “设为默认”持久化成功，重启后仍生效。
- [ ] “应用并重算”能触发上层 ViewModel 刷新（已通过 `selectedTimeNotifier` 写回）。

## 可测试性
- [ ] 边界测试建议：
  - 23:00、00:00、02:00 两套子时策略的切换
  - 节气交接时刻当日/次日边界
  - 月末/年末、闰年 2 月末
  - DST 起止日、平/真太阳时路径
  - 不同时区（如 America/New_York）

## 性能/鲁棒性
- [ ] helper 内多次 `dateFormat.parse` 是否可以复用对象（已静态）。
- [ ] 物候索引计算对负值/越界进行 clamp 处理。
- [ ] UI 异步调用后使用 `mounted` 判断（SnackBar 部分）。

## 代码风格
- [ ] 遵循 `flutter_lints`；文件/类/成员命名符合约定。
- [ ] 新增文件路径与模块划分符合仓库结构（features/widgets/docs）。

## 未来演进
- [ ] 如需“严格平气法”，考虑加入平气年表或历元对齐算法，替换当前工程近似。
- [ ] 结合区域/气象数据做物候动态修正（接口预留）。

