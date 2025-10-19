# 代码审阅与架构总览

说明：本文件对项目中策略演示入口、四门法V2与八卦滚法、皇极取数法V2、六亲考刻取数法/八刻秘数考刻法、考订六亲的核心代码结构、调用链与数据流进行结构化审阅，便于后续维护与扩展。

1. Strategy 演示入口页面 StrategyDemoPage
- 文件：presentation/pages/strategy_demo_page.dart
- 职责：统一演示与对比多种策略的计算结果；集中初始化各 ViewModel；提供“刷新当前/刷新全部”等交互。
- Tab 与 ViewModel 映射（12个）：
  - 日干支卦 DayGanZhiGuaViewModel（usecases/day_gan_zhi_gua_tiao_wen_list_use_case.dart）
  - 四柱天干 FourZhuTianGanViewModel（usecases/four_zhu_tian_gan_tiao_wen_list_use_case.dart）
  - 太玄四柱 TaiXuanFourZhuViewModel（usecases/tai_xuan_four_zhu_tiao_wen_list_use_case.dart；presentation/widgets/tai_xuan_dual_method_card.dart）
  - 八卦加则 BaGuaJiaZeViewModel（usecases/ba_gua_jia_ze_tiao_wen_list_use_case.dart）
  - 元堂 YuanTangViewModel（usecases/yuan_tang_tiao_wen_list_use_case.dart；presentation/models/yuan_tang_ui_model.dart）
  - 先后天加则 XianHoutianJiaZeViewModel（usecases/xian_houtian_jia_ze_tiao_wen_list_use_case.dart）
  - 六爻干支和 LiuYaoGanZhiHeViewModel（usecases/liu_yao_gan_zhi_he_tiao_wen_list_use_case.dart）
  - 卦爻干支和 GuaYaoGanZhiHeViewModel（usecases/gua_yao_gan_zhi_he_tiao_wen_list_use_case.dart）
  - 先后天取数 XianHoutianQuShuViewModel（usecases/xian_houtian_qu_shu_tiao_wen_list_use_case.dart）
  - 前后卦 QianHouGuaViewModel（usecases/qian_hou_gua_tiao_wen_list_use_case.dart）
  - 卦中 GuaZhongViewModel（usecases/gua_zhong_tiao_wen_list_use_case.dart）
  - 太玄四柱交互 TaiXuanFourZhuInteractiveViewModel（usecases/tai_xuan_four_zhu_interactive_use_case.dart）
- 依赖注入：infrastructure/di/strategy_providers.dart 提供全部 Strategy/UseCase/ViewModel 的 DI。
- 调用链通用模式：UI Widget -> ViewModel.refresh()/calculate() -> UseCase.execute() -> Strategy.calculate() -> Repository.getByIdList() -> UIModel构建 -> Widget渲染。

2. 四门法V2 与 八卦滚法
- 页面：presentation/pages/four_doors_and_gun_fa_page.dart（两个 Tab，四门法V2/八卦滚法）
- ViewModel：
  - SiMenFaViewModel（presentation/viewmodels/si_men_fa_view_model.dart）
    - UseCase：si_men_fa_tiao_wen_list_use_case.dart
    - Strategy/Calculator：service/strategy/si_men_fa_strategy.dart（SiMenFaStrategy、SiMenFaCalculator，依赖 MultiGuaCalculatorBase 与 TiaoWenNumberCalculator）
    - Domain 模型：domain/models/si_men_fa_base_number_model.dart
    - UI 模型：presentation/models/si_men_fa_ui_model.dart
  - BaGuaGunViewModel（presentation/viewmodels/ba_gua_gun_view_model.dart）
    - UseCase：ba_gua_gun_tiao_wen_list_use_case.dart
    - Strategy：service/strategy/ba_gua_gun_strategy.dart
    - Domain 模型：domain/models/ba_gua_gun_base_number_model.dart
    - UI 模型：presentation/models/ba_gua_gun_ui_model.dart（复用 SiMenFaUIModel 中的 GuaInfoUIModel、GuaThreeNumbersUIModel）
- 数据流（以四门法V2为例）：
  - 输入：EightChars + Gender + YuanYunOrder
  - Strategy 生成 fourGuaList、basic/variation 序列 -> 计算秘数/先天数 -> Final 条文列表 + SourceInfo。
  - UseCase 批量查询条文 Repository.getByIdList -> 封装 BaseNumberTiaoWenListModel。
  - ViewModel 合成 UIModel，提供统计与展示字段（basicGua、variationBase、fourGuaSummary、tiaoWenTotalCount）。
- 错误处理：Strategy 返回 BaseNumberModelResult.error，UseCase抛出异常，ViewModel设置 isLoading/error 并在页面上展示。

3. 皇极取数法 V2 新架构
- 核心文件：features/huang_ji/huang_ji_v2_session_models.dart、huang_ji_formula_v2.dart、huang_ji_v2_use_case.dart
- 会话/状态机：
  - SessionPhase：initialized -> yuanHuiYunShiCalculated -> baseNumberSelectionReady -> baseNumberSelected -> finalCalculationComplete
  - SessionStatus：notStarted/inProgress/waitingForSelection/paused/completed/cancelled/error
  - SessionSnapshot：记录阶段性快照，支持 rollbackToPhase。
- Formula/Converter：
  - HuangJiCalculationFormula（分组 CalculationGroup，围绕 BaseNumberDefinition）
  - BaseNumberDefinition：PredefinedBaseNumber、DerivedBaseNumber、SelectableBaseNumber（V2架构全部需用户选择）；CalculationPart：SingleNumberPart/CompositeNumberPart。
  - 多态 JSON 转换器，支持序列化持久化。
- UseCase：HuangJiV2UseCase
  - initializeSession：创建会话并计算 YuanHuiYunShi。
  - prepareBaseNumberSelection：收集唯一 BaseNumberDefinition，构建派生链，生成候选与条文内容，产出 BaseNumberSelectionRecord。
  - submitBaseNumberSelections：校验/更新用户选择。
  - calculateFinalTiaoWenList：遍历公式，基于选择计算条文并查询内容，生成 TiaoWenResult。
  - rollbackToPhase：通过 SessionManager 回滚到历史快照。
- 依赖：HuangJiSessionManager、HuangJiV2CalculationStrategy、TiaoWenRepository。

4. 六亲考刻取数法 与 八刻秘数考刻法（考刻）
- 交互页面：features/kao_ke/kao_ke_interactive_page.dart
  - 组件：KeSelectionTable（12时辰×8刻）、DouJiaYiSelectionTable（斗甲乙宫四支×1-5）、MethodSelector、GuaDisplay、FinalResultDisplay、TiaoWenDetailDialog。
- ViewModel：features/kao_ke/kao_ke_view_model.dart
  - 会话模型：features/kao_ke/kao_ke_session_models.dart
    - Phase：initialized -> keSelectionReady -> keSelected -> baseNumberCalculated -> finalCalculationComplete
    - Status：notStarted/inProgress/waitingForSelection/completed/cancelled/error
    - 选择记录：KeSelectionRecord（八刻）、DouJiaYiSelectionRecord（斗甲乙宫），最终 Map<Method, List<TiaoWenResult>>。
  - UseCase：features/kao_ke/kao_ke_use_case.dart（编排 SessionManager 与 Strategy，读取常量 KaoKeConstants）
  - Strategy：features/kao_ke/kao_ke_calculation_strategy_impl.dart
    - 计算步骤：由 baseNumber 计算卦（gua_calculation_helper.dart），按方法计算条文：
      - 八卦加则（service/strategy/ba_gua_jia_ze_strategy.dart）
      - 爻干支和数法（service/strategy/liu_yao_gan_zhi_he_strategy.dart，含 domain/models/gua_yao_gan_zhi_he_base_number_model.dart）
    - 查询条文内容：TiaoWenRepository
- “六亲考刻取数法”模块：features/liuqinkaoke/**
  - ViewModel：liuqinkaoke_view_model.dart
  - UseCase：liuqinkaoke_use_case.dart（协调 SessionManager）
  - SessionManager：liuqinkaoke_session_manager.dart（生成候选、完成选择、回滚、恢复最近会话；依赖 TiaoWenListCalculationConfig、middlePalaceFiveStrategy 等）
  - Strategy：liuqinkaoke_calculation_strategy.dart（默认实现 liuqinkaoke_default_strategy.dart）
- 数据流：用户选择八刻/斗甲乙宫刻 -> 计算卦象 -> 按所选方法计算条文 -> 查询条文内容 -> 整理结果展示。

5. 考订六亲
- 页面：features/kao_ding_liu_qin/pages/kao_ding_liu_qin_page.dart
- ViewModel：presentation/viewmodels/kao_ding_liu_qin_view_model.dart（状态：initial/loading/success/error；管理所有六亲类型结果、流度表条目、用户选择的条文、化卦与64卦结果、夫妻任次）
- UseCase：features/kao_ding_liu_qin/usecases/kao_ding_liu_qin_use_case.dart
  - 计算：KaoDingLiuQinStrategy.calculate -> 生成 KaoDingLiuQinResult -> 创建 SessionState 并保存到 SessionManager 历史
- Strategy：features/kao_ding_liu_qin/services/kao_ding_liu_qin_strategy.dart
  - 流程：起卦（features/six_yao_gua/pure_six_yao_gua.dart）-> 纳甲与六亲（NaJiaLiuQinHelper）-> 定位目标爻（父母/妻财等）-> 查流度表（repositories/liu_du_table_repository.dart）-> 生成结果（含所有候选条文与高亮条目）。
- 数据流：输入八字与选择柱/六亲类型/夫妻任次 -> 生成起卦与纳甲 -> 选中目标爻 -> 展示对应流度表并列出条文编号 -> 查询条文内容供 UI 展示。

6. 依赖与错误处理
- DI：infrastructure/di/strategy_providers.dart 统一提供 Strategy、UseCase、ViewModel、Repository、配置等。
- Repository：TiaoWenRepository/TiaoWenRepositoryImpl 负责条文内容查询；LiuDuTableRepository 负责考订六亲流度表。
- 错误处理：
  - Strategy 层返回 Result.error 或抛出异常；UseCase 捕获/再抛；ViewModel 通过 isLoading/error 状态反馈到 UI；页面统一使用 LoadingWidget/ErrorWidget 展示。
- 可扩展性：
  - 新策略接入：实现 BaseCalculationStrategy 或自定义 Strategy + UseCase + ViewModel + UIModel，注册 DI，接入演示页或交互页。
  - 会话化功能：参考皇极V2与考刻两套 SessionManager/SessionSnapshot 实现，支持阶段化推进、回滚与持久化。

7. 文件与类索引（非完整，重点）
- StrategyDemoPage：presentation/pages/strategy_demo_page.dart
- 四门法V2：service/strategy/si_men_fa_strategy.dart、usecases/si_men_fa_tiao_wen_list_use_case.dart、presentation/viewmodels/si_men_fa_view_model.dart、presentation/models/si_men_fa_ui_model.dart
- 八卦滚法：service/strategy/ba_gua_gun_strategy.dart、usecases/ba_gua_gun_tiao_wen_list_use_case.dart、presentation/viewmodels/ba_gua_gun_view_model.dart、presentation/models/ba_gua_gun_ui_model.dart
- 太玄四柱：presentation/widgets/tai_xuan_dual_method_card.dart、presentation/viewmodels/tai_xuan_four_zhu_view_model.dart
- 皇极V2：features/huang_ji/huang_ji_v2_session_models.dart、features/huang_ji/huang_ji_formula_v2.dart、features/huang_ji/huang_ji_v2_use_case.dart
- 考刻：features/kao_ke/kao_ke_interactive_page.dart、features/kao_ke/kao_ke_view_model.dart、features/kao_ke/kao_ke_use_case.dart、features/kao_ke/kao_ke_calculation_strategy_impl.dart、features/kao_ke/kao_ke_session_models.dart
- 六亲考刻取数法：features/liuqinkaoke/viewmodels/liuqinkaoke_view_model.dart、features/liuqinkaoke/usecase/liuqinkaoke_use_case.dart、features/liuqinkaoke/usecase/liuqinkaoke_session_manager.dart、features/liuqinkaoke/strategy/liuqinkaoke_calculation_strategy.dart
- 考订六亲：features/kao_ding_liu_qin/pages/kao_ding_liu_qin_page.dart、presentation/viewmodels/kao_ding_liu_qin_view_model.dart、features/kao_ding_liu_qin/usecases/kao_ding_liu_qin_use_case.dart、features/kao_ding_liu_qin/services/kao_ding_liu_qin_strategy.dart、features/kao_ding_liu_qin/repositories/liu_du_table_repository.dart

结论：项目以“Strategy -> UseCase -> ViewModel -> UIModel/Widget”的分层为主线，配合 Session 化与 DI 体系，形成清晰的调用链与数据流。新增与调整策略时，遵循该模式即可快速集成与演示。