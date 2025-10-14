import 'package:common/enums.dart';
import 'package:tiebanshenshu/domain/pure_yuan_tang_gua.dart';
import 'package:tiebanshenshu/domain/pure_six_yao_gua.dart';

class YuanTangYaoUIModel {
  final int position; // 1-6，自下而上
  final String positionLabel; // 初/二/三/四/五/上
  final YinYang yinYang;
  final List<DiZhi> diZhiList; // 底->顶
  final bool isYuanTang;

  YuanTangYaoUIModel({
    required this.position,
    required this.positionLabel,
    required this.yinYang,
    required this.diZhiList,
    required this.isYuanTang,
  });
}

class YuanTangGuaUIModel {
  final Gua64Enum gua;
  final Enum8Gua topGua;
  final Enum8Gua bottomGua;
  final List<YuanTangYaoUIModel> yaoList; // 自下而上

  YuanTangGuaUIModel({
    required this.gua,
    required this.topGua,
    required this.bottomGua,
    required this.yaoList,
  });

  factory YuanTangGuaUIModel.fromPure(PureYuanTangGua pure) {
    final labels = const ['初', '二', '三', '四', '五', '上'];
    final list = <YuanTangYaoUIModel>[];
    for (var i = 0; i < pure.yaoList.length; i++) {
      final yao = pure.yaoList[i];
      list.add(
        YuanTangYaoUIModel(
          position: i + 1,
          positionLabel: labels[i],
          yinYang: yao.yinYang,
          diZhiList: yao.diZhiList,
          isYuanTang: yao.isYuanTang,
        ),
      );
    }
    return YuanTangGuaUIModel(
      gua: pure.gua,
      topGua: pure.topGua,
      bottomGua: pure.bottomGua,
      yaoList: list,
    );
  }
}