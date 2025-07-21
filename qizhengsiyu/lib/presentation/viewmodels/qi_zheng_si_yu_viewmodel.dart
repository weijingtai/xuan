import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:qizhengsiyu/domain/entities/models/base_panel_model.dart';
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/usecases/calculate_basic_life_panel_usecase.dart';
import 'package:qizhengsiyu/presentation/models/ui_star_model.dart';

class QiZhengSiYuViewModel extends ChangeNotifier {
  final CalculateBasicLifePanelUseCase calculateBasicLifePanelUseCase;

  QiZhengSiYuViewModel({required this.calculateBasicLifePanelUseCase});

  BasePanelModel? _basicLifePanel;
  BasePanelModel? get basicLifePanel => _basicLifePanel;

  List<UIStarModel> _uiBasicLifeStars = [];
  List<UIStarModel> get uiBasicLifeStars => _uiBasicLifeStars;

  Future<void> calculate(ObserverPosition observerPosition) async {
    _basicLifePanel =
        await calculateBasicLifePanelUseCase.execute(observerPosition);

    // TODO: The following calculation logic needs to be implemented
    // _uiBasicLifeStars =
    //     calculateUIStars(_basicLifePanel.starAngleMapper, _baseMiniSafetyAngle);

    notifyListeners();
  }
}
