import 'package:common/enums.dart';
import 'package:qimendunjia/domain/entities/each_gong.dart' as entity;
import 'package:qimendunjia/domain/entities/qimen_pan.dart' as entity;
import 'package:qimendunjia/model/shi_jia_qi_men.dart' as model;
import 'each_gong_mapper.dart';
import 'shi_jia_ju_mapper.dart';

/// QiMenPan Entity ↔ Model 转换器
///
/// 负责在领域层实体和数据层模型之间进行转换
class QiMenPanMapper {
  /// 生成唯一 ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Model → Entity
  ///
  /// 将数据层的 Model 转换为领域层的 Entity
  static entity.QiMenPan fromModel(model.ShiJiaQiMen modelPan) {
    // 转换 gongMapper
    final Map<HouTianGua, entity.EachGong> gongMapper = {};
    modelPan.gongMapper.forEach((gua, modelGong) {
      gongMapper[gua] = EachGongMapper.fromModel(modelGong);
    });

    return entity.QiMenPan(
      id: _generateId(),
      panDateTime: modelPan.shiJiaJu.panDateTime,
      shiJiaJu: ShiJiaJuMapper.fromModel(modelPan.shiJiaJu),
      plateType: modelPan.plateType,
      gongMapper: gongMapper,
      zhiShiDoor: modelPan.zhiShiDoor,
      zhiShiDoorAtGong: modelPan.zhiShiDoorAtGong,
      zhiFuStar: modelPan.zhiFuStar,
      zhiFuStarAtGong: modelPan.zhiFuStarAtGong,
      isStarFuYin: modelPan.isStarFuYin,
      isStarFanYin: modelPan.isStarFanYin,
      isDoorFuYin: modelPan.isDoorFuYin,
      isDoorFanYin: modelPan.isDoorFanYin,
      isGanFuYin: modelPan.isGanFuYin,
      isGanFanYin: modelPan.isGanFanYin,
      horseLocation: modelPan.horseLocation,
      panGeJuList: modelPan.panGeJuList,
    );
  }
}

