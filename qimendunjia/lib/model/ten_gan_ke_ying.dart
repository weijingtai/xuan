import 'package:json_annotation/json_annotation.dart';

import 'base_ten_gan_ke_ying.dart';
part 'ten_gan_ke_ying.g.dart';

@JsonSerializable()
class TenGanKeYing extends BaseTenGanKeYing {
  String? longExplain;
  List<TenGanKeYingZhu>? zhu;
  String? yiXiang;
  Map<String, List<String>>? diseaseAtGongMapper;
  List<String>? xiangList;
  String? thingOnLocation;
  List<Map<String, String>>? others;
  // TODO 取时 others 以及 位置上有什么事物

  TenGanKeYing({
    required String juName,
    required String shortExplain,
    required this.longExplain,
    required this.zhu,
    required this.yiXiang,
    required this.diseaseAtGongMapper,
    required this.xiangList,
    required this.others,
  }) : super(juName: juName, shortExplain: shortExplain);

  factory TenGanKeYing.fromJson(Map<String, dynamic> json) =>
      _$TenGanKeYingFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TenGanKeYingToJson(this);
}

@JsonSerializable()
class TenGanKeYingZhu {
  String? author;
  String content;

  TenGanKeYingZhu({
    this.author,
    required this.content,
  });

  factory TenGanKeYingZhu.fromJson(Map<String, dynamic> json) {
    return TenGanKeYingZhu(
      author: json['author'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'content': content,
    };
  }
}
