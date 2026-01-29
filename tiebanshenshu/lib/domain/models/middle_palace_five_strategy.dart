import 'package:common/enums.dart';

/// 后天八卦“中五宫”取数策略的抽象接口
abstract class MiddlePalaceFiveStrategy {
  /// 根据三元、性别和年干阴阳获取对应的后天八卦
  Enum8Gua getGua({
    required YuanYunOrder era,
    required Gender gender,
    required bool isYang,
  });
}

/// “中五宫”取数策略的默认实现
/// 上元男艮女坤；中元阳女阴男“坤”，阴女阳男“艮”；下元女兑男离
class DefaultMiddlePalaceFiveStrategy implements MiddlePalaceFiveStrategy {
  @override
  Enum8Gua getGua({
    required YuanYunOrder era,
    required Gender gender,
    required bool isYang,
  }) {
    switch (era) {
      case YuanYunOrder.upper:
        return gender == Gender.male ? Enum8Gua.Gen : Enum8Gua.Kun;
      case YuanYunOrder.middle:
        // 阴男阳女“坤”，阳男阴女“艮”
        final isYinMale = gender == Gender.male && !isYang;
        final isYangFemale = gender == Gender.female && isYang;
        if (isYinMale || isYangFemale) {
          return Enum8Gua.Kun;
        } else {
          return Enum8Gua.Gen;
        }
      case YuanYunOrder.lower:
        return gender == Gender.male ? Enum8Gua.Li : Enum8Gua.Dui;
    }
  }
}
