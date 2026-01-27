import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

// Changed filename to avoid potential conflicts if the old one is not deleted immediately
// and to signify it's a data model.
part 'yu_ding_da_liu_ren_data_model.g.dart';

@JsonSerializable()
class YuDingDaLiuRenDataModel { // Renamed class to *DataModel
  final Map<String, String> details;
  final Map<String, String> books;

  @JsonKey(toJson: _jiaZiToJson, fromJson: _jiaZiFromJson)
  final JiaZi dayJiaZi;

  final int juNumber;

  @JsonKey(toJson: _diZhiToJson, fromJson: _diZhiFromJson)
  final DiZhi juName; // This is 干上神 (DiZhi on DayGan)

  final Set<String> body;
  final String meaning;
  final String explain;
  final String predication;

  YuDingDaLiuRenDataModel({ // Renamed constructor
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

  factory YuDingDaLiuRenDataModel.fromJson(Map<String, dynamic> json) =>
      _$YuDingDaLiuRenDataModelFromJson(json); // Adjusted factory name
  Map<String, dynamic> toJson() => _$YuDingDaLiuRenDataModelToJson(this); // Adjusted method name

  // Custom converters for Enums if not handled globally by json_serializable config
  // Or if enums are from a package that doesn't have built-in support in a specific way.
  // common/enums.dart likely uses @JsonValue for its enums, so these might not be strictly necessary
  // if json_serializable is configured to handle enums with @JsonValue correctly.
  // However, explicitly adding them here for clarity for this model.
  static String _jiaZiToJson(JiaZi jiaZi) => jiaZi.name;
  static JiaZi _jiaZiFromJson(String name) => JiaZi.values.firstWhere((e) => e.name == name);

  static String _diZhiToJson(DiZhi diZhi) => diZhi.name;
  static DiZhi _diZhiFromJson(String name) => DiZhi.values.firstWhere((e) => e.name == name);
}
