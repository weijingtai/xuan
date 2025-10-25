import 'package:flutter/foundation.dart';
import 'package:qimendunjia/domain/entities/each_gong.dart';
import 'package:qimendunjia/domain/entities/qimen_pan.dart';
import 'package:qimendunjia/domain/entities/shi_jia_ju.dart';
import 'package:qimendunjia/domain/usecases/arrange_pan_usecase.dart';
import 'package:qimendunjia/domain/usecases/calculate_ju_usecase.dart';
import 'package:qimendunjia/domain/usecases/select_gong_usecase.dart';
import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import 'package:qimendunjia/domain/repositories/qimen_calculator_repository.dart';

/// 奇门遁甲视图状态
enum QiMenViewState {
  /// 初始状态
  initial,

  /// 计算中
  calculating,

  /// 排盘中
  arranging,

  /// 加载宫位详情中
  loadingGongDetail,

  /// 成功
  success,

  /// 错误
  error,
}

/// 奇门遁甲 ViewModel
///
/// 负责管理奇门遁甲界面的状态和业务逻辑
/// 遵循 MVVM 架构模式
class QiMenViewModel extends ChangeNotifier {
  // 用例
  final CalculateJuUseCase _calculateJuUseCase;
  final ArrangePanUseCase _arrangePanUseCase;
  final SelectGongUseCase _selectGongUseCase;

  // 状态
  QiMenViewState _state = QiMenViewState.initial;
  String? _errorMessage;

  // 数据
  ShiJiaJu? _currentJu;
  QiMenPan? _currentPan;
  EachGong? _selectedGong;
  GongDetailInfo? _gongDetailInfo;

  // 设置
  PanSettings _panSettings = PanSettings.defaultSettings();

  QiMenViewModel(
    this._calculateJuUseCase,
    this._arrangePanUseCase,
    this._selectGongUseCase,
  );

  // Getters
  QiMenViewState get state => _state;
  String? get errorMessage => _errorMessage;
  ShiJiaJu? get currentJu => _currentJu;
  QiMenPan? get currentPan => _currentPan;
  EachGong? get selectedGong => _selectedGong;
  GongDetailInfo? get gongDetailInfo => _gongDetailInfo;
  PanSettings get panSettings => _panSettings;

  bool get isLoading =>
      _state == QiMenViewState.calculating ||
      _state == QiMenViewState.arranging ||
      _state == QiMenViewState.loadingGongDetail;

  bool get hasError => _state == QiMenViewState.error;
  bool get hasData => _currentPan != null;

  /// 更新排盘设置
  void updatePanSettings(PanSettings settings) {
    _panSettings = settings;
    notifyListeners();
  }

  /// 计算并排盘
  ///
  /// [dateTime] 起盘时间
  /// [arrangeType] 起盘方式
  /// [plateType] 盘类型
  Future<void> calculateAndArrangePan({
    required DateTime dateTime,
    required ArrangeType arrangeType,
    required PlateType plateType,
  }) async {
    try {
      // 1. 计算局数
      _state = QiMenViewState.calculating;
      _errorMessage = null;
      notifyListeners();

      final ju = await _calculateJuUseCase.execute(
        CalculateJuParams(
          dateTime: dateTime,
          arrangeType: arrangeType,
        ),
      );
      _currentJu = ju;

      // 2. 排盘
      _state = QiMenViewState.arranging;
      notifyListeners();

      final pan = await _arrangePanUseCase.execute(
        ArrangePanParams(
          ju: ju,
          plateType: plateType,
          settings: _panSettings,
        ),
      );
      _currentPan = pan;

      // 3. 成功
      _state = QiMenViewState.success;
      notifyListeners();
    } catch (e) {
      _state = QiMenViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 选择宫位并加载详情
  ///
  /// [gong] 要选择的宫位
  Future<void> selectGong(EachGong gong) async {
    try {
      _state = QiMenViewState.loadingGongDetail;
      _selectedGong = gong;
      _errorMessage = null;
      notifyListeners();

      if (_currentPan == null) {
        throw Exception('请先排盘');
      }

      final detailInfo = await _selectGongUseCase.execute(
        SelectGongParams(
          pan: _currentPan!,
          gongGua: gong.gongGua,
        ),
      );
      _gongDetailInfo = detailInfo;

      _state = QiMenViewState.success;
      notifyListeners();
    } catch (e) {
      _state = QiMenViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 取消选择宫位
  void unselectGong() {
    _selectedGong = null;
    _gongDetailInfo = null;
    _state = QiMenViewState.success;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _state = QiMenViewState.initial;
    _errorMessage = null;
    _currentJu = null;
    _currentPan = null;
    _selectedGong = null;
    _gongDetailInfo = null;
    notifyListeners();
  }
}
