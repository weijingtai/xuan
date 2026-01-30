import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daliuren/presentation/viewmodels/da_liu_ren_viewmodel.dart';

class DivinationDisplayWidget extends StatelessWidget {
  const DivinationDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DaLiuRenViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.currentDivination == null) {
          return const Center(
            child: Text('请选择时间进行占卜'),
          );
        }

        final divination = viewModel.currentDivination!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Card
              _buildBasicInfoCard(context, divination),

              const SizedBox(height: 16),

              // JiaZi Information Card
              _buildJiaZiInfoCard(context, viewModel),

              const SizedBox(height: 16),

              // Divination Panel (placeholder for now)
              _buildDivinationPanel(context, divination),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoCard(BuildContext context, dynamic divination) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text('时间: ${divination.panDateTime}'),
            if (divination.question != null)
              Text('问题: ${divination.question}'),
            Text('八字: ${divination.eightChatStr}'),
          ],
        ),
      ),
    );
  }

  Widget _buildJiaZiInfoCard(BuildContext context, DaLiuRenViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '干支信息',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (viewModel.yearJiaZi != null)
              Text('年干支: ${viewModel.yearJiaZi!.name}'),
            if (viewModel.monthJiaZi != null)
              Text('月干支: ${viewModel.monthJiaZi!.name}'),
            if (viewModel.dayJiaZi != null)
              Text('日干支: ${viewModel.dayJiaZi!.name}'),
            if (viewModel.timeJiaZi != null)
              Text('时干支: ${viewModel.timeJiaZi!.name}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDivinationPanel(BuildContext context, dynamic divination) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '占卜盘',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Four Class (四课)
            _buildFourClassSection(context, divination),

            const SizedBox(height: 16),

            // Three Transmission (三传)
            _buildThreeChuanSection(context, divination),

            const SizedBox(height: 16),

            // Twelve Palaces (十二宫)
            _buildTwelvePalacesSection(context, divination),
          ],
        ),
      ),
    );
  }

  Widget _buildFourClassSection(BuildContext context, dynamic divination) {
    final fourClass = divination.fourClass;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '四课',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildClassItem('第一课', fourClass.first.sky.name, fourClass.first.ground.name),
                  _buildClassItem('第二课', fourClass.second.sky.name, fourClass.second.ground.name),
                  _buildClassItem('第三课', fourClass.third.sky.name, fourClass.third.ground.name),
                  _buildClassItem('第四课', fourClass.fourth.sky.name, fourClass.fourth.ground.name),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: [
                  if (fourClass.isFuYin)
                    Chip(label: Text('伏吟'), backgroundColor: Colors.blue[100]),
                  if (fourClass.isFanYin)
                    Chip(label: Text('反吟'), backgroundColor: Colors.orange[100]),
                  if (fourClass.isFullClass)
                    Chip(label: Text('四课齐备'), backgroundColor: Colors.green[100]),
                  if (fourClass.isThreeClassOnly)
                    Chip(label: Text('三课'), backgroundColor: Colors.purple[100]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassItem(String title, String sky, String ground) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Text(sky, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Divider(height: 8),
              Text(ground),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThreeChuanSection(BuildContext context, dynamic divination) {
    final threeChuan = divination.threeChuan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '三传',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Chip(
                label: Text('九宗门: ${threeChuan.nineZongMen.name}'),
                backgroundColor: Colors.amber[100],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildChuanItem('初传', threeChuan.first),
                  _buildChuanItem('中传', threeChuan.second),
                  _buildChuanItem('末传', threeChuan.third),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChuanItem(String title, dynamic chuan) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepOrange, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (chuan.tianGan != null)
                Text('${chuan.tianGan.name}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                chuan.diZhi.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text('${chuan.guiRen.name}', style: const TextStyle(fontSize: 10)),
              Text('${chuan.liuQin.name}', style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTwelvePalacesSection(BuildContext context, dynamic divination) {
    final gongMapper = divination.gongMapper;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '十二宫位',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final diZhi = divination.gongMapper.keys.elementAt(index);
              final gong = gongMapper[diZhi];
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      gong.skyPanDiZhi.name,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 4),
                    Text(
                      gong.groundPanDiZhi.name,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}