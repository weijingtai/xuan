# 奇门遁甲模块 - 产品需求文档 (PRD)

## 1. 产品概述

### 1.1 产品定位
奇门遁甲模块是玄学应用的核心占卜模块之一，实现了中国传统奇门遁甲术数系统。该模块提供了完整的奇门遁甲起盘、排盘、判断功能，支持多种起盘方式和展示模式。

### 1.2 核心功能
- **多种起盘方式**：支持拆补法、置润法、茅山法、阴盘法四种起盘方式
- **双盘式支持**：支持转盘奇门和飞盘奇门两种盘式
- **完整排盘系统**：实现天盘、地盘、人盘、神盘的完整排布
- **格局判断**：自动识别各种奇门格局（如伏吟、反吟、三奇得使等）
- **克应分析**：提供十干克应、八门克应、门星克应等多维度分析
- **旺衰判断**：计算各宫位元素的旺衰状态

## 2. 技术架构

### 2.1 双架构实现

本项目提供**两套完整的架构实现**，功能相同但设计理念不同：

#### 2.1.1 传统架构 (路由: `/qimendunjia`)
**设计特点:**
- 简单直接的 ViewModel + View 模式
- 业务逻辑集中在 ViewModel 中
- 适合快速开发和原型验证

**架构层级:**
- **展示层**: Flutter Widget (primary_page.dart, shi_jia_qi_men_view_page.dart)
- **状态管理**: Provider (ShiJiaQiMenViewModel)
- **业务逻辑**:
  - 起局计算器 (QiMenJuCalculator)
  - 奇门盘模型 (ShiJiaQiMen)
  - 工具类 (ArrangePlateUtils, NineYiUtils等)
- **数据层**: JSON数据文件 + 枚举定义

#### 2.1.2 MVVM + UseCase 架构 (路由: `/qimendunjia/mvvm`)
**设计特点:**
- Clean Architecture 分层设计
- Domain层独立，不依赖外层
- UseCase 封装单一业务场景
- Repository 模式分离数据层
- 高度可测试和可维护

**架构层级:**

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  ┌────────────────────────────────────┐ │
│  │  QiMenMvvmPage (UI)                │ │
│  │          ↓                         │ │
│  │  QiMenViewModel (State)            │ │
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│           Domain Layer                  │
│  ┌────────────────────────────────────┐ │
│  │  UseCases (Business Logic)         │ │
│  │  • CalculateJuUseCase              │ │
│  │  • ArrangePanUseCase               │ │
│  │  • SelectGongUseCase               │ │
│  │          ↓                         │ │
│  │  Repository Interfaces             │ │
│  │  • QiMenCalculatorRepository       │ │
│  │  • QiMenDataRepository             │ │
│  │          ↓                         │ │
│  │  Entities (Domain Models)          │ │
│  │  • QiMenPan, EachGong, ShiJiaJu   │ │
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│            Data Layer                   │
│  ┌────────────────────────────────────┐ │
│  │  Repository Implementations        │ │
│  │  • QiMenCalculatorRepositoryImpl   │ │
│  │  • QiMenDataRepositoryImpl         │ │
│  │          ↓                         │ │
│  │  DataSources                       │ │
│  │  • JsonDataSource (JSON files)    │ │
│  │  • CalculatorDataSource (计算器)   │ │
│  │  • CacheDataSource (缓存)         │ │
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│      Dependency Injection               │
│  ServiceLocator (管理所有依赖)          │
└─────────────────────────────────────────┘
```

**核心组件:**

1. **Domain Layer** (`lib/domain/`)
   - **Entities**: 纯业务实体，不依赖框架
     - `QiMenPan`: 奇门盘实体
     - `EachGong`: 宫位实体
     - `ShiJiaJu`: 局信息实体
   - **Repository Interfaces**: 定义数据操作契约
     - `QiMenCalculatorRepository`: 计算器仓储接口
     - `QiMenDataRepository`: 数据仓储接口
   - **UseCases**: 封装单一业务场景
     - `CalculateJuUseCase`: 计算局数用例
     - `ArrangePanUseCase`: 排盘用例
     - `SelectGongUseCase`: 选择宫位用例

2. **Data Layer** (`lib/data/`)
   - **DataSources**: 数据源实现
     - `JsonDataSource`: JSON文件读取
     - `ChaiBuCalculatorDataSource`: 拆补法计算器
     - `ZhiRunCalculatorDataSource`: 置润法计算器
     - `MaoShanCalculatorDataSource`: 茅山法计算器
     - `YinPanCalculatorDataSource`: 阴盘法计算器
     - `CacheDataSource`: 内存缓存
   - **Repository Implementations**: 仓储接口实现
     - `QiMenCalculatorRepositoryImpl`
     - `QiMenDataRepositoryImpl`

3. **Presentation Layer** (`lib/presentation/`)
   - **ViewModels**: 状态管理
     - `QiMenViewModel`: 奇门遁甲ViewModel
       - 状态: initial/calculating/arranging/success/error
       - 方法: calculateAndArrangePan(), selectGong(), reset()
   - **Views**: UI页面
     - `QiMenMvvmPage`: MVVM架构UI页面
       - 架构标识展示
       - 配置选择界面
       - 状态可视化
       - 盘信息展示

4. **Dependency Injection** (`lib/di/`)
   - **ServiceLocator**: 依赖注入容器
     - 注册所有 DataSources
     - 注册所有 Repositories
     - 注册所有 UseCases
     - 提供 ViewModel 工厂方法

### 2.1.3 架构对比

| 特性 | 传统架构 | MVVM+UseCase架构 |
|------|----------|------------------|
| **学习曲线** | 低 | 中 |
| **代码复杂度** | 低 | 中 |
| **可测试性** | 一般 | 优秀 |
| **可维护性** | 一般 | 优秀 |
| **解耦程度** | 中 | 高 |
| **业务复用** | 困难 | 容易 |
| **适用场景** | 小型项目 | 中大型项目 |
| **团队协作** | 一般 | 优秀 |

### 2.1.4 架构选择入口

应用启动后会显示**架构选择页面** (ArchitectureSelectionPage)，用户可以选择:
- 蓝色卡片: 传统架构版本
- 绿色卡片: MVVM+UseCase版本

两套架构完全独立运行，互不干扰，便于学习和对比。

### 2.2 核心模型

#### 2.2.1 ShiJiaJu (时家局)
起局结果模型，包含：
- 局数 (juNumber)
- 阴阳遁 (yinYangDun)
- 符头甲子 (fuTouJiaZi)
- 节气信息 (jieQi)
- 四柱八字 (fourZhuEightChar)
- 三元 (atThreeYuan)

#### 2.2.2 ShiJiaQiMen (时家奇门盘)
完整盘局模型，包含：
- 基础信息：盘类型、起盘方式、寄宫类型
- 时间信息：年月日时四柱、空亡信息
- 值符值使：值符星、值使门及落宫
- 宫位信息：九宫配置 (gongMapper)
- 旺衰信息：各宫旺衰状态 (gongWangShuaiMapper)
- 格局信息：伏吟反吟判断、特殊格局

#### 2.2.3 EachGong (单宫信息)
每个宫位的详细配置：
- 九星 (star: NineStarsEnum)
- 八门 (door: EightDoorEnum)
- 八神 (god: EightGodsEnum)
- 天盘干 (tianPan: TianGan)
- 地盘干 (diPan: TianGan)
- 天盘暗干 (tianPanAnGan)
- 人盘暗干 (renPanAnGan)
- 隐干 (yinGan)
- 寄干 (tianPanJiGan, diPanJiGan)

### 2.3 核心算法

#### 2.3.1 起局算法
**拆补法 (ChaiBuCalculator)**:
1. 根据节气确定阴阳遁
2. 根据日干支确定符头（甲己为符头）
3. 根据符头地支确定三元
4. 查表得到局数

**置润法 (ZhiRunCalculator)**:
1. 找到上一个正授冬至时间
2. 计算时间差，判断阴阳遁
3. 处理超神、接气、置润情况
4. 每5天一元，循环36元

**茅山法 (MaoShanCalculator)**:
1. 根据节气确定阴阳遁和局数
2. 前180时辰为上元，180-360为中元，360+为下元
3. 超出360时辰重复下元

**阴盘法 (YinPanCalculator)**:
1. 局数 = (年支序数 + 月数 + 日数 + 时支序数) % 9
2. 冬至后阳遁，夏至后阴遁

#### 2.3.2 排盘算法

**转盘奇门 (calculateZhuanPan)**:
1. 排地盘：根据局数排布三奇六仪
2. 排天盘：值符星加时干，顺时针转动
3. 排八门：值使门加时支，根据阴阳遁顺逆排布
4. 排八神：值符神加地盘旬首
5. 处理中五宫寄宫

**飞盘奇门 (calculateFeiPan)**:
1. 地盘同转盘
2. 天盘：按1-9顺序或逆序飞布
3. 八门：按九宫顺序飞布
4. 八神：天盘神加值符，地盘神加旬首

#### 2.3.3 格局判断

**伏吟反吟判断**:
- 星伏吟：九星落回本宫
- 星反吟：九星与对宫交换
- 门伏吟：八门落回本宫
- 门反吟：八门与对宫交换
- 干伏吟：天地盘干相同
- 干反吟：天地盘干与对宫相反

**常见格局识别** (EnumMostPopularGeJu):
- 青龙回首、飞鸟跌穴、玉女守门
- 三奇得使、奇游禄位、门迫、门墓
- 六仪击刑、时干入墓、日干入墓
- 三诈、六仪击刑、伏吟反吟

### 2.4 旺衰系统

#### 2.4.1 门旺衰判断
- **月令判断**: 月令主气五行与八门五行生克关系
- **宫内判断**: 宫卦五行与八门五行生克关系
- **入墓判断**: 判断门是否入墓

#### 2.4.2 星旺衰判断
- **月令判断**: 月令主气干纳甲换卦与星五行论生克
- **宫内判断**: 宫内地支主气与星五行论生克

#### 2.4.3 干旺衰判断
- **月令判断**: 十二长生表状态（长生、沐浴等）
- **宫内判断**: 天盘干与地盘干生克比和关系
- **长生判断**: 干在宫内的十二长生状态

#### 2.4.4 神旺衰判断
- **宫内判断**: 地盘干纳卦五行与八神生克比和

## 3. 功能特性

### 3.1 已实现功能

#### 3.1.1 基础功能
- ✅ 四种起局方式（拆补、置润、茅山、阴盘）
- ✅ 两种盘式（转盘、飞盘）
- ✅ 完整的天地人神四盘排布
- ✅ 多种寄宫策略（坤宫、坤艮、四维、八宫）
- ✅ 四柱八字计算
- ✅ 空亡计算
- ✅ 马星定位

#### 3.1.2 判断系统
- ✅ 伏吟反吟判断
- ✅ 常见格局识别（40+种）
- ✅ 六庚格判断
- ✅ 六丙格判断
- ✅ 十干克应
- ✅ 八门克应
- ✅ 门星克应
- ✅ 三奇入宫
- ✅ 旺衰分析

#### 3.1.3 UI展示
- ✅ 九宫格展示
- ✅ 各宫详细信息
- ✅ 天地人神四盘显示
- ✅ 格局标注
- ✅ 克应信息展示
- ✅ 旺衰状态显示

### 3.2 待实现功能

#### 3.2.1 缺失功能 (来自README bug列表)
- ❌ 节气精确时间获取
- ❌ 置润法细节完善
- ❌ 人盘干支显示
- ❌ 宫位甲子干支显示
- ❌ 日期选择器

#### 3.2.2 功能增强
- ⏳ 盘局保存与历史记录
- ⏳ 多盘对比功能
- ⏳ 详细解释文档
- ⏳ 自定义排盘设置
- ⏳ 更多格局识别
- ⏳ 动态演示功能

## 4. 数据结构

### 4.1 枚举定义
- **ArrangeType**: 起盘方式（拆补、置润、茅山、阴盘）
- **PlateType**: 盘式（转盘、飞盘）
- **NineStarsEnum**: 九星（天蓬、天芮、天冲等）
- **EightDoorEnum**: 八门（休、生、伤、杜等）
- **EightGodsEnum**: 八神（值符、螣蛇、太阴等）
- **SixJia**: 六甲（甲子、甲戌、甲申等）
- **EnumMostPopularGeJu**: 常见格局枚举
- **CenterGongJiGongType**: 中宫寄宫类型

### 4.2 JSON数据文件
- **十干克应** (ten_gan_ke_ying.json)
- **八门克应** (eight_door_ke_ying.json)
- **门星克应** (door_star_ke_ying.json)
- **三奇入宫** (qi_yi_ru_gong.json)
- **十干格局** (ten_gan_ke_ying_ge_ju.json)

## 5. 配置选项

### 5.1 PanArrangeSettings
```dart
class PanArrangeSettings {
  ArrangeType arrangeType;              // 起盘方式
  CenterGongJiGongType jiGong;          // 中宫寄宫类型
  MonthTokenTypeEnum starMonthTokenType; // 星月令类型
  GongTypeEnum starFourWeiGongType;     // 星四维宫类型
  GongTypeEnum doorFourWeiGongType;     // 门四维宫类型
  GodWithGongTypeEnum godWithGongTypeEnum; // 神宫类型
  GanGongTypeEnum ganGongType;          // 干宫类型
}
```

### 5.2 配置说明
- **月令类型**: 主气/主气纳卦
- **四维宫类型**: 宫卦/宫内地支
- **神宫类型**: 宫卦/地盘干纳卦
- **干宫类型**: 不同的长生计算方式

## 6. 测试覆盖

### 6.1 单元测试
- ✅ 起局计算测试 (test_qi_men_ju_calculator.dart)
- ✅ 八门测试 (test_eight_doors.dart)
- ✅ 九星测试 (test_nine_stars.dart)
- ✅ 八神测试 (test_eight_gods.dart)
- ✅ 九仪测试 (test_nine_yi.dart)
- ✅ 节气测试 (test_datetime_jie_qi.dart)
- ✅ 转盘测试 (test_shi_jia_zhuan_pan_qi_men.dart)

### 6.2 测试用例
包含多个真实案例验证：
- 不同时间点的起局准确性
- 不同起盘方式的结果对比
- 格局识别准确性
- 旺衰判断准确性

## 7. 依赖关系

### 7.1 外部依赖
- **lunar**: 农历和节气计算
- **tuple**: 元组数据结构
- **intl**: 日期格式化
- **provider**: 状态管理
- **logger**: 日志记录
- **json_serializable**: JSON序列化

### 7.2 内部依赖
- **common**: 共享枚举、模型、工具类
  - 天干地支枚举
  - 五行关系
  - 后天八卦
  - 二十四节气
  - 十二长生

## 8. 性能考虑

### 8.1 优化点
- ✅ 使用Future.wait并行加载数据
- ✅ JSON数据懒加载
- ✅ 计算结果缓存
- ✅ UI按需刷新

### 8.2 潜在问题
- ⚠️ 置润法计算复杂度较高
- ⚠️ 大量JSON数据加载耗时
- ⚠️ 格局判断逻辑复杂

## 9. 用户界面

### 9.1 主要页面
- **PrimaryPage**: 早期测试页面
- **ShiJiaQiMenViewPage**: 标准视图页面
- **ScalableShiJiaQiMenViewPage**: 可缩放视图（当前使用）

### 9.2 UI组件
- **EachGongWidget**: 单宫显示组件
- **TianDiYinPan**: 天地盘显示
- **ShenStarPart**: 神星部分
- **WangShuaiHint**: 旺衰提示
- **TenGanKeYingGeJuDetail**: 十干克应格局详情
- **BounceDialog**: 弹窗组件

### 9.3 UI特性
- 九宫格布局
- 天地盘三层显示
- 颜色标注（旺衰、格局）
- 点击交互
- 响应式设计

## 10. 开发计划

### 10.1 短期目标
1. 修复节气时间精确获取问题
2. 完善人盘干支显示
3. 添加日期选择器
4. 优化UI展示效果

### 10.2 中期目标
1. 实现盘局保存功能
2. 添加历史记录
3. 完善格局解释
4. 优化性能

### 10.3 长期目标
1. 支持更多起盘方式
2. 添加智能判断系统
3. 集成知识库
4. 提供学习模式

## 11. 版本历史

### v0.0.1 (当前版本)
- 实现基础起盘功能
- 支持四种起盘方式
- 完整的排盘系统
- 基础格局判断
- 克应分析
- 旺衰计算
- UI展示

## 12. 附录

### 12.1 术语表
- **时家奇门**: 以时辰起局的奇门遁甲
- **转盘**: 传统顺时针转动排盘方式
- **飞盘**: 按九宫顺序飞布的排盘方式
- **拆补法**: 以甲己为符头的起局方法
- **置润法**: 以正授冬至为基准的起局方法
- **值符**: 随时干的九星
- **值使**: 随时支的八门
- **伏吟**: 元素落回本位
- **反吟**: 元素与对宫交换
- **三奇**: 乙丙丁三个天干
- **六仪**: 戊己庚辛壬癸六个天干

### 12.2 参考资料
- 《奇门遁甲统宗》
- 《奇门遁甲应用学》
- 《开悟之门》
