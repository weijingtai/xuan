import 'package:common/enums.dart';
import 'package:common/widgets/yun_liu_widget/yun_liu_cell_widget.dart';
import 'package:flutter/material.dart';

import 'package:common/features/liu_yun/da_yun_liu_nian/dayun_liunian_table_widget.dart';
import 'package:common/features/liu_yun/year_month_table/ink_five_dim_yunliu_table.dart';

class DevYunLiuTable extends StatefulWidget {
  const DevYunLiuTable({super.key});

  @override
  State<DevYunLiuTable> createState() => _DevYunLiuTableState();
}

class _DevYunLiuTableState extends State<DevYunLiuTable> {
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('开发大运流年Big Table'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '大运流年表格'),
              Tab(text: 'Tiny大运流年'),
              Tab(text: '年月table'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            physics: const PageScrollPhysics(),
            children: [
              _buildDaYunLiuNianPage(),
              _buildDaYunLiuNianTinyPage(),
              _buildYearMonthPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaYunLiuNianPage() {
    return const DaYunLiuNianTableDemoWidget();
  }

  Widget _buildDaYunLiuNianTinyPage() {
    return const DaYunLiuNianTinyTableDemoWidget();
  }

  Widget _buildYearMonthPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRect(child: InkFiveDimYunLiuTable()),
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
