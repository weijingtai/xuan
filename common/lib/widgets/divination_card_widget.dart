import 'package:common/datamodel/divination_request_info_datamodel.dart';
import 'package:common/datamodel/divination_type_data_model.dart';
import 'package:common/viewmodels/dev_enter_page_view_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/divination_meta_info.dart';
import 'destiny_question_widget.dart';
import 'divination_question_widget.dart';

class DivinationCardWidget extends StatefulWidget {
  final DevEnterPageViewModel enterPageViewModel;
  const DivinationCardWidget({Key? key, required this.enterPageViewModel})
      : super(key: key);

  @override
  State<DivinationCardWidget> createState() => _DivinationCardWidgetState();
}

class _DivinationCardWidgetState extends State<DivinationCardWidget> {
  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier(false);

  final PageController _pageController = PageController();

  double smallRadius = 8;
  double largeRadius = 24;
  DevEnterPageViewModel get viewModel => widget.enterPageViewModel;
  Duration duration = Duration(milliseconds: 600);

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    context
        .read<DevEnterPageViewModel>()
        .selectedDivinaionTypeNotifier
        .addListener(() {
      if (context
                  .read<DevEnterPageViewModel>()
                  .divinationTypesListNotifier
                  .value !=
              null &&
          context
                  .read<DevEnterPageViewModel>()
                  .selectedDivinaionTypeNotifier
                  .value !=
              null) {
        var index = context
            .read<DevEnterPageViewModel>()
            .divinationTypesListNotifier
            .value!
            .indexWhere((element) =>
                element.uuid ==
                context
                    .read<DevEnterPageViewModel>()
                    .selectedDivinaionTypeNotifier
                    .value!
                    .uuid);
        _pageController.animateToPage(index,
            duration: duration, curve: Curves.linear);
      }
    });
    // widget.enterPageViewModel.selectedDivinationTypeNotifier.addListener(() {
    //   _pageController.animateToPage(
    //       widget.enterPageViewModel.selectedDivinationTypeNotifier.value
    //           .pageIndex,
    //       duration: duration,
    //       curve: Curves.linear);
    // });
  }

  @override
  void dispose() {
    _isExpandedNotifier.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 计算合适的尺寸
    // 获取屏幕尺寸信息
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final contentWidth = screenWidth > 600 ? 512.0 : screenWidth * 0.9;
    final contentPadding = screenWidth > 600 ? 16.0 : 8.0;

    return ValueListenableBuilder(
        valueListenable: viewModel.divinationTypesListNotifier,
        builder: (ctx, types, child) {
          if (types == null || types.isEmpty) {
            return buildDefault(contentWidth, contentPadding);
          }
          return buildRealTime(contentWidth, contentPadding, types);
        });
  }

  Widget _buildDivinationTypeTabBarButton(DivinationTypeDataModel type,
      double smallRadius, DivinationTypeDataModel? selected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      height: 32,
      width: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(smallRadius),
          topRight: Radius.circular(smallRadius),
        ),
        boxShadow: selected == type
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  spreadRadius: 2,
                  offset: Offset(2, 2),
                ),
              ]
            : [],
      ),
      child: Material(
        child: Ink(
          child: InkWell(
            splashColor: Colors.blue.withAlpha(40),
            highlightColor: Colors.blue.withAlpha(40),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(smallRadius),
              topRight: Radius.circular(smallRadius),
            ),
            onTap: () {
              // onDivinationTypeTap(type);
              context.read<DevEnterPageViewModel>().selectDivinationType(type);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 400),
              alignment: Alignment.center,
              child: Text(
                _getDivinationTypeTabBarButtonText(type),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              decoration: BoxDecoration(
                color: selected == type ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(smallRadius),
                  topRight: Radius.circular(smallRadius),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarButton(
      DivinationType type, double smallRadius, DivinationType selected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      height: 32,
      width: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(smallRadius),
          topRight: Radius.circular(smallRadius),
        ),
        boxShadow: selected == type
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  spreadRadius: 2,
                  offset: Offset(2, 2),
                ),
              ]
            : [],
      ),
      child: Material(
        child: Ink(
          child: InkWell(
            splashColor: Colors.blue.withValues(alpha: 0.3),
            highlightColor: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(smallRadius),
              topRight: Radius.circular(smallRadius),
            ),
            // onTap: () => onDivinationTypeTap(type),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 400),
              alignment: Alignment.center,
              child: Text(
                _getTabBarButtonText(type),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              decoration: BoxDecoration(
                color: selected == type ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(smallRadius),
                  topRight: Radius.circular(smallRadius),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRealTime(double contentWidth, double contentPadding,
      List<DivinationTypeDataModel> types) {
    return Container(
        width: contentWidth,
        padding: EdgeInsets.symmetric(
            horizontal: contentPadding, vertical: contentPadding),
        child: ValueListenableBuilder<DivinationTypeDataModel?>(
            valueListenable: context
                .read<DevEnterPageViewModel>()
                .selectedDivinaionTypeNotifier,
            builder: (ctx, selecetedDivinationType, _) {
              // debugPrint("buildRealTime: $selecetedDivinationType");
              return ValueListenableBuilder(
                valueListenable: context
                    .read<DevEnterPageViewModel>()
                    .divinationTypesListNotifier,
                builder: (ctx, types, child) {
                  if (types == null || types.isEmpty) {
                    return SizedBox(
                      height: 32,
                    );
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Listener(
                        onPointerSignal: (event) {
                          // 监听鼠标滚轮事件[6,8](@ref)
                          if (event is PointerScrollEvent) {
                            _scrollController.animateTo(
                              _scrollController.offset +
                                  event.scrollDelta.dy * 5, // 调整滚轮灵敏度
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        child: GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            // 处理水平拖动手势[7,8](@ref)
                            _scrollController.jumpTo(
                                _scrollController.offset - details.delta.dx);
                          },
                          child: Container(
                              height: 32,
                              width: contentWidth - (contentPadding * 2),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                // physics: ClampingScrollPhysics(),
                                physics: BouncingScrollPhysics(
                                  parent: NeverScrollableScrollPhysics(),
                                  decelerationRate: ScrollDecelerationRate.fast,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: types
                                      .map((e) =>
                                          _buildDivinationTypeTabBarButton(
                                              e,
                                              smallRadius,
                                              selecetedDivinationType))
                                      .toList(),
                                ),
                              )),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _isExpandedNotifier,
                        builder: (ctx, isExpanded, child) {
                          double height = 160;
                          if (selecetedDivinationType?.name == "命理") {
                            height = 160;
                          } else {
                            height = isExpanded ? 340 : 180;
                          }
                          return AnimatedContainer(
                            alignment: selecetedDivinationType?.name ==
                                    DivinationType.destiny.name
                                ? Alignment.center
                                : Alignment.topCenter,
                            duration: Duration(milliseconds: 300),
                            height: height,
                            width: contentWidth - (contentPadding * 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(largeRadius),
                                bottomLeft: Radius.circular(largeRadius),
                                bottomRight: Radius.circular(largeRadius),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  offset: Offset(1, 2),
                                  blurRadius: 2,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: contentPadding),
                            child: PageView(
                              controller: _pageController,
                              clipBehavior: Clip.antiAlias,
                              physics: BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                                decelerationRate: ScrollDecelerationRate.fast,
                              ),
                              onPageChanged: (index) {
                                // viewModel.selectedDivinationTypeNotifier.value =
                                //     index == 0
                                //         ? DivinationType.destiny
                                //         : DivinationType.divination;
                              },
                              children: [
                                Container(
                                  // width: 640,
                                  height: height,
                                  child: _buildDestinyQuestion(),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 4),
                                  child: _buildDivinationQuestion(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            }));
  }

  Widget buildDefault(
    double contentWidth,
    double contentPadding,
  ) {
    return Container(
      width: contentWidth,
      padding: EdgeInsets.symmetric(
          horizontal: contentPadding, vertical: contentPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: contentWidth - (contentPadding * 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: DivinationType.values
                  .map((e) => _buildTabBarButton(
                      e, smallRadius, DivinationType.destiny))
                  .toList(),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _isExpandedNotifier,
            builder: (ctx, isExpanded, child) {
              double height = 160;
              return AnimatedContainer(
                alignment: Alignment.center,
                duration: Duration(milliseconds: 300),
                height: height,
                width: contentWidth - (contentPadding * 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(largeRadius),
                    bottomLeft: Radius.circular(largeRadius),
                    bottomRight: Radius.circular(largeRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      offset: Offset(1, 2),
                      blurRadius: 2,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: contentPadding),
                child: PageView(
                  controller: _pageController,
                  clipBehavior: Clip.antiAlias,
                  physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                    decelerationRate: ScrollDecelerationRate.fast,
                  ),
                  onPageChanged: (index) {
                    // viewModel.selectedDivinationTypeNotifier.value =
                    //     index == 0
                    //         ? DivinationType.destiny
                    //         : DivinationType.divination;
                  },
                  children: [
                    Container(
                      // width: 640,
                      height: height,
                      child: _buildDestinyQuestion(),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 4),
                      child: _buildDivinationQuestion(),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  // void onDivinationTypeTap(DivinationType type) {
  //   viewModel.divinationTypeChanged(type);
  // }

  String _getDivinationTypeTabBarButtonText(DivinationTypeDataModel type) {
    return type.name;
  }

  String _getTabBarButtonText(DivinationType type) {
    switch (type) {
      case DivinationType.destiny:
        return "命理";
      case DivinationType.divination:
        return "占测";
    }
  }

  Widget _buildDestinyQuestion() {
    return DestinyQuestionWidget(
      width: 640,
      enterPageViewModel: widget.enterPageViewModel,
    );
  }

  Widget _buildDivinationQuestion() {
    return DivinationQuestionWidget(
      width: 640,
      isExpandedNotifier: _isExpandedNotifier,
      enterPageViewModel: widget.enterPageViewModel,
    );
  }
}
