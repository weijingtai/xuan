# 子时策略迭代 - 原子化任务清单

状态标记: [ ] 待办  [~] 进行中  [x] 完成

## A. 代码架构与策略实现
- [x] A1 建立策略目录结构：`lib/features/four_zhu/strategies/{day_pillar_strategy.dart,hour_pillar_strategy.dart,impl/...}`
- [x] A2 定义 DayPillarStrategy 接口：`DateTime decideDayAnchor(DateTime dt)` 或返回 `DayAnchor { baseDate, isNextDay }`
- [x] A3 定义 HourPillarStrategy 接口：`JiaZi decideHourPillar(DateTime dt, TianGan dayStem)`
- [x] A4 实现 day_23_boundary_strategy（子初/子平新派）
- [x] A5 实现 day_0_boundary_strategy（子正/子平传统派）
- [x] A6 实现 hour_five_mouse_dun_strategy（五鼠遁按“生效日干”起时干）
- [x] A7 实现 hour_fixed_zi_ping_strategy（壬子/癸丑固定）
- [x] A8 新增 FourZhuEngine：组合策略、产出 `EightCharsResult`
- [x] A9 接入 Lunar：基于 `decideDayAnchor` 的时间点获取年/月/日干支；时柱由 HourPillarStrategy 决定

## B. 配置与向后兼容
- [x] B1 扩展 `CalculationStrategyConfig.ZiShiStrategy`：新增 `noDistinguishAt23`、`distinguishAt0FiveMouse`、`distinguishAt0Fixed`
- [x] B2 旧值映射：`startFrom23 → noDistinguishAt23`；`startFrom0 → distinguishAt0FiveMouse`；`splitedZi → distinguishAt0FiveMouse`（过渡保留）
- [x] B3 在 `SolarLunarDateTimeHelper` 内部改为调用 `FourZhuEngine.create(boundary, childMode)`（保持对外接口不变）
    - 现状：已调整 day 某些行为；后续将迁移到引擎调用

## C. UI 与交互
- [x] C1 在高级设置或时间输入卡中加入“子时策略”选择（四项）
- [x] C2 将选择持久化到本地（SharedPreferences 或现有 Repository）
- [x] C3 切换后触发重算并刷新八字展示卡

## D. 测试
- [x] D1 单元测试：四策略在 23:30、00:30 的对照断言
- [x] D2 单元测试：节气交接日的边界行为
- [ ] D3 单元测试：夏令时移除（removeDST）后的边界行为
  - 用例：America/Los_Angeles 在 DST 起止日前后（如 2020-03-08 与 2020-11-01）分别在 23:30、00:30 验证八字日/时柱一致性，确保去除 DST 后按本地“民用时间”正确归属。
  - 对照：Asia/Shanghai 无 DST 的同日样例，结果不受 removeDST 影响。
  - 断言：`SolarLunarDateTimeHelper.calculateRemoveDSTQueryDateTimeInfo(...)` 输出的四柱与普通路径在非 DST 日一致；在 DST 切换点附近不跨错节气/物候边界。
- [ ] D4 单元测试：平太阳时/真太阳时输入的边界行为
  - 用例：选择 23:30、00:30 在同一地点（如 Asia/Shanghai、America/Los_Angeles）分别调用 `calculateMeanSolarQueryDateTimeInfo` 与 `calculateTrueSolarQueryDateTimeInfo`；
  - 断言：两路径均遵循当前子时策略的日界规则（23 界/0 界）且“同桶判定”一致；不要求天文数值完全一致，仅验证边界归属与八字柱序一致性。
- [ ] D5 端到端测试：UI 切换策略后结果一致性
  - 用例：Widget 测试 `QueryTimeInputCard`，注入初始时间与 `ZiStrategySettingsCard`/`JieQiEntrySettingsCard`；
  - 操作：切换子时策略与交节精度，点击“应用并重算”，监听 `selectedTimeNotifier` 写回；
  - 断言：八字展示卡文本（年/月/日/时干支）随选择更新；“设为默认”经 `SharedPreferences` 持久化后，重建时使用默认值。

## E. 文档与示例
- [ ] E1 在 PRDs.md 附加更多示例盘（含截图/期望）
- [ ] E2 开发者文档：如何新增一个自定义 HourPillarStrategy（例如地方流派）
- [ ] E3 用户帮助：四策略说明与选择建议

## F. 里程碑与交付
- [x] F1 迭代一：实现 day/hour 策略与 FourZhuEngine，打通 API
- [ ] F2 迭代二：UI 选择与持久化、单测矩阵
- [ ] F3 迭代三：端到端联调与文档完善
