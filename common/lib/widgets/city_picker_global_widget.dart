import 'package:common/datamodel/geo_location.dart';
import 'package:common/datamodel/location.dart';
import 'package:common/datasource/loca_binary/world_country_repository.dart';
import 'package:common/models/sp_location_datamodel.dart';
import 'package:common/viewmodels/timezone_location_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../datasource/loca_binary/country.pb.dart' as pb;
import '../datasource/local/regions.dart';

class CityPickerGlobalWidget extends StatefulWidget {
  Address? initAddress;
  final ValueNotifier<Address?> newSelectedAddressNotifier;
  final ValueNotifier<Location?> myLocationNotifier;
  CityPickerGlobalWidget(
      {super.key,
      required this.newSelectedAddressNotifier,
      required this.myLocationNotifier,
      required this.initAddress});

  @override
  State<CityPickerGlobalWidget> createState() => _CityPickerGlobalWidgetState();
}

class _CityPickerGlobalWidgetState extends State<CityPickerGlobalWidget> {
  final _selectedRegionId = ValueNotifier<int?>(null);
  // final _selectedRegion = ValueNotifier<RegionDataSet?>(null);
  RegionDataSet? _selectedRegion;
  // 当前选中的省份
  final _selectedCountry = ValueNotifier<pb.Country?>(null);
  final _selectedCountryId = ValueNotifier<int?>(null);

  final _selectedState = ValueNotifier<pb.State?>(null);
  final _selectedStateId = ValueNotifier<int?>(null);

  final _selectedCity = ValueNotifier<pb.City?>(null);
  final _selectedCityId = ValueNotifier<int?>(null);

  // ValueNotifier<Address?> get _addressNotifier =>
  //     widget.newSelectedAddressNotifier;

  late final ValueNotifier<Address?> _addressNotifier;

  // 是否正在加载数据
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasError = ValueNotifier<bool>(false);

  TextStyle subtitleStyle = const TextStyle(
      fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal);

  Color selectedColor = Colors.blue;
  @override
  void initState() {
    super.initState();
    // _addressNotifier.value = widget.initAddress;
    if (widget.initAddress != null) {
      _addressNotifier = ValueNotifier<Address?>(widget.initAddress);
      _selectedRegionId.value = widget.initAddress!.regionId;
      _selectedCountryId.value = widget.initAddress!.countryId;
      _selectedStateId.value = int.parse(widget.initAddress!.province.code);
      _selectedCityId.value = int.parse(widget.initAddress!.city!.code);
    } else {
      _addressNotifier = ValueNotifier<Address?>(null);
    }

    _selectedCountry.addListener(() {
      if (_selectedCountry.value == null) {
        if (_addressNotifier.value != null) {
          _addressNotifier.value = null;
        }
      } else {
        if (_selectedCountry.value!.id != _selectedCountryId.value) {
          if (_addressNotifier.value != null) {
            _addressNotifier.value = null;
          }
        }
      }
    });
    _selectedState.addListener(() {
      if (_selectedState.value == null) {
        if (_addressNotifier.value != null) {
          _addressNotifier.value = null;
        }
      } else {
        _addressNotifier.value = generateLocationModel();
      }
    });
    _selectedCity.addListener(() {
      if (_selectedCity.value == null) {
        if (_addressNotifier.value != null) {
          _addressNotifier.value =
              generateLocationModelWithCity(_addressNotifier.value!);
        }
      } else {
        if (_addressNotifier.value != null) {
          _addressNotifier.value =
              generateLocationModelWithCity(_addressNotifier.value!);
        }
      }
    });
    _addressNotifier.addListener(() {
      if (_addressNotifier.value != null) {
        if ([
          233,
          31,
          39,
          11,
          86,
          142,
          14,
          171,
          89,
          114,
          137,
          77,
          158,
          182,
          207,
          230,
          102,
          112,
          146,
          169,
          236,
          51
        ].contains(_addressNotifier.value!.countryId)) {
          // Montreal coordinates
          double latitude = _addressNotifier.value!.coordinates.latitude;
          double longitude = _addressNotifier.value!.coordinates.longitude;
          // final result =
          // mexicoCountryMapper[_addressNotifier.value!.province.name];

          String tz = tzmap.latLngToTimezoneString(latitude, longitude);
          final updatedTimezone =
              _addressNotifier.value!.copyWith(timezone: tz);
          widget.newSelectedAddressNotifier.value = updatedTimezone;
        } else {
          widget.newSelectedAddressNotifier.value = _addressNotifier.value;
        }
      } else {
        widget.newSelectedAddressNotifier.value = _addressNotifier.value;
      }
    });
  }

  handleByEachCountry() {
    if (_addressNotifier.value!.countryId == 233) {
      final result = usaStateToTimezones[_addressNotifier.value!.province.name];
      final updatedTimezone = result == null
          ? _addressNotifier.value
          : _addressNotifier.value!.copyWith(timezone: result.first);
      widget.newSelectedAddressNotifier.value = updatedTimezone;
    } else if (_addressNotifier.value!.countryId == 31) {
      final result = brazilCountryMapper[_addressNotifier.value!.province.name];
      final updatedTimezone = result == null
          ? _addressNotifier.value
          : _addressNotifier.value!.copyWith(timezone: result.first);
      widget.newSelectedAddressNotifier.value = updatedTimezone;
    } else if (_addressNotifier.value!.countryId == 39) {
      final result = canadaCountryMapper[_addressNotifier.value!.province.name];
      final updatedTimezone = result == null
          ? _addressNotifier.value
          : _addressNotifier.value!.copyWith(timezone: result.first);
      widget.newSelectedAddressNotifier.value = updatedTimezone;
    } else if (_addressNotifier.value!.countryId == 11) {
      final result =
          argentinaCountryMapper[_addressNotifier.value!.province.name];
      final updatedTimezone = result == null
          ? _addressNotifier.value
          : _addressNotifier.value!.copyWith(timezone: result.first);
      widget.newSelectedAddressNotifier.value = updatedTimezone;
    } else if (_addressNotifier.value!.countryId == 86) {
      final result =
          greenlandCountryMapper[_addressNotifier.value!.province.name];
      final updatedTimezone = result == null
          ? _addressNotifier.value
          : _addressNotifier.value!.copyWith(timezone: result.first);
      widget.newSelectedAddressNotifier.value = updatedTimezone;
    } else if (_addressNotifier.value!.countryId == 142) {
      final result = mexicoCountryMapper[_addressNotifier.value!.province.name];
      final updatedTimezone = result == null
          ? _addressNotifier.value
          : _addressNotifier.value!.copyWith(timezone: result.first);
      widget.newSelectedAddressNotifier.value = updatedTimezone;
    }
  }

  @override
  void dispose() {
    // _selectedRegion.dispose();
    _selectedCountry.dispose();
    _selectedState.dispose();
    _selectedCity.dispose();

    // _addressNotifier.dispose();
    _isLoading.dispose();
    _hasError.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSelectionInfoPanelWithSetAsMine(),
        Expanded(
          child: _buildListsView(),
        ),
      ],
    );
  }

  Widget _buildSelectionInfoPanelWithSetAsMine() {
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
      child: ValueListenableBuilder<pb.Country?>(
          valueListenable: _selectedCountry,
          builder: (ctx, selectedCountry, _) {
            return ValueListenableBuilder<Address?>(
                valueListenable: _addressNotifier,
                builder: (ctx, address, _) {
                  // 构建地址文本
                  Tuple2<String, String> res =
                      _buildSelectedTextContent(selectedCountry, address);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 使用ValueListenableBuilder监听选择变化
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            res.item1,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                height: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address?.province != null ? res.item2 : "",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                height: 1),
                          ),
                        ],
                      ),
                      // Expanded(child: SizedBox()),
                      ValueListenableBuilder(
                          valueListenable: context
                              .read<TimezoneLocationViewModel>()
                              .myLocationNotifier,
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
                                    if (setIsMine) {
                                      if (address != null) {
                                        // 设置myLocation
                                        // 当 widget.myLocationNotifier.value.location == null 时，需要先设置
                                        if (widget.myLocationNotifier.value ==
                                            null) {
                                          context
                                              .read<TimezoneLocationViewModel>()
                                              .updateMyLocation(
                                                  Location(address: address));
                                        } else {
                                          // 需要判断是否相同，如果相同则不设置
                                          if (widget.myLocationNotifier.value!
                                                  .address ==
                                              address) {
                                            return;
                                          } else {
                                            context
                                                .read<
                                                    TimezoneLocationViewModel>()
                                                .updateMyLocation(
                                                    Location(address: address));
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
                                Text("set as mine"),
                              ],
                            );
                          })
                    ],
                  );
                });
          }),
    );
  }

  Tuple2<String, String> _buildSelectedTextContent(
      pb.Country? selectedCountry, Address? address) {
    String addressText = 'pleace select';
    String coordinatesText = '';
    String? countryName = address?.countryName;
    if (selectedCountry != null) {
      countryName = selectedCountry.name;
    }
    GeoLocation? province = address?.province;
    GeoLocation? city = address?.city;
    GeoLocation? county = address?.area;

    if (countryName != null) {
      addressText = countryName;
    }
    if (province != null) {
      addressText += ' > ${province.name}';
      coordinatesText =
          '经度: ${province.longitude.toStringAsFixed(2)}, 纬度: ${province.latitude.toStringAsFixed(2)}';
    }
    if (city != null) {
      addressText += ' > ${city.name}';
      coordinatesText =
          '经度: ${city.longitude.toStringAsFixed(5)}, 纬度: ${city.latitude.toStringAsFixed(5)}';
    }
    if (county != null) {
      addressText += ' > ${county.name}';
      coordinatesText =
          '经度: ${county.longitude.toStringAsFixed(5)}, 纬度: ${county.latitude.toStringAsFixed(5)}';
    }
    return Tuple2(addressText, coordinatesText);
  }

  /// 构建选择信息面板
  @Deprecated('使用 _buildSelectionInfoPanelWithSetAsMine 代替')
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ValueListenableBuilder<pb.Country?>(
              valueListenable: _selectedCountry,
              builder: (ctx, selectedCountry, _) {
                return ValueListenableBuilder<Address?>(
                    valueListenable: _addressNotifier,
                    builder: (ctx, address, _) {
                      // 构建地址文本
                      String addressText = 'pleace select';
                      String coordinatesText = '';
                      String? countryName = address?.countryName;
                      if (selectedCountry != null) {
                        countryName = selectedCountry.name;
                      }
                      GeoLocation? province = address?.province;
                      GeoLocation? city = address?.city;
                      GeoLocation? county = address?.area;

                      if (countryName != null) {
                        addressText = countryName;
                      }
                      if (province != null) {
                        addressText += ' > ${province.name}';
                        coordinatesText =
                            '经度: ${province.longitude.toStringAsFixed(2)}, 纬度: ${province.latitude.toStringAsFixed(2)}';
                      }
                      if (city != null) {
                        addressText += ' > ${city.name}';
                        coordinatesText =
                            '经度: ${city.longitude.toStringAsFixed(5)}, 纬度: ${city.latitude.toStringAsFixed(5)}';
                      }
                      if (county != null) {
                        addressText += ' > ${county.name}';
                        coordinatesText =
                            '经度: ${county.longitude.toStringAsFixed(5)}, 纬度: ${county.latitude.toStringAsFixed(5)}';
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            addressText,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                height: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            province != null ? coordinatesText : "",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                height: 1),
                          ),
                        ],
                      );
                    });
              }),
          // 使用ValueListenableBuilder监听选择变化

          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget titleWidget() {
    return ValueListenableBuilder(
      valueListenable: _selectedCountry,
      builder: (context, country, _) {
        return ValueListenableBuilder(
            valueListenable: _selectedState,
            builder: (ctx1, state, _) {
              return ValueListenableBuilder(
                  valueListenable: _selectedCity,
                  builder: (ctx2, city, _) {
                    String? regionStr = _selectedRegion?.name;
                    String? countryStr = country?.name;
                    String? stateStr = state?.name;
                    String? coordinates;
                    if (state != null) {
                      coordinates =
                          "(${state.latitude.toStringAsFixed(3)}, ${state.longitude.toStringAsFixed(3)})";
                    }
                    String? cityStr = city?.name;
                    if (city != null) {
                      coordinates =
                          "(${city.latitude.toStringAsFixed(5)}, ${city.longitude.toStringAsFixed(5)})";
                    }
                    TextSpan subAreaSplit = const TextSpan(
                      text: ' > ',
                    );
                    TextStyle titleTextStyle = const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    );
                    TextStyle subTitleTextStyle = const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(style: titleTextStyle, children: [
                            TextSpan(
                              text: regionStr,
                              style: country == null
                                  ? titleTextStyle.copyWith(
                                      color: selectedColor)
                                  : titleTextStyle,
                            ),
                            if (countryStr != null) subAreaSplit,
                            TextSpan(
                              text: countryStr,
                              style: state == null
                                  ? titleTextStyle.copyWith(
                                      color: selectedColor)
                                  : titleTextStyle,
                            ),
                            if (stateStr != null) subAreaSplit,
                            TextSpan(
                              text: stateStr,
                              style: city == null
                                  ? titleTextStyle.copyWith(
                                      color: selectedColor)
                                  : titleTextStyle,
                            ),
                            if (cityStr != null) subAreaSplit,
                            TextSpan(
                              text: cityStr,
                              style: city != null
                                  ? titleTextStyle.copyWith(
                                      color: selectedColor)
                                  : titleTextStyle,
                            ),
                          ]),
                        ),
                        coordinates != null
                            ? RichText(
                                text: TextSpan(
                                    style: subTitleTextStyle,
                                    children: [
                                      TextSpan(text: coordinates),
                                    ]),
                              )
                            : Container(
                                height: 14,
                              )
                      ],
                    );
                  });
            });
      },
    );
  }

  Widget _buildListsView() {
    return Row(
      children: [
        // 第一部分：选择大洲的国家
        SizedBox(
          width: 128,
          child: _buildRegionSelectListView(),
        ),
        // 分隔线
        Container(width: 1, color: Colors.grey.shade300),
        Expanded(
            child: ValueListenableBuilder<int?>(
                valueListenable: _selectedRegionId,
                builder: (ctx, regionId, child) {
                  if (regionId == null) {
                    return const Center(child: Text('请先选择大洲'));
                  }
                  return _buildCountrySelectListView(regionId);
                })),
        // 分隔线
        Container(width: 1, color: Colors.grey.shade300),
        Expanded(child: _buildStateSelectListView()),
        // 分隔线
        Container(width: 1, color: Colors.grey.shade300),
        Expanded(child: _buildCitySelectListView()),
      ],
    );
  }

  Widget _buildStateSelectListView() {
    return ValueListenableBuilder<int?>(
        valueListenable: _selectedCountryId,
        builder: (context, country, child) {
          if (country == null) {
            return const Center(child: Text('请先选择国家'));
          }
          return StreamBuilder(
              stream: context
                  .read<WorldCountryRepository>()
                  .listStatesByCountryId(
                      _selectedRegionId.value!, _selectedCountryId.value!)
                  .asStream(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return const Center(child: Text('这个国家没有省份'));
                }
                var states = snapshot.data!;
                return ValueListenableBuilder<int?>(
                    valueListenable: _selectedStateId,
                    builder: (ctx, stateId, child) {
                      return ListView.builder(
                          itemCount: states.length,
                          itemBuilder: (context, index) {
                            final state = states[index];
                            bool isSelected = stateId == state.id;
                            return ListTile(
                                title: Text(state.name,
                                    style: TextStyle(
                                        color: isSelected
                                            ? selectedColor
                                            : Colors.black87)),
                                subtitle: Text(
                                  "(${state.latitude.toStringAsFixed(3)}, ${state.longitude.toStringAsFixed(3)})",
                                  style: isSelected
                                      ? subtitleStyle.copyWith(
                                          color: Colors.black87)
                                      : subtitleStyle,
                                ),
                                selected: isSelected,
                                onTap: () {
                                  // 清空下级选择
                                  _selectedState.value = state;
                                  _selectedStateId.value = state.id;
                                  _selectedCity.value = null;
                                  _selectedCityId.value = null;
                                });
                          });
                    });
              });
        });
  }

  Widget _buildCitySelectListView() {
    return ValueListenableBuilder<int?>(
        valueListenable: _selectedStateId,
        builder: (context, stateId, child) {
          if (stateId == null) {
            return const Center(child: Text('请先选择省份'));
          }
          return StreamBuilder(
              stream: context
                  .read<WorldCountryRepository>()
                  .listCitiesByStateId(_selectedRegionId.value!,
                      _selectedCountryId.value!, _selectedStateId.value!)
                  .asStream(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return const Center(child: Text('这个省份没有城市'));
                }
                var cities = snapshot.data!;
                return ValueListenableBuilder(
                    valueListenable: _selectedCityId,
                    builder: (ctx, cityId, child) {
                      return ListView.builder(
                          itemCount: cities.length,
                          itemBuilder: (context, index) {
                            final city = cities[index];
                            bool isSelected = cityId == city.id;
                            return ListTile(
                                title: Text(city.name,
                                    style: TextStyle(
                                        color: isSelected
                                            ? selectedColor
                                            : Colors.black87)),
                                subtitle: Text(
                                  "(${city.latitude.toStringAsFixed(5)}, ${city.longitude.toStringAsFixed(5)})",
                                  style: isSelected
                                      ? subtitleStyle.copyWith(
                                          color: Colors.black87)
                                      : subtitleStyle,
                                ),
                                selected: isSelected,
                                onTap: () {
                                  // 清空下级选择
                                  _selectedCity.value = city;
                                  _selectedCityId.value = city.id;
                                });
                          });
                    });
              });
        });
  }

  Widget _buildCountrySelectListView(int regionId) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return ValueListenableBuilder<bool>(
          valueListenable: _hasError,
          builder: (context, hasError, child) {
            if (hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('加载失败'),
                    TextButton(
                      onPressed: () {
                        // 重新加载数据的逻辑
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }
            return StreamBuilder(
              stream: context
                  .read<WorldCountryRepository>()
                  .listCountriesByRegionId(regionId)
                  .asStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data == null ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(child: Text('暂无数据'));
                }

                final countries = snapshot.data!;

                return ValueListenableBuilder(
                    valueListenable: _selectedCountryId,
                    builder: (ctx, countryId, _) {
                      // if (countryId != null) {
                      //   _selectedCountry.value =
                      //       countries.where((c) => c.id == countryId).first;
                      // }
                      return ListView.builder(
                        itemCount: countries.length,
                        itemBuilder: (context, index) {
                          final country = countries[index];
                          bool isSelected = countryId == country.id;
                          return ListTile(
                            title: Text(country.name,
                                style: TextStyle(
                                    color: isSelected
                                        ? selectedColor
                                        : Colors.black87)),
                            subtitle: RichText(
                                text: TextSpan(
                                    text: "TZ: (",
                                    style: subtitleStyle,
                                    children: [
                                  TextSpan(
                                      text: country.timezones
                                          .map((tx) => tx.zoneName)
                                          .join(", ")),
                                  TextSpan(text: ")")
                                ])),
                            selected: isSelected,
                            onTap: () {
                              _selectedCountry.value = country;
                              _selectedCountryId.value = country.id;
                              _selectedState.value = null;
                              _selectedStateId.value = null;
                              _selectedCity.value = null;
                              _selectedCityId.value = null;
                            },
                          );
                        },
                      );
                    });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRegionSelectListView() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder<bool>(
          valueListenable: _hasError,
          builder: (context, hasError, child) {
            if (hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('加载失败'),
                    TextButton(
                      onPressed: () {
                        // 重新加载数据的逻辑
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }
            return StreamBuilder(
              stream: context
                  .read<WorldCountryRepository>()
                  .listAllRegion()
                  .asStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data == null ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(child: Text('暂无数据'));
                }

                final regions = snapshot.data!;
                if (_selectedStateId.value != null) {
                  _selectedRegion = regions
                      .firstWhere((tx) => tx.id == _selectedRegionId.value);
                }
                return ValueListenableBuilder(
                    valueListenable: _selectedRegionId,
                    builder: (ctx, regionId, _) {
                      return ListView.builder(
                        itemCount: regions.length,
                        itemBuilder: (context, index) {
                          final region = regions[index];
                          bool isSelected = regionId == region.id;
                          return ListTile(
                            title: Text(
                              region.name,
                              style: TextStyle(
                                  color: isSelected
                                      ? selectedColor
                                      : Colors.black87),
                            ),
                            selected: isSelected,
                            onTap: () {
                              if (region.id != _selectedRegion?.id) {
                                _addressNotifier.value = null;
                              }
                              _selectedRegionId.value = region.id;
                              _selectedRegion = region;
                              _selectedCountry.value = null;
                              _selectedCountryId.value = null;
                              _selectedState.value = null;
                              _selectedStateId.value = null;
                              _selectedCity.value = null;
                              _selectedCityId.value = null;
                            },
                          );
                        },
                      );
                    });
              },
            );
          },
        );
      },
    );
  }

  Address? generateLocationModel() {
    // 确定至少state一级及之前不为空

    if (_selectedRegion == null ||
        _selectedCountry.value == null ||
        _selectedState.value == null) {
      return null;
    }
    RegionDataSet? region = _selectedRegion;

    pb.Country? country = _selectedCountry.value;
    pb.State? state = _selectedState.value;

    // 生成Location
    Address address = Address(
      countryName: country!.name,
      countryId: country.id,
      regionId: region!.id,
      timezone: country.timezones.first.zoneName,
      province: GeoLocation(
          code: state!.id.toString(),
          parentCode: country.id.toString(),
          level: GeoLevel.province,
          name: state.name,
          latitude: state.latitude,
          longitude: state.longitude),
      city: null,
    );
    return address;
  }

  Address? generateLocationModelWithCity(Address address) {
    pb.City? city = _selectedCity.value;
    if (city == null) {
      // return address.copyWith(city: null);
      return address.removeArea(); // 不修改city，保持原有的selec
    }
    final cityAddress = GeoLocation(
      code: city.id.toString(),
      name: city.name,
      latitude: city.latitude,
      longitude: city.longitude,
      parentCode: address.province.code,
      level: GeoLevel.city,
    );
    return address.copyWith(city: cityAddress);
  }
}

final Map<String, List<String>> usaStateToTimezones = {
  'Alabama': ['America/Chicago'], // 主要为中部时间
  'Alaska': [
    'America/Anchorage', // 阿拉斯加大部分地区
    'America/Juneau',
    'America/Sitka',
    'America/Nome',
    'America/Yakutat',
    'America/Adak' // 阿留申群岛
  ],
  'Arizona': [
    'America/Phoenix', // 大部分地区，不使用夏令时 (MST all year)
    'America/Denver' // 纳瓦霍族保留地使用山区时间并遵守夏令时
  ],
  'Arkansas': ['America/Chicago'],
  'California': ['America/Los_Angeles'],
  'Colorado': ['America/Denver'],
  'Connecticut': ['America/New_York'],
  'Delaware': ['America/New_York'],
  'Florida': [
    'America/New_York', // 东部时间区 (大部分)
    'America/Chicago' // 中部时间区 (西部狭长地带)
  ],
  'Georgia': ['America/New_York'],
  'Hawaii': ['Pacific/Honolulu'], // 不使用夏令时
  'Idaho': [
    'America/Denver', // 山区时间 (南部)
    'America/Los_Angeles' // 太平洋时间 (北部)
  ],
  'Illinois': ['America/Chicago'],
  'Indiana': [
    'America/New_York', // 东部时间 (大部分)
    'America/Chicago' // 中部时间 (西北和西南部角落)
    // 注意: Indiana 的时区规则比较复杂，具体到县会有差异
    // 'America/Indiana/Indianapolis', 'America/Indiana/Knox', 等也是有效的
  ],
  'Iowa': ['America/Chicago'],
  'Kansas': [
    'America/Chicago', // 中部时间 (大部分)
    'America/Denver' // 山区时间 (西部少数县)
  ],
  'Kentucky': [
    'America/New_York', // 东部时间 (东半部)
    'America/Chicago' // 中部时间 (西半部)
  ],
  'Louisiana': ['America/Chicago'],
  'Maine': ['America/New_York'],
  'Maryland': ['America/New_York'],
  'Massachusetts': ['America/New_York'],
  'Michigan': [
    'America/New_York', // 东部时间 (大部分)
    'America/Chicago' // 中部时间 (邻近威斯康星州的少数县)
    // 'America/Detroit' 是 America/New_York 的一个常用别名
  ],
  'Minnesota': ['America/Chicago'],
  'Mississippi': ['America/Chicago'],
  'Missouri': ['America/Chicago'],
  'Montana': ['America/Denver'],
  'Nebraska': [
    'America/Chicago', // 中部时间 (大部分)
    'America/Denver' // 山区时间 (西部)
  ],
  'Nevada': ['America/Los_Angeles'], // 大部分是太平洋时间，有些小区域在山区时间但通常城市会遵循州的主要时区
  'New Hampshire': ['America/New_York'],
  'New Jersey': ['America/New_York'],
  'New Mexico': ['America/Denver'],
  'New York': ['America/New_York'],
  'North Carolina': ['America/New_York'],
  'North Dakota': [
    'America/Chicago', // 中部时间 (大部分)
    'America/Denver' // 山区时间 (西南部)
  ],
  'Ohio': ['America/New_York'],
  'Oklahoma': ['America/Chicago'],
  'Oregon': [
    'America/Los_Angeles', // 太平洋时间 (大部分)
    'America/Denver' // 山区时间 (马卢尔县的一小部分)
    // 'America/Boise' (爱达荷州) 有时也用于临近的山区时间区域
  ],
  'Pennsylvania': ['America/New_York'],
  'Rhode Island': ['America/New_York'],
  'South Carolina': ['America/New_York'],
  'South Dakota': [
    'America/Chicago', // 中部时间 (东半部)
    'America/Denver' // 山区时间 (西半部)
  ],
  'Tennessee': [
    'America/New_York', // 东部时间 (大部分东部地区)
    'America/Chicago' // 中部时间 (大部分中部和西部地区)
  ],
  'Texas': [
    'America/Chicago', // 中部时间 (大部分)
    'America/Denver' // 山区时间 (最西部，如 El Paso)
  ],
  'Utah': ['America/Denver'],
  'Vermont': ['America/New_York'],
  'Virginia': ['America/New_York'],
  'Washington': ['America/Los_Angeles'],
  'West Virginia': ['America/New_York'],
  'Wisconsin': ['America/Chicago'],
  'Wyoming': ['America/Denver'],
  // 你可以根据需要添加更多州或地区
};
Map<String, List<String>> brazilCountryMapper = {
  // Fernando de Noronha Time (UTC-02:00)
  "Fernando de Noronha": [
    "America/Noronha"
  ], // Islands (Fernando de Noronha archipelago)

  // Brasilia Time (UTC-03:00)
  "Alagoas": ["America/Maceio"],
  "Amapá": ["America/Belem"],
  "Bahia": ["America/Bahia"],
  "Ceará": ["America/Fortaleza"],
  "Distrito Federal": ["America/Sao_Paulo"], // Federal District
  "Espírito Santo": ["America/Sao_Paulo"],
  "Goiás": ["America/Sao_Paulo"],
  "Maranhão": ["America/Fortaleza"],
  "Minas Gerais": ["America/Sao_Paulo"],
  "Pará (East)": ["America/Belem"],
  "Paraíba": ["America/Fortaleza"],
  "Paraná": ["America/Sao_Paulo"],
  "Pernambuco": ["America/Recife"],
  "Piauí": ["America/Fortaleza"],
  "Rio de Janeiro": ["America/Sao_Paulo"],
  "Rio Grande do Norte": ["America/Fortaleza"],
  "Rio Grande do Sul": ["America/Sao_Paulo"],
  "Santa Catarina": ["America/Sao_Paulo"],
  "São Paulo": ["America/Sao_Paulo"],
  "Sergipe": ["America/Maceio"],
  "Tocantins": ["America/Araguaina"],
  "Pará (West)": [
    "America/Santarem"
  ], // Western part of Pará state can observe Brasilia Time

  // Amazon Time (UTC-04:00)
  "Amazonas (East)": ["America/Manaus"], // Eastern part of Amazonas state
  "Mato Grosso": ["America/Cuiaba"],
  "Mato Grosso do Sul": ["America/Campo_Grande"],
  "Rondônia": ["America/Porto_Velho"],
  "Roraima": ["America/Boa_Vista"],
  "Pará (Santarem region)": [
    "America/Santarem"
  ], // While mostly BRT, some sources indicate Santarem uses AMT

  // Acre Time (UTC-05:00)
  "Acre": ["America/Rio_Branco"],
  "Amazonas (West)": ["America/Eirunepe"], // Western part of Amazonas state
};
Map<String, List<String>> argentinaCountryMapper = {
  // Argentina generally observes UTC-03:00 year-round.
  // Historically, some provinces had different time zone behaviors or observed DST.
  // The IANA time zone database often uses specific city names within a province
  // to represent the province's time zone.

  "City of Buenos Aires": ["America/Argentina/Buenos_Aires"],
  "Buenos Aires": ["America/Argentina/Buenos_Aires"],
  "Catamarca": ["America/Argentina/Catamarca"],
  "Chaco": ["America/Argentina/Cordoba"],
  "Chubut": ["America/Argentina/Catamarca"],
  "Córdoba": ["America/Argentina/Cordoba"],
  "Corrientes": ["America/Argentina/Cordoba"],
  "Entre Ríos": ["America/Argentina/Cordoba"],
  "Formosa": ["America/Argentina/Cordoba"],
  "Jujuy": ["America/Argentina/Jujuy"],
  "La Pampa": ["America/Argentina/Salta"], // Often grouped with Salta TZ
  "La Rioja": ["America/Argentina/La_Rioja"],
  "Mendoza": ["America/Argentina/Mendoza"],
  "Misiones": ["America/Argentina/Cordoba"],
  "Neuquén": ["America/Argentina/Salta"], // Often grouped with Salta TZ
  "Río Negro": ["America/Argentina/Salta"], // Often grouped with Salta TZ
  "Salta": ["America/Argentina/Salta"],
  "San Juan": ["America/Argentina/San_Juan"],
  "San Luis": ["America/Argentina/San_Luis"],
  "Santa Cruz": ["America/Argentina/Rio_Gallegos"],
  "Santa Fe": ["America/Argentina/Cordoba"],
  "Santiago del Estero": ["America/Argentina/Cordoba"],
  "Tierra del Fuego": ["America/Argentina/Ushuaia"],
  "Tucumán": ["America/Argentina/Tucuman"],
};

Map<String, List<String>> mexicoCountryMapper = {
  // Zona Noroeste (Northwest Zone) - UTC-08:00 (Standard)
  "Baja California": [
    "America/Tijuana"
  ], // Observes DST (aligns with US Pacific Time)

  // Zona Pacífico (Pacific Zone) - UTC-07:00 (Standard)
  "Baja California Sur": ["America/Mazatlan"],
  "Chihuahua (US border - west)": [
    "America/Ciudad_Juarez"
  ], // Observes DST (aligns with US Mountain Time)
  "Nayarit": ["America/Mazatlan"],
  "Sinaloa": ["America/Mazatlan"],
  "Sonora": ["America/Hermosillo"], // Does not observe DST

  // Zona Centro (Central Zone) - UTC-06:00 (Standard)
  "Aguascalientes": ["America/Mexico_City"],
  "Chihuahua": ["America/Chihuahua"], // Does not observe DST (as of 2022)
  "Coahuila": [
    "America/Mexico_City"
  ], // Some border municipalities follow US DST. Default to Mexico City.
  "Colima": ["America/Mexico_City"],
  "Durango": ["America/Mexico_City"],
  "Guanajuato": ["America/Mexico_City"],
  "Guerrero": ["America/Mexico_City"],
  "Hidalgo": ["America/Mexico_City"],
  "Jalisco": ["America/Mexico_City"],
  "Estado de México": ["America/Mexico_City"],
  "Ciudad de México": [
    "America/Mexico_City"
  ], // Does not observe DST (as of 2022)
  "Michoacán de Ocampo": ["America/Mexico_City"],
  "Morelos": ["America/Mexico_City"],
  "Nuevo León": [
    "America/Monterrey"
  ], // Some border municipalities follow US DST. Default to Monterrey/Mexico City.
  "Oaxaca": ["America/Mexico_City"],
  "Puebla": ["America/Mexico_City"],
  "Querétaro": ["America/Mexico_City"],
  "San Luis Potosí": ["America/Mexico_City"],
  "Tamaulipas (US border)": [
    "America/Matamoros"
  ], // Observes DST (aligns with US Central Time)
  "Tamaulipas": ["America/Mexico_City"], // Default to Mexico City
  "Tlaxcala": ["America/Mexico_City"],
  "Veracruz": ["America/Mexico_City"],
  "Zacatecas": ["America/Mexico_City"],
  "Ojinaga (Chihuahua, US border - east)": [
    "America/Ojinaga"
  ], // Observes DST (aligns with US Central Time)

  // Zona Sureste (Southeast Zone) - UTC-05:00 (Standard)
  "Campeche": ["America/Cancun"],
  "Quintana Roo": ["America/Cancun"], // Does not observe DST
  "Tabasco": ["America/Cancun"],
  "Yucatán": ["America/Cancun"],
};

Map<String, List<String>> greenlandCountryMapper = {
  // Thule Air Base / Pituffik area (UTC-04:00 Standard, UTC-03:00 Daylight)
  // This area follows North American DST rules.
  "Avannaata (Pituffik/Thule Air Base)": ["America/Thule"],

  // West Greenland Time (UTC-02:00 Standard, UTC-01:00 Daylight)
  // This covers most populated areas, including the capital Nuuk.
  // Note: Greenland's DST dates are different from North America/Europe.
  "Sermersooq (Nuuk area)": ["America/Nuuk"],
  "Kujalleq": ["America/Nuuk"],
  "Qeqqata": ["America/Nuuk"],
  "Qeqertalik": ["America/Nuuk"],
  "Avannaata": ["America/Nuuk"],

  // East Greenland Time (UTC-00:00 Standard, UTC+00:00 Daylight)
  "Northeast Greenland National Park": [
    "Atlantic/Jan_Mayen"
  ], // Danmarkshavn often uses GMT/UTC+00:00 year-round (no DST)
  "Sermersooq": [
    "America/Scoresbysund"
  ], // This area observes GMT-1 (standard) / GMT+0 (DST)
};
Map<String, List<String>> canadaCountryMapper = {
  // Pacific Time (UTC-08:00 Standard, UTC-07:00 Daylight)
  "British Columbia": ["America/Vancouver"],
  "Yukon": [
    "America/Whitehorse"
  ], // Note: Yukon moved to permanent MST in 2020 (UTC-7) but is often still listed with Pacific time zones

  // Mountain Time (UTC-07:00 Standard, UTC-06:00 Daylight)
  "Alberta": ["America/Edmonton"],
  "Northwest Territories": ["America/Yellowknife"],
  "Nunavut": ["America/Cambridge_Bay"],
  // "Nunavut": ["America/Rankin_Inlet"],
  "British Columbia (northeast)": [
    "America/Dawson_Creek"
  ], // Some regions of BC
  "Saskatchewan (Lloydminster)": [
    "America/Dawson_Creek"
  ], // Lloydminster observes MDT

  // Central Time (UTC-06:00 Standard, UTC-05:00 Daylight)
  "Manitoba": ["America/Winnipeg"],
  "Saskatchewan": [
    "America/Regina"
  ], // Most of Saskatchewan observes CST year-round, no DST

  // Eastern Time (UTC-05:00 Standard, UTC-04:00 Daylight)
  "Ontario": ["America/Toronto"],
  "Quebec": ["America/Montreal"],

  // Atlantic Time (UTC-04:00 Standard, UTC-03:00 Daylight)
  "New Brunswick": ["America/Moncton"],
  "Nova Scotia": ["America/Halifax"],
  "Prince Edward Island": ["America/Halifax"],
  "Labrador": ["America/Goose_Bay"],
  "Quebec (Specific areas)": ["America/Halifax"], // Specific areas in Quebec

  // Newfoundland Time (UTC-03:30 Standard, UTC-02:30 Daylight)
  "Newfoundland": ["America/St_Johns"],
  "Labrador (southeastern)": ["America/St_Johns"],
};
