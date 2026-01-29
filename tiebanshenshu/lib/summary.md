# tiebanshenshu/lib 代码总览与架构说明

本目录实现了“铁板神数”相关的取数与条文检索显示，整体采用分层与策略模式，配合 Provider 依赖注入与 MVVM+UseCase 架构，覆盖多种取数法（太玄、先后天、八卦加则、四门法、八卦滚法、元堂卦、前后卦、六爻干支合、卦爻干支合等）。

## 架构总览
- 分层结构：
  - domain：核心领域模型与结果类型，记录基础数、卦象、中间过程、条文列表等。
  - service/strategy：所有取数法的“策略”实现与公共基类；负责把四柱、卦象、映射表等转为基础数，并配置条文扩展。
  - usecases：围绕策略与仓库的应用用例，负责把“基础数”扩展为“条文编号列表”，并取回条文内容。
  - repository：条文数据访问层（CSV 资源加载、缓存、查询、搜索）。
  - infrastructure：DI（Provider）集中配置，串联 Repository→Strategy→UseCase→ViewModel。
  - presentation/ui：UI 视图模型、页面与展示模型，将领域结果转换为用户可读的文本与组件。
  - application：跨策略的服务与交互式用例基础类。
  - utils：工具函数与通用计算器（如条文扩展、太玄/四门法数值计算）。
- 模式与数据流：UI 触发 ViewModel→UseCase→Strategy 计算基础数→UseCase 根据配置扩展条文编号→Repository 取条文内容→UI 展示。

## 关键模块与职责
- domain/models：
  - BaseNumberModel/BaseNumberSource：统一的基础数载体与来源标识（年柱、月柱、组合、交互、皇极等）。
  - BaseNumberTiaoWenListModel：在基础数上承载条文编号与内容（可从/转回 BaseNumberModel）。
  - 多种特定模型：YuanTangBaseNumberModel、QianHouGuaBaseNumberModel、SiMenFaBaseNumberModel、BaGuaGunBaseNumberModel、GuaYaoGanZhiHeBaseNumberModel、GuaZhongBaseNumberModel 等，细致记录各算法的中间变量、公式与说明。
  - 结果类型：BaseNumberModelResult、YuanTangModelResult、MultiBaseNumberResult（多基础数聚合）。
- service/strategy：
  - BaseCalculationStrategy/StrategyCategory：所有策略的抽象接口（名称、描述、步骤、流派、分类、默认与支持的条文扩展配置）。
  - GenericTiaoWenCalculationConfig：为策略提供统一的条文扩展（自定义、递增96、加减48×倍数等）。
  - tiao_wen_list_calculation.dart：通用条文列表计算器与配置（loopAddTimes/fromMultiples/listAdd）。
  - base/multi_gua_calculator_base.dart：多卦场景的公共计算骨架（四门法/八卦滚法），含干支→数映射、互卦/错卦/变爻生成、先天/洛书数衍生等。
  - 具体策略示例：
    - TaiXuanFourZhuStrategy（太玄取数法（1））：四柱天干地支各配卦与纳甲，按太玄数求和，千百位=上卦，十个位=下卦；默认“太玄标准”±96 扩展。
    - FourZhuTianGanStrategy（四柱天干取数法）：仅取四柱天干配数，按月日时年组合成四位基础数，递加 96（标准/简化/扩展三套）。
    - XianHoutianQuShuStrategy（先后天卦取数）：以卦象的先天/后天数拼接四位基数（含互卦），默认使用 ±48×倍数扩展（±96/±192/±384/±768）。
    - QianHouGuaStrategy（前后卦取数）：年/月为前卦、日/时为后卦，各用太玄与甲则生成基数，再分别递增96四次/递减96四次。
    - SiMenFaStrategy（四门法 V2）：基卦→变爻基数→前四卦→秘数列→先天数列→最终条文；条文扩展依赖自定义组合，非单一固定偏移。
    - BaGuaGunStrategy（八卦滚法）：以三基数（先天顺序、先天洛书、后天洛书）组合生成 48 条文。
    - LiuYaoGanZhiHeStrategy/GuaYaoGanZhiHeStrategy：六爻/卦爻纳甲与太玄数求和，拼接上下卦形成四位基数，再用配置扩展条文。
    - BaGuaJiaZeStrategy/XianHoutianJiaZeStrategy：按“甲则/加则”生成基础数与扩展（如前卦加、后卦减）。
    - YuanTangStrategy：元堂卦完整流水线（天地卦→先天→元堂→后天→互卦→大运），输出多种取数与条文列表。
- usecases：
  - 每种策略配套一个 TiaoWenListUseCase（如 tai_xuan_four_zhu_tiao_wen_list_use_case、qian_hou_gua_tiao_wen_list_use_case 等），负责：
    1) 调策略产出基础数（含过程说明）；
    2) 依据策略默认/用户选择的扩展配置生成条文编号；
    3) 调 TiaoWenRepository 批量取内容，构造 BaseNumberTiaoWenListModel 或特定 UI 模型。
- repository：
  - TiaoWenRepository 抽象接口：提供按 ID、区间、间隔与搜索的多种读取方式；支持批量获取条文内容（numbers→content）。
  - TiaoWenRepositoryImpl：基于 CSV 资源加载（assets），带 Map/List 双缓存与并发安全；解析 setName（地支）、content 与 ageSet（年龄段）。
  - 辅助：RepositoryFactory 与 SessionRepository（会话管理，供某些交互或 V2 架构使用）。
- infrastructure/di：
  - strategy_providers.dart：集中声明 Provider 依赖：Repository→Strategy→UseCase→ViewModel；含 HuangJiV2、LiuQinKaoKe、KaoKe、KaoDingLiuQin 等特性线的 DI。
- presentation：
  - models：UI 展示模型（如 YuanTangUIModel、BaGuaGunUIModel、BaGuaJiaZeUIModel 等），把领域模型转为易读文案与表格化结构。
  - viewmodels：针对每个策略的 ViewModel（tai_xuan_four_zhu_view_model、four_zhu_tian_gan_view_model 等），封装用户输入与结果状态。
  - widgets/pages/styles：通用组件与页面（如 dev_page.dart），辅助调试与展示。
- application：
  - services/interactive_session_service.dart、usecases/base_interactive_use_case.dart：交互式流程的基类与服务。
- utils：
  - tiao_wen_number_calculator.dart：四门法与八卦滚法的数值核心（秘数、先天数三基数组合）。
  - tiao_wen_list_calculation.dart：条文扩展配置器（loopAddTimes、fromMultiples、listAdd）。
  - tiao_wen_calculator.dart：旧版条文工具（标注 Deprecated），包含甲则、太玄数汇总与 ±96/±48 等扩展示例。

## 映射与计算要点
- 太玄数映射：
  - TianGan/DiZhi→TaiXuanNumber（和为 10 不计入总和）。
  - 在六爻/卦爻求和场景中，分别对上下卦三爻求和，上卦作千百位，下卦作十个位形成四位基础数。
- 先天/后天卦数：
  - 64/8卦转换与互卦生成；拼接规则常为：千=上卦、百=下卦、十=互卦上、个=互卦下。
- 甲则/加则：
  - 以“甲则”或“加则”的数值规则生成基础数与扩展（例如前卦递增、后卦递减）。
- 条文扩展（TiaoWenCalculationConfig）：
  - 统一通过 GenericTiaoWenCalculationConfig 或 TiaoWenListCalculationConfig 生成 offsets，再以 baseNumber+offset 形成条文编号。
  - 常见方案：递增 96×N、递减 96×N、±48×倍数（2/4/8/16）、自定义列表（四门法/八卦滚法）。

## 依赖注入与运行时配置
- strategy_providers.dart 将：
  - RepositoryFactory.defaultTiaoWenRepository 注入为 TiaoWenRepository；
  - 每个 Strategy、UseCase、ViewModel 成链路注入；
  - TiaoWenListCalculationConfig 作为全局或默认偏移配置供用例使用（可在 UI 侧切换）。

## 典型数据流（以太玄取数法（1）为例）
1) UI 输入四柱 EightChars 与纳甲方法→ViewModel 调用 TaiXuanFourZhuTiaoWenListUseCase。
2) UseCase 调 TaiXuanFourZhuStrategy：
   - 天干/地支配卦、纳甲，六爻干支取太玄数并求和；
   - 形成四位基础数（上卦两位为千/百，下卦两位为十/个）。
3) UseCase 根据策略的默认/用户选定配置（如“太玄标准”±96）生成条文编号列表。
4) 调 TiaoWenRepository 批量取内容，生成 BaseNumberTiaoWenListModel 或 UI 模型→ViewModel 更新→UI 显示。

## 扩展指南
- 新增取数法：
  - 新建 Strategy（继承 BaseCalculationStrategy），实现 name/description/detailSteps/school/category 与 calculate()；
  - 指定 defaultTiaoWenCalculationConfig 与 supportedTiaoWenCalculationConfigs；
  - 新建对应 UseCase（聚合 Strategy 与 Repository）；
  - 在 infrastructure/di/strategy_providers.dart 注册 Provider；
  - 如有特殊 UI，新增 presentation/models 与 viewmodels，再在 UI 侧接入。
- 新增条文扩展规则：
  - 通过 GenericTiaoWenCalculationConfig.customList 或 tiao_wen_list_calculation.dart 的 factory 快速组合。

## 注意事项
- tiao_wen_calculator.dart 已标注为 Deprecated，新实现统一走 Strategy + GenericTiaoWenCalculationConfig/tiao_wen_list_calculation。
- CSV 解析兼容不规范的年龄集格式，RepositoryImpl 内部有清洗逻辑并采用双缓存与并发保护。

## 算法与代码文件详解（加入）

说明约定：

- 输入一般指四柱 EightChars 或派生的干支、卦象等。
- “基础数”指 4 位或其他形式的基数，用于扩展条文编号。
- 条文扩展通过配置（GenericTiaoWenCalculationConfig 或 TiaoWenListCalculationConfig）把基础数变换为一组条文编号。
- 绝对路径均以 /Users/jingtaiwei/Git/Public/xuan 作为项目根。
### 一、太玄取数法（1） TaiXuanFourZhuStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/tai_xuan_four_zhu_strategy.dart
  - /tiebanshenshu/lib/usecases/tai_xuan_four_zhu_tiao_wen_list_use_case.dart
  - /tiebanshenshu/lib/presentation/viewmodels/tai_xuan_four_zhu_view_model.dart
  - /tiebanshenshu/lib/domain/models/tai_xuan_base_number_model.dart
  - /tiebanshenshu/lib/domain/models/base_number_model_result.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart（Provider 注册）
  - /tiebanshenshu/lib/constant/constants.dart（天干地支配卦、纳甲、太玄数映射）
  - /tiebanshenshu/lib/features/six_yao_gua/pure_six_yao_gua.dart（六爻结构）
#### 计算流程
  - 输入：EightChars（年、月、日、时四柱），以及纳甲方法 TaiXuanNaJiaMethod（yearGanYinYang 或 innerOuterGua）。
  - 干支配卦：
    - 天干配卦：壬甲从乾数，乙癸向坤求，庚来震上里，辛在巽方留，己从离门起，戊以坎为头，丙须艮处出，丁向兑家收。
    - 地支配卦：亥子坎宫寅木震，巳午离门丑在坤，卯酉乾金辰是兑，未申艮宫戌巽真。
  - 组六爻卦：以“柱的天干为上卦、地支为下卦”合成一个六爻卦（PureSixYaoGua）。
  - 纳甲与太玄求和：
    - 依据纳甲方法选择天干配置：阳年用 yangGuaYaoTianGan，阴年用 yinGuaYaoTianGan；地支纳甲分别用 innerGuaYaoDiZhi（下卦）与 outerGuaYaoDiZhi（上卦）。
    - 对每一爻算 TaiXuanGanNumber + TaiXuanZhiNumber；若和为 10 则该爻不计。
    - 下卦三爻和为 lowerSum，上卦三爻和为 upperSum。
  - 基础数计算：baseNumber = upperSum * 100 + lowerSum（千百位对应上卦，两位；十个位对应下卦，两位）。
  - 扩展条文：默认“太玄标准”配置（±96），也支持简化（仅 ±96）与扩展（±96 到 ±3072）等。
- 条文扩展配置
  - 默认：GenericTiaoWenCalculationConfig.taiXuanStandard()
  - 支持：简化配置（仅 ±96）、扩展配置（±96×多次）
- 输出与领域模型
  - TaiXuanBaseNumberModel：包含每柱的上下卦、纳甲干支、每爻太玄数、上下卦求和、基础数、后天卦数、公式说明等。
  - BaseNumberModelResult：聚合四柱的 TaiXuanBaseNumberModel。
- 用例与依赖注入
  - UseCase：/usecases/tai_xuan_four_zhu_tiao_wen_list_use_case.dart
  - DI：strategy_providers.dart 中 Provider
    与 Provider
  - ViewModel：presentation/viewmodels/tai_xuan_four_zhu_view_model.dart
- 工具与常量
  - constants.dart：tianGanGuaMapper、diZhiGuaMapper、纳甲天干/地支映射、太玄数映射等。
  - PureSixYaoGua：六爻结构与互卦等运算。
### 二、四柱天干取数法 FourZhuTianGanStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/four_zhu_tian_gan_strategy.dart
  - /tiebanshenshu/lib/usecases/four_zhu_tian_gan_tiao_wen_list_use_case.dart
  - /tiebanshenshu/lib/presentation/viewmodels/four_zhu_tian_gan_view_model.dart
  - /tiebanshenshu/lib/domain/models/base_number_model.dart
  - /tiebanshenshu/lib/domain/models/base_number_model_result.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
  - /tiebanshenshu/lib/constant/constants.dart（fourZhuTianGanNumberMapper）
#### 计算流程
  - 输入：EightChars。
  - 天干配数：甲1、乙6、丙2、丁7、戊3、己8、庚4、辛9、壬5、癸0。
  - 组合顺序：按月、日、时、年的顺序排列四个天干配数，构成四位基础数 baseNumber。
  - 扩展条文：以 baseNumber 为基础递加 96（标准：7 次；简化：3 次；扩展：10 次）。
- 条文扩展配置
  - 默认：customList [0, 96, 192, 288, 384, 480, 576, 672]
  - 支持：简化与扩展版本
- 输出与领域模型
  - BaseNumberModel（source: combined），聚合为 BaseNumberModelResult。
- 用例与依赖注入
  - UseCase：/usecases/four_zhu_tian_gan_tiao_wen_list_use_case.dart
  - DI：strategy_providers.dart 中 Provider
    与 Provider
- 工具与常量
  - constants.dart：fourZhuTianGanNumberMapper。
### 三、先后天卦取数法 XianHoutianQuShuStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/xian_houtian_qu_shu_strategy.dart
  - /tiebanshenshu/lib/usecases/xian_houtian_qu_shu_tiao_wen_list_use_case.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
  - /tiebanshenshu/lib/utils/utils.dart（gua 工具：互卦等）
  - /tiebanshenshu/lib/constant/constants.dart（先天/后天卦数、纳甲映射、太玄数）
#### 计算流程
  - 输入：一个 64 卦（通常由四柱推导）。
  - 先后天基础数拼接：
    - 先天 baseNumber：千=上卦先天数、百=下卦先天数、十=互卦上卦先天数、个=互卦下卦先天数。
    - 后天 baseNumber：同理使用后天数。
  - 六爻干支和法（可选）：按纳甲配置（内卦用 inner 映射，下卦三爻；外卦用 outer 映射，上卦三爻），每爻太玄数求和（和为 10 不计）。
  - 扩展条文：默认使用 ±48×倍数扩展（倍数 2/4/8/16，即 ±96/±192/±384/±768）。
- 条文扩展配置
  - 默认：GenericTiaoWenCalculationConfig.addSub48x(multiples: [2,4,8,16])
- 输出与领域模型
  - 生成 baseNumber 列表并映射为 BaseNumberModel 或特定模型（策略内部有细化）。
- 用例与依赖注入
  - UseCase：/usecases/xian_houtian_qu_shu_tiao_wen_list_use_case.dart
  - DI：Provider
    与对应的 UseCase
### 四、前后卦取数法 QianHouGuaStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/qian_hou_gua_strategy.dart
  - /tiebanshenshu/lib/domain/models/qian_hou_gua_base_number_model.dart
  - /tiebanshenshu/lib/usecases/qian_hou_gua_tiao_wen_list_use_case.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
  - /tiebanshenshu/lib/constant/constants.dart（太玄数映射）
  - /tiebanshenshu/lib/features/six_yao_gua/pure_six_yao_gua.dart
#### 计算流程
  - 输入：EightChars。
  - 前卦：年柱+月柱；后卦：日柱+时柱。各柱天干地支的太玄数相加（和为 10 不计），上卦汇总为千百位，下卦汇总为十个位，得到两个四位基础数。
  - 甲则扩展：基础数分别用甲则增减扩展。
  - 扩展条文：前卦递增 96 四次，后卦递减 96 四次，合并为一个列表。
- 条文扩展配置
  - 默认：customList [0, 96, 192, 288, 384, -96, -192, -288, -384]
- 输出与领域模型
  - QianHouGuaBaseNumberModel：保存前/后卦卦名、上下卦数、基础数、条文列表与公式。
- 用例与依赖注入
  - UseCase：/usecases/qian_hou_gua_tiao_wen_list_use_case.dart
  - DI：Provider
    与对应 UseCase
### 五、四门法 V2 SiMenFaStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/si_men_fa_strategy.dart
  - /tiebanshenshu/lib/service/strategy/base/multi_gua_calculator_base.dart（多卦骨架与变爻、互卦、错卦生成）
  - /tiebanshenshu/lib/utils/tiao_wen_number_calculator.dart（四门法秘数与先天数计算器）
  - /tiebanshenshu/lib/domain/models/si_men_fa_base_number_model.dart
  - /tiebanshenshu/lib/usecases/si_men_fa_tiao_wen_list_use_case.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
#### 计算流程
  - 输入：EightChars。
  - 计算基本卦与基本数：依据 MultiGuaCalculatorBase 的干支→数映射与组卦规则求出第一基本卦与基本数。
  - 变爻基数：从基本卦与“变爻规则”计算变爻的基数（variation base）。
  - 生成前四卦：互卦 → 变爻错卦 → 第一卦互卦 → 第二卦互卦，得到序列。
  - 秘数列表：通过 TiaoWenNumberCalculator 的四门法部分计算秘数（结合年干阴阳、卦序等）。
  - 先天数列表：从卦象导出各卦的先天数序列。
  - 最终条文：将秘数与先天数按既定公式组合，生成条文列表（通常非简单 base+offset，而是组合计算）。
- 条文扩展配置
  - 默认：customList [0]（策略内部采用组合算法，不靠标准偏移）
- 输出与领域模型
  - SiMenFaBaseNumberModel：保存基本卦、变爻、前四卦、秘数/先天数序列、最终条文与公式。
- 用例与依赖注入
  - UseCase：/usecases/si_men_fa_tiao_wen_list_use_case.dart
  - DI：Provider
    与对应 UseCase
- 工具与常量
  - MultiGuaCalculatorBase：提供 GanZhiToNumber、Number→Gua 转换、互卦/错卦/变爻生成。
  - TiaoWenNumberCalculator：四门法的秘数和先天数组合逻辑。
### 六、八卦滚法 BaGuaGunStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/ba_gua_gun_strategy.dart
  - /tiebanshenshu/lib/utils/tiao_wen_number_calculator.dart（八卦滚法三基数）
  - /tiebanshenshu/lib/domain/models/ba_gua_gun_base_number_model.dart
  - /tiebanshenshu/lib/usecases/ba_gua_gun_tiao_wen_list_use_case.dart
  - /tiebanshenshu/lib/presentation/models/ba_gua_gun_ui_model.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
#### 计算流程
  - 输入：EightChars。
  - 基本卦与变爻基数：同样基于 MultiGuaCalculatorBase。
  - 三基数导出：对每一个衍生卦，计算三组数：
    - 先天顺序数（xiantianShunxu）
    - 先天洛书数（xiantianLuoshu）
    - 后天洛书数（houtianLuoshu）
  - 组合条文：三基数按规则组合为 6 个条文编号/每卦，8 卦共 48 条文。
- 条文扩展配置
  - 专用组合计算，不使用标准偏移配置；supportedConfigs 仅返回默认。
- 输出与领域模型
  - BaGuaGunBaseNumberModel：记录基本数、八卦序列、三基数与最终条文。
  - BaGuaGunUIModel：将领域结果转为 UI 展示结构。
- 用例与依赖注入
  - UseCase：/usecases/ba_gua_gun_tiao_wen_list_use_case.dart
  - DI：Provider
    与对应 UseCase
- 工具与常量
  - TiaoWenNumberCalculator：八卦滚法的三基数组合逻辑。
### 七、六爻干支和法 LiuYaoGanZhiHeStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/liu_yao_gan_zhi_he_strategy.dart
  - /tiebanshenshu/lib/usecases/liu_yao_gan_zhi_he_tiao_wen_list_use_case.dart
  - /tiebanshenshu/lib/domain/models/gua_yao_gan_zhi_he_base_number_model.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
  - /tiebanshenshu/lib/constant/constants.dart（纳甲、太玄数映射）
  - /tiebanshenshu/lib/features/six_yao_gua/pure_six_yao_gua.dart
#### 计算流程
  - 输入：一个六爻卦（通常由四柱配卦而来）。
  - 纳甲：下卦三爻配 innerGuaYaoTianGan/DiZhi，上卦三爻配 outerGuaYaoTianGan/DiZhi。
  - 太玄数求和：
    - 每爻：GanNumber + ZhiNumber，和为 10 不计。
    - 下三爻和为 lowerSum，上三爻和为 upperSum。
  - 基础数：baseNumber = upperSum * 100 + lowerSum。
  - 扩展条文：使用默认的配置（通常为递增 96×N 或自定义）。
- 条文扩展配置
  - 默认：策略内指定（支持 GenericTiaoWenCalculationConfig）
- 输出与领域模型
  - GuaYaoGanZhiHeBaseNumberModel（或 BaseNumberModel）：包含每爻细节与基础数。
- 用例与依赖注入
  - UseCase：/usecases/liu_yao_gan_zhi_he_tiao_wen_list_use_case.dart
  - DI：Provider
### 八、卦爻干支和法 GuaYaoGanZhiHeStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/gua_yao_gan_zhi_he_strategy.dart
  - /tiebanshenshu/lib/usecases/gua_yao_gan_zhi_he_tiao_wen_list_use_case.dart
  - /tiebanshenshu/lib/domain/models/gua_yao_gan_zhi_he_base_number_model.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
  - /tiebanshenshu/lib/constant/constants.dart、pure_six_yao_gua.dart
#### 计算流程
  - 与“六爻干支和法”相似，但聚焦某一卦或某一爻序列的求和，最终同样构造四位基础数并扩展条文。
- 条文扩展配置
  - 默认：策略内指定
- 用例与依赖注入
  - UseCase：/usecases/gua_yao_gan_zhi_he_tiao_wen_list_use_case.dart
  - DI：Provider
### 九、八卦加则法 BaGuaJiaZeStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/ba_gua_jia_ze_strategy.dart
  - /tiebanshenshu/lib/usecases/ba_gua_jia_ze_tiao_wen_list_use_case.dart
  - /tiebanshenshu/lib/presentation/models/ba_gua_jia_ze_ui_model.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
  - /tiebanshenshu/lib/repository/tiao_wen_repository.dart（取条文内容）
#### 计算流程
  - 输入：八卦相关参数（多来自四柱与卦象）。
  - 基础数：按“加则（甲则）”规则生成对应基础数。
  - 扩展条文：策略固定（通常只有一种默认扩展），取回条文并在 UI 中展示年龄集信息。
- 条文扩展配置
  - 默认：策略固定唯一配置
- 输出与领域模型
  - BaseNumberTiaoWenListModel（含条文内容与年龄集）
- 用例与依赖注入
  - UseCase：/usecases/ba_gua_jia_ze_tiao_wen_list_use_case.dart
  - DI：Provider
### 十、先后天加则法 XianHoutianJiaZeStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/xian_houtian_jia_ze_strategy.dart
  - /tiebanshenshu/lib/usecases/xian_houtian_jia_ze_tiao_wen_list_use_case.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
#### 计算流程
  - 输入：先天/后天卦的基础数。
  - 扩展条文：先天卦递增 96 四次、后天卦递减 96 四次，分别生成条文列表。
- 条文扩展配置
  - 默认：increment96x4 与 decrement96x4
  - 支持：自定义列表
- 输出与领域模型
  - BaseNumberModel 或特定模型聚合为 BaseNumberTiaoWenListModel
- 用例与依赖注入
  - UseCase：/usecases/xian_houtian_jia_ze_tiao_wen_list_use_case.dart
  - DI：Provider
### 十一、元堂卦取数法 YuanTangStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/yuan_tang_strategy.dart
  - /tiebanshenshu/lib/features/yuan_tang_gua/yuan_tang_calculator.dart
  - /tiebanshenshu/lib/features/yuan_tang_gua/yuan_tang_info.dart
  - /tiebanshenshu/lib/features/yuan_tang_gua/yuan_tang_info_ext.dart
  - /tiebanshenshu/lib/utils/utils.dart（卦运算）
  - /tiebanshenshu/lib/domain/models/yuan_tang_base_number_model.dart
  - /tiebanshenshu/lib/domain/models/yuan_tang_model_result.dart
  - /tiebanshenshu/lib/usecases/yuan_tang_tiao_wen_list_use_case.dart
  - /tiebanshenshu/lib/presentation/models/yuan_tang_ui_model.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
#### 计算流程
  - 输入：EightChars、性别等元堂参数。
  - 天地卦生成：以奇偶数/三元五宫等规则构造天卦与地卦。
  - 先天卦与元堂卦：从天地卦推导先天卦、选择元堂爻（根据奇偶、阴阳与规则定位元堂爻）。
  - 后天卦与互卦：派生后天卦、互卦（先天/后天），用于后续流运与条文计算。
  - 大运体系：计算起运年龄与大运列表（先天、后天两套），用于 UI 展示与条文年龄对应。
  - 多条取数与条文：
    - 甲则先天/后天条文
    - 纳甲太玄（先天/后天）条文
    - 本互（先天本互、后天本互）条文
    - 互卦条文列表（先天互、后天互）
  - 扩展条文：通常采用 ±48×倍数扩展（或策略内置的自定义列表组合），并合并各方法条文。
- 条文扩展配置
  - 默认：GenericTiaoWenCalculationConfig（描述含 ±48×倍数）
- 输出与领域模型
  - YuanTangBaseNumberModel：非常完整，包含天/地卦数、上下卦、互卦、本互、元堂爻、纳甲太玄数、先后天取数、条文各组与公式、大运等。
  - YuanTangModelResult：携带 YuanTangInfo 与 BaseNumberModel。
- 用例与依赖注入
  - UseCase：/usecases/yuan_tang_tiao_wen_list_use_case.dart
  - DI：Provider
  - UI：YuanTangUIModel 将领域结果映射为页面展示内容。
### 十二、日干支卦取数法 DayGanZhiGuaStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/day_gan_zhi_gua_strategy.dart
  - /tiebanshenshu/lib/usecases/day_gan_zhi_gua_tiao_wen_list_use_case.dart
  - /tiebanshenshu/lib/presentation/viewmodels/day_gan_zhi_gua_view_model.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
#### 计算流程
  - 输入：EightChars（日柱）。
  - 日干配卦与日支配卦，组合六爻，纳甲太玄求和，形成四位基础数，再扩展条文（通常递增 96）。
- 条文扩展配置
  - 默认：UseCase 注入的 TiaoWenListCalculationConfig 或策略自带配置。
- 用例与依赖注入
  - UseCase：/usecases/day_gan_zhi_gua_tiao_wen_list_use_case.dart
  - DI：Provider
### 十三、卦中取数法 GuaZhongStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/gua_zhong_strategy.dart
  - /tiebanshenshu/lib/usecases/gua_zhong_tiao_wen_list_use_case.dart
  - /tiebanshenshu/lib/domain/models/gua_zhong_base_number_model.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
#### 计算流程（根据领域模型字段推断）
  - 输入：EightChars。
  - 太玄数计算：年/月/日/时各干支太玄数（yearGanTaixuanNumber、yearZhiTaixuanNumber 等），求和（yearSum、monthSum）。
  - 先天卦数：年/月上、下卦的先天数（nianYueUpperGuaXiantianNumber、nianYueLowerGuaXiantianNumber）。
  - 派生卦象与条文：生成某些“日时互卦”的条文编号（riShiHuGuaTiaoWenNumber_Plan1/2/3 等）。
  - 最终形成基础数与条文列表并输出。
- 条文扩展配置
  - 默认：策略内部定义（可能含自定义列表）
- 用例与依赖注入
  - UseCase：/usecases/gua_zhong_tiao_wen_list_use_case.dart
  - DI：Provider
### 十四、太玄四柱交互法 TaiXuanFourZhuInteractiveStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/tai_xuan_four_zhu_interactive_strategy.dart
  - /tiebanshenshu/lib/application/services/interactive_session_service.dart
  - /tiebanshenshu/lib/application/usecases/base_interactive_use_case.dart
  - /tiebanshenshu/lib/usecases/tai_xuan_four_zhu_interactive_use_case.dart
  - /tiebanshenshu/lib/presentation/viewmodels/tai_xuan_four_zhu_interactive_view_model.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
#### 计算流程
  - 输入：EightChars，交互式步骤由 ViewModel 驱动（用户可参与参数选择或确认中间结果）。
  - 流程：在 standard 策略的基础上增加交互确认点（如纳甲方法、某些过滤条件），最终产生基础数与条文列表。
- 用例与依赖注入
  - UseCase：/usecases/tai_xuan_four_zhu_interactive_use_case.dart
  - DI：Provider
### 十五、中宫五策略 MiddlePalaceFiveStrategy（在六亲考刻中使用）
#### 涉及代码文件
  - /tiebanshenshu/lib/service/strategy/middle_palace_five_strategy.dart
  - /tiebanshenshu/lib/features/liuqinkaoke/strategy/liuqinkaoke_calculation_strategy.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart（LiuQinKaoKe DI）
#### 计算流程
  - 输入：EightChars 与六亲考刻参数。
  - 规则：在中宫五的框架下，结合卦象与六亲关系产生中间数与基础数，为六亲考刻策略提供支持。
- 用例与依赖注入
  - 由 LiuQinKaoKeUseCase 聚合调用，DI 提供 MiddlePalaceFiveStrategy 与相关仓库/常量。
### 十六、皇极 V2 HuangJiV2CalculationStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/features/huang_ji/huang_ji_v2_calculation_strategy.dart
  - /tiebanshenshu/lib/features/huang_ji/huang_ji_v2_calculation_strategy_impl.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart（HuangJiV2 DI 链路）
  - /tiebanshenshu/lib/domain/models/yuan_hui_yun_shi.dart、base_number_selection_record.dart、huang_ji_number.dart
  - /tiebanshenshu/lib/features/huang_ji/huang_ji_formula_data_v2.dart（公式数据）
#### 计算流程
  - 输入：EightChars 与会话信息（SessionRepository）。
  - 规则：按皇极公式与三元流运的体系计算皇极数；生成选择记录与输出数字。
  - 输出：HuangJiNumber 与关联的流程信息。
- 用例与依赖注入
  - UseCase：/tiebanshenshu/lib/features/huang_ji/huang_ji_v2_use_case.dart
  - ViewModel：/tiebanshenshu/lib/features/huang_ji/huang_ji_v2_view_model.dart
  - DI：Provider
    、Provider
    、Provider
    等。
### 十七、考刻 KaoKeCalculationStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/features/kao_ke/kao_ke_calculation_strategy_impl.dart
  - /tiebanshenshu/lib/features/kao_ke/kao_ke_calculation_strategy.dart（接口/抽象）
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart（KaoKe DI 链路）
  - 依赖策略：/service/strategy/ba_gua_jia_ze_strategy.dart、/service/strategy/gua_yao_gan_zhi_he_strategy.dart
  - 领域模型：/domain/models/gua_yao_gan_zhi_he_base_number_model.dart
#### 计算流程
  - 输入：EightChars 与考刻参数。
  - 规则：组合八卦加则与卦爻干支和法的输出；批量取条文；整合为考刻的结果集合。
  - 输出：TiaoWenResult（聚合多个基础数的条文集合）或特定 UI 显示模型。
- 用例与依赖注入
  - KaoKeUseCase、KaoKeViewModel、Provider
    。
### 十八、六亲考刻 LiuQinKaoKe
#### 涉及代码文件
  - /tiebanshenshu/lib/features/liuqinkaoke/strategy/liuqinkaoke_calculation_strategy.dart
  - /tiebanshenshu/lib/features/liuqinkaoke/repository/liuqinkaoke_session_repository.dart
  - /tiebanshenshu/lib/features/liuqinkaoke/usecase/liuqinkaoke_session_manager.dart
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart（LiuQinKaoKe DI）
  - 依赖策略：/service/strategy/middle_palace_five_strategy.dart
#### 计算流程
  - 输入：EightChars 与六亲关系参数。
  - 规则：利用中宫五策略与六亲表数据（LiuDuTableRepository）计算对应条文集合。
- 用例与依赖注入
  - LiuQinKaoKeUseCase、LiuQinKaoKeViewModel、Provider
    等。
### 十九、考订六亲 KaoDingLiuQinStrategy
#### 涉及代码文件
  - /tiebanshenshu/lib/features/kao_ding_liu_qin/strategy/kao_ding_liu_qin_strategy.dart（在 DI 中引用）
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart（KaoDingLiuQin DI 链路）
  - /tiebanshenshu/lib/domain/models（六度表、六亲映射）
#### 计算流程
  - 输入：EightChars 与六亲订正参数。
  - 规则：依据六度表与策略规则订正六亲对应，生成条文或校验结果。
- 用例与依赖注入
  - KaoDingLiuQinUseCase、KaoDingLiuQinViewModel、Provider
    。
### 二十、通用条文扩展与数据仓库

- 条文扩展工具与配置
  - /tiebanshenshu/lib/service/strategy/base_calculation_strategy.dart
    - 抽象策略接口：name/description/detailSteps/school/category/defaultTiaoWenCalculationConfig/supportedConfigs/calculateTiaoWenListWithConfig
    - GenericTiaoWenCalculationConfig：统一封装“递增96×N、递减96×N、±48×倍数、customList”等
  - /tiebanshenshu/lib/service/strategy/tiao_wen_list_calculation.dart
    - TiaoWenListCalculationConfig：支持 loopAddTimes（基数+次数）、fromMultiples（倍数列表）、listAdd（自定义偏移）
    - TiaoWenListCalculator：把 baseNumber 与 offsets 组合为条文编号列表
- 条文数据仓库
  - /tiebanshenshu/lib/repository/tiao_wen_repository.dart（抽象接口）
  - /tiebanshenshu/lib/repository/tiao_wen_repository_impl.dart（CSV 资源加载、并发安全、Map/List 双缓存、区间/间隔/搜索）
  - /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart（RepositoryFactory.defaultTiaoWenRepository 注入）
  - 常用方法：
    - getTiaoWenContentByNumbers(numbers)：批量取条文内容（Map<int,String>）
    - getByIdList、getByIdRange、getByIntervalAroundId、getAroundById、search 等
### 二十一、依赖注入与 UI 接入

- /tiebanshenshu/lib/infrastructure/di/strategy_providers.dart
  - 集中注册 Repository、Strategy、UseCase、ViewModel，提供全链路 DI。
  - 包含：四柱天干、太玄四柱、八卦加则、元堂卦、先后天加则、六爻干支合、卦爻干支合、先后天取数、前后卦、卦中、四门法、八卦滚法，以及皇极 V2、考刻、六亲考刻、考订六亲等特性线。
- UI 层
  - /tiebanshenshu/lib/presentation/viewmodels：每个算法配套的 ViewModel（管理输入与状态）
  - /tiebanshenshu/lib/presentation/models：UI 展示模型（把领域模型转为可读文本、表格与卡片）
  - /tiebanshenshu/lib/ui/pages/dev_page.dart：调试页面

### 二十二、八刻密数表（12时辰×8刻）

- 涉及代码文件
  - /tiebanshenshu/lib/constant/kao_ke_constants.dart（KaoKeConstants.keNumbers、EigthKe 枚举、KaoEigthKeNumber/KaoEigthKeTiaoWen）
  - /tiebanshenshu/lib/features/kao_ke/kao_ke_use_case.dart（prepareKeSelectionData、submitKeSelection、calculateGua）
  - /tiebanshenshu/lib/features/kao_ke/kao_ke_view_model.dart（initialize、selectKe、calculateFinalResults、状态管理）
  - /tiebanshenshu/lib/features/kao_ke/widgets/ke_selection_table.dart（UI：12×8 表格、出生时辰高亮、点击选择）
  - /tiebanshenshu/lib/repository/tiao_wen_repository.dart（取条文内容）
  - 可选参考：/tiebanshenshu/lib/constant/constants.dart（eightKeNumberMapper 重复映射，KaoKe 默认使用 KaoKeConstants 的版本）
- 核心概念与字段
  - cipherText（密数）：用于表格显示的密文短语
  - originalText（原文）：对应条文的原文提示或断语
  - tiaoWenNumber（条文编号）：作为基础数源，进入卦象与条文计算
- 计算/选择流程
  - 初始化会话后，ViewModel 调用 UseCase.prepareKeSelectionData()，返回 12 时辰 × 8 刻的完整数据（Map<DiZhi, List<KaoEigthKeNumber>）；
  - UI KeSelectionTable 展示密数表，用户点击某个刻单元格；
  - ViewModel.selectKe() 提交选择，生成 KeSelectionRecord，并自动调用 UseCase.calculateGua() 根据所选条文编号计算卦象；
  - 后续可切换计算方法（八卦加则、卦爻干支合），最终 UseCase.calculateFinalTiaoWen() 产出条文集合。
- 与条文扩展的关系
  - 八刻本身是“基础数来源”，扩展由考刻策略在后续方法中完成（如递增 96、±48×倍数、或策略固定组合）。
- 异常与注意
  - docs/code_review.md 有“八刻选择不完整/重复”的备注，请注意数据完整性与 UI 校验；
  - KaoKeConstants.keNumbers 为主数据，若维护 eightKeNumberMapper（constants.dart）请避免与 KaoKeConstants 重复或不一致。

### 二十三、斗甲乙宫（三宫之数）

- 涉及代码文件
  - /tiebanshenshu/lib/constant/kao_ke_constants.dart（DouJiaYiType、DouJiaYiNumber、eightKeNumberMapper 三宫映射）
  - /tiebanshenshu/lib/features/kao_ke/kao_ke_use_case.dart
    - _palaceTypeForShiChen：按出生时辰判定宫别（斗：子午卯酉；甲：辰戌丑未；乙：寅申巳亥）
    - prepareDouJiaYiSelectionDataForBirthShiChen：返回本宫四支 × 1-5 的条目
    - submitDouJiaYiSelection：按条文编号匹配并生成 DouJiaYiSelectionRecord
    - calculateGua/calculateFinalTiaoWen：将选择的条文编号作为 baseNumber 进入后续计算
  - /tiebanshenshu/lib/features/kao_ke/kao_ke_view_model.dart（initialize、selectDouJiaYiByNumber、toggleCalculationMethod、calculateFinalResults）
  - /tiebanshenshu/lib/features/kao_ke/widgets/dou_jia_yi_selection_table.dart（UI：本宫四支×序1-5，加载条文内容并点击选择）
  - /tiebanshenshu/lib/features/kao_ke/kao_ke_interactive_page.dart（输入条文编号预览与提交）
  - /tiebanshenshu/lib/repository/tiao_wen_repository.dart（批量加载条文内容用于 UI 预览）
  - 可选参考：/tiebanshenshu/lib/constant/constants.dart（doujiayiMapper 旧/通用映射）
- 选择与计算流程
  - ViewModel.initialize() 加载会话后，以出生时辰 birthShiChen 判定所属宫（斗/甲/乙），并准备 douJiaYiSelectionData；
  - 用户可在交互页直接输入条文编号，也可通过 DouJiaYiSelectionTable 点击选择；
  - 提交后生成 DouJiaYiSelectionRecord，推进阶段到 keSelected，与八刻选择共享同一后续流程；
  - UseCase.calculateGua() 基于 tiaoWenNumber 计算卦象；UseCase.calculateFinalTiaoWen() 依据所选方法生成条文集合。
- 数据结构要点
  - DouJiaYiNumber 包含 type（斗/甲/乙）、ke（地支：本宫四支之一）、order（序1-5）、tiaoWenNumber；
  - eightKeNumberMapper 的嵌套 Map 组织为 Map<DouJiaYiType, Map<DiZhi, List<DouJiaYiNumber>>>；
  - DouJiaYiTiaoWen 可与仓库数据结合以携带条文内容（在 UI 预加载使用）。
- 异常与注意
  - docs/code_review.md 有“斗甲乙宫索引越界”等提示；在提交编号时未匹配到本宫条目会抛出异常；
  - UI 侧 DouJiaYiSelectionTable 会尝试批量加载条文内容；若仓库未注入或读取失败，UI 仍可展示编号但内容可能显示“加载中”。

- 与考刻策略的关系
  - “八刻密数表”和“斗甲乙宫”都为考刻的基础数来源；KaoKeCalculationStrategyImpl 在拿到 baseNumber 后统一使用：
    - GuaCalculationHelper.calculateGua(baseNumber) 生成卦象；
    - BaGuaJiaZeStrategy / GuaYaoGanZhiHeStrategy 计算条文编号；
    - TiaoWenRepository 批量取回条文内容，组合为 TiaoWenResult 列表。

说明与后续

- 已将“八刻密数表”和“斗甲乙宫”补充进 summary.md，涵盖模型、常量、UseCase/ViewModel、UI 与仓库交互及与考刻策略的关系；
- 如需进一步展示某个宫或某个时辰的完整条目，请告知，我可追加具体条文编号与密数原文示例。