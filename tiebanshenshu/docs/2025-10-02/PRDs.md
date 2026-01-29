# 铁板神数（tiebanshenshu）PRD初稿（2025-10-02）

## 概述
- 本PRD基于当前仓库`tiebanshenshu`代码现状与已实现模块，结合“皇极取数法”“太玄四柱”“多基数选择”等交互页面与策略逻辑，拟定MVP范围与阶段性目标。
- 产品形态：Flutter应用（可同时支持移动端与Web构建）。
- 当前入口与路由：`lib/navigator.dart`中定义`/tiebanshenshu/huang_ji`、`/tiebanshenshu/tai_xuan`、`/tiebanshenshu/multi_selection`、`/tiebanshenshu/strategy_demo`等；`lib/main.dart`集成`MultiProvider`与`timezone`初始化。

## 目标 / Objectives（MVP）
- 核心：提供“皇极取数法”与“太玄四柱”的交互式排盘与结果展示，支持多基数选择流程；确保关键策略计算正确、流程可用、页面稳定。
- SMART示例：
  - 在2周内完成MVP：包含“皇极交互”“太玄交互”“多基数选择”三页面的稳定发布；
  - 关键计算正确率≥95%（以现有测试用例为准，如`integration/huang_ji_formula_v2_integration_test.dart`与`strategy/huang_ji_strategy_test.dart`通过率）；
  - 页面加载与交互响应时间≤1s（常规设备与网络）；
  - 基本错误处理与提示覆盖≥90%的常见输入与计算异常。

## 用户 / Personas
- 入门用户：希望快速体验“铁板神数”的核心方法、查看排盘与解释提示。
- 从业者/研究者：需要更透明的计算过程、策略步骤展示、便捷查看结果与案例。

## 用户故事 / Use Cases
- 作为入门用户，我可以在“皇极交互”页面输入必要信息（出生时辰/八字等），获得结果展示与简单解释。
- 作为研究者，我可以在“太玄四柱交互”中逐步查看步骤进度（Step Indicator）、中间状态与最终结果。
- 作为用户，我可以在“多基数选择”中选择多个基数（如元会运势维度），并在完成后回到上层流程继续计算或查看结果。
- 作为用户，我遇到错误或数据不足时，可以看到明确的错误提示并重试。

## 功能需求 / Functional Requirements
- 路由与导航：
  - 定义并可达的路由：`/tiebanshenshu/huang_ji`、`/tiebanshenshu/tai_xuan`、`/tiebanshenshu/multi_selection`、`/tiebanshenshu/strategy_demo`。
  - 支持从`/dev`或首页快速进入各模块演示页面。
- 交互页面：
  - 皇极交互：使用`HuangJiInteractiveViewModel`进行状态管理，包含初始化/加载/错误/完成/交互态；显示`HuangJiSessionHeader`、`HuangJiStepIndicator`、`HuangJiResultWidget`等组件。
  - 太玄交互：使用`TaiXuanFourZhuInteractiveViewModel`，支持动画与进度展示，显示初始化/错误/加载/完成/交互内容。
  - 多基数选择：使用`MultiBaseNumberSelectionViewModel`与`YuanHuiYunShi`数据，包含初始化/加载/错误/内容态，提供完成/取消回调。
- 策略与计算：
  - 复用现有策略服务与模型（如`EightChars`），确保与测试用例一致。
  - 对异常输入与缺失数据进行校验并提示。
- 数据与资源：
  - 访问`assets/`中公式/词条等必要资源；
  - 如有`web/`构建静态资源，确保正确加载。
- 错误处理：
  - 页面级错误与网络/资源加载错误提示统一处理；
  - 异常状态下支持重试或返回。

## 非功能需求 / Non-Functional Requirements
- 性能：首屏与操作响应≤1s；策略计算在常规设备上≤500ms。
- 可用性：清晰的步骤指示与状态切换；错误信息可读。
- 可靠性：关键集成与单测通过；CI构建稳定。
- 安全性：本地计算为主；如涉及外部数据，需最小权限与校验。
- 可维护性：ViewModel与UI分层清晰；路由集中管理；测试覆盖关键流程。
- 兼容性：Flutter移动端与Web；考虑不同分辨率布局。

## 设计考虑 / Design Considerations
- 组件化：Header/StepIndicator/Result等可复用组件。
- 交互引导：逐步展示计算过程，提供返回与重试。
- 文案与多语言：若需多语言，抽取文案至资源文件；默认中文。

## 成功指标 / Success Metrics
- 测试通过率：现有测试（集成+策略）通过率≥95%。
- 性能指标：TTI≤1s，核心计算≤500ms。
- 错误率：用户可见错误发生率≤2%（常规操作）。
- 留存与使用：交互页面完播率≥60%，二次使用率≥30%。

## 开放问题 / Open Questions
- 是否需要离线模式与持久化案例库？
- 是否需要多语言支持与国际化？
- 是否需要与其他子项目联动（`taiyishenshu`、`qimendunjia`等）中的数据或路由？
- 是否需提供更详细的断语与解释模块（教学/说明）？

## 假设 / Assumptions
- 当前MVP以`tiebanshenshu`的三模块为核心；
- 以现有测试与UI结构为准进行迭代；
- 时间约束为2周MVP，后续再扩展案例库与教学模块。