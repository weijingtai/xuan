import 'package:common/viewmodels/dev_enter_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/divination_datetime.dart';
import 'eight_chars_selection_card.dart';

class EightCharsSelectCardListWidget extends StatefulWidget {
  ValueNotifier<List<MapEntry<EnumDatetimeType, DivinationDatetimeModel>>?>
      selectableCardsNotifier;
  DevEnterPageViewModel enterPageViewModel;

  double contentPadding = 0;
  double cardSize = 0;
  EightCharsSelectCardListWidget(
      {super.key,
      required this.selectableCardsNotifier,
      required this.contentPadding,
      required this.cardSize,
      required this.enterPageViewModel});

  @override
  State<EightCharsSelectCardListWidget> createState() =>
      _EightCharsSelectCardListWidgetState();
}

class _EightCharsSelectCardListWidgetState
    extends State<EightCharsSelectCardListWidget> {
  final ValueNotifier<int?> _selectedIndexNotifier = ValueNotifier(null);
  final PageController _pageController = PageController();
  @override
  void initState() {
    super.initState();
    _selectedIndexNotifier.addListener(() {
      if (_selectedIndexNotifier.value != null &&
          widget.selectableCardsNotifier.value != null &&
          widget.selectableCardsNotifier!.value!.isNotEmpty) {
        context.read<DevEnterPageViewModel>().selectDivinationDatetime(widget
            .selectableCardsNotifier
            .value![_selectedIndexNotifier.value!]
            .value);
      }
    });
  }

  @override
  void dispose() {
    _selectedIndexNotifier.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.selectableCardsNotifier,
      builder: (ctx, mapEntries, child) {
        if (mapEntries == null) return child!;
        Set<int> highLightIndexSet = Set();
        if (mapEntries.map((e) => e.value.bazi.year).toSet().length > 1) {
          highLightIndexSet.add(1);
        }
        if (mapEntries.map((e) => e.value.bazi.month).toSet().length > 1) {
          highLightIndexSet.add(2);
        }
        if (mapEntries.map((e) => e.value.bazi.day).toSet().length > 1) {
          highLightIndexSet.add(3);
        }
        if (mapEntries.map((e) => e.value.bazi.time).toSet().length > 1) {
          highLightIndexSet.add(4);
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(widget.contentPadding * 2),
          child: ValueListenableBuilder<int?>(
            valueListenable: _selectedIndexNotifier,
            builder: (context, selectedIndex, _) {
              return Row(
                children: List.generate(mapEntries.length, (index) {
                  // final cardSize =
                  // screenWidth > 600 ? 256.0 : screenWidth * 0.8;
                  return EightCharsSelectionCard(
                    isSelected:
                        selectedIndex == null ? false : selectedIndex == index,
                    queryDateTime: mapEntries[index].value,
                    onTap: () {
                      widget.enterPageViewModel
                          .setDivinationDateTime(mapEntries[index].value);
                      _selectedIndexNotifier.value = index;
                    },
                    timeFormat: DateFormat("HH:mm"),
                    dateFormat: DateFormat("yyyy-MM-dd"),
                    dateTimeFormat: DateFormat("yyyy-MM-dd HH:mm"),
                    highLight: highLightIndexSet,
                    size: Size(widget.cardSize, widget.cardSize + 96 + 32),
                    margin: EdgeInsets.symmetric(
                      horizontal: widget.contentPadding * 2,
                      vertical: widget.contentPadding * 2,
                    ),
                  );
                }),
              );
            },
          ),
        );
      },
      child: SizedBox(height: 256 + 96 + 32 + 32),
    );
  }
}
