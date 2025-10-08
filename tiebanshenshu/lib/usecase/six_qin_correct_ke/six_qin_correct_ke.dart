import 'package:common/enums.dart';
import 'package:tiebanshenshu/domain/models/base_number_model.dart';
import 'package:tiebanshenshu/domain/models/base_number_model_result.dart';
import 'package:tiebanshenshu/repository/datamodels/tiao_wen_datamodel.dart';

class SixQinCorrectKeParams {
  final Enum8Gua topGua;
  final Enum8Gua bottomGua;
  final int originalGuaNum;
  final int totalGuaNum;
  final int ke;

  SixQinCorrectKeParams({
    required this.topGua,
    required this.bottomGua,
    required this.originalGuaNum,
    required this.totalGuaNum,
    required this.ke,
  });
}

class SixQinCorrectKeResult extends BaseNumberModelResult {
  final List<TiaoWenDataModel> tiaoWen;

  SixQinCorrectKeResult({
    required super.algorithmName,
    required super.algorithmDescription,
    required super.calculationParams,
    required super.baseNumbers,
    required super.calculationTime,
    required super.sourceData,
    required this.tiaoWen,
    super.errorMessage,
  });

  factory SixQinCorrectKeResult.success({
    required String algorithmName,
    required String algorithmDescription,
    required String calculationParams,
    required List<BaseNumberModel> baseNumbers,
    required List<TiaoWenDataModel> tiaoWen,
    required Map<String, dynamic> sourceData,
  }) {
    return SixQinCorrectKeResult(
      algorithmName: algorithmName,
      algorithmDescription: algorithmDescription,
      calculationParams: calculationParams,
      baseNumbers: baseNumbers,
      calculationTime: DateTime.now(),
      sourceData: sourceData,
      tiaoWen: tiaoWen,
    );
  }
}
