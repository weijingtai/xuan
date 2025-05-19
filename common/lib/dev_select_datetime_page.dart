import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/widgets/eight_chars_select_card_list_widget.dart';
import 'package:common/widgets/eight_chars_selection_card.dart';
import 'package:common/widgets/query_time_input_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'helpers/solar_lunar_datetime_helper.dart';
import 'models/divination_datetime.dart';
import 'viewmodels/dev_enter_page_view_model.dart';
import 'widgets/destiny_question_widget.dart';
import 'widgets/divination_card_widget.dart';
import 'widgets/divination_question_widget.dart';
import 'widgets/eight_chars_input_card.dart';
import 'widgets/world_country_city_picker_page.dart';

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

  late final DevEnterPageViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = DevEnterPageViewModel();
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
            enterPageViewModel: _viewModel,
          ),
          Container(
            width: contentWidth,
            // height: 512,
            padding: EdgeInsets.symmetric(
                horizontal: contentPadding * 2, vertical: contentPadding * 2),
            child: QueryTimeInputCard(
              defaultPageType: PageType.datetime,
              selectableCardsNotifier: _selectableCardsNotifier,
              defaultTimezone: "America/Los_Angeles",
            ),
          ),
          SizedBox(height: spacing * 2),
          EightCharsSelectCardListWidget(
            selectableCardsNotifier: _selectableCardsNotifier,
            contentPadding: contentPadding,
            cardSize: cardSize,
            enterPageViewModel: _viewModel,
          ),
          SizedBox(height: spacing * 2),
          SizedBox(
            height: spacing * 2,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/qizhengsiyu/panel");
              },
              child: Text("七政四余"))
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
