import 'package:common/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:qimendunjia/enums/enum_most_popular_ge_ju.dart';
import 'package:qimendunjia/ui_models/ui_each_gong_model.dart';

import '../enums/enum_arrange_plate_type.dart';
import '../enums/enum_eight_door.dart';
import '../enums/enum_nine_stars.dart';
import '../model/door_star_ke_ying.dart';
import '../model/each_gong.dart';
import '../model/each_gong_ge_ju.dart';
import '../model/eight_door_ke_ying.dart';
import '../model/pan_arrange_settings.dart';
import '../model/qi_yi_ru_gong.dart';
import '../model/shi_jia_ju.dart';
import '../model/shi_jia_qi_men.dart';
import '../model/ten_gan_ke_ying.dart';
import '../model/ten_gan_ke_ying_ge_ju.dart';
import '../ui_models/ui_pan_meta_model.dart';
import '../ui_models/ui_ten_gan_key_ying_ge_ju.dart';
import '../utils/read_data_utils.dart';

class ShiJiaQiMenViewModel extends ChangeNotifier {
  BuildContext context;

  // DateTime? _dateTime;
  // DateTime? get dateTime => _dateTime;
  // set dateTime(DateTime? value) {
  //   _dateTime = value;
  //   notifyListeners();
  // }
  UIPanMetaModel? _uiPanMetaModel;
  UIPanMetaModel? get uiPanMetaModel => _uiPanMetaModel;

  ShiJiaQiMen? _shiJiaQiMen;
  ShiJiaQiMen? get shiJiaQiMen => _shiJiaQiMen;
  set shiJiaQiMen(ShiJiaQiMen? value) {
    _shiJiaQiMen = value;
    notifyListeners();
  }

  Map<HouTianGua, UIEachGongModel?> _gongUIMapper = {};

  UIEachGongModel? _selectedGong;
  UIEachGongModel? get selectedGong => _selectedGong;

  UIGongExplains? _selectedGongExplain;
  UIGongExplains? get selectedGongExplain => _selectedGongExplain;
  // each gong
  UIEachGongModel? get kanGong => _gongUIMapper[HouTianGua.Kan];
  UIEachGongModel? get genGong => _gongUIMapper[HouTianGua.Gen];
  UIEachGongModel? get zhenGong => _gongUIMapper[HouTianGua.Zhen];
  UIEachGongModel? get xunGong => _gongUIMapper[HouTianGua.Xun];
  UIEachGongModel? get liGong => _gongUIMapper[HouTianGua.Li];
  UIEachGongModel? get kunGong => _gongUIMapper[HouTianGua.Kun];
  UIEachGongModel? get duiGong => _gongUIMapper[HouTianGua.Dui];
  UIEachGongModel? get qianGong => _gongUIMapper[HouTianGua.Qian];
  UIEachGongModel? get zhongGong {
    if (_shiJiaQiMen != null && _shiJiaQiMen!.plateType == PlateType.FEI_PAN) {
      return _gongUIMapper[HouTianGua.Center];
    } else {
      return null;
    }
  }

  UIEachGongModel? _generateEachGong(HouTianGua gua,
      UITenGanKeYingGeJu tenGanKeYingGeJu, List<QiYiRuGong>? qiYiRuGongList) {
    if (shiJiaQiMen != null) {
      return UIEachGongModel(
          gua: gua,
          gong: _shiJiaQiMen!.gongMapper[gua]!,
          gongWangShuai: _shiJiaQiMen!.gongWangShuaiMapper[gua]!,
          tenGanKeYingGeJu: tenGanKeYingGeJu,
          panMete: _uiPanMetaModel!,
          eachGongGeJu: EnumMostPopularGeJu.checkGeJuAtEachGong(
              _shiJiaQiMen!.timeJiaZi,
              _shiJiaQiMen!.sixJiaXunHeader,
              _shiJiaQiMen!.zhiShiDoor,
              _shiJiaQiMen!.gongMapper[gua]!),
          qiYiRuGongList: qiYiRuGongList);
    }
    return null;
  }

  // Map<HouTianGua,UITenGanKeYingGeJu> tenGanKeYingGeJuMapper = {};

  ShiJiaQiMenViewModel(this.context);

  UIEachGongModel? getGongByGua(HouTianGua gongGua) {
    return _gongUIMapper[gongGua];
  }

  Future<void> selectGong(HouTianGua? gongGua) async {
    if (_selectedGong == null && _gongUIMapper[gongGua] != null) {
      UIEachGongModel selectedGong = _gongUIMapper[gongGua]!;

      EachGong gong = selectedGong.gong;
      var fixedList = [
        loadAllTenGanKeYingForCurrentGong(_uiPanMetaModel!.xunHeaderTianGan,
            gong.tianPan, gong.diPan, gong.tianPanJiGan, gong.diPanJiGan),
        loadDoorStarKeYing(gong.door, gong.star),
        loadThreeQiRuGong(gong.gongGua, gong.tianPan),
        loadEightDoorGanKeYing(gong.door, gong.tianPan),
        loadTianPanGanRuGong(gong.gongGua, gong.tianPan),
        loadEightDoorKeYing(
            gong.door,
            EightDoorEnum.listOrderedByGongNumber
                .firstWhere((t) => t.originalGong == gong.gongGua))
      ];
      bool withTianGanJiGan = gong.tianPanJiGan != null;
      if (withTianGanJiGan) {
        fixedList.addAll([
          loadEightDoorGanKeYing(gong.door, gong.tianPanJiGan!),
          loadThreeQiRuGong(gong.gongGua, gong.tianPanJiGan!),
          loadTianPanGanRuGong(gong.gongGua, gong.tianPanJiGan!),
        ]);
      }
      EachGongGeJu eachGongGeJu = EnumMostPopularGeJu.checkGeJuAtEachGong(
          _shiJiaQiMen!.timeJiaZi,
          _shiJiaQiMen!.sixJiaXunHeader,
          _shiJiaQiMen!.zhiShiDoor,
          gong);
      Future.wait(fixedList).then((values) {
        _selectedGongExplain = UIGongExplains(
            // selectedGong: selectedGong,
            doorStarKeYing: values[1] as DoorStarKeYing?,
            qiYiRuGong: values[2] as QiYiRuGong?,
            doorGanKeYingString: values[3] as String?,
            tianPanGanRuGong: values[4] as String?,
            uiGongTenGanKeYing: values[0] as UIGongTenGanKeYing,
            eightDoorKeYingMapper: values[5] as Map<YinYang, EightDoorKeYing>,
            doorJiGanKeYingString:
                withTianGanJiGan ? values[6] as String? : null,
            jiGanThreeRuGong:
                withTianGanJiGan ? values[7] as QiYiRuGong? : null,
            tianPanJiGanRuGong: withTianGanJiGan ? values[8] as String? : null,
            eachGongGeJu: eachGongGeJu);
        notifyListeners();
      });
      _selectedGong = selectedGong;
      notifyListeners();

      //
      // DoorStarKeYing? doorStarKeYing = await loadDoorStarKeYing(gong.door, gong.star);
      // QiYiRuGong? qiYiRuGong =  await loadThreeQiRuGong(gong.gongGua, gong.tianPan);
      // String? doorGanKeYingString = await loadEightDoorGanKeYing(gong.door, gong.tianPan);
      // String? tianPanGanRuGong = await loadTianPanGanRuGong(gong.gongGua, gong.tianPan);
      //
      // Map<YinYang,EightDoorKeYing>? eightDoorKeYingMapper = await loadEightDoorKeYing(gong.door,EightDoorEnum.listOrderedByGongNumber.firstWhere((t)=>t.originalGong == gong.gongGua));
      // UIGongTenGanKeYing uiGongTenGanKeYing = await loadAllTenGanKeYingForCurrentGong(_uiPanMetaModel!.xunHeaderTianGan,gong.tianPan,gong.diPan,gong.tianPanJiGan,gong.diPanJiGan);
      //
      // QiYiRuGong? jiGanThreeRuGong;
      // String? doorJiGanKeYingString;
      // String? tianPanJiGanRuGong;
      // if (gong.tianPanJiGan!=null){
      //   doorJiGanKeYingString = await loadEightDoorGanKeYing(gong.door, gong.tianPanJiGan!);
      //   jiGanThreeRuGong = await loadThreeQiRuGong(gong.gongGua, gong.tianPanJiGan!);
      //   tianPanJiGanRuGong = await loadTianPanGanRuGong(gong.gongGua, gong.tianPanJiGan!);
      // }
      // _selectedGong = UIGongExplains(
      //   // selectedGong: selectedGong,
      //   doorStarKeYing:doorStarKeYing,
      //  qiYiRuGong:qiYiRuGong,
      //   doorGanKeYingString:doorGanKeYingString,
      //   tianPanGanRuGong:tianPanGanRuGong,
      //   uiGongTenGanKeYing:uiGongTenGanKeYing,
      //   eightDoorKeYingMapper:eightDoorKeYingMapper,
      //   jiGanThreeRuGong:jiGanThreeRuGong,
      //   doorJiGanKeYingString:doorJiGanKeYingString,
      //   tianPanJiGanRuGong:tianPanJiGanRuGong,
      // );
    } else {
      _selectedGong = null;
      _selectedGongExplain = null;
    }
    notifyListeners();
  }

  void createShiJiaQiMen(PlateType plateType, DateTime dateTime,
      ShiJiaJu shiJiaJu, PanArrangeSettings settings) {
    // _dateTime = dateTime;
    List<String> eightCharList = shiJiaJu.fourZhuEightChar.split(" ").toList();
    var shiJiaQiMen = ShiJiaQiMen(
      plateType: plateType,
      shiJiaJu: shiJiaJu,
      settings: settings,
    );
    _uiPanMetaModel = UIPanMetaModel(
      yinYangDun: shiJiaJu.yinYangDun,
      zhiShiDoor: shiJiaQiMen.zhiShiDoor,
      zhiFuStar: shiJiaQiMen.zhiFuStar,
      xunHeaderTianGan: shiJiaQiMen.xunHeaderTianGan,
      timeXunKong: shiJiaQiMen.timeXunKong,
      horseLocation: shiJiaQiMen.horseLocation,
      monthToken: shiJiaQiMen.monthToken,
    );
    _shiJiaQiMen = shiJiaQiMen;
    // 三奇入宫的三奇 与 宫Mapper
    Map<TianGan, HouTianGua> sanQiRuGongMapper = {};
    for (var g in shiJiaQiMen.gongMapper.values) {
      if (g.tianPan.isThreeQi) {
        sanQiRuGongMapper[g.tianPan] = g.gongGua;
      }
      if (g.tianPanJiGan != null && g.tianPanJiGan!.isThreeQi) {
        sanQiRuGongMapper[g.tianPanJiGan!] = g.gongGua;
      }
    }

    Future.wait([
      loadTenGanKeYingGeJu(
          plateType, shiJiaQiMen.xunHeaderTianGan, shiJiaQiMen.gongMapper),
      listThreeQiRuGong(sanQiRuGongMapper)
    ]).then((resList) {
      print("Logic: ten gan ke ying loadded ${resList.first.length}");
      for (var gua in HouTianGua.values) {
        if (gua == HouTianGua.Center && plateType == PlateType.ZHUAN_PAN) {
        } else {
          _gongUIMapper[gua] = _generateEachGong(
            gua,
            resList.first[gua] as UITenGanKeYingGeJu,
            resList[1][gua] == null
                ? null
                : (resList[1][gua] as List<QiYiRuGong>),
          );
        }
      }
      notifyListeners();
    });
    // notifyListeners();
  }

  void reset() {
    _shiJiaQiMen = null;
    _uiPanMetaModel = null;
    // tenGanKeYingGeJuMapper = {};
    _gongUIMapper = {};
    notifyListeners();
  }

  Future<DoorStarKeYing?> loadDoorStarKeYing(
      EightDoorEnum door, NineStarsEnum star) async {
    Map<EightDoorEnum, Map<NineStarsEnum, DoorStarKeYing>> loadResult =
        await ReadDataUtils.readDoorStarKeYing();
    return loadResult[door]?[star];
  }

  Future<String?> loadEightDoorGanKeYing(
      EightDoorEnum door, TianGan tianPanGan) async {
    Map<EightDoorEnum, Map<TianGan, String>> loadResult =
        await ReadDataUtils.readDoorGanKeYing();
    return loadResult[door]?[tianPanGan];
  }

  // tuple1 天盘干、地盘干 十干克应
  // tuple2 天盘寄干、地盘干 十干克应
  // tuple3 天盘干、地盘寄干 十干克应
  // tuple4 天盘寄干、地盘寄干 十干克应
  Future<UIGongTenGanKeYing> loadAllTenGanKeYingForCurrentGong(
    TianGan xunShouGan,
    TianGan tianPanGan,
    TianGan diPanGan,
    TianGan? tianPanJiGan,
    TianGan? diPanJiGan,
  ) async {
    print("loadAllTenGanKeYingForCurrentGong");
    Map<TianGan, Map<TianGan, TenGanKeYing>> loadResult =
        await ReadDataUtils.readTenGanKeYing();
    TenGanKeYing tianDiPanKeYing = loadResult[tianPanGan]![diPanGan]!;
    TenGanKeYing? tianPanJiaDiPanKey;
    if (xunShouGan == tianPanGan) {
      tianPanJiaDiPanKey = loadResult[TianGan.JIA]![diPanGan]!;
    }
    TenGanKeYing? tianPanJiDiPanKeYing;
    TenGanKeYing? tianPanJiJiaDiPanKeYing;
    if (tianPanJiGan != null) {
      tianPanJiDiPanKeYing = loadResult[tianPanJiGan]![diPanGan]!;
      if (xunShouGan == tianPanJiGan) {
        tianPanJiJiaDiPanKeYing = loadResult[TianGan.JIA]![diPanGan]!;
      }
    }

    TenGanKeYing? tianPanDiPanJiGanKeYing;
    TenGanKeYing? tianPanDiPanJiJiaKeYing;
    if (diPanJiGan != null) {
      tianPanDiPanJiGanKeYing = loadResult[tianPanGan]![diPanJiGan]!;
      if (xunShouGan == diPanJiGan) {
        tianPanDiPanJiJiaKeYing = loadResult[TianGan.JIA]![diPanJiGan]!;
      }
    }

    TenGanKeYing? tianPanJiDiPanJiGanKeYing;
    TenGanKeYing? tianPanJiaDiPanJiaGanKeYing;
    if (tianPanJiGan != null && diPanJiGan != null) {
      tianPanJiDiPanJiGanKeYing = loadResult[tianPanJiGan]![diPanJiGan]!;
      if (xunShouGan == tianPanJiGan) {
        tianPanJiaDiPanJiaGanKeYing = loadResult[TianGan.JIA]![TianGan.JIA]!;
      }
    }
    return UIGongTenGanKeYing(
      tianDiPanKeYing: tianDiPanKeYing,
      tianPanJiaDiPanKey: tianPanJiaDiPanKey,
      tianPanJiDiPanKeYing: tianPanJiDiPanKeYing,
      tianPanJiJiaDiPanKeYing: tianPanJiJiaDiPanKeYing,
      tianPanDiPanJiGanKeYing: tianPanDiPanJiGanKeYing,
      tianPanDiPanJiJiaKeYing: tianPanDiPanJiJiaKeYing,
      tianPanJiDiPanJiGanKeYing: tianPanJiDiPanJiGanKeYing,
      tianPanJiaDiPanJiaGanKeYing: tianPanJiaDiPanJiaGanKeYing,
    );
  }

  Future<TenGanKeYing?> loadTenGanKeyYing(
      TianGan tianPanGan, TianGan diPanGan) async {
    print("loadTenGanKeyYing");
    Map<TianGan, Map<TianGan, TenGanKeYing>> loadResult =
        await ReadDataUtils.readTenGanKeYing();
    // if (tianPanGan == TianGan.JIA && diPanGan == TianGan.BING){
    //   print(loadResult[tianPanGan]?[TianGan.BING]);
    // }
    return loadResult[tianPanGan]?[diPanGan];
  }

  Future<Map<YinYang, EightDoorKeYing>?> loadEightDoorKeYing(
      EightDoorEnum door, EightDoorEnum fixDoor) async {
    /// YinYang  阳为动应，阴为静应

    try {
      Map<EightDoorEnum, Map<EightDoorEnum, Map<YinYang, EightDoorKeYing>>>
          loadResult = await ReadDataUtils.readEightDoorKeYing();
      return loadResult[door]?[fixDoor];
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// 当前只有 三奇入宫
  Future<QiYiRuGong?> loadThreeQiRuGong(
      HouTianGua gongGua, TianGan tianPanGan) async {
    if (tianPanGan.isThreeQi) {
      Map<HouTianGua, Map<TianGan, QiYiRuGong>> qiYiRuGongMapper =
          await ReadDataUtils.readQiYiRuGong();
      return qiYiRuGongMapper[gongGua]![tianPanGan]!;
    }
    return null;
  }

  Future<Map<HouTianGua, List<QiYiRuGong>>> listThreeQiRuGong(
      Map<TianGan, HouTianGua> mapper) async {
    Map<HouTianGua, Map<TianGan, QiYiRuGong>> qiYiRuGongMapper =
        await ReadDataUtils.readQiYiRuGong();
    Map<HouTianGua, List<QiYiRuGong>> res = {};
    for (var mapperEntry in mapper.entries) {
      if (!res.containsKey(mapperEntry.value)) {
        res[mapperEntry.value] = [
          qiYiRuGongMapper[mapperEntry.value]![mapperEntry.key]!
        ];
      } else {
        res[mapperEntry.value]!
            .add(qiYiRuGongMapper[mapperEntry.value]![mapperEntry.key]!);
      }
    }

    return res;
  }

  Future<String?> loadTianPanGanRuGong(
      HouTianGua gongGua, TianGan tianPanGan) async {
    Map<HouTianGua, Map<TianGan, String>> qiYiRuGongMapper =
        await ReadDataUtils.readQiYiRuGongDisease();
    return qiYiRuGongMapper[gongGua]?[tianPanGan];
  }

  Future<Map<HouTianGua, UITenGanKeYingGeJu>> loadTenGanKeYingGeJu(
      PlateType plateType,
      TianGan xunShouGan,
      Map<HouTianGua, EachGong> gong) async {
    Map<TianGan, Map<TianGan, TenGanKeYingGeJu>> loadResult =
        await ReadDataUtils.readTenGanKeYingGeJu();
    Map<HouTianGua, UITenGanKeYingGeJu> result = {};
    for (var entry in gong.entries) {
      if (plateType == PlateType.ZHUAN_PAN && entry.key == HouTianGua.Center) {
        continue;
      }
      TenGanKeYingGeJu tianGeJu =
          loadResult[entry.value.tianPan]![entry.value.diPan]!;
      TenGanKeYingGeJu? tianDunJiaGeJu;
      if (entry.value.tianPan == xunShouGan) {
        tianDunJiaGeJu = loadResult[TianGan.JIA]![entry.value.diPan]!;
      }
      TenGanKeYingGeJu? diDunJiaGeJu;
      if (entry.value.diPan == xunShouGan) {
        diDunJiaGeJu = loadResult[entry.value.tianPan]![TianGan.JIA]!;
      }
      TenGanKeYingGeJu? diPanJiGeJu;
      TenGanKeYingGeJu? diPanJiJiaGeJu;
      TenGanKeYingGeJu? tianDunJiaDiPanJi;
      if (entry.value.diPanJiGan != null) {
        diPanJiGeJu = loadResult[entry.value.tianPan]![entry.value.diPanJiGan]!;
        if (entry.value.diPanJiGan == xunShouGan) {
          diPanJiJiaGeJu = loadResult[entry.value.tianPan]![TianGan.JIA]!;
        }
        if (entry.value.tianPan == xunShouGan) {
          tianDunJiaDiPanJi = loadResult[TianGan.JIA]![entry.value.diPanJiGan]!;
        }
      }
      TenGanKeYingGeJu? tianPanJiGeJu;
      TenGanKeYingGeJu? tianPanJiJiaGeJu;
      TenGanKeYingGeJu? tianPanJiGanDiPanJia;
      if (entry.value.tianPanJiGan != null) {
        tianPanJiGeJu =
            loadResult[entry.value.tianPanJiGan]![entry.value.diPan]!;
        if (entry.value.tianPanJiGan == xunShouGan) {
          tianPanJiJiaGeJu = loadResult[TianGan.JIA]![entry.value.diPan]!;
        }
        if (entry.value.diPan == xunShouGan) {
          tianPanJiGanDiPanJia =
              loadResult[entry.value.tianPanJiGan]![TianGan.JIA]!;
        }
      }
      TenGanKeYingGeJu? tianDiPanJia; // 天地盘相同，且同为“遁干”
      if (entry.value.tianPan == entry.value.diPan &&
          entry.value.tianPan == xunShouGan) {
        tianDiPanJia = loadResult[TianGan.JIA]![TianGan.JIA]!;
      }
      TenGanKeYingGeJu? tianDiJiGan;
      TenGanKeYingGeJu? tianDiJiaGanJiaGeJu;
      // print("${entry.value.tianPanJiGan != null}=====${entry.value.tianPanJiGan == entry.value.diPanJiGan}");
      if (entry.value.tianPanJiGan != null &&
          entry.value.tianPanJiGan == entry.value.diPanJiGan) {
        tianDiJiGan =
            loadResult[entry.value.tianPanJiGan]![entry.value.diPanJiGan]!;
        if (entry.value.tianPanJiGan == xunShouGan) {
          tianDiJiaGanJiaGeJu = loadResult[TianGan.JIA]![TianGan.JIA]!;
        }
      }

      result[entry.key] = UITenGanKeYingGeJu(
          gongGua: entry.key,
          tianGan: entry.value.tianPan,
          tianGeJu: tianGeJu,
          diGan: entry.value.diPan,
          isTianGanDunJia: entry.value.tianPan == xunShouGan,
          isDiGanDunJia: entry.value.diPan == xunShouGan,
          tianDunJiaGeJu: tianDunJiaGeJu,
          diDunJiaGeJu: diDunJiaGeJu,
          tianPanJiGan: entry.value.tianPanJiGan,
          tianPanJiGanGeJu: tianPanJiGeJu,
          diPanJiGan: entry.value.diPanJiGan,
          diPanJiGanGeJu: diPanJiGeJu,
          isTianJiGanJia: entry.value.tianPanJiGan == xunShouGan,
          isDiJiGanJia: entry.value.diPanJiGan == xunShouGan,
          tianJiGanJiaGeJu: tianPanJiJiaGeJu,
          diJiGanJiaGeJu: diPanJiJiaGeJu,
          tianDiJiGanGeJu: tianDiJiGan,
          tianDiPanGanGeJu: tianDiPanJia,
          tianDiJiaGanJiaGeJu: tianDiJiaGanJiaGeJu,
          tianPanJiGanDiPanJia: tianPanJiGanDiPanJia,
          tianDunJiaDiPanJi: tianDunJiaDiPanJi);
    }

    return result;
  }
}

class UIGongTenGanKeYing {
  TenGanKeYing tianDiPanKeYing;
  TenGanKeYing? tianPanJiaDiPanKey;
  TenGanKeYing? tianPanJiDiPanKeYing;
  TenGanKeYing? tianPanJiJiaDiPanKeYing;
  TenGanKeYing? tianPanDiPanJiGanKeYing;
  TenGanKeYing? tianPanDiPanJiJiaKeYing;
  TenGanKeYing? tianPanJiDiPanJiGanKeYing;
  TenGanKeYing? tianPanJiaDiPanJiaGanKeYing;
  UIGongTenGanKeYing({
    required this.tianDiPanKeYing,
    required this.tianPanJiaDiPanKey,
    required this.tianPanJiDiPanKeYing,
    required this.tianPanJiJiaDiPanKeYing,
    required this.tianPanDiPanJiGanKeYing,
    required this.tianPanDiPanJiJiaKeYing,
    required this.tianPanJiDiPanJiGanKeYing,
    required this.tianPanJiaDiPanJiaGanKeYing,
  });
}

class UIGongExplains {
  // UIEachGongModel selectedGong;
  DoorStarKeYing? doorStarKeYing;
  QiYiRuGong? qiYiRuGong;
  String? doorGanKeYingString;
  String? tianPanGanRuGong;
  UIGongTenGanKeYing uiGongTenGanKeYing;
  Map<YinYang, EightDoorKeYing>? eightDoorKeYingMapper;
  QiYiRuGong? jiGanThreeRuGong;
  String? doorJiGanKeYingString;
  String? tianPanJiGanRuGong;
  EachGongGeJu eachGongGeJu;
  UIGongExplains({
    // required this.selectedGong,
    required this.doorStarKeYing,
    required this.qiYiRuGong,
    required this.doorGanKeYingString,
    required this.tianPanGanRuGong,
    required this.uiGongTenGanKeYing,
    required this.eightDoorKeYingMapper,
    required this.jiGanThreeRuGong,
    required this.doorJiGanKeYingString,
    required this.tianPanJiGanRuGong,
    required this.eachGongGeJu,
  });
}
