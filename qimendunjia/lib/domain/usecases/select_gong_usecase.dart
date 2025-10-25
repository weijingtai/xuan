import 'package:common/enums.dart';
import 'package:qimendunjia/model/door_star_ke_ying.dart';
import 'package:qimendunjia/model/eight_door_ke_ying.dart';
import 'package:qimendunjia/model/qi_yi_ru_gong.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying.dart';
import 'package:qimendunjia/model/ten_gan_ke_ying_ge_ju.dart';
import '../entities/each_gong.dart';
import '../entities/qimen_pan.dart';
import '../repositories/qimen_data_repository.dart';
import 'base_usecase.dart';

/// 选择宫位用例参数
class SelectGongParams {
  final QiMenPan pan;
  final HouTianGua gongGua;

  const SelectGongParams({
    required this.pan,
    required this.gongGua,
  });
}

/// 宫位详细信息
///
/// 包含选中宫位的完整克应和格局信息
class GongDetailInfo {
  /// 宫位基础信息
  final EachGong gong;

  /// 十干克应数据
  final TenGanKeYingData? tenGanKeYing;

  /// 门星克应
  final DoorStarKeYing? doorStarKeYing;

  /// 三奇入宫
  final QiYiRuGong? qiYiRuGong;

  /// 八门克应（阴阳两种情况）
  final Map<YinYang, EightDoorKeYing>? doorKeYing;

  /// 八门干克应
  final String? doorGanKeYing;

  /// 天干入宫疾病
  final String? tianGanRuGongDisease;

  const GongDetailInfo({
    required this.gong,
    this.tenGanKeYing,
    this.doorStarKeYing,
    this.qiYiRuGong,
    this.doorKeYing,
    this.doorGanKeYing,
    this.tianGanRuGongDisease,
  });
}

/// 十干克应数据
class TenGanKeYingData {
  /// 天盘-地盘克应
  final TenGanKeYing tianDiKeYing;

  /// 天盘-地盘格局
  final TenGanKeYingGeJu tianDiGeJu;

  /// 天盘-暗干克应
  final TenGanKeYing? tianAnKeYing;

  /// 天盘-暗干格局
  final TenGanKeYingGeJu? tianAnGeJu;

  const TenGanKeYingData({
    required this.tianDiKeYing,
    required this.tianDiGeJu,
    this.tianAnKeYing,
    this.tianAnGeJu,
  });
}

/// 选择宫位用例
///
/// 负责加载宫位的详细克应和格局信息
///
/// 使用示例:
/// ```dart
/// final params = SelectGongParams(
///   pan: currentPan,
///   gongGua: HouTianGua.Kan,
/// );
/// final info = await selectGongUseCase.execute(params);
/// ```
class SelectGongUseCase extends UseCase<GongDetailInfo, SelectGongParams> {
  final QiMenDataRepository _dataRepository;

  SelectGongUseCase(this._dataRepository);

  @override
  Future<GongDetailInfo> execute(SelectGongParams params) async {
    final gong = params.pan.getGong(params.gongGua);
    if (gong == null) {
      throw QiMenDataNotFoundException('未找到${params.gongGua.name}宫数据');
    }

    try {
      // 并行加载所有数据
      final results = await Future.wait([
        _loadTenGanKeYing(gong),
        _loadDoorStarKeYing(gong),
        _loadQiYiRuGong(gong),
        _loadEightDoorKeYing(params.pan, gong),
        _loadDoorGanKeYing(gong),
        _loadTianGanRuGongDisease(gong),
      ]);

      return GongDetailInfo(
        gong: gong,
        tenGanKeYing: results[0] as TenGanKeYingData?,
        doorStarKeYing: results[1] as DoorStarKeYing?,
        qiYiRuGong: results[2] as QiYiRuGong?,
        doorKeYing: results[3] as Map<YinYang, EightDoorKeYing>?,
        doorGanKeYing: results[4] as String?,
        tianGanRuGongDisease: results[5] as String?,
      );
    } catch (e) {
      throw QiMenDataNotFoundException('加载宫位信息失败: $e');
    }
  }

  /// 加载十干克应
  Future<TenGanKeYingData?> _loadTenGanKeYing(EachGong gong) async {
    try {
      // 天盘-地盘克应
      final tianDiKeYing = await _dataRepository.getTenGanKeYing(
        tianPan: gong.tianPan,
        diPan: gong.diPan,
      );

      final tianDiGeJu = await _dataRepository.getTenGanKeYingGeJu(
        tianPan: gong.tianPan,
        diPan: gong.diPan,
      );

      // 天盘-暗干克应（如果有暗干且不同于天盘）
      TenGanKeYing? tianAnKeYing;
      TenGanKeYingGeJu? tianAnGeJu;

      if (gong.tianPanAnGan != gong.tianPan) {
        tianAnKeYing = await _dataRepository.getTenGanKeYing(
          tianPan: gong.tianPan,
          diPan: gong.tianPanAnGan,
        );
        tianAnGeJu = await _dataRepository.getTenGanKeYingGeJu(
          tianPan: gong.tianPan,
          diPan: gong.tianPanAnGan,
        );
      }

      return TenGanKeYingData(
        tianDiKeYing: tianDiKeYing,
        tianDiGeJu: tianDiGeJu,
        tianAnKeYing: tianAnKeYing,
        tianAnGeJu: tianAnGeJu,
      );
    } catch (e) {
      return null;
    }
  }

  /// 加载门星克应
  Future<DoorStarKeYing?> _loadDoorStarKeYing(EachGong gong) async {
    try {
      return await _dataRepository.getDoorStarKeYing(
        door: gong.door,
        star: gong.star,
      );
    } catch (e) {
      return null;
    }
  }

  /// 加载三奇入宫
  Future<QiYiRuGong?> _loadQiYiRuGong(EachGong gong) async {
    try {
      return await _dataRepository.getQiYiRuGong(
        gong: gong.gongGua,
        gan: gong.tianPan,
      );
    } catch (e) {
      return null;
    }
  }

  /// 加载八门克应
  Future<Map<YinYang, EightDoorKeYing>?> _loadEightDoorKeYing(
    QiMenPan pan,
    EachGong gong,
  ) async {
    try {
      return await _dataRepository.getEightDoorKeYing(
        door: gong.door,
        fixDoor: pan.zhiShiDoor,
      );
    } catch (e) {
      return null;
    }
  }

  /// 加载八门干克应
  Future<String?> _loadDoorGanKeYing(EachGong gong) async {
    try {
      return await _dataRepository.getEightDoorGanKeYing(
        door: gong.door,
        gan: gong.tianPan,
      );
    } catch (e) {
      return null;
    }
  }

  /// 加载天干入宫疾病
  Future<String?> _loadTianGanRuGongDisease(EachGong gong) async {
    try {
      return await _dataRepository.getTianGanRuGongDisease(
        gong: gong.gongGua,
        gan: gong.tianPan,
      );
    } catch (e) {
      return null;
    }
  }
}
