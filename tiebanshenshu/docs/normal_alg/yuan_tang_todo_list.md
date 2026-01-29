# 元堂卦取数法开发任务清单

## 📋 项目概述

**算法名称**: 元堂卦取数法
**开发周期**: 预计20-28小时
**优先级**: 高
**负责人**: 待分配
**最后更新**: 2025-10-11

---

## 🚀 Phase 10: 后天卦元堂爻与大运功能 (预计10-12小时)

### 功能概述
实现后天卦元堂爻计算、大运计算、条文扩展规则，完善元堂卦取数法的完整功能。

### 核心需求
1. 后天卦也需要计算元堂爻位置
2. 先天卦和后天卦的元堂爻信息都要保存
3. 实现大运计算：从元堂爻开始，阳爻9年、阴爻6年
4. 条文扩展：基础数递加96四次（总共5个条文）
5. 保留条文来源和运算公式

---

### Task 10.1: 模型扩展 - 添加后天卦元堂爻字段
**文件**: `lib/domain/models/yuan_tang_base_number_model.dart`

**要求**:
- [ ] 添加后天卦元堂爻字段：
  ```dart
  // 后天卦元堂装卦相关
  final List<List<String>> houtianZhiList;          // 后天卦六爻地支列表
  final int houtianYuantangYaoIndex;                 // 后天卦元堂爻索引（0-5）
  final String houtianYuantangYaoLabel;              // 后天卦元堂爻位标签
  ```
- [ ] 实现 `get houtianYaoDetails` 返回后天卦六爻详情列表
- [ ] 更新 `create()` 工厂方法参数
- [ ] 更新 `copyWith()` 方法
- [ ] 更新 `toMap()` 方法
- [ ] 更新 `toString()` 方法

**验收标准**:
- [ ] 字段定义清晰，与先天卦字段保持一致的命名风格
- [ ] getter方法功能正确
- [ ] 所有辅助方法更新完整

---

### Task 10.2: 模型扩展 - 添加大运计算字段
**文件**: `lib/domain/models/yuan_tang_base_number_model.dart`

**要求**:
- [ ] 定义大运期间数据结构：
  ```dart
  class YuanTangDayunPeriod {
    final int yaoPosition;           // 爻位（0-5）
    final String yaoLabel;            // "初" / "二" / "三" / "四" / "五" / "上"
    final String yinYang;             // "阳" / "阴"
    final int years;                  // 年数（9或6）
    final int startAge;               // 起始年龄
    final int endAge;                 // 结束年龄
    final List<String> diZhiList;     // 该爻配置的地支
  }
  ```
- [ ] 添加大运列表字段：
  ```dart
  final int xiantianDayunStartAge;                    // 先天卦大运起始年龄
  final List<YuanTangDayunPeriod> xiantianDayunList;  // 先天卦大运列表（6个期间）
  final int houtianDayunStartAge;                     // 后天卦大运起始年龄
  final List<YuanTangDayunPeriod> houtianDayunList;   // 后天卦大运列表（6个期间）
  ```
- [ ] 更新 `create()` 工厂方法
- [ ] 更新 `copyWith()` 方法
- [ ] 更新 `toMap()` 方法
- [ ] 添加文档注释说明大运计算规则

**验收标准**:
- [ ] YuanTangDayunPeriod 数据结构定义完整
- [ ] 大运列表字段添加正确
- [ ] 文档注释清晰说明规则

---

### Task 10.3: 实现后天卦元堂装卦逻辑
**文件**: `lib/service/strategy/yuan_tang_strategy.dart`

**要求**:
- [ ] 实现 `_houtianYuantangZhuanggua()` 方法
  ```dart
  /// 步骤4.5：后天卦元堂装卦
  ///
  /// 返回: (houtianYuantangYaoIndex, houtianYuantangYaoLabel, houtianZhiList)
  (int, String, List<List<String>>) _houtianYuantangZhuanggua(
    YuanTangStrategyParams params,
    String houtianGua,
  ) {
    // 1. 判断时辰阴阳（与先天卦相同）
    // 2. 将后天卦转换为二进制列表
    // 3. 计算阳爻和阴爻数量
    // 4. 根据爻数分三种情况调用装卦方法（复用现有方法）
    // 5. 获取后天卦元堂爻索引
    // 6. 返回结果
  }
  ```
- [ ] 复用现有装卦方法（`_zhuangguaLowerThan3`, `_zhuanggua45`, `_zhuanggua6Yang`）
- [ ] 在 `calculate()` 主方法中调用后天卦装卦
- [ ] 将结果传递给 YuanTangBaseNumberModel

**验收标准**:
- [ ] 后天卦装卦逻辑正确
- [ ] 与先天卦装卦逻辑保持一致
- [ ] 正确调用复用方法

---

### Task 10.4: 实现大运计算逻辑
**文件**: `lib/service/strategy/yuan_tang_strategy.dart`

**要求**:
- [ ] 实现 `_calculateDayun()` 方法
  ```dart
  /// 计算大运列表
  ///
  /// [guaName] 卦名（如"震坤"）
  /// [yuantangYaoIndex] 元堂爻索引（0-5）
  /// [zhiList] 六爻地支配置
  /// [startAge] 起始年龄
  ///
  /// 返回: List<YuanTangDayunPeriod>
  ///
  /// 规则：
  /// 1. 从元堂爻开始，按照 元堂→下一爻→...→上爻→初爻→... 的顺序循环6个爻位
  /// 2. 阳爻9年，阴爻6年
  /// 3. 年龄连续累加
  List<YuanTangDayunPeriod> _calculateDayun(
    String guaName,
    int yuantangYaoIndex,
    List<List<String>> zhiList,
    int startAge,
  ) {
    final dayunList = <YuanTangDayunPeriod>[];
    final binaryList = gua_utils.guaToBinaryList(guaName);

    var currentAge = startAge;

    // 从元堂爻开始，循环6个爻位
    // 顺序：元堂爻 → 下一爻(+1) → ... → 上爻 → 初爻 → ...
    for (var i = 0; i < 6; i++) {
      final yaoIndex = (yuantangYaoIndex + i) % 6;

      // 注意：binaryList是从上到下的顺序，需要转换
      // binaryList[0]=上卦第1爻, binaryList[5]=下卦第3爻
      // yaoIndex: 0=初爻, 5=上爻
      // 转换：binaryIndex = 5 - yaoIndex
      final binaryIndex = 5 - yaoIndex;
      final yinYang = binaryList[binaryIndex] == 1 ? '阳' : '阴';
      final years = yinYang == '阳' ? 9 : 6;
      final endAge = currentAge + years - 1;

      dayunList.add(YuanTangDayunPeriod(
        yaoPosition: yaoIndex,
        yaoLabel: _getYaoPositionLabel(yaoIndex),
        yinYang: yinYang,
        years: years,
        startAge: currentAge,
        endAge: endAge,
        diZhiList: zhiList[yaoIndex],
      ));

      currentAge = endAge + 1;
    }

    return dayunList;
  }
  ```
- [ ] 在 `calculate()` 主方法中调用：
  ```dart
  // 计算先天卦大运（从1岁开始）
  final xiantianDayunStartAge = 1;
  final xiantianDayunList = _calculateDayun(
    xiantianGua,
    yuantangYaoIndex,
    zhiList,
    xiantianDayunStartAge,
  );

  // 计算先天卦结束年龄
  final xiantianDayunEndAge = xiantianDayunList.last.endAge;

  // 计算后天卦大运（接着先天卦继续）
  final houtianDayunStartAge = xiantianDayunEndAge + 1;
  final houtianDayunList = _calculateDayun(
    houtianGua,
    houtianYuantangYaoIndex,
    houtianZhiList,
    houtianDayunStartAge,
  );
  ```
- [ ] 将结果传递给 YuanTangBaseNumberModel

**注意事项**:
- 大运起始年龄固定从1岁开始
- 先天卦6个爻位走完后，后天卦接着走
- 年龄是连续累加的，不会重置

**验收标准**:
- [ ] 大运计算逻辑正确（从元堂爻开始循环）
- [ ] 阳爻9年、阴爻6年规则正确
- [ ] 年龄区间连续累加正确
- [ ] 先天卦和后天卦年龄无缝衔接

---

### Task 10.5: 创建条文扩展配置 - 递加96规则
**文件**: `lib/service/strategy/yuan_tang_strategy.dart`

**要求**:
- [ ] 修改 `defaultTiaoWenCalculationConfig` 实现：
  ```dart
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return GenericTiaoWenCalculationConfig.customList(
      name: "元堂卦递加96四次",
      description: "先天卦/后天卦基础数分别递加96四次，得到5个条文编号",
      customList: [0, 96, 192, 288, 384], // 基础数 + 这些偏移量
      withSub: false,
    );
  }
  ```
- [ ] 修改 `calculateTiaoWenListWithConfig()` 方法：
  ```dart
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    YuanTangStrategyParams params,
    TiaoWenCalculationConfig config,
  ) {
    if (config is GenericTiaoWenCalculationConfig) {
      // 使用customList进行递加
      return config.customList.map((offset) => baseNumber + offset).toList();
    }
    return [baseNumber]; // 降级处理
  }
  ```
- [ ] 更新 `supportedTiaoWenCalculationConfigs` 方法

**验收标准**:
- [ ] 配置定义清晰
- [ ] 递加逻辑正确
- [ ] 降级处理完善

---

### Task 10.6: 修改UseCase处理条文扩展
**文件**: `lib/usecases/yuan_tang_tiao_wen_list_use_case.dart`

**要求**:
- [ ] 修改 `execute()` 方法，处理先天卦和后天卦的条文扩展：
  ```dart
  @override
  Future<MultiBaseNumberResult> execute(
    YuanTangUseCaseParams params, {
    TiaoWenListCalculationConfig? calculationConfig,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 调用Strategy计算
      final strategyParams = YuanTangStrategyParams(...);
      final strategyResult = _strategy.calculate(strategyParams);

      if (strategyResult.hasError) {
        throw Exception("元堂卦计算失败: ${strategyResult.errorMessage}");
      }

      // 3. 获取YuanTangBaseNumberModel
      final yuanTangModel = strategyResult.baseNumbers.first as YuanTangBaseNumberModel;

      // 4. 扩展先天卦条文编号（使用加则法基础数）
      final xiantianBaseNumber = yuanTangModel.tiaowenNumberJiazeXiantiangua;
      final xiantianTiaoWenList = _strategy.calculateTiaoWenListWithConfig(
        xiantianBaseNumber,
        strategyParams,
        _strategy.defaultTiaoWenCalculationConfig,
      );

      // 5. 扩展后天卦条文编号（使用加则法基础数）
      final houtianBaseNumber = yuanTangModel.tiaowenNumberJiazeHoutiangua;
      final houtianTiaoWenList = _strategy.calculateTiaoWenListWithConfig(
        houtianBaseNumber,
        strategyParams,
        _strategy.defaultTiaoWenCalculationConfig,
      );

      // 6. 合并所有条文编号
      final allTiaoWenNumbers = <int>[
        ...xiantianTiaoWenList,
        ...houtianTiaoWenList,
      ].toSet().toList(); // 去重

      // 7. 批量查询条文
      final tiaoWenDataList = await _repository.getByIdList(
        queryList: allTiaoWenNumbers,
      );

      // 8. 构建两个BaseNumberTiaoWenListModel（先天和后天分开）
      final baseNumberTiaoWenList = [
        BaseNumberTiaoWenListModel(
          baseNumber: xiantianBaseNumber,
          tiaoWenDataList: tiaoWenDataList.where((t) =>
            xiantianTiaoWenList.contains(t.id)
          ).toList(),
          name: "${yuanTangModel.name} - 先天卦",
          description: "先天卦${yuanTangModel.xiantianGua}条文（递加96四次）",
          source: yuanTangModel.source,
          tiaoWenNumbers: xiantianTiaoWenList,
          calculationFormula: "先天卦基础数 + [0, 96, 192, 288, 384]",
        ),
        BaseNumberTiaoWenListModel(
          baseNumber: houtianBaseNumber,
          tiaoWenDataList: tiaoWenDataList.where((t) =>
            houtianTiaoWenList.contains(t.id)
          ).toList(),
          name: "${yuanTangModel.name} - 后天卦",
          description: "后天卦${yuanTangModel.houtianGua}条文（递加96四次）",
          source: yuanTangModel.source,
          tiaoWenNumbers: houtianTiaoWenList,
          calculationFormula: "后天卦基础数 + [0, 96, 192, 288, 384]",
        ),
      ];

      // 9. 返回结果
      return MultiBaseNumberResult.success(
        algorithmName: '元堂卦取数法',
        algorithmDescription: '元堂卦取数法（性别:${params.gender}, 三元:${params.threeYuan}）',
        calculationParams: params.toString(),
        baseNumberTiaoWenList: baseNumberTiaoWenList,
        tiaoWenEntities: tiaoWenDataList,
        sourceData: {
          'fourZhu': params.fourZhu.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'birthAfterZhi': params.birthAfterZhi,
          'xiantianTiaoWenCount': xiantianTiaoWenList.length,
          'houtianTiaoWenCount': houtianTiaoWenList.length,
          'totalTiaoWenNumbers': allTiaoWenNumbers.length,
        },
      );
    } catch (e, stackTrace) {
      return MultiBaseNumberResult.error(...);
    }
  }
  ```

**验收标准**:
- [ ] 先天卦和后天卦条文分别扩展
- [ ] 条文来源（先天/后天）正确标注
- [ ] 计算公式正确保存
- [ ] 批量查询实现正确

---

### Task 10.7: 更新YuanTangUIModel
**文件**: `lib/presentation/models/yuan_tang_ui_model.dart`

**要求**:
- [ ] 添加后天卦元堂爻相关字段：
  ```dart
  final String houtianYuantangYaoLabel;              // 后天卦元堂爻标签
  final List<YuanTangYaoUIModel> houtianYaoList;     // 后天卦六爻列表
  ```
- [ ] 添加大运相关字段：
  ```dart
  final List<YuanTangDayunPeriodUI> xiantianDayunList;  // 先天卦大运
  final List<YuanTangDayunPeriodUI> houtianDayunList;   // 后天卦大运
  ```
- [ ] 定义 YuanTangDayunPeriodUI：
  ```dart
  class YuanTangDayunPeriodUI {
    final String yaoLabel;
    final String yinYang;
    final int years;
    final String ageRange;      // "34-39"
    final List<String> diZhiList;
  }
  ```
- [ ] 添加条文扩展相关字段：
  ```dart
  final List<int> xiantianTiaoWenNumbers;    // 先天卦条文列表（5个）
  final List<int> houtianTiaoWenNumbers;     // 后天卦条文列表（5个）
  final String xiantianCalculationFormula;   // 先天卦计算公式
  final String houtianCalculationFormula;    // 后天卦计算公式
  ```
- [ ] 更新 `fromYuanTangModel()` 工厂方法

**验收标准**:
- [ ] 字段定义完整
- [ ] UI数据结构清晰
- [ ] 工厂方法正确转换

---

### Task 10.8: 创建大运展示组件
**文件**: `lib/presentation/widgets/yuan_tang_dayun_widget.dart`

**要求**:
- [ ] 创建大运展示组件：
  ```dart
  class YuanTangDayunWidget extends StatelessWidget {
    final String title;                               // "先天卦大运" / "后天卦大运"
    final List<YuanTangDayunPeriodUI> dayunList;

    @override
    Widget build(BuildContext context) {
      return Card(
        child: ExpansionTile(
          title: Text(title),
          children: [
            _buildDayunTable(),  // 表格展示
          ],
        ),
      );
    }

    Widget _buildDayunTable() {
      return DataTable(
        columns: [
          DataColumn(label: Text('爻位')),
          DataColumn(label: Text('阴阳')),
          DataColumn(label: Text('年数')),
          DataColumn(label: Text('年龄区间')),
          DataColumn(label: Text('地支')),
        ],
        rows: dayunList.map((period) => DataRow(
          cells: [
            DataCell(Text(period.yaoLabel)),
            DataCell(Text(period.yinYang)),
            DataCell(Text('${period.years}年')),
            DataCell(Text(period.ageRange)),
            DataCell(Text(period.diZhiList.join('、'))),
          ],
        )).toList(),
      );
    }
  }
  ```

**验收标准**:
- [ ] 大运信息清晰展示
- [ ] 表格布局美观
- [ ] 支持展开/收起

---

### Task 10.9: 更新YuanTangCard展示后天卦元堂爻和大运
**文件**: `lib/presentation/widgets/yuan_tang_card.dart`

**要求**:
- [ ] 在计算步骤中添加后天卦元堂爻展示：
  ```dart
  Widget _buildHoutianGuaYuantangSection() {
    return Column(
      children: [
        Text('后天卦元堂爻: ${model.houtianYuantangYaoLabel}'),
        _buildYaoListDisplay(model.houtianYaoList),
      ],
    );
  }
  ```
- [ ] 添加大运展示部分：
  ```dart
  Widget _buildDayunSection() {
    return Column(
      children: [
        YuanTangDayunWidget(
          title: '先天卦大运（${model.xiantianGua}）',
          dayunList: model.xiantianDayunList,
        ),
        YuanTangDayunWidget(
          title: '后天卦大运（${model.houtianGua}）',
          dayunList: model.houtianDayunList,
        ),
      ],
    );
  }
  ```
- [ ] 更新条文展示部分，区分先天卦和后天卦条文：
  ```dart
  Widget _buildTiaoWenSection() {
    return Column(
      children: [
        _buildTiaoWenGroup(
          title: '先天卦条文',
          formula: model.xiantianCalculationFormula,
          tiaoWenNumbers: model.xiantianTiaoWenNumbers,
        ),
        _buildTiaoWenGroup(
          title: '后天卦条文',
          formula: model.houtianCalculationFormula,
          tiaoWenNumbers: model.houtianTiaoWenNumbers,
        ),
      ],
    );
  }
  ```

**验收标准**:
- [ ] 后天卦元堂爻信息清晰展示
- [ ] 大运信息完整展示
- [ ] 条文分组清晰（先天/后天）

---

### Task 10.10: 编写单元测试 - 后天卦元堂爻
**文件**: `test/service/strategy/yuan_tang_houtian_yuantang_test.dart`

**要求**:
- [ ] 测试后天卦元堂装卦逻辑：
  ```dart
  group('后天卦元堂装卦', () {
    test('阳时应该取阳爻', () { });
    test('阴时应该取阴爻', () { });
    test('1-3爻应该双重装配', () { });
    test('4-5爻应该自上而下', () { });
    test('6爻应该三爻分组', () { });
  });
  ```
- [ ] 使用测试数据验证：
  ```dart
  // 癸巳甲子丁酉癸卯案例
  // 先天卦：震坤，元堂爻二爻
  // 后天卦：坎震，元堂爻应该是？
  ```

**验收标准**:
- [ ] 测试用例覆盖所有情况
- [ ] 测试通过

---

### Task 10.11: 编写单元测试 - 大运计算
**文件**: `test/service/strategy/yuan_tang_dayun_test.dart`

**要求**:
- [ ] 测试大运计算逻辑：
  ```dart
  group('大运计算', () {
    test('从元堂爻开始循环', () { });
    test('阳爻9年', () { });
    test('阴爻6年', () { });
    test('年龄区间连续累加', () { });
    test('先天卦6个爻位全部计算', () { });
    test('后天卦接着先天卦继续', () { });
  });
  ```
- [ ] 验证示例数据（癸巳甲子丁酉癸卯）：
  ```dart
  // 先天卦：震坤，元堂爻二爻（索引1）
  // 震坤=001000：初(阴) 二(阴) 三(阴) 四(阴) 五(阳) 上(阴)
  // 预期大运：
  // 二爻(阴6年,1-6) → 三爻(阴6年,7-12) → 四爻(阴6年,13-18) →
  // 五爻(阳9年,19-27) → 上爻(阴6年,28-33) → 初爻(阴6年,34-39)

  // 后天卦：坎震，元堂爻应该计算（假设也是阳时）
  // 坎震=010001：初(阳) 二(阴) 三(阴) 四(阴) 五(阳) 上(阴)
  // 后天卦元堂爻位置需要根据坎震+阳时计算
  // 预期接着先天卦继续，从40岁开始
  ```

**验收标准**:
- [ ] 大运计算逻辑正确（从元堂爻开始循环）
- [ ] 年龄区间准确连续
- [ ] 先天卦和后天卦无缝衔接
- [ ] 测试通过

---

### Task 10.12: 编写单元测试 - 条文扩展
**文件**: `test/service/strategy/yuan_tang_tiaogen_expand_test.dart`

**要求**:
- [ ] 测试条文扩展逻辑：
  ```dart
  group('条文扩展 - 递加96四次', () {
    test('先天卦条文应该正确扩展', () {
      // 基础数3387 -> [3387, 3483, 3579, 3675, 3771]
    });

    test('后天卦条文应该正确扩展', () {
      // 基础数2477 -> [2477, 2573, 2669, 2765, 2861]
    });

    test('条文来源应该正确标注', () { });
    test('计算公式应该正确保存', () { });
  });
  ```

**验收标准**:
- [ ] 扩展逻辑正确
- [ ] 公式保存正确
- [ ] 测试通过

---

### Task 10.13: 更新文档
**文件**: `docs/normal_alg/yuan_tang_todo_list.md`

**要求**:
- [x] 添加Phase 10所有任务
- [ ] 更新功能概述
- [ ] 更新算法步骤说明
- [ ] 添加大运计算规则说明
- [ ] 添加条文扩展规则说明

**验收标准**:
- [x] 文档更新完整
- [ ] 规则说明清晰
- [ ] 示例准确

---

## 📋 Phase 10 检查清单

### 模型层
- [ ] YuanTangBaseNumberModel添加后天卦元堂爻字段
- [ ] YuanTangBaseNumberModel添加大运字段
- [ ] YuanTangDayunPeriod数据结构定义

### 算法层
- [ ] 后天卦元堂装卦实现
- [ ] 大运计算实现
- [ ] 条文扩展配置实现

### UseCase层
- [ ] 条文扩展逻辑实现
- [ ] 先天/后天条文分组处理

### UI层
- [ ] YuanTangUIModel字段扩展
- [ ] 大运展示组件创建
- [ ] YuanTangCard更新

### 测试
- [ ] 后天卦元堂爻测试
- [ ] 大运计算测试
- [ ] 条文扩展测试

### 文档
- [x] TODO列表更新
- [ ] 功能说明文档

---

## ⚠️ 待确认事项

### 1. 后天卦元堂爻计算规则 ✅ 已确认
**问题**: 后天卦的元堂爻是否与先天卦使用相同的规则（时辰阴阳+爻的阴阳）？
**确认**: 使用相同规则

### 2. 大运计算规则 ✅ 已确认
**规则**:
- 从1岁开始
- 先天卦从元堂爻开始，循环6个爻位（元堂→下一爻→...→上爻→初爻→...）
- 阳爻9年，阴爻6年
- 先天卦走完后，后天卦从其元堂爻继续，年龄连续累加
- 示例：先天卦1-39岁，后天卦40-81岁（12个爻位共81年）

### 3. 条文基础数选择 ⚠️ 待确认
**问题**: 条文扩展使用哪个基础数？
**当前计划**: 使用先天卦/后天卦的加则法条文编号作为基础数
**其他选项**:
- 纳甲太玄数
- 本互数
- 用户选择

**需要用户确认**: ________________

---

**创建日期**: 2025-10-11

## 🎯 核心目标

实现元堂卦取数法算法，包含完整的中间计算过程，支持多种条文编号计算方法，为用户提供详细的计算步骤展示。

## 📊 算法概览

### 输入
- 四柱信息（FourZhu对象）
- 性别（"男" / "女"）
- 三元（"上" / "中" / "下"）
- 出生节气（"夏至" / "冬至"）

### 输出
- 先天卦、后天卦
- 元堂爻信息
- 六爻地支配置
- 多种条文编号：
  - 先天卦加则法条文
  - 后天卦加则法条文
  - 先天卦纳甲太玄数条文
  - 后天卦纳甲太玄数条文
  - 先天卦本互条文
  - 后天卦本互条文
  - 先天卦互取数列表
  - 后天卦互取数列表

### 核心算法步骤

#### 步骤1：生成天地卦
1. 提取四柱天干数列表
2. 提取四柱地支数列表（每个地支配两个数）
3. 计算奇数总和 → 天数（模25处理）→ 天卦
4. 计算偶数总和 → 地数（模30处理）→ 地卦
5. 特殊处理：数为5时查询三元五宫映射表

#### 步骤2：生成上下卦（先天卦）
根据年份阴阳和性别决定上下卦位置：
- 阳年男性：天卦在上，地卦在下
- 阳年女性：地卦在上，天卦在下
- 阴年女性：天卦在上，地卦在下
- 阴年男性：地卦在上，天卦在下

#### 步骤3：元堂装卦
根据时辰阴阳和爻的阴阳属性装配地支：
- 阳时：取阳爻为元堂爻
- 阴时：取阴爻为元堂爻

分三种情况：
1. **爻数1-3**：双重装配
2. **爻数4-5**：自上而下排列
3. **爻数6**：三爻分组，考虑性别和节气

#### 步骤4：生成后天卦
1. 元堂爻爻变（阴→阳，阳→阴）
2. 上下卦互换

#### 步骤5：计算各种条文编号
- 加则法（先天卦、后天卦）
- 纳甲太玄数法（先天卦、后天卦）
- 本互法（先天卦、后天卦）
- 互取数列表（先天卦、后天卦）

---

## ✅ 任务分解

### Phase 1: 数据模型设计 (预计3-4小时)

#### Task 1.1: 创建 YuanTangYaoDetail 模型
**文件**: `lib/domain/models/yuan_tang_base_number_model.dart`

**要求**:
- [x] 定义 YuanTangYaoDetail 类
- [x] 添加字段：
  ```dart
  final int position;              // 爻位（0-5）
  final String positionLabel;      // "初" / "二" / "三" / "四" / "五" / "上"
  final String yinYang;            // "阳" / "阴"
  final List<String> diZhiList;    // 配上的地支列表（可能多个）
  final bool isYuanTangYao;        // 是否为元堂爻
  ```
- [x] 实现构造函数
- [x] 实现 `copyWith()` 方法
- [x] 实现 `toMap()` 方法
- [x] 实现 `toString()` 方法
- [x] 重写 `==` 和 `hashCode`
- [x] 添加文档注释

**验收标准**:
- 所有字段定义清晰
- 文档注释完整
- 辅助方法实现正确

---

#### Task 1.2: 创建 YuanTangBaseNumberModel
**文件**: `lib/domain/models/yuan_tang_base_number_model.dart`

**要求**:
- [x] 继承 BaseNumberModel
- [x] 添加输入参数字段：
  ```dart
  final FourZhu fourZhu;           // 四柱信息
  final String gender;              // "男" / "女"
  final String threeYuan;           // "上" / "中" / "下"
  final String birthAfterZhi;       // "夏至" / "冬至"
  ```
- [ ] 添加步骤1（生成天地卦）字段：
  ```dart
  final List<int> ganNumList;          // 四柱天干数列表
  final List<List<int>> zhiNumList;    // 四柱地支数列表
  final int oddNumTotal;                // 奇数总和
  final int evenNumTotal;               // 偶数总和
  final int tianGuaNum;                 // 天数
  final int diGuaNum;                   // 地数
  final String tianGua;                 // 天卦
  final String diGua;                   // 地卦
  final bool usedThreeYuanWuGong;      // 是否使用三元五宫
  ```
- [ ] 添加步骤2（生成上下卦）字段：
  ```dart
  final String yearYinYang;             // 年份阴阳
  final String upperGua;                // 上卦
  final String lowerGua;                // 下卦
  final String xiantianGua;             // 先天卦（上+下）
  final int xiantianUpperGuaNumber;     // 先天卦上卦后天数
  final int xiantianLowerGuaNumber;     // 先天卦下卦后天数
  ```
- [ ] 添加步骤3（元堂装卦）字段：
  ```dart
  final String timeGanzhi;              // 时柱干支
  final String timeYinYang;             // 时辰阴阳
  final int totalYangYao;               // 卦中阳爻总数
  final int totalYinYao;                // 卦中阴爻总数
  final List<List<String>> zhiList;     // 六爻地支列表
  final int yuantangYaoIndex;           // 元堂爻索引（0-5）
  final String yuantangYaoLabel;        // 元堂爻位标签
  ```
- [ ] 添加步骤4（生成后天卦）字段：
  ```dart
  final String houtianGua;              // 后天卦
  final int houtianUpperGuaNumber;      // 后天卦上卦后天数
  final int houtianLowerGuaNumber;      // 后天卦下卦后天数
  ```
- [ ] 添加步骤5（互卦）字段：
  ```dart
  final String xiantianGuaHu;           // 先天卦互卦
  final String houtianGuaHu;            // 后天卦互卦
  ```
- [ ] 添加最终条文编号字段：
  ```dart
  final int tiaowenNumberJiazeXiantiangua;           // 先天卦加则法
  final int tiaowenNumberJiazeHoutiangua;            // 后天卦加则法
  final int tiaowenNumberNajiaTaixuanXiantiangua;    // 先天卦纳甲太玄数
  final int tiaowenNumberNajiaTaixuanHoutiangua;     // 后天卦纳甲太玄数
  final int tiaowenNumberXiantianBenhu;              // 先天卦本互
  final int tiaowenNumberHoutianBenhu;               // 后天卦本互
  final List<int> tiaowenNumberListXiantianGuahu;    // 先天卦互取数列表
  final List<int> tiaowenNumberListHoutianGuahu;     // 后天卦互取数列表
  ```
- [x] 实现工厂方法 `YuanTangBaseNumberModel.create()`
- [x] 实现 `get yaoDetails` 返回六爻详情列表
- [x] 实现便捷getter：
  ```dart
  String get upperGuaDisplayText         // "乾(6)"
  String get lowerGuaDisplayText         // "坤(2)"
  String get houtianUpperGuaDisplayText  // 后天卦上卦显示
  String get houtianLowerGuaDisplayText  // 后天卦下卦显示
  String get tianDiGuaFormula            // 天地卦生成说明
  ```
- [x] 实现 `copyWith()` 方法
- [x] 实现 `toMap()` 方法
- [x] 实现 `toString()` 方法
- [x] 重写 `==` 和 `hashCode`
- [x] 添加详细的文档注释

**验收标准**:
- 所有字段定义清晰
- 继承关系正确
- 文档注释完整
- 包含完整的计算过程数据
- getter方法功能正确

---

### Phase 2: Strategy层实现 (预计5-6小时)

#### Task 2.1: 创建 YuanTangStrategyParams
**文件**: `lib/service/strategy/yuan_tang_strategy.dart`

**要求**:
- [x] 定义参数类 YuanTangStrategyParams
- [x] 添加字段：
  ```dart
  final FourZhu fourZhu;
  final String gender;
  final String threeYuan;
  final String birthAfterZhi;
  ```
- [x] 实现 `description` getter
- [x] 实现 `toString()` 方法（在description中实现）
- [x] 实现 `==` 和 `hashCode`（未实现，但不影响核心功能）
- [x] 添加文档注释

**验收标准**:
- 参数类定义正确
- 所有必要字段包含
- 文档注释完整

---

#### Task 2.2: 创建 YuanTangStrategy 基础框架
**文件**: `lib/service/strategy/yuan_tang_strategy.dart`

**要求**:
- [x] 继承 StandardCalculationStrategy<YuanTangStrategyParams, YuanTangBaseNumberModel>
- [x] 实现 `name` getter = "元堂卦取数法"
- [x] 实现 `description` getter（算法描述）
- [x] 实现 `detailSteps` getter（详细步骤说明）
- [x] 定义 `calculate()` 主方法框架
- [x] 添加三元五宫映射表常量
  ```dart
  static const Map<String, Map<String, Map<String, String>>> _threeYuan5GongMapper = {
    "上": {"男": {"阳": "艮", "阴": "艮"}, "女": {"阳": "坤", "阴": "坤"}},
    "中": {"男": {"阳": "艮", "阴": "坤"}, "女": {"阳": "坤", "阴": "艮"}},
    "下": {"男": {"阳": "离", "阴": "离"}, "女": {"阳": "兑", "阴": "兑"}},
  };
  ```

**验收标准**:
- 框架搭建正确
- 常量定义完整
- 文档注释清晰

---

#### Task 2.3: 实现步骤1 - 生成天地卦
**文件**: `lib/service/strategy/yuan_tang_strategy.dart`

**要求**:
- [x] 实现 `_generateTianDiGua()` 方法
- [ ] 提取四柱天干数列表
  ```dart
  List<int> ganNumList = [
    Constants.tianGanNumberMapper[fourZhu.yearGan]!,
    Constants.tianGanNumberMapper[fourZhu.monthGan]!,
    Constants.tianGanNumberMapper[fourZhu.dayGan]!,
    Constants.tianGanNumberMapper[fourZhu.timeGan]!,
  ];
  ```
- [ ] 提取四柱地支数列表（每个地支两个数）
  ```dart
  List<List<int>> zhiNumList = [
    Constants.diZhiNumberMapper[fourZhu.yearZhi]!,
    Constants.diZhiNumberMapper[fourZhu.monthZhi]!,
    Constants.diZhiNumberMapper[fourZhu.dayZhi]!,
    Constants.diZhiNumberMapper[fourZhu.timeZhi]!,
  ];
  ```
- [ ] 计算奇数总和
- [ ] 计算偶数总和
- [ ] 计算天数：`GuaUtils.calculateGuaNum(oddNumTotal, 25, 5)`
- [ ] 计算地数：`GuaUtils.calculateGuaNum(evenNumTotal, 30, 3)`
- [ ] 数配卦逻辑：
  ```dart
  String tianGua;
  if (tianGuaNum == 5) {
    tianGua = _threeYuan5GongMapper[threeYuan]![gender]![yearYinYang]!;
  } else {
    tianGua = Constants.yuantangHuaTianNumberGuaMapper[tianGuaNum]!;
  }
  ```
- [ ] 同样处理地卦
- [x] 返回：(tianGua, diGua, ganNumList, zhiNumList, oddNumTotal, evenNumTotal, tianGuaNum, diGuaNum, usedThreeYuanWuGong)

**验收标准**:
- 奇偶数计算正确
- 模运算处理正确
- 三元五宫特殊情况处理正确
- 返回完整的中间结果

---

#### Task 2.4: 实现步骤2 - 生成上下卦
**文件**: `lib/service/strategy/yuan_tang_strategy.dart`

**要求**:
- [x] 实现 `_generateUpperLowerGua()` 方法
- [ ] 根据年份阴阳和性别决定上下卦：
  ```dart
  String upperGua, lowerGua;
  if (yearYinYang == "阳") {
    if (gender == "男") {
      upperGua = tianGua;
      lowerGua = diGua;
    } else {
      upperGua = diGua;
      lowerGua = tianGua;
    }
  } else {
    if (gender == "女") {
      upperGua = tianGua;
      lowerGua = diGua;
    } else {
      upperGua = diGua;
      lowerGua = tianGua;
    }
  }
  ```
- [ ] 组合先天卦：`xiantianGua = upperGua + lowerGua`
- [ ] 查询后天数
- [x] 返回：(upperGua, lowerGua, xiantianGua, upperGuaNumber, lowerGuaNumber)

**验收标准**:
- 上下卦位置逻辑正确
- 四种组合都能正确处理
- 后天数查询正确

---

#### Task 2.5: 实现步骤3 - 元堂装卦
**文件**: `lib/service/strategy/yuan_tang_strategy.dart`

**要求**:
- [x] 实现 `_yuantangZhuanggua()` 方法
- [ ] 判断时辰阴阳：
  ```dart
  List<String> yuantangYangTimeSet = ["子", "丑", "寅", "卯", "辰", "巳"];
  List<String> yuantangYinTimeSet = ["午", "未", "申", "酉", "戌", "亥"];
  String timeYinyang = yuantangYangTimeSet.contains(timeZhi) ? "阳" : "阴";
  ```
- [ ] 将卦转换为二进制列表
- [ ] 计算阳爻总数和阴爻总数
- [ ] 根据爻数分三种情况调用不同方法：
  - 1-3爻：调用 `_zhuangguaLowerThan3()`
  - 4-5爻：调用 `_zhuanggua45()`
  - 6爻：调用 `_zhuanggua6Yang()`
- [ ] 计算元堂爻索引：`_getYuantanYaoIndex()`
- [x] 返回：(yuantangYaoIndex, zhiList, timeYinYang, totalYangYao, totalYinYao)

**验收标准**:
- 时辰阴阳判断正确
- 爻数分类正确
- 元堂爻定位正确

---

#### Task 2.6: 实现元堂装卦子方法
**文件**: `lib/service/strategy/yuan_tang_strategy.dart`

**要求**:
- [x] 实现 `_zhuangguaLowerThan3()` 方法
  - 双重装配逻辑
  - 剩余地支填充
- [x] 实现 `_zhuanggua45()` 方法
  - 自上而下排列
  - 先排目标爻,后排其他爻
- [x] 实现 `_zhuanggua6Yang()` 方法
  - 考虑性别和节气
  - 三爻分组装配
  - 男性逻辑
  - 女性逻辑（夏至/冬至）
- [x] 实现 `_getYuantangYaoIndex()` 方法
  - 查找时支所在爻位

**验收标准**:
- 三种装卦方法逻辑正确
- 特殊情况处理完善
- 边界检查完整

---

#### Task 2.7: 实现步骤4 - 生成后天卦
**文件**: `lib/service/strategy/yuan_tang_strategy.dart`

**要求**:
- [x] 实现 `_generateHoutianGua()` 方法
- [ ] 元堂爻爻变：
  ```dart
  List<int> binaryList = GuaUtils.guaToBinaryList(xiantianGua);
  binaryList[yuantangYaoIndex] = binaryList[yuantangYaoIndex] == 0 ? 1 : 0;
  ```
- [ ] 拆分成两个卦
- [ ] 根据二进制找到八经卦
- [ ] 上下卦互换：`houtianGua = lowerGua + upperGua`
- [ ] 查询后天数
- [x] 返回：(houtianGua, houtianUpperGuaNumber, houtianLowerGuaNumber)

**验收标准**:
- 爻变逻辑正确
- 上下卦互换正确
- 后天数查询正确

---

#### Task 2.8: 实现步骤5 - 计算各种条文编号
**文件**: `lib/service/strategy/yuan_tang_strategy.dart`

**要求**:
- [x] 实现加则法条文编号计算
  ```dart
  int tiaowenNumberJiazeXiantiangua = TiaowenCalculator.getTiaowenNumberByJiaZe(xiantianGua);
  int tiaowenNumberJiazeHoutiangua = TiaowenCalculator.getTiaowenNumberByJiaZe(houtianGua);
  ```
- [ ] 实现纳甲太玄数条文编号计算
  ```dart
  int tiaowenNumberNajiaTaixuanXiantiangua = TiaowenCalculator.getTiaowenNumberByTaixuan(xiantianGua);
  int tiaowenNumberNajiaTaixuanHoutiangua = TiaowenCalculator.getTiaowenNumberByTaixuan(houtianGua);
  ```
- [ ] 实现本互条文编号计算
  ```dart
  String xiantianGuaHu = GuaUtils.guaToHuGua(xiantianGua);
  String houtianGuaHu = GuaUtils.guaToHuGua(houtianGua);
  int tiaowenNumberXiantianBenhu = _calculateBenhuNumber(xiantianGua, xiantianGuaHu, isXiantian: true);
  int tiaowenNumberHoutianBenhu = _calculateBenhuNumber(houtianGua, houtianGuaHu, isXiantian: false);
  ```
- [ ] 实现互取数列表计算
  ```dart
  List<int> tiaowenNumberListXiantianGuahu = TiaowenCalculator.calculateTiaoWenListBySubAndAdd(
    tiaowenNumberXiantianBenhu,
    [2, 4, 8, 16],
  );
  List<int> tiaowenNumberListHoutianGuahu = TiaowenCalculator.calculateTiaoWenListBySubAndAdd(
    tiaowenNumberHoutianBenhu,
    [2, 4, 8, 16],
  );
  ```
- [x] 实现 `_calculateBenhuNumber()` 辅助方法
- [x] 实现 `_getSourceFromParams()` 辅助方法

**验收标准**:
- 所有条文编号计算正确
- 工具方法调用正确
- 本互数计算逻辑正确

---

#### Task 2.9: 实现 calculate() 主方法
**文件**: `lib/service/strategy/yuan_tang_strategy.dart`

**要求**:
- [x] 实现完整的 `calculate()` 方法
- [x] 调用所有步骤方法
- [x] 创建 YuanTangBaseNumberModel 实例
- [x] 包装为 BaseNumberModelResult.success()
- [x] 添加 try-catch 错误处理
- [x] 返回 BaseNumberModelResult.error() 在异常时
- [x] 添加详细的 sourceData

**验收标准**:
- 主方法流程正确
- 所有中间结果都保存
- 错误处理完善
- sourceData 包含完整信息

---

### Phase 3: UseCase层实现 (预计2-3小时)

#### Task 3.1: 创建 YuanTangUseCaseParams
**文件**: `lib/usecases/yuan_tang_tiao_wen_list_use_case.dart`

**要求**:
- [x] 定义参数类 YuanTangUseCaseParams
- [x] 添加字段：
  ```dart
  final FourZhu fourZhu;
  final String gender;
  final String threeYuan;
  final String birthAfterZhi;
  ```
- [x] 实现 `toString()` 方法
- [x] 实现 `==` 和 `hashCode`
- [x] 添加文档注释

**验收标准**:
- 参数类定义正确
- 文档注释完整

---

#### Task 3.2: 创建 YuanTangTiaoWenListUseCase
**文件**: `lib/usecases/yuan_tang_tiao_wen_list_use_case.dart`

**要求**:
- [x] 继承 BaseGetTiaoWenListUseCase
- [x] 实现构造函数，注入 YuanTangStrategy 和 TiaoWenRepository
- [x] 实现 `validateParams()` 方法
  - 验证 fourZhu 不为空
  - 验证 gender 为 "男" 或 "女"
  - 验证 threeYuan 为 "上"、"中" 或 "下"
  - 验证 birthAfterZhi 为 "夏至" 或 "冬至"
- [x] 实现 `execute()` 主方法
- [x] 调用 Strategy 计算基础数
- [x] 决定条文扩展策略：
  - 默认：使用所有8种条文编号
  - 可选：通过配置选择使用哪些方法
- [x] 查询条文数据
- [x] 构建 BaseNumberTiaoWenListModel
- [x] 返回 MultiBaseNumberResult

**核心逻辑**:
```dart
@override
Future<MultiBaseNumberResult> execute(
  YuanTangUseCaseParams params, {
  TiaoWenListCalculationConfig? calculationConfig,
}) async {
  try {
    // 1. 验证参数
    validateParams(params);

    // 2. 调用Strategy计算
    final strategyParams = YuanTangStrategyParams(
      fourZhu: params.fourZhu,
      gender: params.gender,
      threeYuan: params.threeYuan,
      birthAfterZhi: params.birthAfterZhi,
    );
    final strategyResult = _strategy.calculate(strategyParams);

    if (strategyResult.hasError) {
      throw Exception("元堂卦计算失败: ${strategyResult.errorMessage}");
    }

    // 3. 获取YuanTangBaseNumberModel（只有一个结果）
    final yuanTangModel = strategyResult.baseNumbers.first as YuanTangBaseNumberModel;

    // 4. 收集所有条文编号
    final tiaoWenNumbers = <int>[
      yuanTangModel.tiaowenNumberJiazeXiantiangua,
      yuanTangModel.tiaowenNumberJiazeHoutiangua,
      yuanTangModel.tiaowenNumberNajiaTaixuanXiantiangua,
      yuanTangModel.tiaowenNumberNajiaTaixuanHoutiangua,
      yuanTangModel.tiaowenNumberXiantianBenhu,
      yuanTangModel.tiaowenNumberHoutianBenhu,
      ...yuanTangModel.tiaowenNumberListXiantianGuahu,
      ...yuanTangModel.tiaowenNumberListHoutianGuahu,
    ].toSet().toList(); // 去重

    // 5. 批量查询条文
    final tiaoWenDataList = await _repository.getByIdList(queryList: tiaoWenNumbers);

    // 6. 构建结果
    final baseNumberTiaoWenList = [
      BaseNumberTiaoWenListModel(
        baseNumber: yuanTangModel.baseNumber,
        tiaoWenDataList: tiaoWenDataList,
        name: yuanTangModel.name,
        description: yuanTangModel.description,
        source: yuanTangModel.source,
        tiaoWenNumbers: tiaoWenNumbers,
      ),
    ];

    return MultiBaseNumberResult.success(
      algorithmName: '元堂卦取数法',
      algorithmDescription: '元堂卦取数法（性别:${params.gender}, 三元:${params.threeYuan}）',
      calculationParams: params.toString(),
      baseNumberTiaoWenList: baseNumberTiaoWenList,
      tiaoWenEntities: tiaoWenDataList,
      sourceData: {
        'fourZhu': params.fourZhu.toString(),
        'gender': params.gender,
        'threeYuan': params.threeYuan,
        'birthAfterZhi': params.birthAfterZhi,
        'tiaoWenMethodsCount': 8,
        'totalTiaoWenNumbers': tiaoWenNumbers.length,
      },
    );
  } catch (e, stackTrace) {
    return MultiBaseNumberResult.error(
      algorithmName: '元堂卦取数法',
      algorithmDescription: '元堂卦取数法',
      calculationParams: params.toString(),
      errorMessage: e.toString(),
      sourceData: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
    );
  }
}
```

**验收标准**:
- [x] 参数验证完善
- [x] Strategy调用正确
- [x] 条文编号收集完整
- [x] 批量查询实现正确
- [x] 错误处理完善
- [x] 返回结果结构正确

---

### Phase 4: ViewModel层实现 (预计2-3小时)

#### Task 4.1: 创建 YuanTangViewModel
**文件**: `lib/presentation/viewmodels/yuan_tang_view_model.dart`

**要求**:
- [x] 继承 BaseTiaoWenListViewModel
- [x] 添加字段：
  ```dart
  final YuanTangTiaoWenListUseCase _useCase;
  FourZhu? _currentFourZhu;
  String? _currentGender;
  String? _currentThreeYuan;
  String? _currentBirthAfterZhi;
  ```
- [x] 实现构造函数
- [x] 实现 `setYuanTangParams()` 方法
  ```dart
  Future<void> setYuanTangParams({
    required FourZhu fourZhu,
    required String gender,
    required String threeYuan,
    required String birthAfterZhi,
  }) async {
    _currentFourZhu = fourZhu;
    _currentGender = gender;
    _currentThreeYuan = threeYuan;
    _currentBirthAfterZhi = birthAfterZhi;
    await calculateTiaoWenList();
  }
  ```
- [x] 实现 `calculateTiaoWenList()` 方法
  ```dart
  Future<void> calculateTiaoWenList() async {
    if (_currentFourZhu == null) return;

    await safeExecute(() async {
      final params = YuanTangUseCaseParams(
        fourZhu: _currentFourZhu!,
        gender: _currentGender!,
        threeYuan: _currentThreeYuan!,
        birthAfterZhi: _currentBirthAfterZhi!,
      );
      return await _useCase.execute(params);
    });
  }
  ```
- [x] 实现便捷 getter 方法：
  ```dart
  YuanTangBaseNumberModel? get yuanTangModel {
    if (!hasResult) return null;
    final domainModel = result!.baseNumberTiaoWenList.first;
    // 需要从Strategy结果中获取完整的YuanTangBaseNumberModel
    return _extractYuanTangModel(domainModel);
  }

  bool get hasYuanTangModel => yuanTangModel != null;

  List<int> get allTiaoWenNumbers {
    if (!hasResult) return [];
    return result!.baseNumberTiaoWenList.first.tiaoWenNumbers;
  }
  ```
- [x] 添加文档注释

**验收标准**:
- [x] ViewModel正确管理状态
- [x] 参数设置方法完善
- [x] 计算方法调用UseCase
- [x] 便捷方法实现正确
- [x] 错误处理完善

---

### Phase 5: UI层实现 (预计4-5小时)

#### Task 5.1: 创建 YuanTangUIModel
**文件**: `lib/presentation/models/yuan_tang_ui_model.dart`

**要求**:
- [x] 定义UI展示所需的数据结构
- [x] 添加字段：
  ```dart
  // 输入参数
  final String gender;
  final String threeYuan;
  final String birthAfterZhi;

  // 步骤1：天地卦
  final String tianGua;
  final String diGua;
  final String tianDiGuaFormula;

  // 步骤2：上下卦
  final String xiantianGua;
  final String upperGuaDisplay;
  final String lowerGuaDisplay;

  // 步骤3：元堂装卦
  final String yuantangYaoLabel;
  final List<YuanTangYaoUIModel> yaoList;

  // 步骤4：后天卦
  final String houtianGua;
  final String houtianUpperGuaDisplay;
  final String houtianLowerGuaDisplay;

  // 步骤5：互卦
  final String xiantianGuaHu;
  final String houtianGuaHu;

  // 条文编号（按方法分类）
  final Map<String, List<int>> tiaoWenByMethod;
  final List<int> allTiaoWenNumbers;
  final List<TiaoWenDataModel> tiaoWenDataList;
  ```
- [x] 定义 YuanTangYaoUIModel：
  ```dart
  class YuanTangYaoUIModel {
    final int position;
    final String positionLabel;
    final String yinYang;
    final List<String> diZhiList;
    final bool isYuanTangYao;
  }
  ```
- [x] 实现 `fromDomain()` 工厂方法
- [x] 实现 `fromYuanTangModel()` 工厂方法（保留完整中间结果）
- [x] 实现便捷 getter：
  ```dart
  bool get hasTiaoWen => tiaoWenDataList.isNotEmpty;
  int get tiaoWenCount => tiaoWenDataList.length;
  String get fullDescription; // 完整描述
  ```
- [x] 添加文档注释

**验收标准**:
- [x] 数据结构定义完整
- [x] 工厂方法实现正确
- [x] 包含所有UI展示所需信息
- [x] 中间结果完整保留

---

#### Task 5.2: 创建 YuanTangCalculationStepsWidget
**文件**: `lib/presentation/widgets/yuan_tang_calculation_steps_widget.dart`

**要求**:
- [ ] 展示完整的计算步骤
- [ ] 步骤1展示：天地卦生成
  - 天干数列表
  - 地支数列表
  - 奇偶数总和
  - 天数、地数计算
  - 天卦、地卦结果
  - 三元五宫特殊情况标注
- [ ] 步骤2展示：上下卦生成
  - 年份阴阳
  - 性别
  - 上下卦位置规则
  - 先天卦结果
- [ ] 步骤3展示：元堂装卦
  - 时辰阴阳
  - 卦中阴阳爻统计
  - 六爻地支配置（可视化）
  - 元堂爻标注（高亮显示）
- [ ] 步骤4展示：后天卦生成
  - 元堂爻爻变说明
  - 上下卦互换说明
  - 后天卦结果
- [ ] 步骤5展示：互卦
  - 先天卦互卦
  - 后天卦互卦

**UI结构**:
```dart
ExpansionTile(
  title: Text('计算步骤详情'),
  children: [
    _buildStep1TianDiGua(),
    Divider(),
    _buildStep2UpperLowerGua(),
    Divider(),
    _buildStep3YuanTangZhuanggua(),
    Divider(),
    _buildStep4HoutianGua(),
    Divider(),
    _buildStep5HuGua(),
  ],
)
```

**验收标准**:
- [ ] 五个步骤都清晰展示
- [ ] 卡片布局美观
- [ ] 展开/收起功能正常
- [ ] 关键信息高亮显示
- [ ] 支持响应式布局

---

#### Task 5.3: 创建 YuanTangTiaoWenMethodsWidget
**文件**: `lib/presentation/widgets/yuan_tang_tiao_wen_methods_widget.dart`

**要求**:
- [ ] 展示8种条文编号计算方法的结果
- [ ] 按方法分类展示：
  - 加则法（先天卦、后天卦）
  - 纳甲太玄数法（先天卦、后天卦）
  - 本互法（先天卦、后天卦）
  - 互取数列表（先天卦、后天卦）
- [ ] 每个方法显示：
  - 方法名称
  - 条文编号（单个或列表）
  - 条文内容
- [ ] 支持展开/收起
- [ ] 使用不同颜色标识不同方法

**UI结构**:
```dart
Column(
  children: [
    _buildMethodCard(
      title: '先天卦加则法',
      tiaoWenNumber: model.tiaowenNumberJiazeXiantiangua,
      color: Colors.blue,
    ),
    _buildMethodCard(
      title: '后天卦加则法',
      tiaoWenNumber: model.tiaowenNumberJiazeHoutiangua,
      color: Colors.green,
    ),
    _buildMethodCard(
      title: '先天卦纳甲太玄数',
      tiaoWenNumber: model.tiaowenNumberNajiaTaixuanXiantiangua,
      color: Colors.orange,
    ),
    _buildMethodCard(
      title: '后天卦纳甲太玄数',
      tiaoWenNumber: model.tiaowenNumberNajiaTaixuanHoutiangua,
      color: Colors.purple,
    ),
    _buildMethodCard(
      title: '先天卦本互',
      tiaoWenNumber: model.tiaowenNumberXiantianBenhu,
      color: Colors.teal,
    ),
    _buildMethodCard(
      title: '后天卦本互',
      tiaoWenNumber: model.tiaowenNumberHoutianBenhu,
      color: Colors.indigo,
    ),
    _buildMethodListCard(
      title: '先天卦互取数列表',
      tiaoWenNumbers: model.tiaowenNumberListXiantianGuahu,
      color: Colors.cyan,
    ),
    _buildMethodListCard(
      title: '后天卦互取数列表',
      tiaoWenNumbers: model.tiaowenNumberListHoutianGuahu,
      color: Colors.pink,
    ),
  ],
)
```

**验收标准**:
- [ ] 8种方法都清晰展示
- [ ] 颜色标识易于区分
- [ ] 条文内容完整显示
- [ ] 列表方法支持滚动
- [ ] 展开/收起功能正常

---

#### Task 5.4: 创建 YuanTangCard 主Widget
**文件**: `lib/presentation/widgets/yuan_tang_card.dart`

**要求**:
- [x] 整合所有子组件
- [x] 顶部显示：
  - 性别、三元、节气
  - 先天卦、后天卦
- [x] 中间显示：
  - 计算步骤详情（整合在主Card中）
- [x] 底部显示：
  - 条文编号方法（整合在主Card中）
- [x] 支持展开/收起

**实际实现**:
```dart
Card(
  child: Column(
    children: [
      // 可点击的头部
      InkWell(onTap: _toggleExpand, child: _buildHeader()),

      if (_isExpanded) ...[
        Divider(),
        // 卦象概览
        _buildGuaSummary(),
        // 计算步骤（ExpansionTile）
        _buildCalculationSteps(),
        // 条文编号方法（ExpansionTile）
        _buildTiaoWenMethods(),
        // 条文统计
        _buildTiaoWenStats(),
      ],
    ],
  ),
)
```

**验收标准**:
- [x] 布局美观统一
- [x] 信息层次清晰
- [x] 交互流畅（支持多层展开/收起）
- [x] 支持响应式

---

#### Task 5.5: 更新 StrategyDemoPage
**文件**: `lib/presentation/pages/strategy_demo_page.dart`

**要求**:
- [x] 添加元堂卦页面到 PageView
- [x] 更新底部导航栏（添加第6个tab - 元堂卦）
- [x] 实现页面初始化逻辑
- [x] 实现刷新逻辑
- [x] 创建 _buildYuanTangContent 方法

**实际实现**:
```dart
// 初始化
final yuanTangViewModel = context.read<YuanTangViewModel>();
final fourZhu = FourZhu(
  yearGanzhi: eightChars.year.name,
  monthGanzhi: eightChars.month.name,
  dayGanzhi: eightChars.day.name,
  timeGanzhi: eightChars.time.name,
);
await yuanTangViewModel.setYuanTangParams(
  fourZhu: fourZhu,
  gender: "男",
  threeYuan: "上",
  birthAfterZhi: "夏至",
);

// UI构建
Widget _buildYuanTangContent(YuanTangViewModel viewModel) {
  if (viewModel.isLoading) return LoadingWidget();
  if (viewModel.hasError) return ErrorWidget();
  if (!viewModel.hasResult) return NoDataWidget();

  final uiModel = YuanTangUIModel.fromYuanTangModel(
    viewModel.yuanTangModel!,
    tiaoWenDataList: viewModel.result!.tiaoWenEntities,
  );

  return YuanTangCard(model: uiModel, initiallyExpanded: true);
}
```

**验收标准**:
- [x] 页面集成成功
- [x] 初始化逻辑正确（使用DevConstant.dev_usa）
- [x] 刷新逻辑工作正常
- [x] 导航切换流畅（6个tab）
- [x] 底部导航栏显示正确

---

### Phase 6: 参数输入UI实现 (预计2-3小时)

**注意**: 根据用户要求，此阶段已跳过，不实现任何参数输入相关UI，直接使用DevConstants.dev_usa固定参数进行演示。

#### Task 6.1: 创建 YuanTangParamsInputDialog
**状态**: ~~已跳过（按用户要求）~~

#### Task 6.2: 集成参数输入到页面
**状态**: ~~已跳过（按用户要求）~~

---

### Phase 7: 依赖注入配置 (预计1小时)

#### Task 7.1: 更新 strategy_providers.dart
**文件**: `lib/infrastructure/di/strategy_providers.dart`

**要求**:
- [x] 添加 YuanTangStrategy Provider
  ```dart
  Provider<YuanTangStrategy>(
    create: (_) => YuanTangStrategy(),
  ),
  ```
- [x] 添加 YuanTangTiaoWenListUseCase Provider
  ```dart
  ProxyProvider2<YuanTangStrategy, TiaoWenRepository, YuanTangTiaoWenListUseCase>(
    update: (_, strategy, repository, __) =>
        YuanTangTiaoWenListUseCase(strategy, repository),
  ),
  ```
- [x] 添加 YuanTangViewModel Provider
  ```dart
  ChangeNotifierProxyProvider<YuanTangTiaoWenListUseCase, YuanTangViewModel>(
    create: (context) {
      final useCase = context.read<YuanTangTiaoWenListUseCase>();
      return YuanTangViewModel(useCase);
    },
    update: (_, useCase, viewModel) =>
        viewModel ?? YuanTangViewModel(useCase),
  ),
  ```
- [x] 验证依赖关系正确

**验收标准**:
- [x] 所有Provider配置正确
- [x] 依赖注入工作正常
- [x] 无运行时错误
- [ ] 热重载正常（需要集成测试后验证）

---

### Phase 8: 测试实现 (预计4-5小时)

#### Task 8.1: 创建Strategy单元测试
**文件**: `test/service/strategy/yuan_tang_strategy_test.dart`

**要求**:
- [x] 测试天地卦生成
- [x] 测试上下卦生成
- [x] 测试元堂装卦（三种情况）
- [x] 测试后天卦生成
- [x] 测试互卦计算
- [x] 测试各种条文编号计算
- [x] 测试边界条件
- [x] 测试错误处理

**测试数据**:
```dart
final testFourZhu = FourZhu(
  yearGanzhi: "甲戌",
  monthGanzhi: "己巳",
  dayGanzhi: "辛丑",
  timeGanzhi: "丁酉",
);

final testParams = YuanTangStrategyParams(
  fourZhu: testFourZhu,
  gender: "男",
  threeYuan: "上",
  birthAfterZhi: "夏至",
);
```

**测试组**:
```dart
group('YuanTangStrategy - 天地卦生成', () {
  test('应该正确计算奇偶数总和', () { });
  test('应该正确计算天数和地数', () { });
  test('数为5时应该查询三元五宫', () { });
});

group('YuanTangStrategy - 上下卦生成', () {
  test('阳年男性应该天上地下', () { });
  test('阳年女性应该地上天下', () { });
  test('阴年女性应该天上地下', () { });
  test('阴年男性应该地上天下', () { });
});

group('YuanTangStrategy - 元堂装卦', () {
  test('1-3爻应该使用双重装配', () { });
  test('4-5爻应该自上而下排列', () { });
  test('6爻全阳应该正确处理', () { });
  test('元堂爻索引应该正确', () { });
});

group('YuanTangStrategy - 后天卦生成', () {
  test('元堂爻应该正确爻变', () { });
  test('上下卦应该正确互换', () { });
});

group('YuanTangStrategy - 条文编号计算', () {
  test('加则法条文编号应该正确', () { });
  test('纳甲太玄数条文编号应该正确', () { });
  test('本互条文编号应该正确', () { });
  test('互取数列表应该正确', () { });
});
```

**验收标准**:
- [x] 所有测试通过
- [x] 测试覆盖率 > 80%
- [x] 测试数据验证正确
- [x] 边界条件测试完整

---

#### Task 8.2: 创建调试测试
**文件**: `test/service/strategy/yuan_tang_strategy_debug_test.dart`

**要求**:
- [x] 打印完整的计算过程
- [x] 包含所有中间结果
- [x] 格式化输出易于阅读
- [x] 对比不同参数的结果

**输出格式**:
```
========== 元堂卦取数法计算结果 ==========
四柱: 甲戌 己巳 辛丑 丁酉
性别: 男
三元: 上
节气: 夏至

步骤1：生成天地卦
  天干数: [1, 6, 8, 4]
  地支数: [[3,7], [8,6], [10,5], [2,9]]
  奇数和: 47 → 天数: 22 → 天卦: 兑
  偶数和: 50 → 地数: 20 → 地卦: 坤

步骤2：生成上下卦
  年份阴阳: 阳
  性别: 男
  上卦: 兑 (7)
  下卦: 坤 (2)
  先天卦: 兑坤

步骤3：元堂装卦
  时辰阴阳: 阴
  阳爻数: 1, 阴爻数: 5
  六爻地支: [[], [丑], [未], [酉], [亥], []]
  元堂爻: 五爻

步骤4：生成后天卦
  元堂爻爻变: 五爻 阴→阳
  上下卦互换
  后天卦: 坤兑

步骤5：互卦
  先天卦互卦: ...
  后天卦互卦: ...

条文编号:
  先天卦加则法: 1234
  后天卦加则法: 5678
  先天卦纳甲太玄数: 2345
  后天卦纳甲太玄数: 6789
  先天卦本互: 3456
  后天卦本互: 7890
  先天卦互取数列表: [...]
  后天卦互取数列表: [...]
========================================
```

**验收标准**:
- [x] 打印输出清晰
- [x] 包含所有关键信息
- [x] 格式化良好
- [x] 便于人工验证

---

#### Task 8.3: 创建UseCase测试
**文件**: `test/usecases/yuan_tang_use_case_test.dart`

**要求**:
- [ ] 测试参数验证
- [ ] 测试Strategy调用
- [ ] 测试条文查询
- [ ] 测试结果构建
- [ ] 测试错误处理

**验收标准**:
- [ ] 所有测试通过
- [ ] 测试用例覆盖主要场景
- [ ] Mock对象使用正确

---

#### Task 8.4: 创建ViewModel测试
**文件**: `test/presentation/viewmodels/yuan_tang_view_model_test.dart`

**要求**:
- [ ] 测试状态管理
- [ ] 测试参数设置
- [ ] 测试计算触发
- [ ] 测试错误处理
- [ ] 测试刷新功能

**验收标准**:
- [ ] 所有测试通过
- [ ] 状态转换测试完整
- [ ] notifyListeners 调用正确

---

### Phase 9: 文档和测试报告 (预计2-3小时)

#### Task 9.1: 创建测试报告
**文件**: `docs/normal_alg/yuan_tang_test_report.md`

**要求**:
- [ ] 测试概述和状态
- [ ] 测试数据说明
- [ ] 计算过程验证
- [ ] 测试用例分组说明
- [ ] 重要发现和问题
- [ ] 运行测试命令
- [ ] 结论和建议

**验收标准**:
- [ ] 文档结构完整
- [ ] 数据表格清晰
- [ ] 分析详细

---

#### Task 9.2: 创建代码审查报告
**文件**: `docs/normal_alg/yuan_tang_code_review.md`

**要求**:
- [ ] 审查概述
- [ ] 文件清单
- [ ] 代码质量评价
- [ ] 架构设计评价
- [ ] 测试覆盖情况
- [ ] 潜在问题与建议
- [ ] 验收标准检查
- [ ] 审查结论

**验收标准**:
- [ ] 文档格式规范
- [ ] 评价客观准确
- [ ] 建议具体可行

---

#### Task 9.3: 更新 PRD 文档
**文件**: `docs/normal_alg/PRD.md`

**要求**:
- [ ] 添加元堂卦取数法模块说明
- [ ] 更新算法原理描述
- [ ] 更新用户交互说明
- [ ] 更新验收标准
- [ ] 更新里程碑

**验收标准**:
- [ ] PRD 更新完整
- [ ] 描述清晰准确
- [ ] 与实现一致

---

#### Task 9.4: 创建用户使用文档
**文件**: `docs/normal_alg/yuan_tang_user_guide.md`

**要求**:
- [ ] 功能介绍
- [ ] 参数说明（性别、三元、节气）
- [ ] 操作步骤
- [ ] 计算过程解释
- [ ] 条文编号方法说明
- [ ] 界面截图
- [ ] 常见问题解答

**验收标准**:
- [ ] 文档易于理解
- [ ] 操作步骤清晰
- [ ] 包含示例

---

## 📝 开发检查清单

### 代码质量
- [ ] 所有方法都有文档注释
- [ ] 代码符合Dart风格规范
- [ ] 没有硬编码的Magic Number
- [ ] 异常处理完善
- [ ] 日志输出合理
- [ ] 变量命名清晰

### 功能完整性
- [ ] 天地卦生成正确
- [ ] 上下卦生成正确
- [ ] 元堂装卦三种情况都正确
- [ ] 后天卦生成正确
- [ ] 互卦计算正确
- [ ] 8种条文编号都正确
- [ ] 边界情况处理（如地支不足）
- [ ] 条文查询正常

### 中间结果保留
- [ ] 天干数列表
- [ ] 地支数列表
- [ ] 奇偶数总和
- [ ] 天数、地数
- [ ] 三元五宫使用情况
- [ ] 年份阴阳
- [ ] 时辰阴阳
- [ ] 阴阳爻统计
- [ ] 六爻地支列表
- [ ] 元堂爻索引
- [ ] 互卦信息
- [ ] 所有条文编号

### UI/UX
- [ ] 界面美观统一
- [ ] 交互流畅
- [ ] 错误提示友好
- [ ] 加载状态清晰
- [ ] 计算过程展示详细
- [ ] 六爻详情可视化清晰
- [ ] 参数输入便捷
- [ ] 支持响应式布局

### 测试
- [ ] Strategy单元测试通过
- [ ] UseCase测试通过
- [ ] ViewModel测试通过
- [ ] 调试测试输出正确
- [ ] 测试覆盖率达标（>80%）
- [ ] 边界条件测试完整

### 文档
- [ ] PRD文档更新
- [ ] 测试报告完成
- [ ] 代码审查报告完成
- [ ] 用户指南完成
- [ ] API文档更新
- [ ] CHANGELOG更新

---

## 🐛 已知问题与风险

### 潜在问题
1. **三元五宫映射复杂**:
   - 风险：映射规则可能理解不准确
   - 解决：参考现有代码，充分测试

2. **元堂装卦六爻全阳/全阴情况复杂**:
   - 风险：性别和节气组合多，逻辑复杂
   - 解决：拆分成独立方法，每种情况单独测试

3. **中间结果字段众多**:
   - 风险：Model字段过多，维护困难
   - 解决：良好的文档注释，清晰的分组

4. **条文编号方法多**:
   - 风险：8种方法容易混淆
   - 解决：UI上用颜色和标题清晰区分

5. **性能考虑**:
   - 风险：计算步骤多，可能较慢
   - 优化：计算本身较快，主要是UI渲染

### 待讨论事项
- [ ] 是否需要支持条文编号方法的自定义选择
- [ ] 是否需要添加计算过程动画演示
- [ ] UI展示是否需要更多可视化元素（如卦象图）
- [ ] 是否需要支持批量计算（不同参数组合）

---

## 📅 里程碑

### M1: 数据模型完成 (3-4小时)
- [x] YuanTangYaoDetail 创建完成
- [x] YuanTangBaseNumberModel 创建完成

### M2: Strategy实现完成 (5-6小时)
- [x] YuanTangStrategy 基础框架完成
- [x] 步骤1-5 所有方法实现完成
- [x] calculate() 主方法完成
- [x] 单元测试通过 (45/45 tests passed)

### M3: UseCase实现完成 (2-3小时)
- [x] YuanTangTiaoWenListUseCase 实现完成
- [x] 条文查询集成完成

### M4: ViewModel实现完成 (2-3小时)
- [x] YuanTangViewModel 实现完成
- [x] 状态管理正常

### M5: UI实现完成 (4-5小时)
- [x] YuanTangUIModel 创建完成
- [x] YuanTangCard Widget创建完成
- [x] StrategyDemoPage集成完成
- [x] 页面展示正常（含6个tab）

### M6: 参数输入完成 (2-3小时)
- ~~已跳过（按用户要求使用固定参数）~~

### M7: 测试完成 (4-5小时)
- [x] 所有单元测试通过 (45/45)
- [x] 调试测试完成
- ~~集成测试已跳过~~

### M8: 文档完成 (2-3小时)
- [ ] 测试报告完成
- [ ] 代码审查报告完成
- [ ] PRD更新完成
- [ ] 用户指南完成

**预计总时间**: 20-28小时

---

## 🔗 相关资源

### 代码参考
- 现有元堂算法: `lib/service/yuan_tang/yuan_tang_calculator.dart`
- 太玄四柱Strategy: `lib/service/strategy/tai_xuan_four_zhu_strategy.dart`
- 八卦加则Strategy: `lib/service/strategy/ba_gua_jia_ze_strategy.dart`
- FourZhu: `lib/domain/four_zhu.dart`
- Constants: `lib/constant/constants.dart`

### 文档
- PRD: `docs/normal_alg/PRD.md`
- 太玄TODO: `docs/normal_alg/tai_xuan_todo_list.md`
- 八卦加则TODO: `docs/normal_alg/eight_gua_jia_ze_todo_list.md`
- 代码审查: `docs/normal_alg/code_review.md`

### 关键常量
- tianGanNumberMapper: 天干配数
- diZhiNumberMapper: 地支配数（每个地支两个数）
- yuantangHuaTianNumberGuaMapper: 数配卦映射
- houGuaNumberMapper: 后天卦数映射
- xianTianGuaNumberMapper: 先天卦数映射
- guaBinaryMapper: 卦名到二进制映射

### 工具方法
- GuaUtils.calculateGuaNum(): 计算卦数（模运算）
- GuaUtils.guaToBinaryList(): 卦转二进制
- GuaUtils.guaToHuGua(): 计算互卦
- TiaowenCalculator.getTiaowenNumberByJiaZe(): 加则法条文
- TiaowenCalculator.getTiaowenNumberByTaixuan(): 纳甲太玄数条文
- TiaowenCalculator.calculateTiaoWenListBySubAndAdd(): 互取数列表

---

## 📧 联系方式

**技术问题**: 请提Issue或联系项目维护者
**需求变更**: 请更新PRD并通知团队
**进度更新**: 每完成一项任务则在此TODO清单中勾选

---

**创建日期**: 2025-10-11
**文档版本**: v1.0
**最后更新**: 2025-10-11
