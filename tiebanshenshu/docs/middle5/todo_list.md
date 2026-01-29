# “中五宫”取数策略 TODO 列表

本项目旨在将“中五宫（取5）”的特殊取数规则封装成一个可复用、可扩展的策略模块。

## 里程碑 A: 定义策略接口与实现

- [x] 在 `lib/service/strategy/` 目录下创建 `middle_palace_five_strategy.dart` 文件。
- [x] 在文件中定义抽象类 `MiddlePalaceFiveStrategy`，包含一个 `getGua` 方法。
- [x] 创建 `DefaultMiddlePalaceFiveStrategy` 类，实现 `MiddlePalaceFiveStrategy` 接口。
- [x] 在 `DefaultMiddlePalaceFiveStrategy` 的 `getGua` 方法中，完整实现基于上/中/下三元、性别和阴阳的判断逻辑。

## 里程碑 B: 集成策略

- [x] 修改 `LiuQinKaoKeCalculationStrategy`，在构造函数中注入 `MiddlePalaceFiveStrategy`。
- [x] 修改 `LiuQinKaoKeCalculationStrategy` 的 `_getTopGua` 和 `_getBottomGua` 方法：当余数为5时，调用注入的策略来获取卦象。
- [x] 确保 `YuanYunOrder`（三元）作为参数正确传递给策略（从 `SessionManager` 开始传递）。

## 里程碑 C: 配置依赖注入

- [x] 在 `infrastructure/di/strategy_providers.dart` 中，为 `MiddlePalaceFiveStrategy` 添加 Provider，使其默认使用 `DefaultMiddlePalaceFiveStrategy`。
- [x] 更新 `LiuQinKaoKeCalculationStrategy` 的 Provider，将新的 `MiddlePalaceFiveStrategy` 依赖注入进去。

## 里程碑 D: 验证与清理

- [ ] 重新运行测试，确保在余数为5时，程序能够正确执行新策略而不崩溃。
- [ ] （可选）为新的 `DefaultMiddlePalaceFiveStrategy` 添加独立的单元测试。
