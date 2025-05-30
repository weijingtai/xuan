import 'package:common/widgets/city_picker_chinese_widget.dart';
import 'package:common/widgets/city_picker_global_widget.dart';
import 'package:flutter/material.dart';

import '../datamodel/location.dart';
import '../models/sp_location_datamodel.dart';

/// 显示城市选择器底部弹窗
Future<Address?> showCityPickerBottomSheet({
  required BuildContext context,
  required Address initAddress,
  required ValueNotifier<Location?> myLocationNotifier,
}) {
  // 检查 initLocation, 当initLocation 不是中国时，跳转制全球选择器

  return showModalBottomSheet<Address>(
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
          initAddress: initAddress,
          myLocationNotifier: myLocationNotifier,
        );
      },
    ),
  );
}

/// 城市选择器底部弹窗
class CityPickerBottomSheet extends StatefulWidget {
  /// 初始选中的地理位置编码
  // final String? initialCode;
  final Address initAddress;

  /// 滚动控制器
  final ValueNotifier<Location?> myLocationNotifier;

  const CityPickerBottomSheet({
    Key? key,
    required this.initAddress,
    required this.myLocationNotifier,
  }) : super(key: key);

  @override
  State<CityPickerBottomSheet> createState() => _CityPickerBottomSheetState();
}

class _CityPickerBottomSheetState extends State<CityPickerBottomSheet> {
  late final PageController _pageController;

  final ValueNotifier<Address?> _newSelectedAddressNotifier =
      ValueNotifier(null);

  Address? insideNation;
  Address? globalNation;

  late final ValueNotifier<bool> _isNation;
  // bool _isLoading = true;

  // 是否发生错误
  // bool _hasError = false;

  @override
  void initState() {
    super.initState();

    if (widget.initAddress.countryId == 45 &&
        widget.initAddress.regionId == 9) {
      _isNation = ValueNotifier(true);
      _pageController = PageController(initialPage: 0);
      insideNation = widget.initAddress;
    } else {
      _isNation = ValueNotifier(false);
      _pageController = PageController(initialPage: 1);
      globalNation = widget.initAddress;
    }
    _newSelectedAddressNotifier.addListener(() {
      if (_newSelectedAddressNotifier.value != null) {
        Address newSelectedAddress = _newSelectedAddressNotifier.value!;
        if (newSelectedAddress.regionId == 9 &&
            newSelectedAddress.countryId == 45) {
          insideNation = newSelectedAddress;
        } else {
          globalNation = newSelectedAddress;
        }
      }
    });
  }

  @override
  void dispose() {
    _isNation.dispose();
    _newSelectedAddressNotifier.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// 完成选择
  void _finishSelection() {
    if (_newSelectedAddressNotifier.value == null) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop(_newSelectedAddressNotifier.value);
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
          Expanded(
              child: PageView(
                  // controller: widget.scrollController,
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                CityPickerChineseWidget(
                  initAddress: insideNation,
                  // scrollController: widget.scrollController,
                  selectedAddressNotifier: _newSelectedAddressNotifier,
                  myLocationNotifier: widget.myLocationNotifier,
                ),
                CityPickerGlobalWidget(
                  newSelectedAddressNotifier: _newSelectedAddressNotifier,
                  initAddress: globalNation,
                  myLocationNotifier: widget.myLocationNotifier,
                )
              ]))
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
              SizedBox(
                  height: 28,
                  width: 128,
                  child: ValueListenableBuilder(
                      valueListenable: _isNation,
                      builder: (ctx, isNation, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                _isNation.value = true;
                                _pageController.animateToPage(0,
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.easeInOut);
                              },
                              child: AnimatedDefaultTextStyle(
                                child: Text(
                                  "国内城市",
                                ),
                                style: _isNation.value
                                    ? TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        height: 1)
                                    : TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 12,
                                        height: 1),
                                duration: Duration(milliseconds: 200),
                              ),
                            ),
                            SizedBox(width: 4),
                            InkWell(
                                onTap: () {
                                  _isNation.value = false;
                                  _pageController.animateToPage(1,
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeInOut);
                                },
                                child: AnimatedDefaultTextStyle(
                                  child: Text("全球城市"),
                                  style: _isNation.value
                                      ? TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 12,
                                          height: 1)
                                      : TextStyle(
                                          color: Colors.black87,
                                          fontSize: 18,
                                          height: 1),
                                  duration: Duration(milliseconds: 200),
                                ))
                          ],
                        );
                      })),
              Row(children: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "取消",
                      style: TextStyle(color: Colors.grey),
                    )),
                ValueListenableBuilder<Address?>(
                    valueListenable: _newSelectedAddressNotifier,
                    builder: (ctx, address, _) {
                      return TextButton(
                          onPressed: address?.lowestGeoLocation == null
                              ? null
                              : _finishSelection,
                          child: Text(
                            "完成",
                            style: TextStyle(
                                color: address?.lowestGeoLocation == null
                                    ? Colors.grey
                                    : Colors.blue),
                          ));
                    })
              ])
            ],
          ),
        ),
      ],
    );
  }
}
