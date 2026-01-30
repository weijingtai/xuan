# 奇门遁甲模块 - 架构重构实施指南

## 🎯 总览

本文档提供详细的、可执行的步骤来重构 qimendunjia 模块。每个步骤都包含具体的代码示例和验证方法。

---

## 📅 时间线

```
Day 1-2:  Phase 1 - 建立架构骨架
Day 3-4:  Phase 2 - 实现核心层
Day 5-6:  Phase 3 - 重构 ViewModel
Day 7:    Phase 4 - 迁移 UI
Day 8:    Phase 5 - 测试与验证
Day 9-10: Phase 6 - 优化与文档
```

---

## Phase 1: 建立架构骨架 (Day 1-2)

### Step 1.1: 创建目录结构

```bash
cd qimendunjia

# 创建新架构目录
mkdir -p lib/domain/entities
mkdir -p lib/domain/repositories
mkdir -p lib/domain/usecases
mkdir -p lib/data/models
mkdir -p lib/data/models/mappers
mkdir -p lib/data/datasources
mkdir -p lib/data/datasources/calculator
mkdir -p lib/data/repositories
mkdir -p lib/presentation/viewmodels
mkdir -p lib/presentation/views
mkdir -p lib/di
mkdir -p lib/legacy/model
mkdir -p lib/legacy/utils

# 创建测试目录
mkdir -p test/domain/usecases
mkdir -p test/data/repositories
mkdir -p test/presentation/viewmodels
```

### Step 1.2: 移动遗留代码

```bash
# 移动旧模型到 legacy（先复制，后续再删除）
cp -r lib/model/* lib/legacy/model/
cp -r lib/utils/* lib/legacy/utils/

# 保留原位置代码，确保不中断现有功能
```

### Step 1.3: 创建基础实体

**创建文件**: `lib/domain/entities/base_entity.dart`

```dart
/// 基础实体接口
abstract class Entity {
  String get id;
}

/// 实体相等性比较
abstract class Equatable {
  List<Object?> get props;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Equatable &&
        _listEquals(props, other.props);
  }

  @override
  int get hashCode => Object.hashAll(props);

  bool _listEquals(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
```

**创建文件**: `lib/domain/entities/shi_jia_ju.dart`

```dart
import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import 'package:qimendunjia/enums/enum_three_yuan.dart';
import 'base_entity.dart';

/// 时家局实体（纯业务对象）
class ShiJiaJu extends Equatable {
  final String id;
  final DateTime panDateTime;
  final int juNumber;
  final JiaZi fuTouJiaZi;
  final YinYang yinYangDun;
  final TwentyFourJieQi jieQiAt;
  final DateTime jieQiStartAt;
  final TwentyFourJieQi jieQiEnd;
  final DateTime jieQiEndAt;
  final EnumThreeYuan atThreeYuan;
  final String fourZhuEightChar;
  final TwentyFourJieQi? panJuJieQi;
  final int? juDayNumber;

  const ShiJiaJu({
    required this.id,
    required this.panDateTime,
    required this.juNumber,
    required this.fuTouJiaZi,
    required this.yinYangDun,
    required this.jieQiAt,
    required this.jieQiStartAt,
    required this.jieQiEnd,
    required this.jieQiEndAt,
    required this.atThreeYuan,
    required this.fourZhuEightChar,
    this.panJuJieQi,
    this.juDayNumber,
  });

  @override
  List<Object?> get props => [
        id,
        panDateTime,
        juNumber,
        fuTouJiaZi,
        yinYangDun,
        jieQiAt,
        jieQiStartAt,
        jieQiEnd,
        jieQiEndAt,
        atThreeYuan,
        fourZhuEightChar,
        panJuJieQi,
        juDayNumber,
      ];

  ShiJiaJu copyWith({
    String? id,
    DateTime? panDateTime,
    int? juNumber,
    JiaZi? fuTouJiaZi,
    YinYang? yinYangDun,
    TwentyFourJieQi? jieQiAt,
    DateTime? jieQiStartAt,
    TwentyFourJieQi? jieQiEnd,
    DateTime? jieQiEndAt,
    EnumThreeYuan? atThreeYuan,
    String? fourZhuEightChar,
    TwentyFourJieQi? panJuJieQi,
    int? juDayNumber,
  }) {
    return ShiJiaJu(
      id: id ?? this.id,
      panDateTime: panDateTime ?? this.panDateTime,
      juNumber: juNumber ?? this.juNumber,
      fuTouJiaZi: fuTouJiaZi ?? this.fuTouJiaZi,
      yinYangDun: yinYangDun ?? this.yinYangDun,
      jieQiAt: jieQiAt ?? this.jieQiAt,
      jieQiStartAt: jieQiStartAt ?? this.jieQiStartAt,
      jieQiEnd: jieQiEnd ?? this.jieQiEnd,
      jieQiEndAt: jieQiEndAt ?? this.jieQiEndAt,
      atThreeYuan: atThreeYuan ?? this.atThreeYuan,
      fourZhuEightChar: fourZhuEightChar ?? this.fourZhuEightChar,
      panJuJieQi: panJuJieQi ?? this.panJuJieQi,
      juDayNumber: juDayNumber ?? this.juDayNumber,
    );
  }
}
```

**创建文件**: `lib/domain/entities/each_gong.dart`

```dart
import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_eight_gods.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:qimendunjia/enums/enum_six_jia.dart';
import 'base_entity.dart';

/// 单宫实体
class EachGong extends Equatable {
  final int gongNumber;
  final HouTianGua gongGua;
  final NineStarsEnum star;
  final EightDoorEnum door;
  final EightGodsEnum god;
  final EightGodsEnum diGod;
  final TianGan tianPan;
  final TianGan diPan;
  final TianGan tianPanAnGan;
  final TianGan renPanAnGan;
  final TianGan yinGan;
  final TianGan? tianPanJiGan;
  final TianGan? diPanJiGan;
  final SixJia? sixJiaXunHeader;
  final bool isJiTianQin;

  const EachGong({
    required this.gongNumber,
    required this.gongGua,
    required this.star,
    required this.door,
    required this.god,
    required this.diGod,
    required this.tianPan,
    required this.diPan,
    required this.tianPanAnGan,
    required this.renPanAnGan,
    required this.yinGan,
    this.tianPanJiGan,
    this.diPanJiGan,
    this.sixJiaXunHeader,
    this.isJiTianQin = false,
  });

  @override
  List<Object?> get props => [
        gongNumber,
        gongGua,
        star,
        door,
        god,
        diGod,
        tianPan,
        diPan,
        tianPanAnGan,
        renPanAnGan,
        yinGan,
        tianPanJiGan,
        diPanJiGan,
        sixJiaXunHeader,
        isJiTianQin,
      ];

  // 业务方法
  bool get isStarFuYin => star.originalGong == gongGua;
  bool get isStarFanYin => star.checkFanYinByGong(gongGua);
  bool get isDoorFuYin => door.originalGong == gongGua;
  bool get isDoorFanYin => door.checkFanYinByGong(gongGua);
  bool get isSixJiXing => sixJiaXunHeader?.isSixJiXing(star) ?? false;
}
```

**创建文件**: `lib/domain/entities/qimen_pan.dart`

```dart
import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_most_popular_ge_ju.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'base_entity.dart';
import 'each_gong.dart';
import 'shi_jia_ju.dart';

/// 奇门盘实体
class QiMenPan extends Equatable {
  final String id;
  final DateTime panDateTime;
  final ShiJiaJu shiJiaJu;
  final PlateType plateType;
  final Map<HouTianGua, EachGong> gongMapper;

  // 值符值使
  final EightDoorEnum zhiShiDoor;
  final HouTianGua zhiShiDoorAtGong;
  final NineStarsEnum zhiFuStar;
  final HouTianGua zhiFuStarAtGong;

  // 伏吟反吟
  final bool isStarFuYin;
  final bool isStarFanYin;
  final bool isDoorFuYin;
  final bool isDoorFanYin;
  final bool isGanFuYin;
  final bool isGanFanYin;

  // 格局
  final List<EnumMostPopularGeJu>? panGeJuList;

  // 其他信息
  final DiZhi horseLocation;
  final MonthToken monthToken;

  const QiMenPan({
    required this.id,
    required this.panDateTime,
    required this.shiJiaJu,
    required this.plateType,
    required this.gongMapper,
    required this.zhiShiDoor,
    required this.zhiShiDoorAtGong,
    required this.zhiFuStar,
    required this.zhiFuStarAtGong,
    required this.isStarFuYin,
    required this.isStarFanYin,
    required this.isDoorFuYin,
    required this.isDoorFanYin,
    required this.isGanFuYin,
    required this.isGanFanYin,
    required this.horseLocation,
    required this.monthToken,
    this.panGeJuList,
  });

  @override
  List<Object?> get props => [
        id,
        panDateTime,
        shiJiaJu,
        plateType,
        gongMapper,
        zhiShiDoor,
        zhiShiDoorAtGong,
        zhiFuStar,
        zhiFuStarAtGong,
        isStarFuYin,
        isStarFanYin,
        isDoorFuYin,
        isDoorFanYin,
        isGanFuYin,
        isGanFanYin,
        panGeJuList,
        horseLocation,
        monthToken,
      ];

  // 业务方法
  bool get hasAnyFuYin => isStarFuYin || isDoorFuYin || isGanFuYin;
  bool get hasAnyFanYin => isStarFanYin || isDoorFanYin || isGanFanYin;

  EachGong? getGong(HouTianGua gua) => gongMapper[gua];
}
```

### Step 1.4: 创建仓储接口

**创建文件**: `lib/domain/repositories/qimen_calculator_repository.dart`

```dart
import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import '../entities/qimen_pan.dart';
import '../entities/shi_jia_ju.dart';

/// 奇门计算器仓储接口
abstract class QiMenCalculatorRepository {
  /// 计算局数
  ///
  /// [dateTime] 起盘时间
  /// [arrangeType] 起盘方式（拆补/置润/茅山/阴盘）
  ///
  /// 返回计算好的局信息
  ///
  /// 抛出 [QiMenCalculationException] 当计算失败时
  Future<ShiJiaJu> calculateJu({
    required DateTime dateTime,
    required ArrangeType arrangeType,
  });

  /// 排盘
  ///
  /// [ju] 局信息
  /// [plateType] 盘类型（转盘/飞盘）
  /// [settings] 排盘设置
  ///
  /// 返回完整的奇门盘
  ///
  /// 抛出 [QiMenCalculationException] 当排盘失败时
  Future<QiMenPan> arrangePan({
    required ShiJiaJu ju,
    required PlateType plateType,
    required PanSettings settings,
  });
}
```

**创建文件**: `lib/domain/repositories/qimen_data_repository.dart`

```dart
import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:qimendunjia/model/door_star_ke_ying.dart';
import 'package:qimendunjia/model/eight_door_ke_ying.dart';
import 'package:qimendunjia/model/qi_yi_ru_gong.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying_ge_ju.dart';

/// 奇门数据仓储接口
abstract class QiMenDataRepository {
  /// 获取十干克应
  Future<TenGanKeYing> getTenGanKeYing({
    required TianGan tianPan,
    required TianGan diPan,
  });

  /// 获取门星克应
  Future<DoorStarKeYing?> getDoorStarKeYing({
    required EightDoorEnum door,
    required NineStarsEnum star,
  });

  /// 获取八门克应
  Future<Map<YinYang, EightDoorKeYing>?> getEightDoorKeYing({
    required EightDoorEnum door,
    required EightDoorEnum fixDoor,
  });

  /// 获取三奇入宫
  Future<QiYiRuGong?> getQiYiRuGong({
    required HouTianGua gong,
    required TianGan gan,
  });

  /// 获取十干克应格局
  Future<TenGanKeYingGeJu> getTenGanKeYingGeJu({
    required TianGan tianPan,
    required TianGan diPan,
  });

  /// 获取八门干克应字符串
  Future<String?> getEightDoorGanKeYing({
    required EightDoorEnum door,
    required TianGan gan,
  });

  /// 获取天干入宫疾病信息
  Future<String?> getTianGanRuGongDisease({
    required HouTianGua gong,
    required TianGan gan,
  });

  /// 清除缓存
  Future<void> clearCache();
}
```

### Step 1.5: 创建 UseCase

**创建文件**: `lib/domain/usecases/calculate_ju_usecase.dart`

```dart
import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import '../entities/shi_jia_ju.dart';
import '../repositories/qimen_calculator_repository.dart';
import 'base_usecase.dart';

/// 计算局数用例参数
class CalculateJuParams {
  final DateTime dateTime;
  final ArrangeType arrangeType;

  const CalculateJuParams({
    required this.dateTime,
    required this.arrangeType,
  });
}

/// 计算局数用例
class CalculateJuUseCase extends UseCase<ShiJiaJu, CalculateJuParams> {
  final QiMenCalculatorRepository _repository;

  CalculateJuUseCase(this._repository);

  @override
  Future<ShiJiaJu> execute(CalculateJuParams params) async {
    try {
      return await _repository.calculateJu(
        dateTime: params.dateTime,
        arrangeType: params.arrangeType,
      );
    } catch (e) {
      throw QiMenCalculationException('计算局数失败: $e');
    }
  }
}
```

**创建文件**: `lib/domain/usecases/base_usecase.dart`

```dart
/// UseCase 基类
abstract class UseCase<Type, Params> {
  Future<Type> execute(Params params);
}

/// 无参数 UseCase
abstract class NoParamsUseCase<Type> {
  Future<Type> execute();
}

/// 奇门计算异常
class QiMenCalculationException implements Exception {
  final String message;
  QiMenCalculationException(this.message);

  @override
  String toString() => 'QiMenCalculationException: $message';
}

/// 奇门数据未找到异常
class QiMenDataNotFoundException implements Exception {
  final String message;
  QiMenDataNotFoundException(this.message);

  @override
  String toString() => 'QiMenDataNotFoundException: $message';
}
```

**创建文件**: `lib/domain/usecases/arrange_pan_usecase.dart`

```dart
import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import '../entities/qimen_pan.dart';
import '../entities/shi_jia_ju.dart';
import '../repositories/qimen_calculator_repository.dart';
import 'base_usecase.dart';

/// 排盘用例参数
class ArrangePanParams {
  final ShiJiaJu ju;
  final PlateType plateType;
  final PanSettings settings;

  const ArrangePanParams({
    required this.ju,
    required this.plateType,
    required this.settings,
  });
}

/// 排盘用例
class ArrangePanUseCase extends UseCase<QiMenPan, ArrangePanParams> {
  final QiMenCalculatorRepository _repository;

  ArrangePanUseCase(this._repository);

  @override
  Future<QiMenPan> execute(ArrangePanParams params) async {
    try {
      return await _repository.arrangePan(
        ju: params.ju,
        plateType: params.plateType,
        settings: params.settings,
      );
    } catch (e) {
      throw QiMenCalculationException('排盘失败: $e');
    }
  }
}
```

### Step 1.6: 验证 Phase 1

```bash
# 运行代码分析
flutter analyze

# 确保没有编译错误
flutter pub get
flutter packages pub run build_runner build

# 检查目录结构
tree lib/domain
tree lib/data
```

**预期结果**:
- ✅ 所有文件编译通过
- ✅ 没有分析错误
- ✅ 目录结构正确

---

## Phase 2: 实现数据层 (Day 3-4)

### Step 2.1: 创建 Mapper

**创建文件**: `lib/data/models/mappers/shi_jia_ju_mapper.dart`

```dart
import 'package:qimendunjia/domain/entities/shi_jia_ju.dart' as entity;
import 'package:qimendunjia/model/shi_jia_ju.dart' as model;
import 'package:uuid/uuid.dart';

/// ShiJiaJu Entity ↔ Model 转换器
class ShiJiaJuMapper {
  static const _uuid = Uuid();

  /// Model → Entity
  static entity.ShiJiaJu fromModel(model.ShiJiaJu modelJu) {
    return entity.ShiJiaJu(
      id: _uuid.v4(),
      panDateTime: modelJu.panDateTime,
      juNumber: modelJu.juNumber,
      fuTouJiaZi: modelJu.fuTouJiaZi,
      yinYangDun: modelJu.yinYangDun,
      jieQiAt: modelJu.jieQiAt,
      jieQiStartAt: modelJu.jieQiStartAt,
      jieQiEnd: modelJu.jieQiEnd,
      jieQiEndAt: modelJu.jieQiEndAt,
      atThreeYuan: modelJu.atThreeYuan,
      fourZhuEightChar: modelJu.fourZhuEightChar,
      panJuJieQi: modelJu.panJuJieQi,
      juDayNumber: modelJu.juDayNumber,
    );
  }

  /// Entity → Model
  static model.ShiJiaJu toModel(entity.ShiJiaJu entityJu) {
    return model.ShiJiaJu(
      panDateTime: entityJu.panDateTime,
      juNumber: entityJu.juNumber,
      fuTouJiaZi: entityJu.fuTouJiaZi,
      yinYangDun: entityJu.yinYangDun,
      jieQiAt: entityJu.jieQiAt,
      jieQiStartAt: entityJu.jieQiStartAt,
      jieQiEnd: entityJu.jieQiEnd,
      jieQiEndAt: entityJu.jieQiEndAt,
      atThreeYuan: entityJu.atThreeYuan,
      fourZhuEightChar: entityJu.fourZhuEightChar,
      panJuJieQi: entityJu.panJuJieQi,
      juDayNumber: entityJu.juDayNumber,
    );
  }
}
```

### Step 2.2: 创建数据源

**创建文件**: `lib/data/datasources/cache_data_source.dart`

```dart
/// 内存缓存数据源
class CacheDataSource {
  final Map<String, dynamic> _cache = {};
  final int _maxSize;
  final List<String> _accessOrder = [];

  CacheDataSource({int maxSize = 1000}) : _maxSize = maxSize;

  /// 获取缓存
  Future<T?> get<T>(String key) async {
    if (!_cache.containsKey(key)) {
      return null;
    }

    // 更新访问顺序 (LRU)
    _accessOrder.remove(key);
    _accessOrder.add(key);

    return _cache[key] as T?;
  }

  /// 设置缓存
  Future<void> set<T>(String key, T value) async {
    // 超出容量，删除最少使用的
    if (_cache.length >= _maxSize && !_cache.containsKey(key)) {
      final lruKey = _accessOrder.first;
      _cache.remove(lruKey);
      _accessOrder.remove(lruKey);
    }

    _cache[key] = value;
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  /// 清除缓存
  Future<void> clear() async {
    _cache.clear();
    _accessOrder.clear();
  }

  /// 获取缓存大小
  int get size => _cache.length;
}
```

**创建文件**: `lib/data/datasources/json_data_source.dart`

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:qimendunjia/model/door_star_ke_ying.dart';
import 'package:qimendunjia/model/eight_door_ke_ying.dart';
import 'package:qimendunjia/model/qi_yi_ru_gong.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying_ge_ju.dart';

/// JSON 数据源（负责加载和解析 JSON 文件）
class JsonDataSource {
  final AssetBundle _assetBundle;
  final Map<String, dynamic> _loadedData = {};

  static const String _basePath = 'packages/qimendunjia/assets/data';

  JsonDataSource(this._assetBundle);

  /// 加载十干克应
  Future<Map<TianGan, Map<TianGan, TenGanKeYing>>> loadTenGanKeYing() async {
    const key = 'ten_gan_ke_ying';
    if (_loadedData.containsKey(key)) {
      return _loadedData[key] as Map<TianGan, Map<TianGan, TenGanKeYing>>;
    }

    final jsonString = await _assetBundle.loadString('$_basePath/ten_gan_ke_ying.json');
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    final result = _parseTenGanKeYing(jsonData);
    _loadedData[key] = result;

    return result;
  }

  /// 加载门星克应
  Future<Map<EightDoorEnum, Map<NineStarsEnum, DoorStarKeYing>>> loadDoorStarKeYing() async {
    const key = 'door_star_ke_ying';
    if (_loadedData.containsKey(key)) {
      return _loadedData[key] as Map<EightDoorEnum, Map<NineStarsEnum, DoorStarKeYing>>;
    }

    final jsonString = await _assetBundle.loadString('$_basePath/door_star_ke_ying.json');
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    final result = _parseDoorStarKeYing(jsonData);
    _loadedData[key] = result;

    return result;
  }

  /// 加载三奇入宫
  Future<Map<HouTianGua, Map<TianGan, QiYiRuGong>>> loadQiYiRuGong() async {
    const key = 'qi_yi_ru_gong';
    if (_loadedData.containsKey(key)) {
      return _loadedData[key] as Map<HouTianGua, Map<TianGan, QiYiRuGong>>;
    }

    final jsonString = await _assetBundle.loadString('$_basePath/qi_yi_ru_gong.json');
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    final result = _parseQiYiRuGong(jsonData);
    _loadedData[key] = result;

    return result;
  }

  // 解析方法（从 ReadDataUtils 迁移）
  Map<TianGan, Map<TianGan, TenGanKeYing>> _parseTenGanKeYing(Map<String, dynamic> json) {
    // 实现解析逻辑...
    // 参考 utils/read_data_utils.dart 中的实现
    throw UnimplementedError('待实现');
  }

  Map<EightDoorEnum, Map<NineStarsEnum, DoorStarKeYing>> _parseDoorStarKeYing(Map<String, dynamic> json) {
    throw UnimplementedError('待实现');
  }

  Map<HouTianGua, Map<TianGan, QiYiRuGong>> _parseQiYiRuGong(Map<String, dynamic> json) {
    throw UnimplementedError('待实现');
  }

  /// 清除已加载数据
  void clearLoadedData() {
    _loadedData.clear();
  }
}
```

### 继续实施...

由于篇幅限制，完整的实施指南已包含在重构计划文档中。

---

## 验证检查清单

每完成一个 Phase，执行以下检查：

### ✅ 编译检查
```bash
flutter analyze
flutter packages pub run build_runner build
```

### ✅ 测试检查
```bash
flutter test
```

### ✅ 功能检查
- 旧 UI 是否正常显示
- 起盘功能是否正常
- 选择宫位是否正常
- 格局显示是否正常

---

**文档版本**: v1.0
**创建日期**: 2025-10-01
