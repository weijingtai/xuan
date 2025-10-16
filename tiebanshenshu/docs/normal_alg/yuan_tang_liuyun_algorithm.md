# 元堂卦流运系统算法文档

## 文档信息
- **文档名称**: 元堂卦流运系统算法文档
- **版本**: v1.0
- **创建日期**: 2025-10-12
- **作者**: Claude
- **目标读者**: 开发人员、算法维护者

---
# 元堂卦流运系统算法文档
## 元堂流年 倪海厦有另外的排法
http://www.360doc.com/content/23/1218/17/21686608_1107997200.shtml
## 元堂流日 
http://www.360doc.com/content/23/1218/17/21686608_1107997200.shtml
## 1. 算法概述

### 1.1 系统架构
元堂卦流运系统包含三个层次的运势推演:

```
先天卦/后天卦 (基础)
    ↓
大运卦系统 (6-9年/期, 共12期)
    ↓
流年卦系统 (1年/卦, 每大运6-9个)
    ↓
流月卦系统 (1月/卦, 每流年12个)
```

### 1.2 核心修正: 至尊卦换卦规则
**问题:** 现有实现中,所有卦的后天卦生成规则统一为"爻变+上下卦互换"

**修正:** 坎坎、坎震、坎艮三个至尊卦在特定条件下有特殊换卦规则

---

## 2. 至尊卦换卦算法

### 2.1 算法描述

#### 2.1.1 触发条件
```
IF (先天卦 in [坎坎, 坎震, 坎艮])
   AND (元堂爻索引 in [4, 5])  // 九五或上六
THEN
   使用至尊卦特殊换卦规则
ELSE
   使用通用换卦规则(爻变+上下卦互换)
```

#### 2.1.2 月份判定
```dart
/// 从地支提取月份数字
int getMonthNumberFromZhi(String zhi) {
  const zhiToMonth = {
    '子': 11, '丑': 12,
    '寅': 1,  '卯': 2,  '辰': 3,  '巳': 4,
    '午': 5,  '未': 6,  '申': 7,  '酉': 8,
    '戌': 9,  '亥': 10,
  };
  return zhiToMonth[zhi]!;
}

/// 判断月份阴阳
bool isYangMonth(int month) {
  return [1, 3, 5, 7, 9, 11].contains(month);
}
```

#### 2.1.3 换卦规则矩阵

| 卦名 | 元堂爻 | 出生月 | 爻变 | 上下卦互换 | 后天卦 |
|-----|--------|--------|------|-----------|--------|
| 坎坎 | 九五(4) | 阴月 | 阳→阴 | ❌ 不互换 | 坤坎(师) |
| 坎坎 | 九五(4) | 阳月 | 阳→阴 | ✅ 互换 | 坎坤(比) |
| 坎坎 | 上六(5) | 阴月 | 阴→阳 | ✅ 互换 | 巽坎(井) |
| 坎坎 | 上六(5) | 阳月 | 阴→阳 | ❌ 不互换 | 坎巽(涣) |
| 坎震 | 九五(4) | 阴月 | 阳→阴 | ❌ 不互换 | 坤震(复) |
| 坎震 | 九五(4) | 阳月 | 阳→阴 | ✅ 互换 | 震坤(豫) |
| 坎震 | 上六(5) | 阴月 | 阴→阳 | ✅ 互换 | 震巽(恒) |
| 坎震 | 上六(5) | 阳月 | 阴→阳 | ❌ 不互换 | 坎巽(益) |
| 坎艮 | 九五(4) | 阴月 | 阳→阴 | ❌ 不互换 | 坤艮(谦) |
| 坎艮 | 九五(4) | 阳月 | 阳→阴 | ✅ 互换 | 艮坤(剥) |
| 坎艮 | 上六(5) | 阴月 | 阴→阳 | ✅ 互换 | 艮巽(蛊) |
| 坎艮 | 上六(5) | 阳月 | 阴→阳 | ❌ 不互换 | 坎巽(渐) |

#### 2.1.4 规律总结
```
九五爻(阳爻):
  阴月 → 爻变, 不互换
  阳月 → 爻变, 互换

上六爻(阴爻):
  阴月 → 爻变, 互换
  阳月 → 爻变, 不互换

记忆口诀: "九五阴不换阳换, 上六阴换阳不换"
```

### 2.2 算法实现

#### 2.2.1 核心方法
```dart
/// 生成后天卦(修改版,支持至尊卦)
static (String, int, int) generateHoutianGua({
  required String xiantianGua,
  required int yuantangYaoIndex,
  required int birthMonth,
}) {
  // 判断是否为至尊卦且在特殊爻位
  final isZhiZunGua = ['坎坎', '坎震', '坎艮'].contains(xiantianGua);
  final isSpecialYao = (yuantangYaoIndex == 4 || yuantangYaoIndex == 5);

  if (isZhiZunGua && isSpecialYao) {
    return _generateHoutianGuaForZhiZunGua(
      xiantianGua,
      yuantangYaoIndex,
      birthMonth,
    );
  }

  // 原有通用逻辑: 爻变 + 上下卦互换
  final binaryList = gua_utils.guaToBinaryList(xiantianGua);
  final binaryIndex = 5 - yuantangYaoIndex;
  binaryList[binaryIndex] = binaryList[binaryIndex] == 0 ? 1 : 0;

  final oldUpon = binaryList.sublist(0, 3).join();
  final oldUnder = binaryList.sublist(3).join();
  final oldUponGua = constants.binaryStrGuaMapper[oldUpon]!;
  final oldUnderGua = constants.binaryStrGuaMapper[oldUnder]!;

  // 上下卦互换
  final houtianGua = oldUnderGua + oldUponGua;

  final houtianUpperGuaNumber = constants.houTianGuaNumberMapper[houtianGua[0]]!;
  final houtianLowerGuaNumber = constants.houTianGuaNumberMapper[houtianGua[1]]!;

  return (houtianGua, houtianUpperGuaNumber, houtianLowerGuaNumber);
}

/// 至尊卦专用后天卦生成
static (String, int, int) _generateHoutianGuaForZhiZunGua(
  String xiantianGua,
  int yuantangYaoIndex,
  int birthMonth,
) {
  // 判断月份阴阳
  final isYangMonth = [1, 3, 5, 7, 9, 11].contains(birthMonth);

  // 爻变
  final binaryList = gua_utils.guaToBinaryList(xiantianGua);
  final binaryIndex = 5 - yuantangYaoIndex;
  binaryList[binaryIndex] = binaryList[binaryIndex] == 0 ? 1 : 0;

  final oldUpon = binaryList.sublist(0, 3).join();
  final oldUnder = binaryList.sublist(3).join();
  final oldUponGua = constants.binaryStrGuaMapper[oldUpon]!;
  final oldUnderGua = constants.binaryStrGuaMapper[oldUnder]!;

  // 根据爻位和月份决定是否互换
  String houtianGua;

  if (yuantangYaoIndex == 4) {
    // 九五爻: 阴月不换, 阳月互换
    if (isYangMonth) {
      houtianGua = oldUnderGua + oldUponGua; // 互换
    } else {
      houtianGua = oldUponGua + oldUnderGua; // 不互换
    }
  } else {
    // 上六爻: 阴月互换, 阳月不换
    if (isYangMonth) {
      houtianGua = oldUponGua + oldUnderGua; // 不互换
    } else {
      houtianGua = oldUnderGua + oldUponGua; // 互换
    }
  }

  final houtianUpperGuaNumber = constants.houTianGuaNumberMapper[houtianGua[0]]!;
  final houtianLowerGuaNumber = constants.houTianGuaNumberMapper[houtianGua[1]]!;

  return (houtianGua, houtianUpperGuaNumber, houtianLowerGuaNumber);
}
```

#### 2.2.2 测试用例
```dart
group('至尊卦换卦规则', () {
  test('坎卦九五阴月-师卦不互换', () {
    final (houtianGua, _, _) = YuanTangGuaHelper.generateHoutianGua(
      xiantianGua: '坎坎',
      yuantangYaoIndex: 4,
      birthMonth: 2, // 卯月(阴月)
    );
    expect(houtianGua, '坤坎'); // 师卦
  });

  test('坎卦九五阳月-比卦互换', () {
    final (houtianGua, _, _) = YuanTangGuaHelper.generateHoutianGua(
      xiantianGua: '坎坎',
      yuantangYaoIndex: 4,
      birthMonth: 1, // 寅月(阳月)
    );
    expect(houtianGua, '坎坤'); // 比卦
  });

  test('坎卦上六阴月-井卦互换', () {
    final (houtianGua, _, _) = YuanTangGuaHelper.generateHoutianGua(
      xiantianGua: '坎坎',
      yuantangYaoIndex: 5,
      birthMonth: 2, // 卯月(阴月)
    );
    expect(houtianGua, '巽坎'); // 井卦
  });

  test('坎卦上六阳月-涣卦不互换', () {
    final (houtianGua, _, _) = YuanTangGuaHelper.generateHoutianGua(
      xiantianGua: '坎坎',
      yuantangYaoIndex: 5,
      birthMonth: 1, // 寅月(阳月)
    );
    expect(houtianGua, '坎巽'); // 涣卦
  });

  // 屯卦、蹇卦的测试用例类似...
});
```

---

## 3. 流年卦算法

### 3.1 算法描述

#### 3.1.1 基本概念
- **大运期**: 每个爻对应一个大运期,阳爻9年,阴爻6年
- **流年卦**: 大运期内每个虚岁年龄对应一个卦
- **卦源**: 流年卦从先天卦或后天卦变化而来

#### 3.1.2 年份阴阳判定
```dart
/// 判断年份是否为阳年
bool isYangGanYear(int year) {
  // 根据天干判断: 甲丙戊庚壬为阳, 乙丁己辛癸为阴
  // 公元4年为甲子年(天干索引0)
  final ganIndex = (year - 4) % 10;
  return [0, 2, 4, 6, 8].contains(ganIndex); // 甲丙戊庚壬
}
```

**天干与索引对应:**
```
索引: 0   1   2   3   4   5   6   7   8   9
天干: 甲  乙  丙  丁  戊  己  庚  辛  壬  癸
阴阳: 阳  阴  阳  阴  阳  阴  阳  阴  阳  阴
```

#### 3.1.3 爻变通用方法
```dart
/// 对指定爻位进行爻变
String changeYao(String gua, int yaoIndex) {
  final binaryList = gua_utils.guaToBinaryList(gua);
  final binaryIndex = 5 - yaoIndex; // 转换索引(从下到上 → 从上到下)

  // 爻变: 阴变阳, 阳变阴
  binaryList[binaryIndex] = binaryList[binaryIndex] == 0 ? 1 : 0;

  // 重组卦象
  final upper = binaryList.sublist(0, 3).join();
  final lower = binaryList.sublist(3).join();
  final upperGua = constants.binaryStrGuaMapper[upper]!;
  final lowerGua = constants.binaryStrGuaMapper[lower]!;

  return upperGua + lowerGua;
}
```

### 3.2 阳爻大运的流年卦

#### 3.2.1 算法规则
```
阳爻大运(9年):
1. 判断大运初年的阴阳(出生年 + 大运起始年龄 - 1)
2. 如果初年为阳年:
   - 第1年: 直接使用先天卦/后天卦,不变换
   - 第2-9年: 依次变换爻位
3. 如果初年为阴年:
   - 第1年: 先变换大运爻
   - 第2-9年: 依次变换爻位

变换顺序(循环):
  (大运爻-2) → 大运爻 → (大运爻+1) → (大运爻+2) → (大运爻-2) → ...

注意: 爻位索引采用模运算, (yaoIndex + offset + 6) % 6
```

#### 3.2.2 实现代码
```dart
/// 计算阳爻大运的流年卦
List<YuanTangLiunianGua> _calculateLiunianForYangYaoDayun(
  YuanTangDayunPeriod dayun,
  String baseGua,
  String guaSource,
  int birthYear,
) {
  final liunianList = <YuanTangLiunianGua>[];

  // 判断大运初年的阴阳
  final dayunStartYear = birthYear + dayun.startAge - 1;
  final isYangStartYear = _isYangGanYear(dayunStartYear);

  String currentGua = baseGua;
  int? firstChangedYaoIndex;

  // 第1年
  if (!isYangStartYear) {
    // 初年为阴年: 先变换大运爻
    currentGua = _changeYao(baseGua, dayun.yaoPosition);
    firstChangedYaoIndex = dayun.yaoPosition;
  }

  liunianList.add(YuanTangLiunianGua(
    age: dayun.startAge,
    yearIndex: 0,
    gua: currentGua,
    guaSource: guaSource,
    dayunPeriod: dayun,
    changedYaoIndex: firstChangedYaoIndex ?? -1,
    previousGua: null,
  ));

  // 第2-9年: 按顺序变换爻位
  final changeSequence = [
    (dayun.yaoPosition - 2 + 6) % 6, // 大运爻-2
    dayun.yaoPosition,                // 大运爻
    (dayun.yaoPosition + 1) % 6,      // 大运爻+1
    (dayun.yaoPosition + 2) % 6,      // 大运爻+2
  ];

  for (int i = 1; i < 9; i++) {
    final previousGua = currentGua;
    final yaoToChange = changeSequence[(i - 1) % 4];
    currentGua = _changeYao(currentGua, yaoToChange);

    liunianList.add(YuanTangLiunianGua(
      age: dayun.startAge + i,
      yearIndex: i,
      gua: currentGua,
      guaSource: guaSource,
      dayunPeriod: dayun,
      changedYaoIndex: yaoToChange,
      previousGua: previousGua,
    ));
  }

  return liunianList;
}
```

#### 3.2.3 示例推演
```
大运: 上爻(阳爻), 1-9岁
出生年: 甲子年(阳年)
基础卦: 震坤

大运初年 = 甲子年(阳年)

第1年(1岁): 震坤 (不变换,因为初年为阳年)
第2年(2岁): 震坤 变换四爻(上爻-2) → 新卦
第3年(3岁): 上一卦 变换上爻(大运爻) → 新卦
第4年(4岁): 上一卦 变换初爻(上爻+1) → 新卦
第5年(5岁): 上一卦 变换二爻(上爻+2) → 新卦
第6年(6岁): 上一卦 变换四爻(上爻-2) → 新卦 [循环]
第7年(7岁): 上一卦 变换上爻(大运爻) → 新卦
第8年(8岁): 上一卦 变换初爻(上爻+1) → 新卦
第9年(9岁): 上一卦 变换二爻(上爻+2) → 新卦
```

### 3.3 阴爻大运的流年卦

#### 3.3.1 算法规则
```
阴爻大运(6年):
1. 不论大运初年是阴年还是阳年
2. 第1年: 先变换大运爻
3. 第2-6年: 依次变换大运爻的下一爻、下两爻...

变换顺序:
  大运爻 → (大运爻+1) → (大运爻+2) → (大运爻+3) → (大运爻+4) → (大运爻+5)
```

#### 3.3.2 实现代码
```dart
/// 计算阴爻大运的流年卦
List<YuanTangLiunianGua> _calculateLiunianForYinYaoDayun(
  YuanTangDayunPeriod dayun,
  String baseGua,
  String guaSource,
  int birthYear,
) {
  final liunianList = <YuanTangLiunianGua>[];

  // 第1年: 先变换大运爻(不论初年阴阳)
  String currentGua = _changeYao(baseGua, dayun.yaoPosition);

  liunianList.add(YuanTangLiunianGua(
    age: dayun.startAge,
    yearIndex: 0,
    gua: currentGua,
    guaSource: guaSource,
    dayunPeriod: dayun,
    changedYaoIndex: dayun.yaoPosition,
    previousGua: null,
  ));

  // 第2-6年: 逐爻变换
  for (int i = 1; i < 6; i++) {
    final previousGua = currentGua;
    final yaoToChange = (dayun.yaoPosition + i) % 6;
    currentGua = _changeYao(currentGua, yaoToChange);

    liunianList.add(YuanTangLiunianGua(
      age: dayun.startAge + i,
      yearIndex: i,
      gua: currentGua,
      guaSource: guaSource,
      dayunPeriod: dayun,
      changedYaoIndex: yaoToChange,
      previousGua: previousGua,
    ));
  }

  return liunianList;
}
```

#### 3.3.3 示例推演
```
大运: 初爻(阴爻), 7-12岁
基础卦: 震坤

第1年(7岁): 震坤 变换初爻 → 新卦
第2年(8岁): 上一卦 变换二爻(初爻+1) → 新卦
第3年(9岁): 上一卦 变换三爻(初爻+2) → 新卦
第4年(10岁): 上一卦 变换四爻(初爻+3) → 新卦
第5年(11岁): 上一卦 变换五爻(初爻+4) → 新卦
第6年(12岁): 上一卦 变换上爻(初爻+5) → 新卦
```

### 3.4 完整流年卦计算流程

```dart
/// 计算所有流年卦(先天卦6个爻 + 后天卦6个爻)
List<YuanTangLiunianGua> calculateAllLiunianGua(
  YuanTangBaseNumberModel model,
  int birthYear,
) {
  final allLiunianList = <YuanTangLiunianGua>[];

  // 先天卦的6个大运
  for (final dayun in model.xiantianDayunList) {
    final liunianList = _calculateLiunianForDayun(
      dayun,
      model.xiantianGua,
      '先天卦',
      birthYear,
    );
    allLiunianList.addAll(liunianList);
  }

  // 后天卦的6个大运
  for (final dayun in model.houtianDayunList) {
    final liunianList = _calculateLiunianForDayun(
      dayun,
      model.houtianGua,
      '后天卦',
      birthYear,
    );
    allLiunianList.addAll(liunianList);
  }

  return allLiunianList;
}

/// 根据大运的阴阳性分派计算
List<YuanTangLiunianGua> _calculateLiunianForDayun(
  YuanTangDayunPeriod dayun,
  String baseGua,
  String guaSource,
  int birthYear,
) {
  if (dayun.yinYang == '阳') {
    return _calculateLiunianForYangYaoDayun(dayun, baseGua, guaSource, birthYear);
  } else {
    return _calculateLiunianForYinYaoDayun(dayun, baseGua, guaSource, birthYear);
  }
}
```

---

## 4. 流月卦算法

### 4.1 算法描述

#### 4.1.1 基本规则
```
流月卦计算基于流年卦:
1. 阳月卦(1,3,5,7,9,11月): 从正月卦开始, 逐月变换下一爻
2. 阴月卦(2,4,6,8,10,12月): 取对应阳月卦, 变换其"应爻"

正月卦起法:
  变换(元堂爻 - 1)的爻位 → 正月卦
```

#### 4.1.2 应爻对应关系
```
传统六爻术数中的应爻:
  初爻(0) ←→ 四爻(3)
  二爻(1) ←→ 五爻(4)
  三爻(2) ←→ 上爻(5)

计算公式: yingYaoIndex = (yaoIndex + 3) % 6
```

### 4.2 算法实现

#### 4.2.1 应爻计算
```dart
/// 获取应爻位置
int getYingYaoIndex(int yaoIndex) {
  return (yaoIndex + 3) % 6;
}
```

#### 4.2.2 流月卦计算
```dart
/// 计算指定年龄的12个流月卦
List<YuanTangLiuyueGua> calculateLiuyueForAge(
  int targetAge,
  String liunianGua,      // 该年的流年卦
  int yuantangYaoIndex,   // 元堂爻位置
) {
  final liuyueList = <YuanTangLiuyueGua>[];

  // 步骤1: 计算正月卦(变换元堂爻前一爻)
  final zhengYueYaoIndex = (yuantangYaoIndex - 1 + 6) % 6;
  String zhengYueGua = _changeYao(liunianGua, zhengYueYaoIndex);

  liuyueList.add(YuanTangLiuyueGua(
    month: 1,
    isYangMonth: true,
    gua: zhengYueGua,
    age: targetAge,
    changedYaoIndex: zhengYueYaoIndex,
    sourceGua: liunianGua,
    yingYaoIndex: null,
  ));

  // 步骤2: 计算其他阳月卦(3,5,7,9,11月)
  String currentYangGua = zhengYueGua;
  int lastChangedYaoIndex = zhengYueYaoIndex;

  for (int month in [3, 5, 7, 9, 11]) {
    final previousGua = currentYangGua;
    // 逐月向前变换(变换上一次变换爻的下一爻)
    final nextYaoIndex = (lastChangedYaoIndex + 1) % 6;
    currentYangGua = _changeYao(currentYangGua, nextYaoIndex);

    liuyueList.add(YuanTangLiuyueGua(
      month: month,
      isYangMonth: true,
      gua: currentYangGua,
      age: targetAge,
      changedYaoIndex: nextYaoIndex,
      sourceGua: previousGua,
      yingYaoIndex: null,
    ));

    lastChangedYaoIndex = nextYaoIndex;
  }

  // 步骤3: 计算阴月卦(2,4,6,8,10,12月)
  final yangMonths = [1, 3, 5, 7, 9, 11];
  final yinMonths = [2, 4, 6, 8, 10, 12];

  for (int i = 0; i < 6; i++) {
    final yangMonth = yangMonths[i];
    final yinMonth = yinMonths[i];

    // 找到对应阳月卦
    final yangGua = liuyueList.firstWhere((g) => g.month == yangMonth).gua;

    // 计算该阳月的变爻位置
    final yangYaoIndex = i == 0
        ? zhengYueYaoIndex
        : (zhengYueYaoIndex + i) % 6;

    // 变换应爻
    final yingYaoIndex = _getYingYaoIndex(yangYaoIndex);
    final yinGua = _changeYao(yangGua, yingYaoIndex);

    liuyueList.add(YuanTangLiuyueGua(
      month: yinMonth,
      isYangMonth: false,
      gua: yinGua,
      age: targetAge,
      changedYaoIndex: yingYaoIndex,
      sourceGua: yangGua,
      yingYaoIndex: yingYaoIndex,
    ));
  }

  // 按月份排序
  liuyueList.sort((a, b) => a.month.compareTo(b.month));

  return liuyueList;
}
```

### 4.3 示例推演

```
假设:
  流年卦: 震坤
  元堂爻: 三爻(索引2)

正月卦:
  变换二爻(元堂爻-1) → 正月卦A

二月卦:
  正月卦A 变换其应爻(二爻的应爻=五爻) → 二月卦

三月卦:
  正月卦A 变换三爻(二爻+1) → 三月卦B

四月卦:
  三月卦B 变换其应爻(三爻的应爻=上爻) → 四月卦

五月卦:
  三月卦B 变换四爻(三爻+1) → 五月卦C

六月卦:
  五月卦C 变换其应爻(四爻的应爻=初爻) → 六月卦

... (以此类推)
```

---

## 5. 数据结构设计

### 5.1 流年卦数据结构
```dart
class YuanTangLiunianGua {
  /// 虚岁年龄
  final int age;

  /// 在大运中的年份索引(0-8或0-5)
  final int yearIndex;

  /// 流年卦象(如"震坤")
  final String gua;

  /// 卦象来源("先天卦"/"后天卦")
  final String guaSource;

  /// 所属大运期
  final YuanTangDayunPeriod dayunPeriod;

  /// 本年变换的爻位(-1表示未变换,如阳爻大运阳年起算的第1年)
  final int changedYaoIndex;

  /// 上一年的卦象(第1年为null)
  final String? previousGua;

  const YuanTangLiunianGua({
    required this.age,
    required this.yearIndex,
    required this.gua,
    required this.guaSource,
    required this.dayunPeriod,
    required this.changedYaoIndex,
    this.previousGua,
  });

  /// 获取爻位标签
  String get yaoLabel {
    if (changedYaoIndex == -1) return '未变换';
    return ['初', '二', '三', '四', '五', '上'][changedYaoIndex];
  }

  /// 是否为大运首年
  bool get isFirstYearOfDayun => yearIndex == 0;

  @override
  String toString() {
    if (changedYaoIndex == -1) {
      return '$age岁: $gua (${guaSource}, 未变换)';
    }
    return '$age岁: $gua (${guaSource}, 变${yaoLabel}爻)';
  }
}
```

### 5.2 流月卦数据结构
```dart
class YuanTangLiuyueGua {
  /// 月份(1-12)
  final int month;

  /// 月份阴阳
  final bool isYangMonth;

  /// 流月卦象
  final String gua;

  /// 所属年龄
  final int age;

  /// 本月变换的爻位
  final int changedYaoIndex;

  /// 源卦(阴月取自对应阳月卦, 阳月取自上一个阳月卦或流年卦)
  final String? sourceGua;

  /// 应爻位置(仅阴月有效)
  final int? yingYaoIndex;

  const YuanTangLiuyueGua({
    required this.month,
    required this.isYangMonth,
    required this.gua,
    required this.age,
    required this.changedYaoIndex,
    this.sourceGua,
    this.yingYaoIndex,
  });

  /// 获取爻位标签
  String get yaoLabel => ['初', '二', '三', '四', '五', '上'][changedYaoIndex];

  /// 获取月份类型标签
  String get monthTypeLabel => isYangMonth ? '阳月' : '阴月';

  /// 获取变化描述
  String get changeDescription {
    if (isYangMonth) {
      return '变${yaoLabel}爻';
    } else {
      final yingYaoLabel = ['初', '二', '三', '四', '五', '上'][yingYaoIndex!];
      return '由${month - 1}月卦应爻变换(变${yingYaoLabel}爻)';
    }
  }

  @override
  String toString() {
    return '$month月($monthTypeLabel): $gua - $changeDescription';
  }
}
```

---

## 6. 性能优化

### 6.1 计算策略
```
1. 流年卦: 全量计算
   - 用户打开元堂卦结果页时,一次性计算所有流年卦
   - 最多108个流年卦(12个大运 × 9年)
   - 计算时间 < 100ms

2. 流月卦: 按需计算
   - 用户点击某个流年卦时,才计算该年的12个流月卦
   - 每次计算12个流月卦
   - 计算时间 < 50ms

3. 缓存机制
   - 流年卦结果缓存在YuanTangBaseNumberModel中
   - 流月卦结果缓存在ViewModel中(Map<int, List<YuanTangLiuyueGua>>)
```

### 6.2 算法复杂度分析
```
至尊卦换卦:
  时间复杂度: O(1)
  空间复杂度: O(1)

流年卦计算(单个大运):
  时间复杂度: O(n), n为年数(6或9)
  空间复杂度: O(n)

流年卦计算(全部):
  时间复杂度: O(12 × 9) = O(108) = O(1)
  空间复杂度: O(108)

流月卦计算:
  时间复杂度: O(12)
  空间复杂度: O(12)
```

---

## 7. 测试策略

### 7.1 单元测试覆盖

#### 至尊卦换卦规则
```dart
- [ ] 坎卦九五阴月 → 师卦(不互换)
- [ ] 坎卦九五阳月 → 比卦(互换)
- [ ] 坎卦上六阴月 → 井卦(互换)
- [ ] 坎卦上六阳月 → 涣卦(不互换)
- [ ] 屯卦九五阴月 → 复卦(不互换)
- [ ] 屯卦九五阳月 → 豫卦(互换)
- [ ] 屯卦上六阴月 → 恒卦(互换)
- [ ] 屯卦上六阳月 → 益卦(不互换)
- [ ] 蹇卦九五阴月 → 谦卦(不互换)
- [ ] 蹇卦九五阳月 → 剥卦(互换)
- [ ] 蹇卦上六阴月 → 蛊卦(互换)
- [ ] 蹇卦上六阳月 → 渐卦(不互换)
- [ ] 非至尊卦应使用通用规则
```

#### 流年卦计算
```dart
- [ ] 阳爻大运+阳年起算: 第1年不变换
- [ ] 阳爻大运+阴年起算: 第1年变换大运爻
- [ ] 阳爻大运爻变顺序: (爻-2)→爻→(爻+1)→(爻+2)→循环
- [ ] 阴爻大运: 第1年变换大运爻,后续逐爻变换
- [ ] 流年卦数量: 阳爻9个,阴爻6个
- [ ] 先天卦6个大运流年卦总数正确
- [ ] 后天卦6个大运流年卦总数正确
```

#### 流月卦计算
```dart
- [ ] 正月卦 = 变换(元堂爻-1)
- [ ] 阳月卦逐爻变换(6个)
- [ ] 阴月卦从对应阳月卦应爻变换(6个)
- [ ] 应爻对应关系: 初↔四, 二↔五, 三↔上
- [ ] 流月卦总数 = 12个
- [ ] 月份排序正确(1-12)
```

### 7.2 集成测试
```dart
- [ ] 完整四柱输入 → 输出所有流年卦
- [ ] 所有流年卦的大运归属正确
- [ ] 年龄连续性: 1岁→2岁→...→N岁
- [ ] 卦源标记正确(先天卦/后天卦)
```

### 7.3 边界测试
```dart
- [ ] 元堂在初爻(索引0)
- [ ] 元堂在上爻(索引5)
- [ ] 全阳爻卦(乾卦)
- [ ] 全阴爻卦(坤卦)
- [ ] 流年跨度极限(最大108岁)
```

---

## 8. 常见问题(FAQ)

### Q1: 为什么至尊卦需要特殊处理?
**A:** 传统术数中,坎卦(水)具有特殊地位,坎坎、坎震、坎艮三个卦在元堂爻位于九五或上六时,其变化规则与月份阴阳相关,这是古法的特殊规定。

### Q2: 流年卦的变换顺序为什么是(爻-2)→爻→(爻+1)→(爻+2)?
**A:** 这是元堂卦流年推演的传统规则,依次变换"大运爻的前两爻、大运爻本身、后一爻、后两爻",体现了运势的周期性起伏。

### Q3: 为什么阴月卦要变换"应爻"?
**A:** 六爻术数中,阴阳相对应是基本原理。阴月卦从阳月卦的"应爻"变换,体现了阴阳互补的哲学思想。

### Q4: 如何验证算法实现是否正确?
**A:**
1. 使用文档中的示例数据(如"甲子年出生,元堂在六爻")进行推演
2. 对比每一步的中间结果
3. 检查关键节点:第1年卦、变换顺序、大运交接处
4. 使用已知正确案例进行回归测试

### Q5: 流年卦计算会不会很慢?
**A:**
- 理论最大计算量: 12个大运 × 9年 = 108个流年卦
- 每个流年卦计算时间 < 1ms
- 总计算时间 < 100ms,对用户无感知

---

## 9. 版本历史

| 版本 | 日期 | 修订内容 |
|-----|------|---------|
| v1.0 | 2025-10-12 | 初始版本,完整算法文档 |

---

## 10. 参考资料

1. 元堂卦原始算法文档(用户提供)
2. 六爻应爻理论(传统术数)
3. 干支历法与节气系统
4. 现有实现:
   - `lib/service/strategy/yuan_tang_strategy.dart`
   - `lib/utils/yuan_tang_gua_helper.dart`
   - `lib/domain/models/yuan_tang_base_number_model.dart`
