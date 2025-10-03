import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qimendunjia/presentation/viewmodels/qimen_viewmodel.dart';
import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:intl/intl.dart';

/// 奇门遁甲 MVVM 架构页面
///
/// 使用新的 MVVM+UseCase 架构实现
class QiMenMvvmPage extends StatefulWidget {
  const QiMenMvvmPage({super.key});

  @override
  State<QiMenMvvmPage> createState() => _QiMenMvvmPageState();
}

class _QiMenMvvmPageState extends State<QiMenMvvmPage> {
  DateTime? _selectedDateTime;
  ArrangeType _arrangeType = ArrangeType.CHAI_BU;
  PlateType _plateType = PlateType.ZHUAN_PAN;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('奇门遁甲·MVVM架构'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showArchitectureInfo(context);
            },
          ),
        ],
      ),
      body: Consumer<QiMenViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 架构标识卡片
                _buildArchitectureCard(),
                const SizedBox(height: 24),

                // 配置区域
                _buildConfigSection(viewModel),
                const SizedBox(height: 24),

                // 操作按钮
                _buildActionButtons(viewModel),
                const SizedBox(height: 24),

                // 状态显示
                _buildStateSection(viewModel),
                const SizedBox(height: 24),

                // 盘信息显示
                if (viewModel.currentPan != null) _buildPanInfo(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildArchitectureCard() {
    return Card(
      color: Colors.blue.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.architecture, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'MVVM + UseCase 架构',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '✓ Domain层: Entity + Repository接口 + UseCase业务逻辑\n'
              '✓ Data层: Repository实现 + DataSource数据源\n'
              '✓ Presentation层: ViewModel + View UI',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSection(QiMenViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '排盘配置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // 时间选择
            Row(
              children: [
                const Text('起盘时间：'),
                Expanded(
                  child: Text(
                    _selectedDateTime != null
                        ? DateFormat('yyyy-MM-dd HH:mm')
                            .format(_selectedDateTime!)
                        : '未选择',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await showBoardDateTimePicker(
                      context: context,
                      pickerType: DateTimePickerType.datetime,
                    );
                    if (result != null) {
                      setState(() {
                        _selectedDateTime = result;
                      });
                    }
                  },
                  child: const Text('选择时间'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 起盘方式
            const Text('起盘方式：'),
            Wrap(
              spacing: 8,
              children: ArrangeType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.name),
                  selected: _arrangeType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _arrangeType = type;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 盘类型
            const Text('盘类型：'),
            Wrap(
              spacing: 8,
              children: PlateType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.name),
                  selected: _plateType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _plateType = type;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(QiMenViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: viewModel.isLoading
              ? null
              : () async {
                  final dateTime = _selectedDateTime ?? DateTime.now();
                  await viewModel.calculateAndArrangePan(
                    dateTime: dateTime,
                    arrangeType: _arrangeType,
                    plateType: _plateType,
                  );
                },
          icon: const Icon(Icons.calculate),
          label: const Text('排盘'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        OutlinedButton.icon(
          onPressed: viewModel.isLoading
              ? null
              : () {
                  viewModel.reset();
                  setState(() {
                    _selectedDateTime = null;
                  });
                },
          icon: const Icon(Icons.clear),
          label: const Text('清除'),
        ),
      ],
    );
  }

  Widget _buildStateSection(QiMenViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '当前状态：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                _buildStateIndicator(viewModel.state),
              ],
            ),
            if (viewModel.isLoading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            if (viewModel.hasError) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.errorMessage ?? '未知错误',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStateIndicator(QiMenViewState state) {
    Color color;
    String text;
    IconData icon;

    switch (state) {
      case QiMenViewState.initial:
        color = Colors.grey;
        text = '初始';
        icon = Icons.radio_button_unchecked;
        break;
      case QiMenViewState.calculating:
        color = Colors.orange;
        text = '计算局数中';
        icon = Icons.calculate;
        break;
      case QiMenViewState.arranging:
        color = Colors.blue;
        text = '排盘中';
        icon = Icons.grid_on;
        break;
      case QiMenViewState.loadingGongDetail:
        color = Colors.purple;
        text = '加载宫位详情中';
        icon = Icons.info;
        break;
      case QiMenViewState.success:
        color = Colors.green;
        text = '成功';
        icon = Icons.check_circle;
        break;
      case QiMenViewState.error:
        color = Colors.red;
        text = '错误';
        icon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPanInfo(QiMenViewModel viewModel) {
    final pan = viewModel.currentPan!;
    final ju = viewModel.currentJu!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '盘信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('盘类型', pan.plateType.name),
            // _buildInfoRow('起盘方式', pan.arrangeType.name),
            _buildInfoRow('局数', '${ju.yinYangDun.name}${ju.juNumber}局'),
            _buildInfoRow('旬首', ju.fuTouJiaZi.name),
            _buildInfoRow('节气', ju.jieQiAt.name),
            const SizedBox(height: 16),
            const Text(
              '九宫信息',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('已加载 ${pan.gongMapper.length} 个宫位'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _showGongList(context, viewModel);
              },
              child: const Text('查看九宫详情'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label：',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _showGongList(BuildContext context, QiMenViewModel viewModel) {
    final pan = viewModel.currentPan!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('九宫信息'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pan.gongMapper.length,
            itemBuilder: (context, index) {
              final entry = pan.gongMapper.entries.elementAt(index);
              final gua = entry.key;
              final gong = entry.value;
              return ListTile(
                title: Text('${gua.name}宫'),
                subtitle: Text(
                  '天盘: ${gong.tianPan.name} / 地盘: ${gong.diPan.name}\n'
                  '门: ${gong.door.name} / 星: ${gong.star.name} / 神: ${gong.god.name}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await viewModel.selectGong(gong);
                    if (mounted) {
                      _showGongDetail(context, viewModel);
                    }
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showGongDetail(BuildContext context, QiMenViewModel viewModel) {
    final gong = viewModel.selectedGong;
    final detail = viewModel.gongDetailInfo;

    if (gong == null || detail == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${gong.gongGua.name}宫详情'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('天盘天干: ${gong.tianPan.name}'),
              Text('地盘天干: ${gong.diPan.name}'),
              Text('八门: ${gong.door.name}'),
              Text('九星: ${gong.star.name}'),
              Text('八神: ${gong.god.name}'),
              const Divider(),
              if (detail.tenGanKeYing != null) ...[
                const SizedBox(height: 8),
                const Text('十干克应:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(detail.tenGanKeYing!.tianDiKeYing.shortExplain),
              ],
              if (detail.doorStarKeYing != null) ...[
                const SizedBox(height: 8),
                const Text('门星克应:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(detail.doorStarKeYing!.description),
              ],
              if (detail.qiYiRuGong != null) ...[
                const SizedBox(height: 8),
                const Text('奇仪入宫:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(detail.qiYiRuGong!.description),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.unselectGong();
              Navigator.of(context).pop();
            },
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showArchitectureInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('架构说明'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MVVM + UseCase 架构',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                '📦 Domain层（业务核心）',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Entity: 业务实体类'),
              Text('• Repository接口: 定义数据操作契约'),
              Text('• UseCase: 业务用例逻辑'),
              SizedBox(height: 12),
              Text(
                '📦 Data层（数据处理）',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Repository实现: 实现数据操作'),
              Text('• DataSource: 数据源（JSON/计算器）'),
              SizedBox(height: 12),
              Text(
                '📦 Presentation层（界面展示）',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• ViewModel: 界面状态管理'),
              Text('• View: Flutter UI组件'),
              SizedBox(height: 12),
              Text(
                '🔧 依赖注入',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• ServiceLocator: 管理依赖关系'),
              Text('• 使用Provider进行状态管理'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
