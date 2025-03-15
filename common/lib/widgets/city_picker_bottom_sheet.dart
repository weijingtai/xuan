import 'package:common/datamodel/basic_person_info.dart';
import 'package:flutter/material.dart';
import 'package:common/datamodel/geo_location.dart';
import 'package:common/helpers/geo_location_helper.dart';

/// 显示城市选择器底部弹窗
Future<Location?> showCityPickerBottomSheet({
  required BuildContext context,
  required Location initLocation,
}) {
  return showModalBottomSheet<Location>(
    context: context,
    isScrollControlled: true, // 允许弹窗占据更大空间
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7, // 初始高度为屏幕的70%
      minChildSize: 0.5, // 最小高度为屏幕的50%
      maxChildSize: 0.9, // 最大高度为屏幕的90%
      expand: false,
      builder: (context, scrollController) {
        return CityPickerBottomSheet(
          initLocation: initLocation,
          scrollController: scrollController,
        );
      },
    ),
  );
}

/// 城市选择器底部弹窗
class CityPickerBottomSheet extends StatefulWidget {
  /// 初始选中的地理位置编码
  // final String? initialCode;
  final Location initLocation;

  /// 滚动控制器
  final ScrollController scrollController;

  const CityPickerBottomSheet({
    Key? key,
    required this.initLocation,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<CityPickerBottomSheet> createState() => _CityPickerBottomSheetState();
}

class _CityPickerBottomSheetState extends State<CityPickerBottomSheet> {
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
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasError = ValueNotifier<bool>(false);
  // bool _isLoading = true;

  // 是否发生错误
  // bool _hasError = false;

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
    _isLoading.dispose();
    _hasError.dispose();
    super.dispose();
  }

  /// 加载地理位置数据
  Future<void> _loadData() async {
    _isLoading.value = true;
    _hasError.value = false;
    // setState(() {
    //   _isLoading = true;
    //   _hasError = false;
    // });

    try {
      // 初始化地理位置数据
      await GeoLocationHelper.initialize();

      // 加载省份列表
      _provinces.value =
          GeoLocationHelper.getLocationsByLevel(GeoLevel.province);

      // 如果有初始编码，则设置初始选中项
      _setInitialSelection(widget.initLocation);

      _isLoading.value = false;
      // setState(() {
      // _isLoading = false;
      // });
    } catch (e) {
      print('加载地理位置数据失败: $e');
      _isLoading.value = false;
      _hasError.value = true;
      // setState(() {
      // _isLoading = false;
      // _hasError = true;
      // });
    }
  }

  /// 设置初始选中项
  void _setInitialSelection(Location initLocation) {
    String code = initLocation.lowestGeoLocation.code;
    // 获取初始位置
    final location = GeoLocationHelper.getLocationByCode(code);
    if (location == null) return;

    // 根据级别设置选中项
    switch (location.level) {
      case GeoLevel.county:
        _selectedCounty.value = location;
        final city = GeoLocationHelper.getLocationByCode(location.parentCode);
        if (city != null) {
          _selectedCity.value = city;
          final province = GeoLocationHelper.getLocationByCode(city.parentCode);
          if (province != null) {
            _selectedProvince.value = province;
            _loadCities(province.code);
            _loadCounties(city.code);
          }
        }
        break;
      case GeoLevel.city:
        _selectedCity.value = location;
        final province =
            GeoLocationHelper.getLocationByCode(location.parentCode);
        if (province != null) {
          _selectedProvince.value = province;
          _loadCities(province.code);
          _loadCounties(location.code);
        }
        break;
      case GeoLevel.province:
        _selectedProvince.value = location;
        _loadCities(location.code);
        break;
      default:
        break;
    }
  }

  /// 加载城市列表
  void _loadCities(String provinceCode) {
    _cities.value = GeoLocationHelper.getChildLocations(provinceCode);
  }

  /// 加载区县列表
  void _loadCounties(String cityCode) {
    _counties.value = GeoLocationHelper.getChildLocations(cityCode);
  }

  /// 选择省份
  void _selectProvince(GeoLocation province) {
    if (_selectedProvince.value?.code == province.code) return;

    _selectedProvince.value = province;
    _selectedCity.value = null;
    _selectedCounty.value = null;
    _loadCities(province.code);
    _counties.value = null;
  }

  /// 选择城市
  void _selectCity(GeoLocation city) {
    if (_selectedCity.value?.code == city.code) return;

    _selectedCity.value = city;
    _selectedCounty.value = null;
    _loadCounties(city.code);
  }

  /// 选择区县
  void _selectCounty(GeoLocation county) {
    _selectedCounty.value = county;
    // 选择完区县后自动返回结果
    // Navigator.of(context).pop(county);
  }

  /// 完成选择
  void _finishSelection() {
    Location newLocation = widget.initLocation.copyWith(
      province: _selectedProvince.value,
      city: _selectedCity.value,
      area: _selectedCounty.value,
    );
    Navigator.of(context).pop(newLocation);
    // 返回最精确的选择结果
    // if (_selectedCounty.value != null) {
    //   Navigator.of(context).pop(_selectedCounty.value);
    // } else if (_selectedCity.value != null) {
    //   Navigator.of(context).pop(_selectedCity.value);
    // } else if (_selectedProvince.value != null) {
    //   Navigator.of(context).pop(_selectedProvince.value);
    // } else {
    //   Navigator.of(context).pop();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 顶部拖动条和标题栏
          _buildHeader(),

          // 选择信息面板
          _buildSelectionInfoPanel(),

          // 列表区域

          Expanded(
            child: ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (ctx, isLoading, child) {
                  if (isLoading) return child!;
                  return ValueListenableBuilder(
                    valueListenable: _hasError,
                    builder: (ctx, hasError, child2) {
                      if (hasError) return child2!;
                      return _buildListsView();
                    },
                    child: _buildErrorView(),
                  );
                },
                child: const Center(child: CircularProgressIndicator())),
          )

          // 底部确认按钮
          // _buildBottomButton(),
        ],
      ),
    );
  }

  /// 构建顶部拖动条和标题
  Widget _buildHeader() {
    return Column(
      children: [
        // 拖动条
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // 标题栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '选择地区',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Row(children: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "取消",
                      style: TextStyle(color: Colors.grey),
                    )),
                ValueListenableBuilder(
                    valueListenable: _selectedCity,
                    builder: (ctx, city, _) {
                      return TextButton(
                          onPressed:
                              city == null ? null : () => _finishSelection(),
                          child: Text(
                            "完成",
                            style: TextStyle(
                                color:
                                    city == null ? Colors.grey : Colors.blue),
                          ));
                    })
              ])
            ],
          ),
        ),
      ],
    );
  }

  /// 构建错误视图
  Widget _buildErrorView() {
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

  /// 构建列表视图
  Widget _buildListsView() {
    return Row(
      children: [
        // 第一部分：省份列表
        Expanded(
          child: ValueListenableBuilder<List<GeoLocation>?>(
            valueListenable: _provinces,
            builder: (ctx, provinces, child) {
              if (provinces == null) return child!;
              return _buildLocationList(
                provinces,
                _selectedProvince,
                _selectProvince,
                '选择省份',
              );
            },
            child: const Center(child: Text('加载中...')),
          ),
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
                cities,
                _selectedCity,
                _selectCity,
                '选择城市',
              );
            },
            child: const Center(child: Text('请先选择省份')),
          ),
        ),

        // 分隔线
        Container(width: 1, color: Colors.grey.shade300),

        // 第三部分：区县列表
        Expanded(
          child: ValueListenableBuilder<List<GeoLocation>?>(
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
            child: const Center(child: Text('请先选择城市')),
          ),
        ),
      ],
    );
  }

  /// 构建选择信息面板
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

  /// 构建底部确认按钮
  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ValueListenableBuilder<GeoLocation?>(
        valueListenable: _selectedProvince,
        builder: (context, province, _) {
          final bool canConfirm = province != null;

          return ElevatedButton(
            onPressed: canConfirm ? _finishSelection : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('确定选择'),
          );
        },
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
    if (locations.isEmpty) {
      return Center(child: Text(emptyText));
    }

    return ValueListenableBuilder<GeoLocation?>(
      valueListenable: selectedLocationNotifier,
      builder: (context, selectedLocation, _) {
        return ListView.builder(
          controller: widget.scrollController,
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
      },
    );
  }
}
