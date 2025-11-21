import 'package:common/models/divination_info_model.dart';
import 'package:common/widgets/eight_chars_select_card_list_widget.dart';
import 'package:common/widgets/query_time_input_card.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'models/divination_datetime.dart';
import 'viewmodels/dev_enter_page_view_model.dart';
import 'widgets/divination_card_widget.dart';
import 'enums/layout_template_enums.dart';
import 'enums/enum_jia_zi.dart';
import 'models/eight_chars.dart';
import 'models/layout_template.dart';
import 'models/text_style_config.dart';

class DevEnterPage extends StatefulWidget {
  const DevEnterPage({super.key});

  @override
  State<DevEnterPage> createState() => _DevEnterPageState();
}

class _DevEnterPageState extends State<DevEnterPage> {
  final ValueNotifier<
          List<MapEntry<EnumDatetimeType, DivinationDatetimeModel>>?>
      _selectableCardsNotifier = ValueNotifier(null);

  final ValueNotifier<int?> _selectedIndexNotifier = ValueNotifier(null);

  final PageController _pageController = PageController();

  // 四柱卡片相关状态
  final bool _isEditable = false;
  late EightChars _sample;
  late List<PillarType> _columnPillars;
  late List<PillarType> _rowPillars;
  late List<RowConfig> _columnRows;
  late List<RowConfig> _rowRows;
  late CardStyle _cardStyle;

  // late final DevEnterPageViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    // _viewModel = DevEnterPageViewModel();
    // context.read<DevEnterPageViewModel>().initState();

    // 初始化四柱示例数据
    _sample = EightChars(
      year: JiaZi.JIA_ZI,
      month: JiaZi.YI_CHOU,
      day: JiaZi.BING_YIN,
      time: JiaZi.DING_MAO,
    );
    _columnPillars = const [
      PillarType.year,
      PillarType.month,
      PillarType.day,
      PillarType.hour
    ];
    _rowPillars = const [
      PillarType.year,
      PillarType.month,
      PillarType.day,
      PillarType.hour
    ];
    _columnRows = [
      RowConfig(
          type: RowType.heavenlyStem,
          isVisible: true,
          isTitleVisible: true,
          textStyleConfig: TextStyleConfig.defaultConfig),
      RowConfig(
          type: RowType.earthlyBranch,
          isVisible: true,
          isTitleVisible: true,
          textStyleConfig: TextStyleConfig.defaultConfig),
      RowConfig(
          type: RowType.naYin,
          isVisible: true,
          isTitleVisible: true,
          textStyleConfig: TextStyleConfig.defaultConfig),
    ];
    _rowRows = [
      RowConfig(
          type: RowType.heavenlyStem,
          isVisible: true,
          isTitleVisible: true,
          textStyleConfig: TextStyleConfig.defaultConfig),
      RowConfig(
          type: RowType.earthlyBranch,
          isVisible: true,
          isTitleVisible: true,
          textStyleConfig: TextStyleConfig.defaultConfig),
      RowConfig(
          type: RowType.naYin,
          isVisible: true,
          isTitleVisible: true,
          textStyleConfig: TextStyleConfig.defaultConfig),
    ];
    _cardStyle = const CardStyle(
      dividerType: BorderType.solid,
      dividerColorHex: '#FF334155',
      dividerThickness: 1,
      globalFontFamily: 'NotoSansSC-Regular',
      globalFontSize: 16,
      globalFontColorHex: '#FF0F172A',
    );
  }

  @override
  void dispose() {
    _selectableCardsNotifier.dispose();
    _selectedIndexNotifier.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dev Widget")),
      body: Center(
        child: _buildCardContent(),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(title: const Text("Dev Widget")),
    //   body: Center(
    //     child: WorldCountryCityPickerPage(),
    //   ),
    // );
  }

  Widget _buildCardContent() {
    // 获取屏幕尺寸信息
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // 计算合适的尺寸
    final contentWidth = screenWidth > 600 ? 512.0 : screenWidth * 0.9;
    final contentPadding = screenWidth > 600 ? 16.0 : 8.0;
    final spacing = screenWidth > 600 ? 16.0 : 8.0;
    final cardSize = screenWidth > 600 ? 256.0 : screenWidth * 0.8;
    return SingleChildScrollView(
      child: Column(
        children: [
          DivinationCardWidget(
            enterPageViewModel: context.read<DevEnterPageViewModel>(),
          ),
          Container(
            width: contentWidth,
            // height: 512,
            padding: EdgeInsets.symmetric(
                horizontal: contentPadding * 2, vertical: contentPadding * 2),
            child: QueryTimeInputCard(
              defaultDateTimeType:
                  context.read<DevEnterPageViewModel>().datetimeType,
              selectableCardsNotifier: context
                  .read<DevEnterPageViewModel>()
                  .selectableCardListNotifier,
            ),
          ),
          SizedBox(height: spacing * 2),
          EightCharsSelectCardListWidget(
            selectableCardsNotifier: context
                .read<DevEnterPageViewModel>()
                .selectableCardListNotifier,
            contentPadding: contentPadding,
            cardSize: cardSize,
            enterPageViewModel: context.read<DevEnterPageViewModel>(),
          ),
          SizedBox(height: spacing * 2),
          SizedBox(
            height: spacing * 2,
          ),
          ElevatedButton(
              onPressed: () async {
                DivinationInfoModel result =
                    await context.read<DevEnterPageViewModel>().create();

                // print(result.toJson());

                Navigator.pushNamed(context, "/qizhengsiyu/panel", arguments: {
                  "divinationInfoModel": result,
                });
              },
              child: const Text("七政四余")),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, "/common/four_zhu_edit");
            },
            child: const Text("打开四柱布局编辑器"),
          ),
        ],
      ),
    );
  }

  int? selectedIndex;

  // Make sure _buildCardContent is accessible, maybe make it a static method
// or part of the same class, or pass it as a parameter if needed.
// For simplicity here, assume it's defined globally or in the same scope.

  final DateTime now = DateTime.now();

  // 获取当前设备的经纬度
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
