import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/widgets/eight_chars_selection_card.dart';
import 'package:common/widgets/query_time_input_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'helpers/solar_lunar_datetime_helper.dart';
import 'models/query_datetime.dart';
import 'widgets/eight_chars_input_card.dart';

class DevEnterPage extends StatefulWidget {
  const DevEnterPage({super.key});

  @override
  State<DevEnterPage> createState() => _DevEnterPageState();
}

class _DevEnterPageState extends State<DevEnterPage> {
  final ValueNotifier<List<MapEntry<EnumDatetimeType,QueryDatetimeModel>>?> _selectableCardsNotifier = ValueNotifier(null);

  final ValueNotifier<int?> _selectedIndexNotifier = ValueNotifier(null);

  @override
  void dispose() {
    // TODO: implement dispose
    _selectableCardsNotifier.dispose();
    _selectedIndexNotifier.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Dev Widget")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              QueryTimeInputCard(
                // defaultTimeZone: "Asia/Shanghai",
                defaultPageType: PageType.datetime,
                selectableCardsNotifier: _selectableCardsNotifier,
              ),
              SizedBox(height: 64,),
              ValueListenableBuilder(
                  valueListenable: _selectableCardsNotifier,
                  builder: (ctx,mapEntries,child){
                    if (mapEntries == null) return child!;
                    Set<int> highLightIndexSet = Set();
                    if (mapEntries.map((e)=>e.value.bazi.year).toSet().length>1){
                      highLightIndexSet.add(1);
                    }
                    if (mapEntries.map((e)=>e.value.bazi.month).toSet().length>1){
                      highLightIndexSet.add(2);
                    }
                    if (mapEntries.map((e)=>e.value.bazi.day).toSet().length>1){
                      highLightIndexSet.add(3);
                    }
                    if (mapEntries.map((e)=>e.value.bazi.time).toSet().length>1){
                      highLightIndexSet.add(4);
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Display cards horizontally
                      padding: const EdgeInsets.all(8.0),
                      child: ValueListenableBuilder<int?>(
                        valueListenable: _selectedIndexNotifier,
                        builder: (context,selectedIndex,_) {
                          return Row(
                            // Generate the cards dynamically
                            children: List.generate(mapEntries.length, (index) {
                              return EightCharsSelectionCard(
                                isSelected: selectedIndex == null ? false : selectedIndex == index,
                                // queryDateTime:  SolarLunarDateTimeHelper.calculateNormalQueryDateTimeInfo(DateTime.now(), "Asia/Shanghai", true),
                                queryDateTime: mapEntries[index].value,
                                onTap: (){
                                  setState(() {
                                    _selectedIndexNotifier.value = index;
                                  });
                                },
                                timeFormat: DateFormat("HH:mm"),
                                dateFormat: DateFormat("yyyy-MM-dd"),
                                dateTimeFormat: DateFormat("yyyy-MM-dd HH:mm"),
                                highLight: highLightIndexSet,
                                size: Size(256, 256 + 96+32),
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              );
                            }),
                          );
                        }
                      ),
                    );

                  },
              child: SizedBox(height:  256 + 96+32 + 32),),

            ],
          ),
        ),
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
