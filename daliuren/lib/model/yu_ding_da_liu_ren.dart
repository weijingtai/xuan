import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
part 'yu_ding_da_liu_ren.g.dart';

@JsonSerializable()
class YuDingDaLiuRen {
  final Map<String, String> details;
  final Map<String, String> books;
  final JiaZi dayJiaZi;
  final int juNumber;
  final DiZhi juName;
  final Set<String> body;
  final String meaning;
  final String explain;
  final String predication;

  YuDingDaLiuRen({
    required this.details,
    required this.books,
    required this.dayJiaZi,
    required this.juNumber,
    required this.juName,
    required this.body,
    required this.meaning,
    required this.explain,
    required this.predication,
  });
  factory YuDingDaLiuRen.fromJson(Map<String, dynamic> json) =>
      _$YuDingDaLiuRenFromJson(json);
  Map<String, dynamic> toJson() => _$YuDingDaLiuRenToJson(this);
}
