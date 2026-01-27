import 'package:common/enums.dart';
import 'package:daliuren/domain/enums/gui_ren.dart'; // Updated import
// import 'package:daliuren/model/zei_key_type.dart'; // This enum also needs to be moved or handled
// For now, let's assume ZeiKeType will be a domain enum or a simple string if not complex
import 'package:json_annotation/json_annotation.dart';

part 'each_class_data_model.g.dart';

// Forward declaration for ZeiKeType if its definition is moved to domain layer
// For now, json_serializable might handle it as dynamic or String if not typed.
// Or we can define a placeholder here if needed for generation, then align.
// For simplicity, let's assume it's not part of the direct JSON model for now,
// and would be calculated in the domain layer.
// If `zei_key_type.dart` defines `EachClassZeiKeType`, it also needs to be moved.
// Given its name, it seems specific to "EachClass" logic.

@JsonSerializable()
class EachClassDataModel {
  final int order;

  @JsonKey(toJson: _diZhiToJson, fromJson: _diZhiFromJson)
  final DiZhi sky;

  @JsonKey(toJson: _diZhiToJson, fromJson: _diZhiFromJson)
  final DiZhi ground;

  final bool isFirstClass; // Indicates if this is the first class (日课)

  // GuiRen enum from domain/enums now has @JsonValue
  final GuiRen guiRen;

  final int? sheHaiTimes; // Retaining as it seems to be part of JSON structure

  // Assuming this is part of the serialized structure from JSON
  final List<int>? otherSameSkyGroundIndexList;

  // zeiKeType will be determined in the domain layer, not part of this DTO from JSON directly.
  // final EachClassZeiKeType? zeiKeType;

  final bool? isSkyKeDayGan;
  final bool isSkySameYinYangWithDayGan;

  // TianGan for the first class (日干) is usually handled by a separate field in FourClass model
  // or by having a specific FirstClassDataModel.
  // If DaLiuRenPanModel's FourClass structure has a dedicated tianGan field for the first class,
  // this model might not need it.
  // For now, keeping it simple.

  EachClassDataModel({
    required this.order,
    required this.sky,
    required this.ground,
    required this.guiRen,
    this.isSkyKeDayGan, // Defaulted to false in original, pass as nullable
    this.isSkySameYinYangWithDayGan = false, // Default provided
    this.isFirstClass = false, // Default provided
    this.sheHaiTimes,
    this.otherSameSkyGroundIndexList,
  });

  factory EachClassDataModel.fromJson(Map<String, dynamic> json) =>
      _$EachClassDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$EachClassDataModelToJson(this);

  static String _diZhiToJson(DiZhi diZhi) => diZhi.name;
  static DiZhi _diZhiFromJson(String name) => DiZhi.values.firstWhere((e) => e.name == name);
}

// Note: The enum `EachClassZeiKeType` from `zei_key_type.dart` needs to be addressed.
// If it's a simple enum and part of the domain logic, it should be moved to `lib/domain/enums/`.
// If its calculation is complex, that logic moves to a use case or domain entity.
// The `tenGanJiGongMapper` has been removed from this DTO. It's a utility/constant.
