import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'star_inn_and_degree.g.dart';

@JsonSerializable()
class StarInnAndDegree {
  final TwentyEightStarInn starInn;
  final double degree;
  const StarInnAndDegree({required this.starInn, required this.degree});

  factory StarInnAndDegree.fromJson(Map<String, dynamic> json) =>
      _$StarInnAndDegreeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StarInnAndDegreeToJson(this);
}
