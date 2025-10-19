# 考订六亲（PRD）

## 背景与目标
- 为“考订六亲”提供一套从八字四柱起卦、纳甲装配、依日干定六亲、定位目标爻，并按六亲类型加载并展示对应流度表的完整流程。
- 目标是让用户在同一页面并列查看父母、夫妻、兄弟、子女四组六亲的流度表条目，并选择贴合的条文编号（tiaoWenNumber）。

## 用户场景
- 输入一个八字，自动按六亲类型（父母、夫妻、兄弟姐妹、子女）计算对应的卦与流度表。
- 页面展示每个六亲类型的候选条目（含密语与条文原文），并高亮算法推荐的目标条目；用户可点击选择最终条文编号。

## 输入
- EightChars `eightChars`：年、月、日、时四柱（`common/models/eight_chars.dart`）。
- LiuQinType `liuQinType`：六亲类型枚举（父/母/夫/妻/兄弟姐妹/子/女）。
- 自动从 `eightChars.day.gan` 获取日干 `TianGan` 用于定六亲。

## 输出
- KaoDingLiuQinResult：
  - `liuQinType`（六亲类型）、`pillar`（对应柱）、`qiGuaResult`（起卦结果）、`naJiaResult`（纳甲六亲结果）。
  - `targetYao`（定位到的目标爻，父母/妻财/兄弟/子孙）、`liuDuTable`（对应流度表）、`targetEntry`（匹配到的流度表条目）。
  - `calculationDetail`（完整的计算过程说明，便于调试与审计）。
- UI：每个六亲类型展示一张流度表的所有条目（带条文内容），支持点击选择条文编号。

## 业务规则与计算流程
1) 选择柱
- 六亲类型映射四柱：
  - 父/母 → 年柱；夫/妻 → 日柱；兄弟姐妹 → 月柱；子/女 → 时柱。

2) 起卦（QiGuaHelper）
- 数源：使用“干支配数”常量表（`constant/constants.dart`）：
  - 天干配数 `ganNumberMapper[TianGan]`。
  - 地支配数（两数）`zhiNumberMapper[DiZhi] = [奇数, 偶数]`。
- 公式：
  - 下卦数 = `(干数 + 支奇数) % 8`，0 记为 8。
  - 上卦数 = `(干数 + 支偶数) % 8`，0 记为 8。
  - 数转卦：先天序 `numberXianGuaMapper`（1乾 2兑 3离 4震 5巽 6坎 7艮 8坤）。
  - 合成 64 卦：`Enum64Gua.getBy8Gua(上卦, 下卦)`。
- 结果体：`QiGuaResult`，含上下卦数/卦名、干支数明细与“公式”文本。

3) 纳甲与六亲（NaJiaLiuQinHelper）
- 归宫与宫序：`eightGongGuaListMapper` 查 64 卦所在宫，宫序 0..7（本卦→归魂）。
- 世应定位：`shiYao[gongXu]` 与 `yiYao[gongXu]` 确定世/应爻索引（下→上，0..5）。
- 装纳甲/纳支：
  - 内卦（初、二、三）：`innerGuaYaoTianGan / innerGuaYaoDiZhi`。
  - 外卦（四、五、上）：`outerGuaYaoTianGan / outerGuaYaoDiZhi`。
- 定六亲：依据日干五行与爻支五行比对 `fiveXingSixQingMapper[dayGan.fiveXing][yaoZhi.fiveXing]`。

4) 目标爻定位（按六亲类型）
- 夫妻取应爻为参考，其余取世爻为参考；在六爻中筛选 `liuQin` 等于目标类型（父母/妻财/兄弟/子孙），取距离参考位最近者。

5) 流度表查询（Repository）
- 资产路径：`assets/kao_ke/*.json`；按六亲类型映射为 8 张表：乾宫甲（父）、坤宫甲（母）、木宫甲（妻）、金宫甲（夫）、纳比卦甲/乙（兄弟）、纳艮卦乙（子）、纳艮卦丙（女）。
- 表模型：`LiuDuTable`（名字、描述、`type`），两种形态：
  - `zhiMapper<DiZhi, LiuDuEntry>`：12 支映射条目（适用于父母/夫妻）。
  - `gongEachList<List<LiuDuEntry>>`：固定列表（纳比卦/纳艮卦系列）。
- 目标条目匹配：
  - 若 `hasZhiMapper`，以目标爻纳支 `naZhi` 直接索引条目；`chiperNumber` 即 `tiaoWenNumber`。
  - 若固定列表：当前不自动匹配（TODO），用户手动选择。

6) 展示与选择
- 页面按组并列展示：父母、夫妻、兄弟、子女四组；每组含对应类型的表条目（带条文原文）。其中“兄弟组”并列展示纳比卦甲表与乙表，两表共享选择状态与高亮规则。
- 高亮目标条目；用户点击即更新选择的 `tiaoWenNumber`，写入 Session。

## UI 交互与页面结构
- 页面：`features/kao_ding_liu_qin/pages/kao_ding_liu_qin_page.dart`
  - 顶栏：重新计算、使用说明。
  - 内容区：分组标题 + 表格（`LiuDuTableSelectionWidget`）。
  - 状态指示：加载中、错误、已计算。
- 选择组件：`LiuDuTableSelectionWidget`
  - 展示地支徽标（若按支索引）、密语、条文内容；高亮目标；点击选择条文编号。

## 数据与依赖
- 常量：`constant/constants.dart`（干支配数、先天/后天映射、归宫表、纳甲表、五行六亲映射等）。
- 资源：
  - 流度表 JSON：`assets/kao_ke/qian_gong_jia_liu_du.json` 等 8 张。
  - 条文 CSV：`assets/tiao_wen_data.csv`（通过 `TiaoWenRepositoryImpl` 读取）。
- 仓库：`features/kao_ding_liu_qin/repositories/LiuDuTableRepository`（缓存与加载）。

## 会话与选择状态
- UseCase：`KaoDingLiuQinUseCase` 管理计算与 Session：
  - `execute / executeMultiple / executeAll` 执行计算。
  - `selectTiaoWen(tiaoWenNumber, method)` 更新当前选择。
  - `getLiuDuEntriesWithTiaoWen(result)` 组合条目与条文内容用于展示。

## 验收标准
- 起卦公式正确：干支配数与奇偶拆分、取模 8、先天映射与 64 卦组合一致。
- 纳甲与六亲装配正确：归宫、世应、内外卦纳甲、五行六亲映射无误。
- 父母/夫妻类型能自动高亮到按地支索引的目标条目。
- 兄弟/子女类型固定列表能正常加载与选择（暂不自动匹配）。
- 页面一次性并列展示四组六亲；可选择条文编号并能在 Session 中记录。
- 资源加载失败时提供错误提示，不崩溃；仓库具备缓存与预加载能力。

## 边界与异常处理
- 目标爻不存在：返回结果 `isSuccess=false`，但仍展示流度表供用户选择。
- 目标爻无纳支：无法按支索引目标条目，保留表展示与选择。
- 固定列表（纳比卦/纳艮卦）：暂不提供自动匹配逻辑，需用户手选（PRD 同步一个后续需求）。
- 资源缺失（JSON/CSV）：仓库抛出异常，页面显示错误并允许重试；支持预加载减缓首屏延迟。

## 性能与可用性
- 流度表仓库带缓存；提供 `preloadTables()` 以优化首屏体验。
- 条文内容按需加载；按地支索引的表保证顺序与支完整性。

## 版本与扩展（Roadmap）
- [短期] 实现固定列表表的自动匹配规则（依据宫序、世应位置或特定映射）。
- [已实现] 兄弟组并列展示纳比卦甲/乙两表，复用选择与高亮逻辑。
- [中期] 增加“方法”字段（如取数策略）在 Session 中记录；完善对不同版本常量表的配置化切换。
- [中期] 增加导出选择结果（tiaoWenNumber）的能力。
- [中期] 增加单元测试覆盖：起卦、纳甲、六亲装配、条目组合与高亮。