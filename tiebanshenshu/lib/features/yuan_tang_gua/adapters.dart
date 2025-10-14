import 'package:tiebanshenshu/domain/pure_yuan_tang_gua.dart';
import 'package:common/enums.dart';
import 'models.dart';

extension PureYuanTangGuaUIAdapter on PureYuanTangGua {
  YuanTangGuaUIModel toUIModel() => YuanTangGuaUIModel.fromPure(this);

  /// 简便标签展示
  String get guaTitle => '${gua.name}（${topGua.nickname}-${bottomGua.nickname}）';
}