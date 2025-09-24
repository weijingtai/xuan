# 皇极交互调试运行指南

## 快速调试步骤

### 1. 准备调试环境

```bash
# 确保在项目根目录
cd /Users/jingtaiwei/Git/Public/xuan

# 清理构建缓存
flutter clean

# 获取依赖
flutter pub get
```

### 2. 运行调试版本

```bash
# 启动调试模式
flutter run --debug

# 或者使用特定设备
flutter run --debug -d chrome
```

### 3. 触发问题场景

1. 启动应用后，导航到皇极交互页面
2. 路由：`/huang-ji-interactive`
3. 观察控制台输出的调试日志

### 4. 日志分析

查找以下关键日志序列：

🚀 HuangJiInteractiveViewModel: 开始启动会话
📊 输入八字: [八字信息]
✅ HuangJiInteractiveViewModel: 参数保存完成
🔧 HuangJiInteractiveViewModel: 计算参数创建完成
📞 HuangJiInteractiveViewModel: 调用UseCase.startSession
🚀 HuangJiInteractiveUseCase: 开始启动会话
📊 输入参数: [参数信息]
✅ HuangJiInteractiveUseCase: 参数验证完成
📞 HuangJiInteractiveUseCase: 调用Strategy.startSession
🚀 HuangJiInteractiveStrategy: 开始启动会话
📊 输入参数: [参数信息]
✅ HuangJiInteractiveStrategy: 参数验证完成
🆔 HuangJiInteractiveStrategy: 会话ID生成: [会话ID]
🔧 HuangJiInteractiveStrategy: 开始标准策略计算
🚀 HuangJiCalculationStrategy: 开始计算
📊 输入八字: [八字信息]
✅ HuangJiCalculationStrategy: 参数验证完成
🔧 HuangJiCalculationStrategy: 开始计算初刻数
✅ HuangJiCalculationStrategy: 初刻数计算完成: [数值]
🔧 HuangJiCalculationStrategy: 开始计算次条文数
✅ HuangJiCalculationStrategy: 次条文数计算完成: [数值]
🔧 HuangJiCalculationStrategy: 开始计算最终条文数列表
✅ HuangJiCalculationStrategy: 最终条文数计算完成: [数值列表]
🔧 HuangJiCalculationStrategy: 构建计算步骤详情
✅ HuangJiCalculationStrategy: 计算步骤构建完成
🎉 HuangJiCalculationStrategy: 计算成功完成
✅ HuangJiInteractiveStrategy: 标准策略计算完成
📊 初刻数: [数值]
📊 次条文数: [数值]
🔧 HuangJiInteractiveStrategy: 创建会话对象
✅ HuangJiInteractiveStrategy: 会话对象创建完成
📊 会话状态: [状态]
🔧 HuangJiInteractiveStrategy: 存储会话
✅ HuangJiInteractiveStrategy: 会话存储完成
📊 当前会话数量: [数量]
🎉 HuangJiInteractiveStrategy: 会话启动成功
✅ HuangJiInteractiveUseCase: Strategy.startSession 完成
🆔 会话ID: [会话ID]
📊 会话状态: [状态]
🎉 HuangJiInteractiveUseCase: 会话启动成功
✅ HuangJiInteractiveViewModel: UseCase.startSession 完成
🆔 会话ID: [会话ID]
📊 会话状态: [状态]
✅ HuangJiInteractiveViewModel: 会话状态更新完成
🔍 needsUserSelection: [true/false]
📋 currentStep: [步骤]
🎉 HuangJiInteractiveViewModel: 会话启动完成



### 5. 问题诊断

#### 5.1 如果日志在某个步骤停止
- 记录最后一条成功日志
- 查看是否有错误日志（❌ 开头）
- 检查对应组件的实现

#### 5.2 如果出现错误日志
- 记录完整的错误信息
- 查看错误类型和堆栈信息
- 根据错误类型定位问题

#### 5.3 如果日志完整但UI仍显示"准备中"
- 检查状态管理是否正确
- 验证`notifyListeners()`是否被调用
- 检查UI组件的状态判断逻辑

### 6. 常见问题排查

#### 6.1 计算阻塞
如果日志停在计算阶段：
- 检查八字数据是否有效
- 验证计算逻辑是否有死循环
- 查看是否有数据访问异常

#### 6.2 会话创建失败
如果日志停在会话创建阶段：
- 检查会话ID生成是否正常
- 验证会话存储是否成功
- 查看内存或存储空间是否充足

#### 6.3 状态更新失败
如果日志完整但UI未更新：
- 检查Provider是否正确注册
- 验证Consumer是否正确监听
- 查看状态变更是否触发重建

### 7. 测试验证

运行调试测试：

```bash
# 运行调试测试
flutter test test/debug/huang_ji_debug_test.dart

# 运行所有测试
flutter test
```

### 8. 问题报告

如果发现问题，请记录：
- 完整的控制台日志
- 问题复现步骤
- 设备和环境信息
- 预期行为vs实际行为

## 调试完成后

1. 确认问题已解决
2. 移除或简化调试日志
3. 更新相关文档
4. 提交代码修改