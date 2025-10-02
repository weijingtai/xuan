# 奇门遁甲 (QiMenDunJia)

中国传统奇门遁甲术数系统的 Flutter 实现。提供完整的奇门遁甲起盘、排盘、判断功能。

## 📖 简介

奇门遁甲是中国古代术数学中的重要分支，被誉为"帝王之学"。本模块实现了完整的时家奇门遁甲系统，支持多种起盘方式和判断体系。

### 核心功能

- ✅ **多种起盘方式**: 拆补法、置润法、茅山法、阴盘法
- ✅ **双盘式支持**: 转盘奇门、飞盘奇门
- ✅ **完整排盘**: 天盘、地盘、人盘、神盘
- ✅ **格局识别**: 40+ 种奇门格局自动识别
- ✅ **克应分析**: 十干克应、八门克应、门星克应
- ✅ **旺衰判断**: 门星神干的旺衰状态分析
- ✅ **可视化展示**: 精美的九宫格界面

## 🚀 快速开始

### 依赖配置

在 `pubspec.yaml` 中添加依赖:

```yaml
dependencies:
  qimendunjia:
    path: ../qimendunjia
  common:
    path: ../common
```

### 基础使用

```dart
import 'package:qimendunjia/utils/qi_men_ju_calculator.dart';
import 'package:qimendunjia/model/shi_jia_qi_men.dart';

// 1. 计算局数（拆补法）
final calculator = ChaiBuCalculator(dateTime: DateTime.now());
final ju = calculator.calculate();

// 2. 排盘
final settings = PanArrangeSettings(
  arrangeType: ArrangeType.CHAI_BU,
  jiGong: CenterGongJiGongType.KUN_GEN_GONG,
);

final pan = ShiJiaQiMen(
  plateType: PlateType.ZHUAN_PAN,
  shiJiaJu: ju,
  settings: settings,
);

// 3. 获取宫位信息
final kanGong = pan.gongMapper[HouTianGua.Kan]!;
print('坎宫: ${kanGong.star.name} ${kanGong.door.name} ${kanGong.god.name}');
```

### UI 集成

```dart
import 'package:qimendunjia/navigator.dart' as qmdj;
import 'package:qimendunjia/pages/shi_jia_qi_men_view_model.dart';

// 使用 Provider 集成
MultiProvider(
  providers: [
    ChangeNotifierProvider<ShiJiaQiMenViewModel>(
      create: (context) => ShiJiaQiMenViewModel(context),
    ),
  ],
  child: MaterialApp(
    onGenerateRoute: qmdj.NavigatorGenerator.generateRoute,
    initialRoute: '/qimendunjia',
  ),
)
```

## 📚 起盘方式详解

### 1. 拆补法 (ChaiBuCalculator)

传统起局方法，以甲己为符头。

```dart
final calculator = ChaiBuCalculator(dateTime: yourDateTime);
final ju = calculator.calculate();
```

**特点**:
- 以甲己为符头（甲子、甲戌、甲申、甲午、甲辰、甲寅、己丑、己亥、己酉、己未、己巳、己卯）
- 根据符头地支确定三元（子午卯酉为上元，寅申巳亥为中元，辰戌丑未为下元）
- 查表得到对应节气的局数

### 2. 置润法 (ZhiRunCalculator)

以正授冬至为基准的精确起局法。

```dart
final calculator = ZhiRunCalculator(dateTime: yourDateTime);
final ju = calculator.calculate();
```

**特点**:
- 从正授冬至开始计算
- 每5天为一元，180天（36元）为一个阴阳遁周期
- 处理超神、接气、置润情况
- 更加精确，但计算复杂

### 3. 茅山法 (MaoShanCalculator)

按节气时辰起局的方法。

```dart
final calculator = MaoShanCalculator(dateTime: yourDateTime);
final ju = calculator.calculate();
```

**特点**:
- 前180时辰为上元
- 180-360时辰为中元
- 360+时辰为下元（重复）
- 简单易用

### 4. 阴盘法 (YinPanCalculator)

特殊的起局方式。

```dart
final calculator = YinPanCalculator(dateTime: yourDateTime);
final ju = calculator.calculate();
```

**特点**:
- 局数 = (年支序数 + 月数 + 日数 + 时支序数) % 9
- 冬至后阳遁，夏至后阴遁

## 🎯 盘式说明

### 转盘奇门 (PlateType.ZHUAN_PAN)

传统的顺时针转动方式。

**特点**:
- 地盘固定
- 天盘、人盘、神盘顺时针转动
- 符合传统理论
- 不使用中五宫（需寄宫）

### 飞盘奇门 (PlateType.FEI_PAN)

现代的飞布方式。

**特点**:
- 按1-9或9-1顺序飞布
- 使用中五宫
- 计算相对简单
- 现代派常用

## ⚙️ 配置选项

### PanArrangeSettings

```dart
final settings = PanArrangeSettings(
  arrangeType: ArrangeType.CHAI_BU,              // 起盘方式
  jiGong: CenterGongJiGongType.KUN_GEN_GONG,    // 中宫寄宫类型
  starMonthTokenType: MonthTokenTypeEnum.ZHU_QI, // 星月令类型
  starFourWeiGongType: GongTypeEnum.GONG_GUA,   // 星四维宫类型
  doorFourWeiGongType: GongTypeEnum.GONG_GUA,   // 门四维宫类型
  godWithGongTypeEnum: GodWithGongTypeEnum.GONG_GUA_ONLY, // 神宫类型
  ganGongType: GanGongTypeEnum.GONG_NEI_DI_ZHI, // 干宫类型
);
```

### 寄宫类型 (CenterGongJiGongType)

- `ONLY_KUN_GONG`: 只寄坤二宫
- `KUN_GEN_GONG`: 阴遁寄坤二，阳遁寄艮八
- `FOUR_WEI_GONG`: 按四季寄四维宫（春艮、夏巽、秋坤、冬乾）
- `EIGTH_GONG`: 按八节寄八宫

## 🎨 数据结构

### ShiJiaJu (时家局)

起局结果:

```dart
class ShiJiaJu {
  final int juNumber;              // 局数 (1-9)
  final YinYang yinYangDun;        // 阴阳遁
  final JiaZi fuTouJiaZi;          // 符头甲子
  final TwentyFourJieQi jieQiAt;   // 当前节气
  final EnumThreeYuan atThreeYuan; // 三元
  final String fourZhuEightChar;   // 四柱八字
  // ...
}
```

### ShiJiaQiMen (奇门盘)

完整盘局:

```dart
class ShiJiaQiMen {
  final PlateType plateType;                       // 盘类型
  final ShiJiaJu shiJiaJu;                        // 局信息
  final Map<HouTianGua, EachGong> gongMapper;     // 九宫信息
  final EightDoorEnum zhiShiDoor;                 // 值使门
  final NineStarsEnum zhiFuStar;                  // 值符星
  final bool isStarFuYin;                         // 星伏吟
  final bool isStarFanYin;                        // 星反吟
  final bool isDoorFuYin;                         // 门伏吟
  final bool isDoorFanYin;                        // 门反吟
  // ...
}
```

### EachGong (单宫)

宫位详细信息:

```dart
class EachGong {
  final NineStarsEnum star;      // 九星
  final EightDoorEnum door;      // 八门
  final EightGodsEnum god;       // 八神
  final TianGan tianPan;         // 天盘干
  final TianGan diPan;           // 地盘干
  final TianGan tianPanAnGan;    // 天盘暗干
  final TianGan renPanAnGan;     // 人盘暗干
  final TianGan yinGan;          // 隐干
  final TianGan? tianPanJiGan;   // 天盘寄干
  final TianGan? diPanJiGan;     // 地盘寄干
  // ...
}
```

## 📊 格局识别

模块支持识别40+种奇门格局，包括:

### 基础格局
- 伏吟、反吟
- 三奇得使、奇游禄位
- 门迫、门墓、门反吟

### 吉格
- 青龙回首、飞鸟跌穴
- 玉女守门、三奇贵人升殿
- 天遁、地遁、人遁、神遁、鬼遁

### 凶格
- 三诈、六仪击刑
- 时干入墓、日干入墓
- 荧入白、白入荧

### 特殊格局
- 六庚格（伏宫格、太白格等）
- 六丙格（悖格、鸟跌穴等）

## 🔧 工具类

### ArrangePlateUtils

排盘工具:

```dart
// 根据甲子获取旬首
final xunShou = ArrangePlateUtils.getXunShouByJiaZi(jiaZi);

// 获取某干在宫中的长生状态
final zhangSheng = ArrangePlateUtils.getTianGanZhangShengAtGong(...);
```

### NineYiUtils

九仪相关工具:

```dart
// 判断门是否入墓
final isRuMu = NineYiUtils.isDoorRuMu(door, gong);

// 计算奇仪长生
final zhangSheng = NineYiUtils.qiYiZhangSheng(...);

// 判断是否为墓库
final isMuOrKu = NineYiUtils.checkMuOrKu(...);
```

## 🧪 测试

运行测试:

```bash
cd qimendunjia
flutter test
```

测试覆盖:
- ✅ 起局计算测试
- ✅ 八门排布测试
- ✅ 九星排布测试
- ✅ 八神排布测试
- ✅ 九仪测试
- ✅ 节气测试
- ✅ 转盘奇门测试

## 📝 已知问题

### 待修复 Bug

1. **节气时间精度问题**
   - 当前节气时间获取不够精确
   - 需要实现更准确的节气计算

2. **置润法细节待完善**
   - 超神、接气、置润的边界情况处理
   - 跨年度计算的准确性

3. **人盘干支显示缺失**
   - 当前未实现人盘干支显示
   - 宫位甲子干支显示缺失

4. **日期选择器未实现**
   - 缺少用户友好的日期时间选择器

### 计划改进

- [ ] 实现盘局保存功能
- [ ] 添加历史记录
- [ ] 完善格局解释系统
- [ ] 优化UI展示效果
- [ ] 添加更多测试用例
- [ ] 性能优化

## 📚 参考文献

- 《奇门遁甲统宗》- 刘伯温
- 《奇门遁甲应用学》- 张志春
- 《开悟之门》- 杜新会

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 开发规范

1. 遵循 Dart 代码规范
2. 添加适当的注释和文档
3. 编写单元测试
4. 提交前运行 `flutter analyze`

### 提交规范

```
feat: 添加新功能
fix: 修复 bug
docs: 文档更新
test: 测试相关
refactor: 重构代码
```

## 📄 许可证

本项目采用 MIT 许可证。

## 🔗 相关链接

- [项目文档](docs/PRDs.md)
- [代码审查](docs/claude/code_review.md)
- [Common 模块](../common)

## 📮 联系方式

如有问题或建议，请通过以下方式联系:

- Issue: 在 GitHub 提交 Issue
- Email: [项目邮箱]

---

**版本**: 0.0.1
**最后更新**: 2025-10-01
