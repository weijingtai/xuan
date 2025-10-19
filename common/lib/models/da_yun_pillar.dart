import 'package:common/enums/enum_jia_zi.dart';
import 'package:equatable/equatable.dart';

class DaYunPillar extends Equatable {
  final int startAge;
  final int endAge;
  final JiaZi pillar;
  final int totalAge;

  const DaYunPillar({
    required this.startAge,
    required this.endAge,
    required this.pillar,
    required this.totalAge,
  });

  @override
  List<Object?> get props => [startAge, endAge, pillar, totalAge];
}
