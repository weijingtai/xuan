import 'package:qimendunjia/domain/entities/each_gong.dart' as entity;
import 'package:qimendunjia/model/each_gong.dart' as model;

/// EachGong Entity ↔ Model 转换器
///
/// 负责在领域层实体和数据层模型之间进行转换
class EachGongMapper {
  /// Model → Entity
  ///
  /// 将数据层的 Model 转换为领域层的 Entity
  static entity.EachGong fromModel(model.EachGong modelGong) {
    return entity.EachGong(
      gongNumber: modelGong.gongNumber,
      gongGua: modelGong.gongGua,
      star: modelGong.star,
      door: modelGong.door,
      god: modelGong.god,
      diGod: modelGong.diGod,
      tianPan: modelGong.tianPan,
      diPan: modelGong.diPan,
      tianPanAnGan: modelGong.tianPanAnGan,
      renPanAnGan: modelGong.renPanAnGan,
      yinGan: modelGong.yinGan,
      tianPanJiGan: modelGong.tianPanJiGan,
      diPanJiGan: modelGong.diPanJiGan,
      sixJiaXunHeader: modelGong.sixJiaXunHeader,
      isJiTianQin: modelGong.isJiTianQin,
    );
  }

  /// Entity → Model
  ///
  /// 将领域层的 Entity 转换为数据层的 Model
  static model.EachGong toModel(entity.EachGong entityGong) {
    final modelGong = model.EachGong(
      gongNumber: entityGong.gongNumber,
      gongGua: entityGong.gongGua,
      star: entityGong.star,
      door: entityGong.door,
      god: entityGong.god,
      diGod: entityGong.diGod,
      tianPan: entityGong.tianPan,
      diPan: entityGong.diPan,
      tianPanAnGan: entityGong.tianPanAnGan,
      renPanAnGan: entityGong.renPanAnGan,
      yinGan: entityGong.yinGan,
      sixJiaXunHeader: entityGong.sixJiaXunHeader,
    );

    // 设置寄干（Model 中的字段）
    modelGong.tianPanJiGan = entityGong.tianPanJiGan;
    modelGong.diPanJiGan = entityGong.diPanJiGan;
    modelGong.isJiTianQin = entityGong.isJiTianQin;

    return modelGong;
  }
}
