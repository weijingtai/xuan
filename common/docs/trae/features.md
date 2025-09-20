# Common 模块功能特性文档

## 📋 概述

Common 模块是铁板神数应用的核心共享模块，提供了数据库管理、数据模型、UI 组件、工具类和业务逻辑的基础设施。本文档为工程人员提供快速的功能预览和使用指南。

## 🗂️ 模块结构概览

```
common/lib/
├── database/           # 数据库相关
├── datamodel/         # 数据模型
├── datasource/        # 数据源
├── enums.dart         # 枚举定义
├── features/          # 业务特性
├── helpers/           # 辅助工具
├── main.dart          # 主入口
├── models/            # 数据模型
├── module.dart        # 模块导出
├── painter/           # 自定义绘制
├── shared/            # 共享组件
├── utils.dart         # 工具类导出
├── viewmodels/        # 视图模型
└── widgets/           # UI 组件
```

## 🔧 核心功能模块

### 1. 数据库管理 (Database Management)

#### 功能描述
提供统一的数据库连接、配置管理和数据访问层。

#### 核心文件和类
| 文件路径 | 核心类 | 功能描述 |
|---------|--------|----------|
| `database/connection.dart` | `AppDatabase` | 数据库连接和配置管理 |
| `database/daos/divination_types_dao.dart` | `DivinationTypesDao` | 占卜类型数据访问 |
| `database/daos/panels_dao.dart` | `PanelsDao` | 面板数据访问 |
| `database/daos/skill_classes_dao.dart` | `SkillClassesDao` | 技能类别数据访问 |
| `database/daos/divination_history_records_dao.dart` | `DivinationHistoryRecordsDao` | 占卜历史记录访问 |
| `database/daos/panel_skill_class_mappers_dao.dart` | `PanelSkillClassMappersDao` | 面板技能映射访问 |

#### 使用示例
```dart
// 获取数据库实例
final db = AppDatabase.instance;

// 查询所有占卜类型
final types = await db.divinationTypesDao.getAllDivinationTypes();

// 插入新的面板数据
await db.panelsDao.insertPanel(panelCompanion);
```

### 2. 数据模型 (Data Models)

#### 功能描述
定义应用中使用的所有数据结构和传输对象。

#### 核心文件和类
| 文件路径 | 核心类 | 功能描述 |
|---------|--------|----------|
| `datamodel/basic_diviation_info.dart` | `BasicDivinationInfo` | 基础占卜信息模型 |
| `datamodel/sp_location_datamodel.dart` | `SpLocationDatamodel` | 位置数据模型 |
| `datamodel/sp_timezone_datamodel.dart` | `SpTimezoneDatamodel` | 时区数据模型 |
| `models/four_zhu_eight_char.dart` | `FourZhuEightChar` | 四柱八字模型 |
| `models/world_info.dart` | `WorldInfo` | 世界信息模型 |
| `models/chinese_date_info.dart` | `ChineseDateInfo` | 中国传统历法综合信息模型 |
| `features/datetime_details/input_info_params.dart` | `DateTimeDetailsBundle` | 日期时间详情数据包 |

#### 重点模型详解

##### ChineseDateInfo - 中国传统历法信息模型
**功能描述**: 封装中国传统历法的核心信息，包括八字、物候、节气等数据。

**核心属性**:
- `eightChars`: 八字信息（年月日时的天干地支）
- `phenology`: 物候信息（二十四节气相关的物候现象）
- `jieQiInfo`: 节气信息（节气的详细信息）
- `lunarMonth`: 农历月份
- `lunarDay`: 农历日期
- `bazi`: 完整的八字信息

**使用场景**:
- 日期时间转换计算
- 占卜算命业务逻辑
- 传统历法分析
- 节气物候查询

##### DateTimeDetailsBundle - 日期时间详情数据包
**功能描述**: 综合管理不同时间系统下的日期时间信息，为复杂的时间计算提供统一的数据结构。

**核心属性**:
- `standeredChineseInfo`: 标准时间的中国日期信息
- `removeDSTChineseInfo`: 移除夏令时后的中国日期信息
- `meanSolarChineseInfo`: 平太阳时的中国日期信息
- `trueSolarChineseInfo`: 真太阳时的中国日期信息
- `inputDateTime`: 输入的原始时间
- `timezone`: 时区信息
- `location`: 地理位置信息

**使用场景**:
- 精确的天文计算
- 多时区时间处理
- 夏令时转换
- 太阳时计算

#### 使用示例
```dart
// 创建基础占卜信息
final divinationInfo = BasicDivinationInfo(
  title: '今日运势',
  description: '查看今日运势详情',
  createdAt: DateTime.now(),
);

// 使用四柱八字
final fourZhu = FourZhuEightChar(
  yearZhu: '甲子',
  monthZhu: '乙丑',
  dayZhu: '丙寅',
  hourZhu: '丁卯',
);

// 计算中国传统历法信息
final chineseDateInfo = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
  DateTime.now(),
  location: LocationInfo(latitude: 39.9042, longitude: 116.4074), // 北京
);

print('八字: ${chineseDateInfo.eightChars}');
print('农历: ${chineseDateInfo.lunarMonth}月${chineseDateInfo.lunarDay}日');
print('节气: ${chineseDateInfo.jieQiInfo.name}');

// 创建日期时间详情数据包
final dateTimeBundle = DateTimeDetailsBundle(
  inputDateTime: DateTime.now(),
  standeredChineseInfo: chineseDateInfo,
  timezone: 'Asia/Shanghai',
  location: LocationInfo(latitude: 39.9042, longitude: 116.4074),
);

// 处理不同时间系统
if (dateTimeBundle.removeDSTChineseInfo != null) {
  print('移除夏令时后的八字: ${dateTimeBundle.removeDSTChineseInfo!.eightChars}');
}

if (dateTimeBundle.trueSolarChineseInfo != null) {
  print('真太阳时八字: ${dateTimeBundle.trueSolarChineseInfo!.eightChars}');
}
```

### 3. UI 组件库 (UI Components)

#### 功能描述
提供可复用的 UI 组件，支持主题定制和响应式设计。

#### 核心文件和类
| 文件路径 | 核心类 | 功能描述 |
|---------|--------|----------|
| `widgets/divination_card_widget.dart` | `DivinationCardWidget` | 占卜卡片组件 |
| `widgets/divination_datetime_selection_card.dart` | `DivinationDatetimeSelectionCard` | 日期时间选择卡片 |
| `widgets/city_picker_bottom_sheet.dart` | `CityPickerBottomSheet` | 城市选择器 |
| `widgets/query_time_input_card.dart` | `QueryTimeInputCard` | 查询时间输入卡 |
| `widgets/eight_chars_selection_card.dart` | `EightCharsSelectionCard` | 八字选择卡 |
| `widgets/divination_question_widget.dart` | `DivinationQuestionWidget` | 占卜问题组件 |
| `widgets/gold_text.dart` | `GoldText` | 金色文本组件 |

#### 使用示例
```dart
// 使用占卜卡片组件
DivinationCardWidget(
  title: '铁板神数',
  subtitle: '精准预测未来',
  onTap: () => Navigator.push(...),
  trailing: Icon(Icons.arrow_forward),
)

// 使用日期时间选择组件
DivinationDatetimeSelectionCard(
  onDateTimeChanged: (dateTime) {
    print('选择的时间: $dateTime');
  },
  initialDateTime: DateTime.now(),
)
```

### 4. 工具类和辅助功能 (Utilities)

#### 功能描述
提供日期时间处理、集合操作、数据转换等辅助功能。

#### 核心文件和类
| 文件路径 | 核心类 | 功能描述 |
|---------|--------|----------|
| `helpers/solar_lunar_datetime_helper.dart` | `SolarLunarDatetimeHelper` | 公历农历转换工具 |
| `utils/julian_day_converter.dart` | `JulianDayConverter` | 儒略日转换器 |
| `utils/collections_utils.dart` | `CollectionsUtils` | 集合操作工具 |
| `shared/common_logger.dart` | `CommonLogger` | 通用日志工具 |
| `features/datetime_details/processors/dst_processor.dart` | `DSTProcessor` | 夏令时处理器 |
| `features/datetime_details/processors/solar_time_processor.dart` | `SolarTimeProcessor` | 太阳时处理器 |
| `features/datetime_details/processors/timezone_processor.dart` | `TimezoneProcessor` | 时区处理器 |

#### 重点工具详解

##### SolarLunarDatetimeHelper - 公历农历转换核心工具
**主要方法**:
- `cacluateChineseDateInfo()`: 计算完整的中国传统历法信息，返回 `ChineseDateInfo` 对象
- `getEighthChars()`: 获取指定时间的八字信息
- `solarToLunar()`: 公历转农历
- `lunarToSolar()`: 农历转公历

##### 时间处理器系列
**DSTProcessor**: 处理夏令时转换，确保时间计算的准确性
**SolarTimeProcessor**: 处理平太阳时和真太阳时的计算
**TimezoneProcessor**: 处理时区转换和标准化

#### 使用示例
```dart
// 公历转农历
final lunarDate = SolarLunarDatetimeHelper.solarToLunar(DateTime.now());

// 计算完整的中国传统历法信息
final chineseDateInfo = SolarLunarDatetimeHelper.cacluateChineseDateInfo(
  DateTime.now(),
  location: LocationInfo(latitude: 39.9042, longitude: 116.4074),
);

// 儒略日转换
final julianDay = JulianDayConverter.dateTimeToJulianDay(DateTime.now());

// 使用日志工具
CommonLogger.info('应用启动成功');

// 处理夏令时
final dstProcessor = DSTProcessor();
final dstResult = await dstProcessor.process(inputDateTime, location);

// 处理太阳时
final solarProcessor = SolarTimeProcessor();
final solarResult = await solarProcessor.process(inputDateTime, location);
```

### 5. 枚举定义 (Enumerations)

#### 功能描述
定义应用中使用的所有枚举类型，确保类型安全。

#### 核心文件和类
| 文件路径 | 核心枚举 | 功能描述 |
|---------|----------|----------|
| `enums/enum_datetime_type.dart` | `DatetimeType` | 日期时间类型枚举 |
| `enums/enum_di_zhi.dart` | `DiZhi` | 地支枚举 |
| `enums/enum_28_constellations.dart` | `TwentyEightConstellations` | 二十八星宿枚举 |
| `enums/enum_month_general.dart` | `MonthGeneral` | 月将枚举 |
| `enums/enum_twelve_zhang_sheng.dart` | `TwelveZhangSheng` | 十二长生枚举 |

#### 使用示例
```dart
// 使用日期时间类型枚举
final dateType = DatetimeType.solar;

// 使用地支枚举
final diZhi = DiZhi.zi;

// 使用二十八星宿
final constellation = TwentyEightConstellations.jiao;
```

### 6. 业务逻辑层 (Business Logic)

#### 功能描述
提供视图模型和业务逻辑处理。

#### 核心文件和类
| 文件路径 | 核心类 | 功能描述 |
|---------|--------|----------|
| `viewmodels/dev_enter_page_view_model.dart` | `DevEnterPageViewModel` | 开发入口页面视图模型 |
| `features/divination_history_record_page.dart` | `DivinationHistoryRecordPage` | 占卜历史记录页面 |
| `features/datetime_details/datetime_details_bundle_calculation.dart` | `DateTimeDetailsBundleCalculation` | 日期时间详情计算业务逻辑 |

#### 重点业务逻辑详解

##### DateTimeDetailsBundleCalculation - 日期时间详情计算
**功能描述**: 负责协调各种时间处理器，计算完整的 `DateTimeDetailsBundle` 对象。

**主要流程**:
1. **基础时区处理**: 获取UTC时间和基础的 `ChineseDateInfo`
2. **夏令时处理**: 使用 `DSTProcessor` 计算移除夏令时后的时间
3. **太阳时处理**: 使用 `SolarTimeProcessor` 计算平太阳时和真太阳时
4. **数据整合**: 将所有计算结果整合到 `DateTimeDetailsBundle` 中

**核心方法**:
- `calculateBundle()`: 计算完整的日期时间详情数据包
- `processTimezone()`: 处理时区相关计算
- `processDST()`: 处理夏令时相关计算
- `processSolarTime()`: 处理太阳时相关计算

#### 使用示例
```dart
// 使用视图模型
final viewModel = DevEnterPageViewModel();
await viewModel.generateDivinationCompanion();

// 监听状态变化
viewModel.addListener(() {
  // 处理状态更新
});

// 计算日期时间详情数据包
final calculator = DateTimeDetailsBundleCalculation();
final bundle = await calculator.calculateBundle(
  inputDateTime: DateTime.now(),
  location: LocationInfo(latitude: 39.9042, longitude: 116.4074),
  timezone: 'Asia/Shanghai',
);

// 使用计算结果
print('标准时间八字: ${bundle.standeredChineseInfo.eightChars}');
if (bundle.removeDSTChineseInfo != null) {
  print('移除夏令时八字: ${bundle.removeDSTChineseInfo!.eightChars}');
}
if (bundle.trueSolarChineseInfo != null) {
  print('真太阳时八字: ${bundle.trueSolarChineseInfo!.eightChars}');
}
```

### 7. 自定义绘制 (Custom Painting)

#### 功能描述
提供自定义绘制组件，用于复杂的图形渲染。

#### 核心文件和类
| 文件路径 | 核心类 | 功能描述 |
|---------|--------|----------|
| `painter/ge_ju_panel_template_ji_1.dart` | `GeJuPanelTemplateJi1` | 格局面板模板绘制 |

#### 使用示例
```dart
// 使用自定义绘制组件
CustomPaint(
  painter: GeJuPanelTemplateJi1(),
  size: Size(300, 300),
)
```

## 🚀 快速开始指南

### 1. 导入模块
```dart
import 'package:common/module.dart';
```

### 2. 初始化数据库
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化数据库
  await AppDatabase.instance.initialize();
  
  runApp(MyApp());
}
```

### 3. 使用 UI 组件
```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DivinationCardWidget(
            title: '今日运势',
            subtitle: '查看详细信息',
            onTap: () {
              // 处理点击事件
            },
          ),
          QueryTimeInputCard(
            onTimeChanged: (time) {
              // 处理时间变化
            },
          ),
        ],
      ),
    );
  }
}
```

### 4. 数据操作示例
```dart
class DivinationService {
  final AppDatabase _db = AppDatabase.instance;
  
  // 获取所有占卜类型
  Future<List<DivinationType>> getDivinationTypes() async {
    return await _db.divinationTypesDao.getAllDivinationTypes();
  }
  
  // 创建新的占卜记录
  Future<int> createDivinationRecord(DivinationHistoryRecordsCompanion record) async {
    return await _db.divinationHistoryRecordsDao.insertDivinationHistoryRecord(record);
  }
}
```

## 📚 最佳实践

### 1. 数据库操作
- 使用事务确保数据一致性
- 合理使用软删除避免数据丢失
- 定期备份重要数据

### 2. UI 组件使用
- 遵循 Material Design 设计规范
- 使用主题系统保持视觉一致性
- 考虑不同屏幕尺寸的适配

### 3. 性能优化
- 使用懒加载减少内存占用
- 合理缓存频繁访问的数据
- 避免在 UI 线程执行耗时操作

### 4. 错误处理
- 使用 try-catch 处理异常
- 提供友好的错误提示
- 记录详细的错误日志

## 🔗 相关文档

- [PRD 产品需求文档](./prds.md)
- [API 接口文档](../../README.md)
- [Flutter 官方文档](https://flutter.dev/docs)
- [Drift 数据库文档](https://drift.simonbinder.eu/)

## 📞 技术支持

如有问题或建议，请联系开发团队或查阅相关技术文档。

---

**文档版本**: 1.0.0  
**创建日期**: 2024-01-21  
**最后更新**: 2024-01-21  
**维护者**: Trae AI Assistant