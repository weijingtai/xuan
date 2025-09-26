# HuangJi Interactive Strategy重构 - 共识文档

## 需求描述

### 核心问题
`HuangJiInteractiveStrategy` 严重违反了Strategy层的架构原则，包含了大量与baseNumber计算无关的代码逻辑，需要进行彻底重构以恢复架构的纯净性。

### 具体问题
1. **Session管理逻辑**: `_sessions`、`startSession`、`getSession`等方法
2. **Repository依赖**: 直接注入和使用`TiaoWenRepository`
3. **用户交互流程**: `getCandidates`、`selectCandidate`、`getNextStep`等方法
4. **候选项生成逻辑**: `_generateUserSelectionCandidates`、`_generateBaseNumberCandidates`等方法
5. **状态管理**: `jumpTo`、`undo`、`adjustStep`等方法

### 重构目标
**完全移除`HuangJiInteractiveStrategy`**，将所有Interactive逻辑重新分配到合适的架构层次。

## 验收标准

### 主要验收标准
1. **Strategy层纯净化**
   - ✅ 删除`HuangJiInteractiveStrategy`类
   - ✅ 所有baseNumber计算直接使用`HuangJiCalculationStrategy`
   - ✅ Strategy层不包含任何Session管理、用户交互、Repository依赖

2. **Interactive逻辑重新分配**
   - ✅ Session管理移至UseCase层
   - ✅ 候选项生成移至UseCase层
   - ✅ 用户交互流程移至UseCase层
   - ✅ Repository依赖移至UseCase层

3. **向后兼容性**
   - ✅ 现有Interactive API保持兼容
   - ✅ 现有调用方式不受影响
   - ✅ 功能行为保持一致

4. **代码质量**
   - ✅ 编译通过，无错误
   - ✅ 现有测试通过
   - ✅ 代码结构清晰，职责明确

## 技术实现方案

### 架构重新设计


### 核心组件设计

#### 1. HuangJiInteractiveUseCase (新建)
- **职责**: 协调Interactive业务流程
- **功能**: Session管理、候选项生成、用户交互协调
- **依赖**: `HuangJiCalculationStrategy`、`InteractiveSessionService`、`TiaoWenRepository`

#### 2. InteractiveSessionService (新建)
- **职责**: 专门的Session管理服务
- **功能**: Session CRUD、状态管理、生命周期管理
- **特点**: 无业务逻辑，纯粹的Session管理

#### 3. HuangJiCalculationStrategy (保持不变)
- **职责**: 纯粹的baseNumber计算
- **特点**: 无状态、无依赖、纯函数式

### 迁移策略
1. **创建新组件**: 先创建`HuangJiInteractiveUseCase`和`InteractiveSessionService`
2. **迁移逻辑**: 将Interactive逻辑从Strategy迁移到UseCase
3. **更新调用**: 修改现有调用方，从Strategy改为UseCase
4. **删除旧代码**: 删除`HuangJiInteractiveStrategy`
5. **测试验证**: 确保功能完整性和兼容性

## 技术约束

### 必须遵守的约束
1. **Strategy层纯净性**: Strategy只能包含baseNumber计算逻辑
2. **现有接口兼容**: 不能破坏现有的API接口
3. **功能完整性**: 所有Interactive功能必须保持完整
4. **性能要求**: 重构后性能不能下降

### 技术栈约束
- 使用现有的Dart/Flutter技术栈
- 遵循现有的MVVM+UseCase架构模式
- 复用现有的数据模型和Repository接口
- 保持现有的异常处理机制

## 集成方案

### 与现有系统的集成点
1. **ViewModel层**: 修改调用方式，从Strategy改为UseCase
2. **Repository层**: 保持现有接口不变
3. **数据模型**: 复用现有的模型定义
4. **异常处理**: 保持现有的异常类型和处理方式

### 依赖关系



## 任务边界限制

### 包含的任务
- 删除`HuangJiInteractiveStrategy`类
- 创建`HuangJiInteractiveUseCase`类
- 创建`InteractiveSessionService`类
- 迁移所有Interactive逻辑
- 更新相关调用方
- 更新相关测试

### 不包含的任务
- 修改`HuangJiCalculationStrategy`的计算逻辑
- 修改现有的数据模型定义
- 修改Repository接口
- 修改UI层的实现
- 添加新的Interactive功能

## 风险评估

### 主要风险
1. **兼容性风险**: 可能影响现有调用方
2. **功能完整性风险**: 可能遗漏某些Interactive功能
3. **性能风险**: 新架构可能影响性能

### 风险缓解措施
1. **渐进式迁移**: 分步骤进行，每步都验证
2. **完整测试**: 确保所有功能都有测试覆盖
3. **性能监控**: 重构过程中监控性能指标

## 验收检查清单

### 代码质量检查
- [ ] 编译通过，无语法错误
- [ ] 所有现有测试通过
- [ ] 代码符合项目规范
- [ ] 无未使用的导入和变量

### 功能完整性检查
- [ ] 所有Interactive功能正常工作
- [ ] Session管理功能完整
- [ ] 候选项生成正确
- [ ] 用户交互流程正常

### 架构合规性检查
- [ ] Strategy层只包含计算逻辑
- [ ] UseCase层正确协调业务流程
- [ ] Service层正确管理Session
- [ ] 依赖关系清晰合理

### 兼容性检查
- [ ] 现有API接口保持兼容
- [ ] 现有调用方式正常工作
- [ ] 数据格式保持一致
- [ ] 异常处理保持一致