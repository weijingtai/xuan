import 'package:qimendunjia/domain/entities/shi_jia_ju.dart' as entity;
import 'package:qimendunjia/model/shi_jia_ju.dart' as model;

/// ShiJiaJu Entity ↔ Model 转换器
///
/// 负责在领域层实体和数据层模型之间进行转换
class ShiJiaJuMapper {
  /// 生成唯一 ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Model → Entity
  ///
  /// 将数据层的 Model 转换为领域层的 Entity
  static entity.ShiJiaJu fromModel(model.ShiJiaJu modelJu) {
    return entity.ShiJiaJu(
      id: _generateId(),
      panDateTime: modelJu.panDateTime,
      juNumber: modelJu.juNumber,
      fuTouJiaZi: modelJu.fuTouJiaZi,
      yinYangDun: modelJu.yinYangDun,
      jieQiAt: modelJu.jieQiAt,
      jieQiStartAt: modelJu.jieQiStartAt ?? DateTime.now(),
      jieQiEnd: modelJu.jieQiEnd,
      jieQiEndAt: modelJu.jieQiEndAt ?? DateTime.now(),
      atThreeYuan: modelJu.atThreeYuan,
      fourZhuEightChar: modelJu.fourZhuEightChar,
      panJuJieQi: modelJu.panJuJieQi,
      juDayNumber: modelJu.juDayNumber,
    );
  }

  /// Entity → Model
  ///
  /// 将领域层的 Entity 转换为数据层的 Model
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
