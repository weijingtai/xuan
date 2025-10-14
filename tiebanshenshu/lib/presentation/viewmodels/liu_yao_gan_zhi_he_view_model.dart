import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import '../../domain/models/base_number_tiao_wen_list_model.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/models/liu_yao_gan_zhi_he_base_number_model.dart';
import '../../usecases/liu_yao_gan_zhi_he_tiao_wen_list_use_case.dart';
import 'base_tiao_wen_list_view_model.dart';

/// 先后天卦六爻干支和数法条文列表ViewModel
///
/// 负责管理先后天卦六爻干支和数法条文列表的UI状态和业务逻辑调用
/// 继承自BaseTiaoWenListViewModel，提供统一的状态管理
class LiuYaoGanZhiHeViewModel extends BaseTiaoWenListViewModel {
  final LiuYaoGanZhiHeTiaoWenListUseCase _useCase;

  /// 当前选择的八字
  EightChars? _currentEightChars;

  /// 当前选择的性别
  Gender? _currentGender;

  /// 当前选择的三元
  YuanYunOrder? _currentThreeYuan;

  /// 当前选择的出生节气后
  TwentyFourJieQi? _currentBirthAfterZhi;

  /// Domain层结果（包含LiuYaoGanZhiHeBaseNumberModel）
  MultiBaseNumberResult? _domainResult;

  LiuYaoGanZhiHeViewModel(this._useCase);

  @override
  String get name => '先后天卦六爻干支和数法ViewModel';

  @override
  String get description => '基于先后天卦六爻干支和数法计算条文列表的ViewModel';

  /// 当前选择的四柱（返回 EightChars）
  EightChars? get currentFourZhu => _currentEightChars;

  /// 当前选择的性别
  Gender? get currentGender => _currentGender;

  /// 当前选择的三元
  YuanYunOrder? get currentThreeYuan => _currentThreeYuan;

  /// 当前选择的出生节气后
  TwentyFourJieQi? get currentBirthAfterZhi => _currentBirthAfterZhi;

  /// 设置先后天卦六爻干支和数法参数并计算条文列表
  ///
  /// [eightChars] 八字信息
  /// [gender] 性别（"男" / "女"）
  /// [threeYuan] 三元（"上" / "中" / "下"）
  /// [birthAfterZhi] 出生节气后（"夏至" / "冬至"）
  Future<void> setParams({
    required EightChars eightChars,
    required Gender gender,
    required YuanYunOrder threeYuan,
    required TwentyFourJieQi birthAfterZhi,
  }) async {
    _currentEightChars = eightChars;
    _currentGender = gender;
    _currentThreeYuan = threeYuan;
    _currentBirthAfterZhi = birthAfterZhi;
    await calculateTiaoWenList();
  }

  /// 计算条文列表
  ///
  /// 使用当前选择的参数计算条文列表
  Future<void> calculateTiaoWenList() async {
    if (_currentEightChars == null ||
        _currentGender == null ||
        _currentThreeYuan == null ||
        _currentBirthAfterZhi == null) {
      return;
    }

    await safeExecute(() async {
      final params = LiuYaoGanZhiHeUseCaseParams(
        eightChars: _currentEightChars!,
        gender: _currentGender!,
        threeYuan: _currentThreeYuan!,
        birthAfterZhi: _currentBirthAfterZhi!,
      );
      final domainResult = await _useCase.execute(params);
      // 保存domain结果以便访问LiuYaoGanZhiHeBaseNumberModel
      _domainResult = domainResult;
      return domainResult;
    });
  }

  @override
  Future<void> refresh() async {
    await calculateTiaoWenList();
  }

  /// 清除选择
  void clearSelection() {
    _currentEightChars = null;
    _currentGender = null;
    _currentThreeYuan = null;
    _currentBirthAfterZhi = null;
    _domainResult = null;
    reset();
  }

  /// 是否已选择参数
  bool get hasSelection =>
      _currentEightChars != null &&
      _currentGender != null &&
      _currentThreeYuan != null &&
      _currentBirthAfterZhi != null;

  /// 获取LiuYaoGanZhiHeBaseNumberModel（完整的中间结果）
  LiuYaoGanZhiHeBaseNumberModel? get liuYaoGanZhiHeModel {
    if (!hasResult || _domainResult == null) return null;

    // 从sourceData中获取LiuYaoGanZhiHeBaseNumberModel
    final sourceData = _domainResult!.sourceData;
    if (sourceData.containsKey('liuYaoGanZhiHeBaseNumberModel')) {
      return sourceData['liuYaoGanZhiHeBaseNumberModel']
          as LiuYaoGanZhiHeBaseNumberModel?;
    }

    return null;
  }

  /// 是否有LiuYaoGanZhiHeModel
  bool get hasLiuYaoGanZhiHeModel => liuYaoGanZhiHeModel != null;

  /// 获取BaseNumberTiaoWenListModel列表（包含先天卦和后天卦条文）
  List<BaseNumberTiaoWenListModel> get baseNumberTiaoWenList {
    if (!hasResult || _domainResult == null) return [];
    return _domainResult!.baseNumberTiaoWenList;
  }

  /// 获取先天卦BaseNumberTiaoWenListModel
  BaseNumberTiaoWenListModel? get xiantianBaseNumberTiaoWen {
    if (baseNumberTiaoWenList.isEmpty) return null;
    return baseNumberTiaoWenList[0]; // 第一个是先天卦
  }

  /// 获取后天卦BaseNumberTiaoWenListModel
  BaseNumberTiaoWenListModel? get houtianBaseNumberTiaoWen {
    if (baseNumberTiaoWenList.length < 2) return null;
    return baseNumberTiaoWenList[1]; // 第二个是后天卦
  }

  /// 获取先天卦条文编号列表
  List<int> get xiantianTiaoWenNumbers {
    final xiantian = xiantianBaseNumberTiaoWen;
    if (xiantian == null) return [];
    return xiantian.tiaoWenNumbers;
  }

  /// 获取后天卦条文编号列表
  List<int> get houtianTiaoWenNumbers {
    final houtian = houtianBaseNumberTiaoWen;
    if (houtian == null) return [];
    return houtian.tiaoWenNumbers;
  }

  /// 获取所有条文编号（先天卦 + 后天卦，去重）
  List<int> get allTiaoWenNumbers {
    if (!hasResult || _domainResult == null) return [];
    return {...xiantianTiaoWenNumbers, ...houtianTiaoWenNumbers}.toList();
  }

  /// 获取参数显示文本
  String get paramsDisplayText {
    if (!hasSelection) return '未选择';
    return '性别:$_currentGender, 三元:$_currentThreeYuan, 节气:$_currentBirthAfterZhi';
  }

  /// 获取四柱显示文本
  String get fourZhuDisplayText {
    if (_currentEightChars == null) return '未选择';
    return _currentEightChars!.toString();
  }

  /// 获取先天卦显示文本
  String get xiantianGuaDisplayText {
    final model = liuYaoGanZhiHeModel;
    if (model == null) return '未计算';
    return '${model.xiantianGua}（上:${model.upperGua} 下:${model.lowerGua}）';
  }

  /// 获取后天卦显示文本
  String get houtianGuaDisplayText {
    final model = liuYaoGanZhiHeModel;
    if (model == null) return '未计算';
    return model.houtianGua.fullname;
  }

  /// 获取天地卦显示文本
  String get tianDiGuaDisplayText {
    final model = liuYaoGanZhiHeModel;
    if (model == null) return '未计算';
    return '天卦:${model.tianGua} 地卦:${model.diGua}';
  }

  /// 获取先天卦基础数
  int get xiantianBaseNumber {
    final model = liuYaoGanZhiHeModel;
    if (model == null) return 0;
    return model.xiantianBaseNumber;
  }

  /// 获取后天卦基础数
  int get houtianBaseNumber {
    final model = liuYaoGanZhiHeModel;
    if (model == null) return 0;
    return model.houtianBaseNumber;
  }

  /// 获取先天卦六爻天干列表
  List<String> get xiantianYaoTianGanList {
    final model = liuYaoGanZhiHeModel;
    if (model == null) return [];
    return model.xiantianYaoTianGanList;
  }

  /// 获取先天卦六爻地支列表
  List<String> get xiantianYaoDiZhiList {
    final model = liuYaoGanZhiHeModel;
    if (model == null) return [];
    return model.xiantianYaoDiZhiList;
  }

  /// 获取先天卦六爻和数列表
  List<int> get xiantianYaoSumList {
    final model = liuYaoGanZhiHeModel;
    if (model == null) return [];
    return model.xiantianYaoSumList;
  }

  /// 获取后天卦六爻天干列表
  List<String> get houtianYaoTianGanList {
    final model = liuYaoGanZhiHeModel;
    if (model == null) return [];
    return model.houtianYaoTianGanList;
  }

  /// 获取后天卦六爻地支列表
  List<String> get houtianYaoDiZhiList {
    final model = liuYaoGanZhiHeModel;
    if (model == null) return [];
    return model.houtianYaoDiZhiList;
  }

  /// 获取后天卦六爻和数列表
  List<int> get houtianYaoSumList {
    final model = liuYaoGanZhiHeModel;
    if (model == null) return [];
    return model.houtianYaoSumList;
  }

  @override
  void dispose() {
    _currentEightChars = null;
    _currentGender = null;
    _currentThreeYuan = null;
    _currentBirthAfterZhi = null;
    _domainResult = null;
    super.dispose();
  }

  @override
  String toString() {
    return 'LiuYaoGanZhiHeViewModel('
        'fourZhu: $_currentEightChars, '
        'gender: $_currentGender, '
        'threeYuan: $_currentThreeYuan, '
        'birthAfterZhi: $_currentBirthAfterZhi, '
        'hasSelection: $hasSelection, '
        '${super.toString()}'
        ')';
  }
}
