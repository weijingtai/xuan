import 'package:flutter/material.dart';

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  static const Color primaryColor = Color(0xFFAF865C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('玄学 Demo'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, '三式术数', _sanShiRoutes),
            const SizedBox(height: 24),
            _buildSection(context, '铁版神数', _tieBanRoutes),
            const SizedBox(height: 24),
            _buildSection(context, '通用工具', _commonRoutes),
            const SizedBox(height: 24),
            _buildSection(context, '开发测试', _devRoutes),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<_RouteItem> routes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: routes.length,
          itemBuilder: (context, index) {
            final item = routes[index];
            return _buildCard(context, item);
          },
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, _RouteItem item) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.pushNamed(context, item.route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteItem {
  final String route;
  final String name;

  const _RouteItem(this.route, this.name);
}

const List<_RouteItem> _sanShiRoutes = [
  _RouteItem('/qimendunjia', '奇门遁甲'),
  _RouteItem('/qimendunjia/mvvm', '奇门遁甲 MVVM'),
  _RouteItem('/qizhengsiyu/panel', '七政四余'),
  _RouteItem('/taiyishenshu', '太乙神数'),
  _RouteItem('/daliuren', '大六壬'),
  _RouteItem('/daliuren/old', '大六壬(旧版)'),
  _RouteItem('/daliuren/dev', '大六壬(开发)'),
];

const List<_RouteItem> _tieBanRoutes = [
  _RouteItem('/tiebanshenshu/huang_ji_v2_demo', '皇极V2演示'),
  _RouteItem('/tiebanshenshu/strategy_demo', '策略演示'),
  _RouteItem('/tiebanshenshu/four_doors_and_gun_fa', '四门gun法'),
  _RouteItem('/tiebanshenshu/liuqinkaoke/selection', '六亲考刻选择'),
  _RouteItem('/tiebanshenshu/kaoke', '考刻交互'),
  _RouteItem('/tiebanshenshu/kao_ding_liu_qin', '考订六亲'),
];

const List<_RouteItem> _commonRoutes = [
  _RouteItem('/common/dev', '开发入口'),
  _RouteItem('/common/dev/lunar_info_card', '农历信息卡'),
  _RouteItem('/common/history', '占测历史'),
  _RouteItem('/common/four_zhu_edit', '四柱编辑'),
  _RouteItem('/common/editable_card_demo', '可编辑卡片演示'),
  _RouteItem('/common/fate_calender', '命运日历'),
];

const List<_RouteItem> _devRoutes = [
  _RouteItem('/one_year', '一年时间轮'),
  _RouteItem('/widget_dev', '小部件开发'),
];
