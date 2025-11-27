# V3 Card 尺寸计算迁移任务清单

- [ ] 初始化计算器与快照复用（UI 构造集中管理）
- [ ] 接入中文文本宽度估算（avgGlyphWidthScale=1.2）
- [ ] 构建并注入 `cellTextSpecMap`（按行类型取字号、统计字符数）
- [ ] 替换 Card 容器尺寸为 `getCardSize(MetricsComputeOptions)`
- [ ] 替换 Pillar 容器宽为 `getPillarSize(pUuid).width`
- [ ] 替换 Cell 宽高为 `getCellFinalSize(rowUuid, pillarUuid)`
- [ ] 统一 Row 行高读取 `RowMetrics`（content+decoration）
- [ ] 幽灵行/列尺寸仅 UI 叠加（不触发快照重算）
- [ ] 映射 `MetricsComputeOptions` 与 UI 状态（抓手/标题/padding/border）
- [ ] 行标题列宽按 `rowTitleWidth`，不重复列装饰
- [ ] 分隔行/列尺寸路径校正（仅容器/叠加层渲染）
- [ ] 拖拽反馈尺寸统一于计算器（ghost/feedback）
- [ ] 旧尺寸覆盖映射与快照兼容（覆盖优先、快照兜底）
- [ ] 性能与缓存：一次快照多处复用，避免重复计算
- [ ] 自测：演示页验证抓手/标题显隐与拖拽交互
- [ ] 静态分析与格式校验（`dart analyze`、格式检查）