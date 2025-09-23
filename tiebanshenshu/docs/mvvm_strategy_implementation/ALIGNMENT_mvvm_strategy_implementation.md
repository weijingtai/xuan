# MVVM+UseCase Strategy实现 - 对齐文档

## 项目上下文分析

### 现有项目架构
- **技术栈**: Flutter + Dart
- **架构模式**: 已有部分MVVM实现（如`DevEnterPageViewModel`、`ShiJiaQiMenViewModel`）
- **Strategy模式**: 已实现`BaseCalculationStrategy`、`StandardCalculationStrategy`基类
- **Repository模式**: 已实现`TiaoWenRepository`和`TiaoWenRepositoryImpl`
- **数据层**: 使用CSV文件存储条文数据，通过Repository访问

### 现有Strategy实现分析
1. **DayGanZhiGuaStrategy**: 日柱变卦取数法 - 已实现基础计算逻辑
2. **FourZhuTianGanStrategy**: 四柱天干取数法 - 已实现基础计算逻辑  
3. **TaiXuanFourZhuStrategy**: 太玄取数法 - 已实现基础计算逻辑

### 条文计算相关组件
- **TiaoWenListCalculator**: 通用条文列表计算策略
- **TiaowenCalculator**: 条文计算工具类（已标记为Deprecated）
- **TiaoWenRepository**: 条文数据访问接口

## 原始需求分析

用户要求：
> 请使用 mvvm+usecase 实现DayGanZhiGuaStrategy、FourZhuTianGanStrategy、TaiXuanFourZhuStrategy 同时当 usecase 根*Strategy 获得baseNumber 之后 通过调用 tiao_wen_list_calculation 以及 repository 获取所有的条文条目

## 需求理解确认

### 核心需求
1. **架构重构**: 将现有Strategy实现重构为MVVM+UseCase架构
2. **UseCase层**: 创建UseCase层来协调Strategy、TiaoWenListCalculation和Repository
3. **ViewModel层**: 创建ViewModel来管理UI状态和业务逻辑调用
4. **完整流程**: Strategy计算baseNumber → UseCase调用条文列表计算 → Repository获取条文数据

### 技术实现要点
1. **Strategy层**: 保持现有Strategy接口，专注于baseNumber计算
2. **UseCase层**: 新增UseCase层，负责：
   - 调用Strategy获取baseNumber
   - 使用TiaoWenListCalculation计算条文ID列表
   - 通过Repository获取具体条文数据
3. **ViewModel层**: 管理UI状态，调用UseCase，处理异步操作
4. **数据流**: ViewModel → UseCase → Strategy + TiaoWenListCalculation + Repository

### 边界确认
- **范围**: 仅针对三个指定Strategy的MVVM+UseCase实现
- **保持兼容**: 不破坏现有Strategy接口和Repository实现
- **新增组件**: UseCase层和对应的ViewModel

## 疑问澄清

### 已通过代码分析解决的疑问
1. ✅ **Strategy接口**: 已确认现有`StandardCalculationStrategy`基类结构
2. ✅ **Repository接口**: 已确认`TiaoWenRepository`提供的数据访问方法
3. ✅ **条文计算**: 已确认`TiaoWenListCalculator`的使用方式
4. ✅ **项目结构**: 已了解tiebanshenshu模块的目录组织

### 需要确认的技术细节
1. **UseCase命名规范**: 建议使用`Get[Strategy]TiaoWenListUseCase`格式
2. **ViewModel命名规范**: 建议使用`[Strategy]ViewModel`格式
3. **条文列表计算配置**: 需要确认每个Strategy使用的具体计算配置（如递增次数、因子等）
4. **错误处理策略**: UseCase和ViewModel的异常处理方式

## 最终理解

### 实现目标
为三个Strategy（DayGanZhiGuaStrategy、FourZhuTianGanStrategy、TaiXuanFourZhuStrategy）创建完整的MVVM+UseCase架构，实现从用户输入到条文数据展示的完整数据流。

### 技术方案
1. **保持现有Strategy**: 不修改现有Strategy实现，仅作为UseCase的依赖
2. **新增UseCase层**: 创建专门的UseCase类处理业务逻辑编排
3. **新增ViewModel层**: 创建对应的ViewModel管理UI状态
4. **集成现有组件**: 充分利用现有的TiaoWenListCalculator和Repository

### 验收标准
1. 每个Strategy都有对应的UseCase和ViewModel
2. UseCase能够正确调用Strategy、TiaoWenListCalculation和Repository
3. ViewModel能够管理异步操作和UI状态
4. 保持现有代码的兼容性
5. 提供完整的错误处理机制


#### 集成方案
- 扩展现有的`StrategyProviders`配置
- 新增Interactive相关的Provider
- 保持与Standard模式的并行支持

## 验收标准

### 功能验收
- [ ] 支持基础条文计算和展示
- [ ] 支持步长调整（±30、±1、±5）
- [ ] 支持候选条文列表展示
- [ ] 支持条文选择确认
- [ ] 支持操作撤销
- [ ] 支持跳转到指定条文
- [ ] 支持会话状态管理

### 技术验收
- [ ] 代码编译通过
- [ ] 单元测试通过
- [ ] 集成测试通过
- [ ] 与现有架构无冲突
- [ ] 依赖注入配置正确
- [ ] 错误处理完善

### 质量验收
- [ ] 代码符合项目规范
- [ ] 注释完整清晰
- [ ] 性能表现良好
- [ ] 内存使用合理
- [ ] 无明显技术债务

## 风险评估

### 技术风险
- **中等**: 会话状态管理的复杂性
- **低**: 与现有架构的集成
- **低**: 性能影响

### 时间风险
- **预估工作量**: 2-3天
- **关键路径**: Interactive基类设计 → 具体实现 → 集成测试

### 依赖风险
- **低**: 主要依赖现有组件，风险可控