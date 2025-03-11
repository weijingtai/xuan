import 'package:common/datamodel/basic_person_info.dart';
import 'package:common/module.dart';
import 'package:flutter/material.dart';
import 'package:common/datamodel/geo_location.dart';
import 'package:common/helpers/geo_location_helper.dart';
import 'package:timezone/timezone.dart' as tz;

/// 城市选择器页面
/// 分为三部分，依次选择省份、城市和区县
class CityPickerPage extends StatefulWidget {
  /// 初始选中的地理位置编码
  final String? initialCode;

  /// 选择完成后的回调函数
  // final Function(GeoLocation location) onLocationSelected;

  const CityPickerPage({
    Key? key,
    this.initialCode,
    // required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<CityPickerPage> createState() => _CityPickerPageState();
}

class _CityPickerPageState extends State<CityPickerPage> {
  String _selectedTimeZone = 'Asia/Shanghai';
  String _groupValue = "option1";

  ValueNotifier<bool> isTrueSolarTime = ValueNotifier(false);
  // 当前选中的省份
  final _selectedProvince = ValueNotifier<GeoLocation?>(null);

  // 当前选中的城市
  final _selectedCity = ValueNotifier<GeoLocation?>(null);

  // 当前选中的区县
  final _selectedCounty = ValueNotifier<GeoLocation?>(null);

  // 省份列表
  final _provinces = ValueNotifier<List<GeoLocation>?>(null);

  // 城市列表
  final _cities = ValueNotifier<List<GeoLocation>?>(null);

  // 区县列表
  final _counties = ValueNotifier<List<GeoLocation>?>(null);

  // 是否正在加载数据
  bool _isLoading = true;

  // 是否发生错误
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _selectedProvince.dispose();
    _selectedCity.dispose();
    _selectedCounty.dispose();
    _provinces.dispose();
    _cities.dispose();
    _counties.dispose();
    isTrueSolarTime.dispose();
    super.dispose();
  }

  /// 加载地理位置数据
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // 初始化地理位置数据
      await GeoLocationHelper.initialize();

      // 加载省份列表
      _provinces.value =
          GeoLocationHelper.getLocationsByLevel(GeoLevel.province);

      // 如果有初始编码，则设置初始选中项
      if (widget.initialCode != null) {
        _setInitialSelection(widget.initialCode!);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('加载地理位置数据失败: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  /// 设置初始选中项
  void _setInitialSelection(String code) {
    // 获取初始位置
    final location = GeoLocationHelper.getLocationByCode(code);
    if (location == null) return;

    // 根据级别设置选中项
    //   switch (location.level) {
    //     case GeoLevel.county:
    //       _selectedCounty = location;
    //       _selectedCity =
    //           GeoLocationHelper.getLocationByCode(location.parentCode);
    //       if (_selectedCity != null) {
    //         _selectedProvince =
    //             GeoLocationHelper.getLocationByCode(_selectedCity!.parentCode);
    //         if (_selectedProvince != null) {
    //           _loadCities(_selectedProvince!.code);
    //           _loadCounties(_selectedCity!.code);
    //         }
    //       }
    //       break;
    //     case GeoLevel.city:
    //       _selectedCity = location;
    //       _selectedProvince =
    //           GeoLocationHelper.getLocationByCode(location.parentCode);
    //       if (_selectedProvince != null) {
    //         _loadCities(_selectedProvince!.code);
    //         _loadCounties(_selectedCity!.code);
    //       }
    //       break;
    //     case GeoLevel.province:
    //       _selectedProvince = location;
    //       _loadCities(_selectedProvince!.code);
    //       break;
    //     default:
    //       break;
    //   }
  }

  /// 加载城市列表
  void _loadCities(String provinceCode) {
    _cities.value = GeoLocationHelper.getChildLocations(provinceCode);
    print(_cities.value);
    // _selectedCity = null;
    // _selectedCounty = null;
    // _counties = [];
  }

  /// 加载区县列表
  void _loadCounties(String cityCode) {
    _counties.value = GeoLocationHelper.getChildLocations(cityCode);
    // _selectedCounty = null;
  }

  /// 选择省份
  void _selectProvince(GeoLocation province) {
    if (_selectedProvince.value != null) {
      if (_selectedProvince.value == province) {
        return;
      }
      // 清空之前的选中项
      _selectedCity.value = null;
      _selectedCounty.value = null;
      _cities.value = null;
      _counties.value = null;
    }
    _selectedProvince.value = province;
    _loadCities(province.code);
    // setState(() {
    //   _selectedProvince = province;
    //   _loadCities(province.code);
    // });
  }

  /// 选择城市
  void _selectCity(GeoLocation city) {
    if (_selectedCity.value != null) {
      if (_selectedCity.value == city) {
        return;
      }
      // 清空之前的选中项
      _selectedCity.value = null;
      _selectedCounty.value = null;
      _counties.value = null;
    }
    _selectedCity.value = city;
    _loadCounties(city.code);
  }

  /// 选择区县
  void _selectCounty(GeoLocation county) {
    _selectedCounty.value = county;
    // setState(() {
    //   _selectedCounty = county;
    // });

    // 调用选择完成回调
    // widget.onLocationSelected(county);
  }

  /// 完成选择
  void _finishSelection() {
    // if (_selectedCounty != null) {
    //   widget.onLocationSelected(_selectedCounty!);
    // } else if (_selectedCity != null) {
    //   widget.onLocationSelected(_selectedCity!);
    // } else if (_selectedProvince != null) {
    //   widget.onLocationSelected(_selectedProvince!);
    // }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('选择地区'),
          actions: [
            if (_selectedProvince != null)
              TextButton(
                onPressed: _finishSelection,
                child: const Text('确定', style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                  onPressed: () async {
                    // 显示城市选择器底部弹窗
                    final Location? selectedLocation =
                        await showCityPickerBottomSheet(
                      context: context,
                      initLocation:
                          Location.defualtLocation(), // 可选，初始选中的地理位置编码
                    );
// 处理选择结果
                    if (selectedLocation != null) {
                      print(selectedLocation.toJson());
                      // print('选中的地区: ${selectedLocation.name}');
                      // print('编码: ${selectedLocation.code}');
                      // print(
                      // '经纬度: (${selectedLocation.latitude}, ${selectedLocation.longitude})');
                    }
                  },
                  child: Text("选择地区")),
              SizedBox(
                height: 64,
              ),
              DropdownButton<String>(
                value: _selectedTimeZone,
                items: tz.timeZoneDatabase.locations.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTimeZone = newValue!;
                  });
                  // 获取当前选定时区的时间
                  tz.TZDateTime now =
                      tz.TZDateTime.now(tz.getLocation(_selectedTimeZone));
                  print(now);
                },
              ),
              SizedBox(height: 20),
              Text('当前选择的时区: $_selectedTimeZone'),
              SizedBox(height: 20),
              RadioListTile<String>(
                title: const Text('选项 1'),
                value: 'option1',
                groupValue: _groupValue,
                onChanged: (String? value) {
                  setState(() {
                    _groupValue = value!;
                  });
                },
                activeColor: Colors.blue, // 设置选中颜色
                controlAffinity: ListTileControlAffinity.trailing, // 将单选框放在尾部
              ),
              RadioListTile<String>(
                title: const Text('选项 2'),
                value: 'option2',
                groupValue: _groupValue,
                onChanged: (String? value) {
                  setState(() {
                    _groupValue = value!;
                  });
                },
                activeColor: Colors.green,
                controlAffinity: ListTileControlAffinity.trailing,
              ),
              RadioListTile<String>(
                title: const Text('选项 3'),
                value: 'option3',
                groupValue: _groupValue,
                onChanged: (String? value) {
                  setState(() {
                    _groupValue = value!;
                  });
                },
                activeColor: Colors.orange,
                controlAffinity: ListTileControlAffinity.trailing,
              ),
              Text('当前选择: $_groupValue'),
              ValueListenableBuilder(
                  valueListenable: isTrueSolarTime,
                  builder: (ctx, trueSolarTime, child) {
                    return Row(
                      children: <Widget>[
                        Checkbox(
                          value: trueSolarTime,
                          onChanged: (bool? value) {
                            isTrueSolarTime.value = value!;
                          },
                        ),
                        Text('选项 1'),
                      ],
                    );
                  })
            ],
          ),
        )
        // body: _buildBody(),
        );
  }

  /// 构建页面主体
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('加载数据失败'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 顶部提示
        _buildSelectionInfoPanel(),

        Expanded(
          child: Row(
            children: [
              // 第一部分：省份列表
              Expanded(
                child: ValueListenableBuilder<List<GeoLocation>?>(
                    valueListenable: _provinces,
                    builder: (ctx, province, child) {
                      if (province == null) return child!;
                      return _buildLocationList(
                        province,
                        _selectedProvince,
                        _selectProvince,
                        '选择省份',
                      );
                    },
                    // 数据loading
                    child: const Center(child: Text('加载中...'))),
              ),

              // 分隔线
              Container(width: 1, color: Colors.grey.shade300),

              // 第二部分：城市列表
              Expanded(
                  child: ValueListenableBuilder<List<GeoLocation>?>(
                valueListenable: _cities,
                builder: (ctx, cities, child) {
                  if (cities == null) return child!;
                  return _buildLocationList(
                    cities!,
                    _selectedCity,
                    _selectCity,
                    '选择城市',
                  );
                },
                child: const Center(child: Text('请先选择省份')),
              )),
              // 分隔线
              Container(width: 1, color: Colors.grey.shade300),
              // 第三部分：区县列表
              Expanded(
                  child: _selectedCity == null
                      ? const Center(child: Text('请先选择城市'))
                      : ValueListenableBuilder<List<GeoLocation>?>(
                          valueListenable: _counties,
                          builder: (ctx, counties, child) {
                            if (counties == null) return child!;
                            return _buildLocationList(
                              counties,
                              _selectedCounty,
                              _selectCounty,
                              '选择区县',
                            );
                          },
                          child: const Center(
                            child: Text('请先选择城市'),
                          ))),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSelectionInfoPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前选择',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          // 使用ValueListenableBuilder监听选择变化
          ValueListenableBuilder<GeoLocation?>(
            valueListenable: _selectedProvince,
            builder: (context, province, _) {
              return ValueListenableBuilder<GeoLocation?>(
                valueListenable: _selectedCity,
                builder: (context, city, _) {
                  return ValueListenableBuilder<GeoLocation?>(
                    valueListenable: _selectedCounty,
                    builder: (context, county, _) {
                      // 构建地址文本
                      String addressText = '请选择地区';
                      String coordinatesText = '';

                      if (province != null) {
                        addressText = province.name;
                        coordinatesText =
                            '经度: ${province.longitude.toStringAsFixed(6)}, 纬度: ${province.latitude.toStringAsFixed(6)}';

                        if (city != null) {
                          addressText += ' > ${city.name}';
                          coordinatesText =
                              '经度: ${city.longitude.toStringAsFixed(6)}, 纬度: ${city.latitude.toStringAsFixed(6)}';

                          if (county != null) {
                            addressText += ' > ${county.name}';
                            coordinatesText =
                                '经度: ${county.longitude.toStringAsFixed(6)}, 纬度: ${county.latitude.toStringAsFixed(6)}';
                          }
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addressText,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          if (province != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              coordinatesText,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建位置列表
  Widget _buildLocationList(
    List<GeoLocation> locations,
    ValueNotifier<GeoLocation?> selectedLocationNotifier,
    Function(GeoLocation) onSelect,
    String emptyText,
  ) {
    return ValueListenableBuilder<GeoLocation?>(
        valueListenable: selectedLocationNotifier,
        builder: (ctx, selectedLocation, _) {
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              final isSelected = selectedLocation?.code == location.code;
              return ListTile(
                title: Text(location.name),
                selected: isSelected,
                selectedTileColor: Colors.blue.withOpacity(0.1),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () => onSelect(location),
              );
            },
          );
        });
  }
}
