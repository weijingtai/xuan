import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/models/liuqinkaoke_models.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/viewmodels/liuqinkaoke_view_model.dart';
import 'package:common/enums.dart';

class LiuQinKaoKeSelectionPage extends StatefulWidget {
  const LiuQinKaoKeSelectionPage({Key? key}) : super(key: key);

  @override
  _LiuQinKaoKeSelectionPageState createState() =>
      _LiuQinKaoKeSelectionPageState();
}

class _LiuQinKaoKeSelectionPageState extends State<LiuQinKaoKeSelectionPage> {
  LiuQinKaoKeSelectionItem? _selectedInnate;
  LiuQinKaoKeSelectionItem? _selectedAcquired;

  @override
  void initState() {
    super.initState();
    // 使用 postFrameCallback 确保 ViewModel 在 build 之后被调用
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // 假定以男性开始，实际应用中应由外部传入
      Provider.of<LiuQinKaoKeViewModel>(context, listen: false)
          .initialize(gender: Gender.male);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('六亲考刻取数法'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _selectedInnate = null;
                _selectedAcquired = null;
              });
              Provider.of<LiuQinKaoKeViewModel>(
                context,
                listen: false,
              ).startNewSession(gender: Gender.male);
            },
          ),
        ],
      ),
      body: Consumer<LiuQinKaoKeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('发生错误: ${viewModel.error}'));
          }

          if (viewModel.session == null) {
            return const Center(child: Text('请开始一个新的会话'));
          }

          if (viewModel.session!.stage ==
              LiuQinKaoKeStage.finalTiaoWenListReady) {
            return _buildFinalListView(
              viewModel.session!.finalTiaoWenList ?? [],
            );
          }

          if (viewModel.session!.stage ==
              LiuQinKaoKeStage.baseNumberSelectionReady) {
            return _buildSelectionView(viewModel);
          }

          return const Center(child: Text('未知的会话状态'));
        },
      ),
    );
  }

  Widget _buildSelectionView(LiuQinKaoKeViewModel viewModel) {
    final innateItems = viewModel.session!.candidateSet!
        .where((item) => item.candidate.originKind == OriginKind.innate)
        .toList();
    final acquiredItems = viewModel.session!.candidateSet!
        .where((item) => item.candidate.originKind == OriginKind.acquired)
        .toList();

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildCandidateColumn('先天', innateItems, _selectedInnate, (item) {
                setState(() => _selectedInnate = item);
              }),
              _buildCandidateColumn('后天', acquiredItems, _selectedAcquired, (
                item,
              ) {
                setState(() => _selectedAcquired = item);
              }),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: (_selectedInnate != null && _selectedAcquired != null)
                ? () {
                    viewModel.selectNumbers(
                      innateItem: _selectedInnate!,
                      acquiredItem: _selectedAcquired!,
                    );
                  }
                : null, // 如果选择不完整则禁用按钮
            child: const Text('提交选择'),
          ),
        ),
      ],
    );
  }

  Widget _buildCandidateColumn(
    String title,
    List<LiuQinKaoKeSelectionItem> items,
    LiuQinKaoKeSelectionItem? selectedItem,
    ValueChanged<LiuQinKaoKeSelectionItem> onSelected,
  ) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item == selectedItem;
                return Card(
                  color: isSelected ? Colors.blue.shade100 : null,
                  child: ListTile(
                    title: Text('${item.candidate.number}'),
                    subtitle: Text(
                      '变爻: ${item.candidate.changeLineIndex == 0 ? "不变" : item.candidate.changeLineIndex}\n${item.tiaoWenContent ?? "无内容"}',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onSelected(item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalListView(List<FinalTiaoWenItem> items) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Provider.of<LiuQinKaoKeViewModel>(
              context,
              listen: false,
            ).rollback();
          },
        ),
        title: const Text('最终结果'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final originStr = item.originKind == OriginKind.innate ? '先天' : '后天';
          final offsetStr = item.offset == 0 ? '' : ' (偏移: ${item.offset})';
          return Card(
            child: ListTile(
              title: Text('${item.number}'),
              subtitle: Text(item.content),
              leading: Chip(label: Text('$originStr$offsetStr')),
            ),
          );
        },
      ),
    );
  }
}
