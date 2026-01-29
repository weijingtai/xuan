# 考订六亲（Code Review）

## 概览
- 本特性实现从八字四柱起卦 → 纳甲与六亲装配 → 目标爻定位 → 流度表匹配 → UI 并列展示与用户选择的完整链路。
- 核心模块职责清晰、依赖集中在 `constant/constants.dart` 与 `assets/kao_ke/*.json`、`assets/tiao_wen_data.csv`。

## 模块结构与职责
- `services/qi_gua_helper.dart`
  - 基于“干支配数”起卦：`ganNumberMapper` 和 `zhiNumberMapper`（奇/偶两数）。
  - 下卦 = 干数 + 支奇数（取模 8），上卦 = 干数 + 支偶数（取模 8）；`0→8` 处理；数转先天八卦（`numberXianGuaMapper`）；组合 64 卦。
  - 暴露 `QiGuaResult`，包含计算公式文本（便于审计）。
- `services/na_jia_liu_qin_helper.dart`
  - 归宫与宫序：`eightGongGuaListMapper`；取世/应位置：`shiYao[gongXu]`、`yiYao[gongXu]`。
  - 装纳甲/纳支：内卦（初二三）与外卦（四五上），来源 `inner/outerGuaYaoTianGan/DiZhi`。
  - 定六亲：`fiveXingSixQingMapper[dayGan.fiveXing][yaoZhi.fiveXing]`。
  - 目标爻定位：夫妻以应爻为参考，其余以世爻为参考；在六爻中筛选目标六亲并取距离参考位最近者。
- `services/kao_ding_liu_qin_strategy.dart`
  - 编排完整流程，生成 `KaoDingLiuQinResult`：包含起卦、纳甲、目标爻、流度表、目标条目与过程说明。
  - 流度表匹配：
    - 若 `LiuDuTable.hasZhiMapper`，以目标爻纳支索引条目，`chiperNumber` 即 `tiaoWenNumber`。
    - 若固定列表（纳比卦/纳艮卦系列），标注 TODO：暂不自动匹配，留待后续实现。
- `repositories/liu_du_table_repository.dart`
  - 从 `assets/kao_ke/*.json` 加载 8 张流度表并缓存；按六亲类型映射表类型；预加载入口。
- `models/liu_du_table.dart`
  - 两种表结构：`zhiMapper<DiZhi, LiuDuEntry>`（父母/夫妻）；`gongEachList<List<LiuDuEntry>>`（兄弟/子女固定列表）。
  - `LiuDuEntry.tiaoWenNumber === chiperNumber` 一致；`LiuDuEntryWithTiaoWen` 组合条目与条文内容并标记是否目标。
- `usecases/kao_ding_liu_qin_use_case.dart`
  - 会话管理：执行单个、多种、全部六亲计算；供页面取条目并附带条文内容；维护选择状态。
- `pages/kao_ding_liu_qin_page.dart` & `widgets/liu_du_table_selection_widget.dart`
  - 并列展示四组（父母、夫妻、兄弟、子女），每组表中高亮目标条目；用户点击更新选择。

## 算法正确性核对
- 起卦：
  - 使用的“干支配数”来源于 `constants.dart`：`ganNumberMapper[TianGan]`、`zhiNumberMapper[DiZhi]=[奇,偶]`；`%8` 并将 `0→8`；数转先天八卦 `numberXianGuaMapper`；组合 64 卦。
  - 与 PRD 描述一致；公式文本记录清晰，便于核对不同柱的数源与映射。
- 纳甲/六亲：
  - 归宫与世应定位根据宫序表；内外卦纳甲/纳支分段写入；定六亲使用五行生克映射。
  - 目标爻选择逻辑为“距离参考位最近”最短距离，若并列不做二次规则（见改进建议）。
- 流度表匹配：
  - 父母/夫妻类型按地支映射能直接锁定目标条目；固定列表（兄弟/子女）暂不自动匹配。

## 数据模型与类型安全
- `PureSixYaoGua` 的 `GuaYao` 字段齐全：`order`、`yinYang`、`naJia`、`naZhi`、`liuQin`、`isShiYao/isYingYao`，并可由 `naJia+naZhi`组合得到 `ganZhi`。
- `LiuDuTable` 明确区分 `zhiMapper` 与 `gongEachList` 两形态，并提供统一的 `getAllEntries()`。

## 资源加载与仓库
- 仓库支持缓存与预加载；异常时抛出明确错误（路径与原因），上层页面有错误状态展示与重试入口。
- 依赖资源：
  - 流度表 JSON：`assets/kao_ke/*.json`（8 张）。
  - 条文 CSV：`assets/tiao_wen_data.csv`（由 `TiaoWenRepositoryImpl` 读取）。

## UI交互与状态管理
- 页面并列展示四组，用户可对每组选择条文编号；选择状态通过 UseCase 的 Session 记录，支持统计、历史、选中更新。
- 地支型表条目展示支持地支徽标；目标条目高亮色使用主题色系（次要/三级容器）。

## 可读性与维护性
- 流程分层良好：Helper（算法细节）→ Strategy（编排）→ Repository（数据）→ UseCase（会话）→ UI（展示）。
- 计算过程详尽写入 `calculationDetail`，对研发与测试友好。
- 常量命名较多，建议在“起卦所用常量”和“纳甲/归宫所用常量”之间进一步分组或注释，以降低认知成本。

## 性能、缓存与扩展性
- 资源量小，流程计算轻；仓库缓存避免重复解析 JSON。
- PRD 已预留固定列表自动匹配的 Roadmap；建议未来将各版本常量表配置化（便于切换与对照）。

## 边界条件与错误处理
- 目标爻不存在或无纳支：结果 `isSuccess=false` 或无法高亮条目，但仍加载表供用户选择。
- 固定列表暂不自动匹配：页面展示完整条目，由用户手选。
- 资源缺失：页面错误提示，不崩溃；仓库支持清缓存、重载。

## 改进建议（TODO）
1) 固定列表自动匹配规则：
- 依据宫序、世应位置、或特定映射规则，为纳比卦/纳艮卦自动推荐候选条目；与地支型表一致提供高亮。
2) 目标爻距离并列的裁决：
- 当“最近距离”出现并列时，建议加二次判定（例如优先靠近参考位的下→上方向、或优先特定爻位）。
3) `PureSixYaoGua.by8Gua` 中 `order` 的构造：
- 现实现使用 `botTopBinStrList.indexOf(b)` 可能在重复“0/1”时产生非期望的序号（因 `indexOf` 返回首个匹配索引）。建议改为按当前迭代下标生成序号（避免歧义）。
4) 常量命名统一：
- `ganNumberMapper` / `tianGanNumberMapper`、`zhiNumberMapper` / `diZhiNumberMapper` 同域内存在多套配数，建议明确分域注释与用途，避免混用。

## 测试建议
- 单元测试：
  - 起卦：针对 10 天干 × 12 地支验证下/上卦数与先天卦映射；`0→8` 边界。
  - 纳甲与六亲：归宫、世应、内外卦纳甲装配；五行六亲映射正确性（含日干五行变化）。
  - 目标爻定位：夫妻使用应爻、其他使用世爻；距离判定正确；并列裁决策略（若实现）。
  - 流度表：父母/夫妻按支索引命中目标条目；固定列表加载与展示；条文内容拼接正确。
- 集成测试：
  - `executeAll` 全类型计算与页面渲染；错误状态（资源缺失）与重试；预加载优化路径。