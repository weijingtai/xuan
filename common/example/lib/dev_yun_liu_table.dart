import 'package:common/enums.dart';
import 'package:common/widgets/yun_liu_widget/yun_liu_cell_widget.dart';
import 'package:flutter/material.dart';

import 'ink_five_dim_yunliu_table.dart';

class DevYunLiuTable extends StatefulWidget {
  const DevYunLiuTable({super.key});

  @override
  State<DevYunLiuTable> createState() => _DevYunLiuTableState();
}

class _DevYunLiuTableState extends State<DevYunLiuTable>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);
  final ValueNotifier<YunLiuHiddenDisplayMode> _displayMode =
      ValueNotifier<YunLiuHiddenDisplayMode>(YunLiuHiddenDisplayMode.showAll);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _isHovered.dispose();
    _displayMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('开发大运流年Big Table')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ValueListenableBuilder<YunLiuHiddenDisplayMode>(
                valueListenable: _displayMode,
                builder: (context, mode, _) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildModeRadio(
                        groupValue: mode,
                        value: YunLiuHiddenDisplayMode.hideHiddenGan,
                        label: '隐藏藏干中的天干',
                      ),
                      _buildModeRadio(
                        groupValue: mode,
                        value: YunLiuHiddenDisplayMode.hideHiddenTenGod,
                        label: '隐藏藏干中的十神',
                      ),
                      _buildModeRadio(
                        groupValue: mode,
                        value: YunLiuHiddenDisplayMode.showAll,
                        label: '全部显示',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              MouseRegion(
                onEnter: (event) {
                  _isHovered.value = true;
                },
                onExit: (event) {
                  _isHovered.value = false;
                },
                child: YunLiuCellWidget(
                  tianGan: TianGan.JIA,
                  diZhi: DiZhi.ZI,
                  isHoveredListenable: _isHovered,
                  displayModeListenable: _displayMode,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: ClipRect(child: InkFiveDimYunLiuTable())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeRadio({
    required YunLiuHiddenDisplayMode groupValue,
    required YunLiuHiddenDisplayMode value,
    required String label,
  }) {
    return InkWell(
      onTap: () {
        _displayMode.value = value;
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<YunLiuHiddenDisplayMode>(
            value: value,
            groupValue: groupValue,
            onChanged: (v) {
              if (v == null) return;
              _displayMode.value = v;
            },
          ),
          Text(label),
        ],
      ),
    );
  }
}
