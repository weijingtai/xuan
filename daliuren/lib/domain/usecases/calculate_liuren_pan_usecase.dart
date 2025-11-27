// lib/domain/usecases/calculate_liuren_pan_usecase.dart

import 'package:common/models/divination_datetime.dart';
import 'package:common/module.dart';
import 'package:common/shared/enums/enum_di_zhi.dart';
import 'package:common/shared/enums/enum_yin_yang.dart';
import 'package:daliuren/domain/services/calculate_raw_pan_service.dart';
import 'package:daliuren/model/pan_config.dart';
import 'package:fpdart/fpdart.dart' hide Failure;
import 'package:daliuren/core/errors/failures.dart';
import 'package:daliuren/core/usecase/usecase.dart'; // Base UseCase interface
import 'package:daliuren/domain/entities/liu_ren_pan_model.dart'; // Return type
import 'package:daliuren/domain/repositories/liuren_repository.dart';

/// Use case for calculating or retrieving a Liu Ren Pan.
/// It orchestrates the interaction with the [LiuRenRepository] to get the divination盘.
class CalculateLiuRenPanUseCase
    implements UseCase<LiuRenPanModel, DivinationInfoModel> {
  final LiuRenRepository _repository;
  final CalculateRawPanService _rawPanService = CalculateRawPanService();

  CalculateLiuRenPanUseCase(this._repository);

  @override
  Future<Either<Failure, LiuRenPanModel>> call(
      DaLiuRenPanConfig config, DivinationInfoModel params) async {
    try {
      final DivinationDatetimeModel divinationDatetimeModel =
          params.divinationDatetime.timingInfoListJson!.firstWhere(
              (t) => t.uuid == params.divinationDatetime.timingInfoUuid);

      // 使用 CalculateRawPanService 进行完整的六壬盘计算
      final LiuRenPanModel liurenPan =
          _rawPanService.calculate(config, divinationDatetimeModel);

      return Right(liurenPan);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
