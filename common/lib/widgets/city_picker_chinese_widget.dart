import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:common/module.dart';

import '../datamodel/geo_location.dart';
import '../datamodel/location.dart';
import '../datasource/geo_location_repository.dart';
import '../viewmodels/timezone_location_viewmodel.dart';

class CityPickerChineseWidget extends StatefulWidget {
  final Address? initAddress;
  final ValueNotifier<Address?> selectedAddressNotifier;

  final ValueNotifier<Location?> myLocationNotifier;

  /// 滚动控制器
  // final ScrollController scrollController;

  const CityPickerChineseWidget({
    super.key,
    required this.initAddress,
    required this.selectedAddressNotifier,
    required this.myLocationNotifier,
  });

  @override
  State<CityPickerChineseWidget> createState() =>
      _CityPickerChineseWidgetState();
}

class _CityPickerChineseWidgetState extends State<CityPickerChineseWidget> {
  late final ValueNotifier<Address?> _newSelectedAddressNotifier;
  // 当前选中的省份
  late final ValueNotifier<GeoLocation?> _selectedProvince;

  // 当前选中的城市
  late final ValueNotifier<GeoLocation?> _selectedCity;

  // 当前选中的区县
  late final ValueNotifier<GeoLocation?> _selectedCounty;

  // 省份列表
  final _provinces = ValueNotifier<List<GeoLocation>?>(null);

  // 城市列表
  final _cities = ValueNotifier<List<GeoLocation>?>(null);

  // 区县列表
  final _counties = ValueNotifier<List<GeoLocation>?>(null);
  // 是否正在加载数据
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasError = ValueNotifier<bool>(false);
  @override
  void initState() {
    super.initState();
    if (widget.initAddress != null) {
      _selectedProvince =
          ValueNotifier<GeoLocation?>(widget.initAddress!.province);
      _selectedCity = ValueNotifier<GeoLocation?>(widget.initAddress?.city);
      _selectedCounty = ValueNotifier<GeoLocation?>(widget.initAddress?.area);
      _newSelectedAddressNotifier = ValueNotifier<Address?>(widget.initAddress);
    } else {
      _selectedProvince = ValueNotifier<GeoLocation?>(null);
      _selectedCity = ValueNotifier<GeoLocation?>(null);
      _selectedCounty = ValueNotifier<GeoLocation?>(null);
      _newSelectedAddressNotifier = ValueNotifier<Address?>(null);
    }

    // widget.selectedAddressNotifier.value = widget.initAddress;
    _selectedProvince.addListener(() {
      if (_selectedProvince.value != null) {
        _newSelectedAddressNotifier.value = Address(
            countryId: 45,
            countryName: "中国",
            regionId: 9,
            province: _selectedProvince.value!,
            timezone: 'Asia/Shanghai');
      } else {
        _newSelectedAddressNotifier.value = null;
      }
    });
    _selectedCity.addListener(() {
      if (_selectedCity.value != null) {
        _newSelectedAddressNotifier.value = _newSelectedAddressNotifier.value!
            .copyWith(city: _selectedCity.value!)
            .removeArea();
      } else {
        _newSelectedAddressNotifier.value =
            _newSelectedAddressNotifier.value!.copyWith(city: null, area: null);
      }
    });
    _selectedCounty.addListener(() {
      if (_selectedCounty.value != null) {
        _newSelectedAddressNotifier.value = _newSelectedAddressNotifier.value!
            .copyWith(area: _selectedCounty.value!);
      } else {
        _newSelectedAddressNotifier.value =
            _newSelectedAddressNotifier.value!.copyWith(area: null);
      }
    });
    _newSelectedAddressNotifier.addListener(() {
      logger
          .d(_newSelectedAddressNotifier.value?.toJson().toString() ?? "null");
      widget.selectedAddressNotifier.value = _newSelectedAddressNotifier.value;
    });

    // _loadData();
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
    _newSelectedAddressNotifier.dispose();
    super.dispose();
  }

  /// 选择省份
  void _selectProvince(GeoLocation province) {
    if (_selectedProvince.value?.code == province.code) return;

    _selectedProvince.value = province;
    _selectedCity.value = null;
    _selectedCounty.value = null;
    _counties.value = null;
  }

  /// 选择城市
  void _selectCity(GeoLocation city) {
    if (_selectedCity.value?.code == city.code) return;

    _selectedCity.value = city;
    _selectedCounty.value = null;
    // _loadCounties(city.code);
  }

  /// 选择区县
  void _selectCounty(GeoLocation county) {
    _selectedCounty.value = county;
    // 选择完区县后自动返回结果
    // Navigator.of(context).pop(county);
  }

  /// 构建选择信息面板
  Widget _buildSelectionInfoPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: ValueListenableBuilder<GeoLocation?>(
        valueListenable: _selectedProvince,
        builder: (ctx, province, child) {
          return ValueListenableBuilder<GeoLocation?>(
              valueListenable: _selectedCity,
              builder: (ctx, city, child) {
                return ValueListenableBuilder<GeoLocation?>(
                    valueListenable: _selectedCounty,
                    builder: (ctx, county, child) {
                      Address? newSelectedAddress = null;
                      if (province != null) {
                        newSelectedAddress = Address(
                            countryId: 45,
                            countryName: "中国",
                            regionId: 9,
                            timezone: 'Asia/Shanghai',
                            province: province,
                            city: city,
                            area: county);
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _selectedLocationView(province, city, county),
                          Expanded(child: Container()),
                          _setAtMineButton(newSelectedAddress),
                        ],
                      );
                    });
              });
        },
      ),
    );
  }

  Widget _setAtMineButton(Address? address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 使用ValueListenableBuilder监听选择变化
        ValueListenableBuilder(
            valueListenable:
                context.read<TimezoneLocationViewModel>().myLocationNotifier,
            builder: (ctx, myLocation, _) {
              if (myLocation != null) {
                return SizedBox();
              }
              // 选中的地点是否为我当前的位置
              bool isMine = false;
              if (myLocation != null && address != null) {
                isMine = myLocation.address == address;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlutterSwitch(
                    value: isMine,
                    width: 32,
                    height: 16,
                    padding: 2,
                    toggleSize: 12,
                    activeColor: Colors.blue,
                    onToggle: (bool setIsMine) {
                      // 过是将当前位置设为“我的位置”,需要确保address不为null
                      if (setIsMine) {
                        if (address != null) {
                          // 设置myLocation
                          // 当 widget.myLocationNotifier.value.location == null 时，需要先设置
                          if (widget.myLocationNotifier.value == null) {
                            context
                                .read<TimezoneLocationViewModel>()
                                .updateMyLocation(Location(address: address));
                          } else {
                            // 需要判断是否相同，如果相同则不设置
                            if (widget.myLocationNotifier.value!.address ==
                                address) {
                              return;
                            } else {
                              context
                                  .read<TimezoneLocationViewModel>()
                                  .updateMyLocation(Location(address: address));
                            }
                          }
                        }
                      } else {
                        // 取消“我的位置”
                        // widget.myLocationNotifier.value = null;
                        context
                            .read<TimezoneLocationViewModel>()
                            .updateMyLocation(null);
                      }
                    },
                  ),
                  Text("我的位置"),
                ],
              );
            })
      ],
    );
  }

  Widget _selectedLocationView(
      GeoLocation? province, GeoLocation? city, GeoLocation? county) {
    String addressText = '请选择地区';
    String coordinatesText = '';
    if (province != null) {
      addressText = province.name;
      coordinatesText =
          '经度: ${province.longitude.toStringAsFixed(2)}, 纬度: ${province.latitude.toStringAsFixed(2)}';
    }
    if (city != null) {
      addressText += ' > ${city.name}';
      coordinatesText =
          '经度: ${city.longitude.toStringAsFixed(3)}, 纬度: ${city.latitude.toStringAsFixed(3)}';
    }
    if (county != null) {
      addressText += ' > ${county.name}';
      coordinatesText =
          '经度: ${county.longitude.toStringAsFixed(5)}, 纬度: ${county.latitude.toStringAsFixed(5)}';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          addressText,
          style:
              TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1),
        ),
        if (province != null) ...[
          const SizedBox(height: 4),
          Text(
            coordinatesText,
            style:
                TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSelectionInfoPanel(),
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
        ),
      ],
    );
  }

  /// 构建列表视图
  Widget _buildListsView() {
    return Row(
      children: [
        // 第一部分：省份列表
        Expanded(
          child: FutureBuilder<List<GeoLocation>>(
              future: context
                  .read<GeoLocationRepository>()
                  .listAllByLevel(GeoLevel.province),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('加载失败: ${snapshot.error}'));
                }
                if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(child: Text('没有数据'));
                }

                List<GeoLocation> pList = snapshot.data!;
                return ValueListenableBuilder<GeoLocation?>(
                    valueListenable: _selectedProvince,
                    builder: (ctx, selected, _) {
                      return ListView.builder(
                          controller: ScrollController(),
                          itemCount: pList.length,
                          itemBuilder: (ctx, index) {
                            final p = pList[index];
                            bool isSelected = p.code == selected?.code;
                            return ListTile(
                              title: Text(p.name),
                              selected: isSelected,
                              selectedTileColor: Colors.blue.withAlpha(10),
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: Colors.blue)
                                  : null,
                              onTap: () => _selectProvince(p),
                            );
                          });
                    });
              }),
        ),

        // 分隔线
        Container(width: 1, color: Colors.grey.shade300),

        // 第二部分：城市列表
        Expanded(
            child: ValueListenableBuilder<GeoLocation?>(
                valueListenable: _selectedProvince,
                builder: (ctx, selectedProvince, _) {
                  if (selectedProvince == null) {
                    return const Center(child: Text('请选择省份'));
                  }
                  return FutureBuilder<List<GeoLocation>>(
                      future: context
                          .read<GeoLocationRepository>()
                          .listCitiesByProvince(selectedProvince.code),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('加载失败: ${snapshot.error}'));
                        }
                        if (snapshot.hasData && snapshot.data!.isEmpty) {
                          return const Center(child: Text('没有数据'));
                        }

                        List<GeoLocation> pList = snapshot.data!;
                        return ValueListenableBuilder<GeoLocation?>(
                            valueListenable: _selectedCity,
                            builder: (ctx, selected, _) {
                              return ListView.builder(
                                  controller: ScrollController(),
                                  itemCount: pList.length,
                                  itemBuilder: (ctx, index) {
                                    final p = pList[index];
                                    bool isSelected = selected == null
                                        ? false
                                        : p.code == selected?.code;
                                    return ListTile(
                                      title: Text(p.name),
                                      selected: isSelected,
                                      selectedTileColor:
                                          Colors.blue.withAlpha(10),
                                      trailing: isSelected
                                          ? const Icon(Icons.check,
                                              color: Colors.blue)
                                          : null,
                                      onTap: () => _selectCity(p),
                                    );
                                  });
                            });
                      });
                })),

        // 分隔线
        Container(width: 1, color: Colors.grey.shade300),

        // 第三部分：区县列表
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: _selectedCity,
              builder: (ctx, city, _) {
                if (city == null) {
                  return const Center(child: Text('请选择城市'));
                }
                return FutureBuilder<List<GeoLocation>>(
                    future: context
                        .read<GeoLocationRepository>()
                        .listCountiesByProvince(city.code),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('加载失败: ${snapshot.error}'));
                      }
                      if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return const Center(child: Text('没有数据'));
                      }

                      List<GeoLocation> pList = snapshot.data!;
                      return ValueListenableBuilder<GeoLocation?>(
                          valueListenable: _selectedCounty,
                          builder: (ctx, selected, _) {
                            return ListView.builder(
                                controller: ScrollController(),
                                itemCount: pList.length,
                                itemBuilder: (ctx, index) {
                                  final p = pList[index];
                                  bool isSelected = p.code == selected?.code;
                                  return ListTile(
                                    title: Text(p.name),
                                    selected: isSelected,
                                    selectedTileColor:
                                        Colors.blue.withAlpha(10),
                                    trailing: isSelected
                                        ? const Icon(Icons.check,
                                            color: Colors.blue)
                                        : null,
                                    onTap: () => _selectCounty(p),
                                  );
                                });
                          });
                    });
              }),
        ),
      ],
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
          // controller: widget.scrollController,
          controller: ScrollController(),
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final location = locations[index];
            final isSelected = selectedLocation?.code == location.code;
            return ListTile(
              title: Text(location.name),
              selected: isSelected,
              selectedTileColor: Colors.blue.withValues(alpha: 0.1),
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

  /// 构建错误视图
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('加载数据失败'),
          const SizedBox(height: 16),
          // ElevatedButton(
          //   onPressed: _loadData,
          //   child: const Text('重试'),
          // ),
        ],
      ),
    );
  }
}
