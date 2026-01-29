# 太玄四柱Interactive模式迁移 - 对齐文档

## 项目上下文分析

### 现有项目架构
- **技术栈**: Flutter + Dart
- **架构模式**: MVVM + UseCase + Strategy模式
- **依赖注入**: Provider模式
- **现有实现**: 已完成太玄四柱的Standard模式实现

### 现有太玄四柱实现分析
基于`service/real_case_5.dart`和现有MVVM架构：

1. **Legacy实现**: `TiaoWenNumberCalculationStrategy`类（已废弃）
2. **Standard实现**: `TaiXuanFourZhuStrategy` + `TaiXuanFourZhuTiaoWenListUseCase` + `TaiXuanFourZhuViewModel`
3. **核心算法**: `TaiXuanEachZhu`类实现太玄取数法逻辑

### 业务域理解
- **太玄取数法**: 基于四柱天干地支配卦，计算太玄数，生成条文列表
- **计算流程**: 四柱 → 配卦 → 纳甲 → 太玄数 → 四位数 → ±96生成条文
- **输出结果**: 四个基础条文数，每个数可扩展为多个条文

## 原始需求分析

### 用户需求
将现有的太玄四柱单向计算模式，迁移为支持用户参与的Interactive模式，具体功能包括：

1. **边界动态调整**: 支持动态调整计算边界
2. **自定义步长**: 支持±30、±1、±5等步长调整
3. **基于内容选择**: 用户可查看条文内容后选择
4. **多条文对比**: 一次展示多个候选条文
5. **中断恢复**: 支持会话保存和恢复
6. **撤销功能**: 支持操作回退
7. **跳转功能**: 支持直接跳转到指定条文
8. **全量展示**: 支持无限列表展示所有条文

### 技术要求
- 设计为"interactive"类型的特殊Strategy和UseCase
- 不是完全独立的模块，而是现有架构的扩展
- 保持与现有Standard模式的兼容性

## 边界确认

### 迁移范围
**包含**:
- 创建Interactive模式的核心接口和模型
- 创建`TaiXuanFourZhuInteractiveStrategy`
- 创建`TaiXuanFourZhuInteractiveUseCase`
- 创建`TaiXuanFourZhuInteractiveViewModel`
- 集成到现有的依赖注入系统
- 基础功能测试

**不包含**:
- UI层的具体实现（本次仅到ViewModel层）
- 其他Strategy的Interactive版本
- 会话持久化的具体存储实现
- 完整的测试用例（仅核心功能测试）

### 技术边界
- 复用现有的`TaiXuanEachZhu`算法逻辑
- 复用现有的`TiaoWenRepository`
- 扩展现有的配置系统
- 保持现有的错误处理机制

## 需求理解

### 对现有项目的理解
1. **架构成熟度**: 已有完整的MVVM+UseCase架构
2. **代码质量**: 有良好的分层和抽象
3. **扩展性**: 现有设计支持Strategy模式扩展
4. **测试覆盖**: 有基础的单元测试和集成测试

### Interactive模式的核心特点
1. **会话管理**: 需要维护用户交互状态
2. **动态配置**: 支持运行时调整参数
3. **候选管理**: 管理多个候选条文
4. **操作历史**: 支持撤销和重做
5. **流式数据**: 支持无限列表加载

## 疑问澄清

### 已明确的设计决策
1. **架构模式**: 扩展现有MVVM+UseCase模式
2. **命名规范**: 使用`Interactive`后缀区分
3. **配置系统**: 扩展现有配置类
4. **数据流**: 保持单向数据流原则
5. **会话持久化**: 使用内存存储（简化实现）
6. **默认配置**: 步长30，候选数量5，支持双向调整

### 技术实现方案

#### 核心组件设计
1. **InteractiveStrategyConfig**: 交互配置类
2. **InteractiveSession**: 会话状态管理
3. **TiaoWenCandidate**: 候选条文封装
4. **BaseInteractiveStrategy**: Interactive Strategy基类
5. **BaseInteractiveUseCase**: Interactive UseCase基类

#### 数据流设计