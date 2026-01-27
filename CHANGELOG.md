# Changelog

## [2025-08-14] 整合 feature/common/birth_details + refactor/common/chinese_date_info

### 概述

本次合并整合了 `feature/common/birth_details` 和 `refactor/common/chinese_date_info` 两个分支的全部工作，涵盖 common 模块新增时间历法数据模型、tiebanshenshu（铁板神数）子模块完整实现，以及 daliuren（大六壬）、qizhengsiyu（七政四余）、qimendunjia（奇门遁甲）多个子模块的架构重构与功能增强。

---

### common 模块

#### 新增: `ChineseDateInfo` 数据模型
- 封装中国传统历法综合信息，可替代 `DivinationInfoModel` 的部分职责
- 包含字段：四柱八字 (`EightChars`)、七十二物候 (`Phenology`)、节气信息 (`JieQiInfo`)、三元 (`YuanYunOrder`)、九运 (`NineYun`)、农历月日
- 提供四柱快捷 getter：`yearGanZhi`、`monthGanZhi`、`dayGanZhi`、`timeGanZhi`

#### 新增: `features/datetime_details/` 时间详情计算模块
- `DateTimeDetailsBundle` — 封装标准时间、UTC、夏令时、平太阳时、真太阳时及对应 `ChineseDateInfo`
- `InputInfoParams` — 输入参数封装
- `CalculationStrategyConfig` — 计算策略配置
- 处理器 (Processors):
  - `DstProcessor` — 夏令时处理
  - `SolarTimeProcessor` — 太阳时处理
  - `TimezoneProcessor` — 时区处理

#### 新增: 枚举与共享模块
- `enum_three_yuan.dart` — 三元九运枚举 (`YuanYunOrder`, `NineYun`)
- `nine_star.dart` — 九星枚举
- `enum_day_night.dart` — 昼夜枚举
- `enum_four_seasons.dart` — 四季枚举（增强版，含旺衰判断）
- `enum_five_xing_relationship.dart` — 五行关系枚举
- 枚举目录迁移至 `shared/enums/`

#### 重构: 胎元计算模块
- `tai_yuan/` 迁移至 `features/tai_yuan/`
- 适配新的 `ChineseDateInfo` 数据模型

#### 重构: 数据模型重命名
- `DivinationInfoDataModel` 重命名为 `DivinationRequestInfoDatamodel`
- `DivinationDatetimeDataModel` 重命名为 `DatetimeDivinationDatamodel`

#### 增强
- `EightChars` 新增 `fourZhu` getter
- `SolarLunarDatetimeHelper` 大幅增强，支持更丰富的日期换算
- `TianGan` 新增 `TianGanFiveCombine#getOtherGan`
- `DiZhi` 新增 `getDiZhiWangShuaiAtFourSeasons`、`getFourSeason`
- 新增测试: `test_eight_char_zi_shi.dart`

---

### tiebanshenshu（铁板神数）子模块 — 全新

完整实现铁板神数算法模块，包含以下核心功能：

#### 领域模型
- `FourZhu` — 四柱模型
- `SixYaoGua` — 六爻卦模型

#### 算法服务
- **经典算法** (`service/classic/`):
  - `CorrectTimeAndKeCalculation` — 校正时辰与课计算
  - `DayGanZhiGuaCalculation` — 日干支卦计算
  - `FourZhuTianGanCalculation` — 四柱天干计算
  - `SixQinCorrectKeCalculation` — 六亲校正课计算
  - `TaiXuanFourZhuCalculation` — 太玄四柱计算
  - `TaiXuanQianHouCalculation` — 太玄前后计算
- **四门/四卦** (`service/four_gua/`):
  - `BaseGuaCalculator` — 卦计算基类
  - `FourDoorsV2` — 四门计算 v2
  - `GuaCalculationConfig` — 卦计算配置
  - `GunFaV2` — 滚法 v2
- **黄极** (`service/huang_ji/`):
  - `HuangJi1/2/3` — 黄极取数策略
  - `HuangJiQuShuBaseStrategy` — 黄极取数基类
- **元堂** (`service/yuan_tang/`):
  - `YuanTangCalculator` — 元堂计算器
- `FourDoors` — 四门计算
- `GunFa` — 滚法
- `CalculationStrategy` — 策略接口

#### 工具
- `TiaoWenCalculator` — 条文计算器
- `Utils` — 通用工具

#### 测试
- 包含 12 个测试文件，覆盖全部 9 个实战案例、四门、滚法、元堂等核心计算

---

### daliuren（大六壬）子模块

#### 架构重构为 MVVM + Repository + UseCase
- **数据层** (`data/`):
  - `datasources/local/database/` — Drift 数据库实现
  - `datasources/local/protobuf/` — Protobuf 数据源
  - `models/` — 数据模型层
  - `services/` — 数据服务实现
- **领域层** (`domain/`):
  - `entities/` — 领域实体 (`LiuRenPanModel`, `RawPanInfoModel`, `ShenShaEntity`, `PanInput`)
  - `enums/` — 领域枚举 (`GuiRen`, `NineZongMen`, `PanType` 等)
  - `repositories/` — Repository 接口
  - `services/` — 领域服务（月将、贵人、三传、九宗门、神煞计算）
  - `usecases/` — 用例 (`CalculateLiurenPanUsecase`, `CalculateShenShaUsecase`, `InitializeDatabaseUsecase`)
- **展示层** (`presentation/`):
  - `pages/` — `DaliurenHomePage`
  - `viewmodels/` — `DaliurenHomeViewmodel`
  - `widgets/` — 四课、三传、盘面、玉定显示组件
- **依赖注入**: `di/service_locator.dart`
- 新增 `ARCHITECTURE.md` 架构文档

---

### qizhengsiyu（七政四余）子模块

#### 新增
- `database/` — Drift 数据库层 (`QizhengSiyuPanDao`, `QizhengSiyuPanTable`)
- `repositories/` — Repository 模式 (`IQizhengSiyuPanRepository`, `QizhengSiyuPanRepository`)
- `usecases/` — 用例 (`CalculateFateDongWeiUsecase`, `SaveCalculatedPanelUsecase`)
- `widgets/rings/body_life_circle_widget.dart` — 命身圈组件
- `xing_xian/` 新增:
  - `BaseXianCalculator` — 限计算基类
  - `BaseXianPalace` — 限宫基类
  - `BasePanelPassageInfo` — 盘面过境信息基类
  - `XiaoXianCalculator` — 小限计算器
  - `GongConstellationMapping` — 宫星座映射
- `enum_dong_wei_type.dart` — 洞微类型枚举
- `PanEntity` — 盘实体模型

#### 重构
- 大限计算器 (`DaXianCalculator`) 重构，提取公共基类
- 飞限计算器 (`FeiXianCalculator`) 重构
- `BasePanelModel` 增强，新增面板配置字段
- 命宫系列模型重命名: `DaXianPanelModel` → `PassageYearPanelModel`

---

### qimendunjia（奇门遁甲）子模块

#### 新增
- `widgets/pan_info_display.dart` — 盘面信息显示组件
- `widgets/pan_settings_panel.dart` — 盘面设置面板
- `enums/enum_center_gong_ji_gong_type.dart` — 中宫寄宫类型枚举
- `utils/constant_resources_of_qi_men.dart` — 奇门常量资源

#### 增强
- `QiMenJuCalculator` 大幅增强
- `DatetimeJieQi` 增强
- 视图页面适配

---

### 根项目

- 新增 `lib/main.dart` 入口
- 移除废弃的 `fate/` 目录和 `naming_degree_pair.dart`
- 新增神煞数据集 (`assets/shen_sha/*.json`)
- 新增大六壬数据集 (`assets/da_liu_ren/`)
