import 'dart:convert';
import 'dart:io';

import 'package:tiebanshenshu/domain/models/base_number_model.dart';
import 'package:tiebanshenshu/features/huang_ji/huang_ji_formula_v2.dart';
import 'package:tiebanshenshu/domain/models/huang_ji_number.dart';

Future<HuangJiCalculationFormula> generate1() async {
  final first_yuanhui = firstYuanHui();
  final first_yunshi = firstYunHui();

  final huangJiFormula = HuangJiCalculationFormula(
    id: 1,
    name: "皇极取数法一",
    description: "来源《铁板神数预测学》中《皇极取数》",
    groups: [first_yuanhui, first_yunshi],
  );

  final huangjiFile = File('test/domain/models/huang_ji_1.json');
  await huangjiFile.create(recursive: true);
  await huangjiFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(huangJiFormula),
  );

  final yuanHuiFile = File('test/domain/models/first_yuanhui.json');
  await yuanHuiFile.create(recursive: true);
  await yuanHuiFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(first_yuanhui),
  );

  final yunshiFile = File('test/domain/models/first_yunshi.json');
  await yunshiFile.create(recursive: true);
  await yunshiFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(first_yunshi),
  );

  return huangJiFormula;
}

CalculationGroup firstYuanHui() {
  ///   + 基础数 + 月干(百位数） = 条文数
  ///   + 基础数 + 月支(百位数) = 条文数
  ///   + 基础数 + 月干支互数(干为十位+支为个位) = 条文数
  ///   + 基础数 + 时干(个位数） = 条文数
  ///   + 基础数 + 时支(个位数) = 条文数
  ///   + 基础数 + 日干支互合数(干为十位+支为个位) + 时干个位数 = 条文数
  ///   + 基础数 + 日干支互合数(干为十位+支为个位) + 时支个位数 = 条文数
  ///   + 基础数 + 年支(千位数) = 条文数
  return CalculationGroup(
    groupId: '元会·基础数一',
    description: "元会基础数 + 年干(千位数） = 条文数` 以及根据次派生出的条文数",
    // baseNumberDefinition: SelectableBaseNumber(
    //   name: "元会基础数",
    //   description: "根据元会基础数+年干(千位数）=条文数(用户选择)",
    //   initialCandidateFormula: DerivedBaseNumber(
    //     name: "元会·基础数一",
    //     description: "元会数 + 年干(千位）= 条文数(用户选择)",
    //     parentGroupId: '元会·基础数一',
    //     baseNumberDefinition: PredefinedBaseNumber(
    //       name: "元会基础数",
    //       description: "元会基础数",
    //       source: NumberSource.yuanHui,
    //     ),
    //     parts: [
    //       SingleNumberPart(
    //         name: "年干(千位数）",
    //         description: "年干太玄数 * 1000",
    //         fourZhuGanZhiType: FourZhuGanZhiType.gan,
    //         fourZhuName: FourZhuName.year,
    //         numberPlace: EnumNumberPlace.Thousands,
    //       ),
    //     ],
    //   ),
    // ),
    baseNumberDefinition: DerivedBaseNumber(
      name: "元会·基础数一",
      description: "元会数 + 年干(千位）= 条文数(用户选择)",
      parentGroupId: '元会·基础数一',
      baseNumberDefinition: PredefinedBaseNumber(
        name: "元会基础数",
        description: "元会基础数",
        source: NumberSource.yuanHui,
      ),
      parts: [
        SingleNumberPart(
          name: "年干(千位数）",
          description: "年干太玄数 * 1000",
          fourZhuGanZhiType: FourZhuGanZhiType.gan,
          fourZhuName: FourZhuName.year,
          numberPlace: EnumNumberPlace.Thousands,
        ),
      ],
    ),
    formulas: [
      TiaoWenFormula(
        name: "年支(千位数）",
        description: "元会·基础数一 + 年支(千位数）",
        parts: [
          SingleNumberPart(
            name: "年支(千位数）",
            description: "年支太玄数 * 1000",
            fourZhuGanZhiType: FourZhuGanZhiType.zhi,
            fourZhuName: FourZhuName.year,
            numberPlace: EnumNumberPlace.Thousands,
          ),
        ],
      ),

      TiaoWenFormula(
        name: "月支(百位数）",
        description: "元会·基础数一 + 月支(百位数）",
        parts: [
          SingleNumberPart(
            name: "月支(百位数）",
            description: "月支太玄数 * 100",
            fourZhuGanZhiType: FourZhuGanZhiType.zhi,
            fourZhuName: FourZhuName.month,
            numberPlace: EnumNumberPlace.Hundreds,
          ),
        ],
      ),
      TiaoWenFormula(
        name: "月干(百位数）",
        description: "元会·基础数一 + 月干(百位数）",
        parts: [
          SingleNumberPart(
            name: "月干(百位数）",
            description: "月干太玄数 * 100",
            fourZhuGanZhiType: FourZhuGanZhiType.gan,
            fourZhuName: FourZhuName.month,
            numberPlace: EnumNumberPlace.Hundreds,
          ),
        ],
      ),

      TiaoWenFormula(
        name: "日干支互合数",
        description: "元会·基础数一 + 日干支互数(干为十位+支为个位)",
        parts: [
          CompositeNumberPart(
            name: "日干支互数",
            description: "基础数 + 日干支互数(干为十位+支为个位) = 条文数",
            components: [
              SingleNumberPart(
                name: "日干十位",
                description: "日干太玄数 * 10",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Tens,
              ),
              SingleNumberPart(
                name: "日支个位",
                description: "日支太玄数",
                fourZhuGanZhiType: FourZhuGanZhiType.zhi,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),
        ],
      ),
      TiaoWenFormula(
        name: "时干(个位数）",
        description: "元会·基础数一 + 时干(个位数）",
        parts: [
          SingleNumberPart(
            name: "时干(个位数）",
            description: "时干太玄数",
            fourZhuGanZhiType: FourZhuGanZhiType.gan,
            fourZhuName: FourZhuName.time,
            numberPlace: EnumNumberPlace.Units,
          ),
        ],
      ),
      TiaoWenFormula(
        name: "时支(个位数）",
        description: "元会·基础数一 + 时支(个位数）",
        parts: [
          SingleNumberPart(
            name: "时支(个位数）",
            description: "时支太玄数",
            fourZhuGanZhiType: FourZhuGanZhiType.zhi,
            fourZhuName: FourZhuName.time,
            numberPlace: EnumNumberPlace.Units,
          ),
        ],
      ),

      TiaoWenFormula(
        name: "日互合+时支(个位数）",
        description: "元会·基础数一 + 日互合(干为十位+支为个位) +时支(个位数）",
        parts: [
          CompositeNumberPart(
            name: "日互合(干为十位+支为个位)",
            description: "日互合(干为十位+支为个位)",
            components: [
              SingleNumberPart(
                name: "日干十位",
                description: "日干太玄数 * 10",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Tens,
              ),
              SingleNumberPart(
                name: "日支个位",
                description: "日支太玄数",
                fourZhuGanZhiType: FourZhuGanZhiType.zhi,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),
          SingleNumberPart(
            name: "时支(个位数）",
            description: "时支太玄数",
            fourZhuGanZhiType: FourZhuGanZhiType.zhi,
            fourZhuName: FourZhuName.time,
            numberPlace: EnumNumberPlace.Units,
          ),
        ],
      ),

      TiaoWenFormula(
        name: "日互合+时干(个位数）",
        description: "元会·基础数一 + 日互合(干为十位+支为个位) +时干(个位数）",
        parts: [
          CompositeNumberPart(
            name: "日互合(干为十位+支为个位)",
            description: "日互合(干为十位+支为个位)",
            components: [
              SingleNumberPart(
                name: "日干十位",
                description: "日干太玄数 * 10",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Tens,
              ),
              SingleNumberPart(
                name: "日支个位",
                description: "日支太玄数",
                fourZhuGanZhiType: FourZhuGanZhiType.zhi,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),
          SingleNumberPart(
            name: "时干(个位数）",
            description: "时干太玄数",
            fourZhuGanZhiType: FourZhuGanZhiType.gan,
            fourZhuName: FourZhuName.time,
            numberPlace: EnumNumberPlace.Units,
          ),
        ],
      ),
    ],
  );
}

CalculationGroup firstYunHui() {
  ///   + 运世基础数 + 日干支互合数 = 条文数
  ///   + 运世基础数 + 时干个位数 = 条文数
  ///   + 运世基础数 + 时支个位数 = 条文数
  ///   + 运世基础数 + 日干支互合数 + 时干个位数 = 条文数
  ///   + 运世基础数 + 日干支互合数 + 时支个位数 = 条文数
  return CalculationGroup(
    groupId: '运世基础数',
    description: '运世基础数 进行的相关条文数计算',
    baseNumberDefinition: PredefinedBaseNumber(
      name: '运世基础数',
      description: '运世基础数',
      source: NumberSource.yunShi,
    ),
    formulas: [
      TiaoWenFormula(
        name: "日互合数",
        description: "运世基础数 + 日干支互合数",
        parts: [
          CompositeNumberPart(
            name: "日互合(干为十位+支为个位)",
            description: "日互合(干为十位+支为个位)",
            components: [
              SingleNumberPart(
                name: "日干十位",
                description: "日干太玄数 * 10",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Tens,
              ),
              SingleNumberPart(
                name: "日支个位",
                description: "日支太玄数",
                fourZhuGanZhiType: FourZhuGanZhiType.zhi,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),
        ],
      ),

      TiaoWenFormula(
        name: "时干个位",
        description: "运世基础数 + 时干个位数",
        parts: [
          SingleNumberPart(
            name: "时干个位数",
            description: "时干太玄数",
            fourZhuGanZhiType: FourZhuGanZhiType.gan,
            fourZhuName: FourZhuName.time,
            numberPlace: EnumNumberPlace.Units,
          ),
        ],
      ),
      TiaoWenFormula(
        name: "时支个位",
        description: "运世基础数 + 时支个位数",
        parts: [
          SingleNumberPart(
            name: "时支个位数",
            description: "时支太玄数",
            fourZhuGanZhiType: FourZhuGanZhiType.zhi,
            fourZhuName: FourZhuName.time,
            numberPlace: EnumNumberPlace.Units,
          ),
        ],
      ),
      TiaoWenFormula(
        name: "日互合数+时干个位",
        description: "运世基础数 + 日干支互合数 + 时干个位数",
        parts: [
          CompositeNumberPart(
            name: "日互合(干为十位+支为个位)",
            description: "日互合(干为十位+支为个位)",
            components: [
              SingleNumberPart(
                name: "日干十位",
                description: "日干太玄数 * 10",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Tens,
              ),
              SingleNumberPart(
                name: "日支个位",
                description: "日支太玄数",
                fourZhuGanZhiType: FourZhuGanZhiType.zhi,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),
          SingleNumberPart(
            name: "时干个位数",
            description: "时干太玄数",
            fourZhuGanZhiType: FourZhuGanZhiType.gan,
            fourZhuName: FourZhuName.time,
            numberPlace: EnumNumberPlace.Units,
          ),
        ],
      ),

      TiaoWenFormula(
        name: "日互合数+时支个位",
        description: "运世基础数 + 日干支互合数 + 时支个位数",
        parts: [
          CompositeNumberPart(
            name: "日互合(干为十位+支为个位)",
            description: "日互合(干为十位+支为个位)",
            components: [
              SingleNumberPart(
                name: "日干十位",
                description: "日干太玄数 * 10",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Tens,
              ),
              SingleNumberPart(
                name: "日支个位",
                description: "日支太玄数",
                fourZhuGanZhiType: FourZhuGanZhiType.zhi,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),
          SingleNumberPart(
            name: "时支个位数",
            description: "时支太玄数",
            fourZhuGanZhiType: FourZhuGanZhiType.zhi,
            fourZhuName: FourZhuName.time,
            numberPlace: EnumNumberPlace.Units,
          ),
        ],
      ),
    ],
  );
}

Future<HuangJiCalculationFormula> generate2() async {
  final huangJiFormula = HuangJiCalculationFormula(
    id: 2,
    name: "皇极取数法二",
    description: "来源《图解易经铁板神数》中《元会运世（一）》",
    groups: [
      // 元会
      CalculationGroup(
        groupId: '元会·基础数一',
        description: "元会基础数 + 年干(千位数） = 条文数` 以及根据次派生出的条文数",
        baseNumberDefinition: SelectableBaseNumber(
          name: "元会基础数",
          description: "根据元会基础数+年干(千位数）=条文数(用户选择)",
          initialCandidateFormula: DerivedBaseNumber(
            name: "元会·基础数一",
            description: "元会数 + 年干(千位）= 条文数(用户选择)",
            parentGroupId: '元会·基础数一',
            baseNumberDefinition: PredefinedBaseNumber(
              name: "元会基础数",
              description: "元会基础数",
              source: NumberSource.yuanHui,
            ),
            parts: [
              SingleNumberPart(
                name: "年干(千位数）",
                description: "年干太玄数 * 1000",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.year,
                numberPlace: EnumNumberPlace.Thousands,
              ),
            ],
          ),
        ),
        formulas: [
          TiaoWenFormula(
            name: "月干太玄(百位数）",
            description: "元会·基础数一 + 月干(百位数）",
            parts: [
              SingleNumberPart(
                name: "月干(百位数）",
                description: "月干太玄数 * 100",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.month,
                numberPlace: EnumNumberPlace.Hundreds,
              ),
            ],
          ),

          TiaoWenFormula(
            name: "日干(十位数）",
            description: "元会·基础数一 + 日干(十位数）",
            parts: [
              SingleNumberPart(
                name: "日干(十位数）",
                description: "日干太玄数 * 10",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Tens,
              ),
            ],
          ),
          TiaoWenFormula(
            name: "时干(个位数）",
            description: "元会·基础数一 + 时干(个位数）",
            parts: [
              SingleNumberPart(
                name: "时干(个位数）",
                description: "时干太玄数(个位)",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.time,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),

          TiaoWenFormula(
            name: "日干(个位数）",
            description: "元会·基础数一 + 日干(个位数）",
            parts: [
              SingleNumberPart(
                name: "日干(个位数）",
                description: "日干太玄数(个位)",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),
        ],
      ),

      // 运世
      CalculationGroup(
        groupId: '运世·基础数一',
        description: "运世基础数 + 年干(千位数） = 条文数` 以及根据次派生出的条文数",
        baseNumberDefinition: DerivedBaseNumber(
          name: "运世·基础数一",
          description: "运世基础数 + 年干(千位）= 条文数(用户选择)",
          parentGroupId: '运世·基础数一',
          baseNumberDefinition: PredefinedBaseNumber(
            name: "运世基础数",
            description: "运世基础数",
            source: NumberSource.yunShi,
          ),
          parts: [
            SingleNumberPart(
              name: "年干(千位数）",
              description: "年干太玄数 * 1000",
              fourZhuGanZhiType: FourZhuGanZhiType.gan,
              fourZhuName: FourZhuName.year,
              numberPlace: EnumNumberPlace.Thousands,
            ),
          ],
        ),
        formulas: [
          TiaoWenFormula(
            name: "月干太玄(百位数）",
            description: "运世·基础数一 + 月干(百位数）",
            parts: [
              SingleNumberPart(
                name: "月干(百位数）",
                description: "月干太玄数 * 100",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.month,
                numberPlace: EnumNumberPlace.Hundreds,
              ),
            ],
          ),

          TiaoWenFormula(
            name: "日干(十位数）",
            description: "运世·基础数一 + 日干(十位数）",
            parts: [
              SingleNumberPart(
                name: "日干(十位数）",
                description: "日干太玄数 * 10",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Tens,
              ),
            ],
          ),
          TiaoWenFormula(
            name: "时干(个位数）",
            description: "运世·基础数一 + 时干(个位数）",
            parts: [
              SingleNumberPart(
                name: "时干(个位数）",
                description: "时干太玄数(个位)",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.time,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),

          TiaoWenFormula(
            name: "日干(个位数）",
            description: "运世·基础数一 + 日干(个位数）",
            parts: [
              SingleNumberPart(
                name: "日干(个位数）",
                description: "日干太玄数(个位)",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),
        ],
      ),
    ],
  );

  final yuanHuiFile = File('test/domain/models/huang_ji_2.json');
  await yuanHuiFile.create(recursive: true);
  await yuanHuiFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(huangJiFormula),
  );
  return huangJiFormula;
}

Future<HuangJiCalculationFormula> generate3() async {
  final huangJiFormula = HuangJiCalculationFormula(
    id: 3,
    name: "皇极取数法三",
    description: "来源《图解易经铁板神数》中《元会运世（二）》",
    groups: [
      // 元会
      CalculationGroup(
        groupId: '元会·基础数一',
        description: "元会基础数 + 年干(千位数） = 条文数` 以及根据次派生出的条文数",
        baseNumberDefinition: SelectableBaseNumber(
          name: "元会基础数",
          description: "根据元会基础数+年干(千位数）=条文数(用户选择)",
          initialCandidateFormula: DerivedBaseNumber(
            name: "元会·基础数一",
            description: "元会数 + 年干(千位）= 条文数(用户选择)",
            parentGroupId: '元会·基础数一',
            baseNumberDefinition: PredefinedBaseNumber(
              name: "元会基础数",
              description: "元会基础数",
              source: NumberSource.yuanHui,
            ),
            parts: [
              SingleNumberPart(
                name: "年干(千位数）",
                description: "年干太玄数 * 1000",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.year,
                numberPlace: EnumNumberPlace.Thousands,
              ),
            ],
          ),
        ),
        formulas: [
          TiaoWenFormula(
            name: "月干太玄(百位数）",
            description: "元会·基础数一 + 月干(百位数）",
            parts: [
              SingleNumberPart(
                name: "月干(百位数）",
                description: "月干太玄数 * 100",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.month,
                numberPlace: EnumNumberPlace.Hundreds,
              ),
            ],
          ),
          TiaoWenFormula(
            name: "月支太玄(百位数）",
            description: "元会·基础数一 + 月支(百位数）",
            parts: [
              SingleNumberPart(
                name: "月支(百位数）",
                description: "月支太玄数 * 100",
                fourZhuGanZhiType: FourZhuGanZhiType.zhi,
                fourZhuName: FourZhuName.month,
                numberPlace: EnumNumberPlace.Hundreds,
              ),
            ],
          ),
        ],
      ),
      CalculationGroup(
        groupId: '元会·基础数二',
        description: "元会·基础数一(元会+年干千位) + 日干互合(干十位+时干个位数） = 条文数` 以及根据次派生出的条文数",
        baseNumberDefinition: SelectableBaseNumber(
          name: "元会基础数",
          description: "根据元会基础数+年干(千位数）=条文数(用户选择)",
          initialCandidateFormula: DerivedBaseNumber(
            name: "元会·基础数二",
            description: "元会数 + 年干(千位）= 条文数(用户选择)",
            parentGroupId: '元会·基础数二',
            baseNumberDefinition: DerivedBaseNumber(
              name: "元会基础数",
              description: "元会基础数",
              baseNumberDefinition: PredefinedBaseNumber(
                name: "元会基础数",
                description: "元会基础数",
                source: NumberSource.yuanHui,
              ),
              parentGroupId: '元会·基础数二',
              parts: [
                SingleNumberPart(
                  name: "年干(千位数）",
                  description: "年干太玄数 * 1000",
                  fourZhuGanZhiType: FourZhuGanZhiType.gan,
                  fourZhuName: FourZhuName.year,
                  numberPlace: EnumNumberPlace.Thousands,
                ),
              ],
            ),
            parts: [
              CompositeNumberPart(
                name: "日干互合(干十位+支个位)",
                description: "日干互合(干十位+支个位)",
                components: [
                  SingleNumberPart(
                    name: "日干(十位）",
                    description: "日干太玄数 * 10",
                    fourZhuGanZhiType: FourZhuGanZhiType.gan,
                    fourZhuName: FourZhuName.day,
                    numberPlace: EnumNumberPlace.Tens,
                  ),
                  SingleNumberPart(
                    name: "日支(个位数）",
                    description: "日支太玄数",
                    fourZhuGanZhiType: FourZhuGanZhiType.zhi,
                    fourZhuName: FourZhuName.day,
                    numberPlace: EnumNumberPlace.Units,
                  ),
                ],
              ),
            ],
          ),
        ),
        formulas: [
          TiaoWenFormula(
            name: "时干太玄(个位数）",
            description: "元会·基础数二 + 时干(个位数）",
            parts: [
              SingleNumberPart(
                name: "时干(个位数）",
                description: "时干太玄数",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.time,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),
          TiaoWenFormula(
            name: "时支太玄(个位数）",
            description: "元会·基础数二 + 时支(个位数）",
            parts: [
              SingleNumberPart(
                name: "时支(个位数）",
                description: "时支太玄数",
                fourZhuGanZhiType: FourZhuGanZhiType.zhi,
                fourZhuName: FourZhuName.time,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),
        ],
      ),

      // 运世
      CalculationGroup(
        groupId: '运世·基础数一',
        description: "运世基础数 + 年干(千位数） = 条文数` 以及根据次派生出的条文数",
        baseNumberDefinition: SelectableBaseNumber(
          name: "运世基础数",
          description: "根据运世基础数+年干(千位数）=条文数(用户选择)",
          initialCandidateFormula: DerivedBaseNumber(
            name: "运世·基础数一",
            description: "运世基础数 + 年干(千位）= 条文数(用户选择)",
            parentGroupId: '运世·基础数一',
            baseNumberDefinition: PredefinedBaseNumber(
              name: "运世基础数",
              description: "运世基础数",
              source: NumberSource.yunShi,
            ),
            parts: [
              SingleNumberPart(
                name: "年干(千位数）",
                description: "年干太玄数 * 1000",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.year,
                numberPlace: EnumNumberPlace.Thousands,
              ),
            ],
          ),
        ),
        formulas: [
          TiaoWenFormula(
            name: "月干太玄(百位数）",
            description: "运世·基础数一 + 月干(百位数）",
            parts: [
              SingleNumberPart(
                name: "月干(百位数）",
                description: "月干太玄数 * 100",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.month,
                numberPlace: EnumNumberPlace.Hundreds,
              ),
            ],
          ),
          TiaoWenFormula(
            name: "月支太玄(百位数）",
            description: "运世·基础数一 + 月支(百位数）",
            parts: [
              SingleNumberPart(
                name: "月支(百位数）",
                description: "月支太玄数 * 100",
                fourZhuGanZhiType: FourZhuGanZhiType.zhi,
                fourZhuName: FourZhuName.month,
                numberPlace: EnumNumberPlace.Hundreds,
              ),
            ],
          ),
        ],
      ),

      CalculationGroup(
        groupId: '运世·基础数二',
        description: "运世·基础数一(运世+年干千位) + 日干互合(干十位+时干个位数） = 条文数` 以及根据次派生出的条文数",
        baseNumberDefinition: SelectableBaseNumber(
          name: "运世基础数",
          description: "根据运世基础数+年干(千位数）=条文数(用户选择)",
          initialCandidateFormula: DerivedBaseNumber(
            name: "运世·基础数二",
            description: "运世数 + 年干(千位）= 条文数(用户选择)",
            parentGroupId: '运世·基础数二',
            baseNumberDefinition: DerivedBaseNumber(
              name: "运世基础数",
              description: "运世基础数",
              baseNumberDefinition: PredefinedBaseNumber(
                name: "运世基础数",
                description: "运世基础数",
                source: NumberSource.yunShi,
              ),
              parentGroupId: '运世·基础数二',
              parts: [
                SingleNumberPart(
                  name: "年干(千位数）",
                  description: "年干太玄数 * 1000",
                  fourZhuGanZhiType: FourZhuGanZhiType.gan,
                  fourZhuName: FourZhuName.year,
                  numberPlace: EnumNumberPlace.Thousands,
                ),
              ],
            ),
            parts: [
              CompositeNumberPart(
                name: "日干互合(干十位+支个位)",
                description: "日干互合(干十位+支个位)",
                components: [
                  SingleNumberPart(
                    name: "日干(十位）",
                    description: "日干太玄数 * 10",
                    fourZhuGanZhiType: FourZhuGanZhiType.gan,
                    fourZhuName: FourZhuName.day,
                    numberPlace: EnumNumberPlace.Tens,
                  ),
                  SingleNumberPart(
                    name: "日支(个位数）",
                    description: "日支太玄数",
                    fourZhuGanZhiType: FourZhuGanZhiType.zhi,
                    fourZhuName: FourZhuName.day,
                    numberPlace: EnumNumberPlace.Units,
                  ),
                ],
              ),
            ],
          ),
        ),
        formulas: [
          TiaoWenFormula(
            name: "时干太玄(个位数）",
            description: "运世·基础数二 + 时干(个位数）",
            parts: [
              SingleNumberPart(
                name: "时干(个位数）",
                description: "时干太玄数",
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.time,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),
          TiaoWenFormula(
            name: "时支太玄(个位数）",
            description: "运世·基础数二 + 时支(个位数）",
            parts: [
              SingleNumberPart(
                name: "时支(个位数）",
                description: "时支太玄数",
                fourZhuGanZhiType: FourZhuGanZhiType.zhi,
                fourZhuName: FourZhuName.time,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          ),
        ],
      ),
    ],
  );

  final yuanHuiFile = File('test/domain/models/huang_ji_3.json');
  await yuanHuiFile.create(recursive: true);
  await yuanHuiFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(huangJiFormula),
  );
  return huangJiFormula;
}

main() async {
  await Future.wait([generate1(), generate2(), generate3()]);
}
