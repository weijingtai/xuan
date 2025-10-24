# 子时策略迭代 - 原子化任务清单

状态标记: [ ] 待办  [~] 进行中  [x] 完成

## A. 代码架构与策略实现
- [ ] A1 建立策略目录结构：`lib/features/four_zhu/strategies/{day_pillar_strategy.dart,hour_pillar_strategy.dart,impl/...}`
- [ ] A2 定义 DayPillarStrategy 接口：`DateTime decideDayAnchor(DateTime dt)` 或返回 `DayAnchor { baseDate, isNextDay }`
- [ ] A3 定义 HourPillarStrategy 接口：`JiaZi decideHourPillar(DateTime dt, TianGan dayStem)`
- [ ] A4 实现 day_23_boundary_strategy（子初/子平新派）
- [ ] A5 实现 day_0_boundary_strategy（子正/子平传统派）
- [ ] A6 实现 hour_five_mouse_dun_strategy（五鼠遁按“生效日干”起时干）
- [ ] A7 实现 hour_fixed_zi_ping_strategy（壬子/癸丑固定）
- [ ] A8 新增 FourZhuEngine：组合策略、产出 `EightCharsResult`
 - [x] A9 接入 Lunar：基于 `decideDayAnchor` 的时间点获取年/月/日干支；时柱由 HourPillarStrategy 决定

## B. 配置与向后兼容
- [ ] B1 扩展 `CalculationStrategyConfig.ZiShiStrategy`：新增 `noDistinguishAt23`、`distinguishAt0FiveMouse`、`distinguishAt0Fixed`
- [ ] B2 旧值映射：`startFrom23 → noDistinguishAt23`；`startFrom0 → distinguishAt0FiveMouse`；`splitedZi → distinguishAt0FiveMouse`（过渡保留）
- [ ] B3 在 `SolarLunarDateTimeHelper` 内部改为调用 `FourZhuEngine.create(boundary, childMode)`（保持对外接口不变）
    - 现状：已调整 day 某些行为；后续将迁移到引擎调用

## C. UI 与交互
- [ ] C1 在高级设置或时间输入卡中加入“子时策略”选择（四项）
- [ ] C2 将选择持久化到本地（SharedPreferences 或现有 Repository）
- [ ] C3 切换后触发重算并刷新八字展示卡

## D. 测试
- [ ] D1 单元测试：四策略在 23:30、00:30 的对照断言
- [ ] D2 单元测试：节气交接日的边界行为
- [ ] D3 单元测试：夏令时移除（removeDST）后的边界行为
- [ ] D4 单元测试：平太阳时/真太阳时输入的边界行为
- [ ] D5 端到端测试：UI 切换策略后结果一致性

## E. 文档与示例
- [ ] E1 在 PRDs.md 附加更多示例盘（含截图/期望）
- [ ] E2 开发者文档：如何新增一个自定义 HourPillarStrategy（例如地方流派）
- [ ] E3 用户帮助：四策略说明与选择建议

## F. 里程碑与交付
- [ ] F1 迭代一：实现 day/hour 策略与 FourZhuEngine，打通 API
- [ ] F2 迭代二：UI 选择与持久化、单测矩阵
- [ ] F3 迭代三：端到端联调与文档完善
