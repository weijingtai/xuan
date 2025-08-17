import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiebanshenshu/ui/viewmodels/algorithm_list_viewmodel.dart';

class AlgorithmListView extends StatelessWidget {
  const AlgorithmListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AlgorithmListViewModel(
        repository: Provider.of(context, listen: false),
      )..loadAlgorithms(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('算法列表'),
        ),
        body: Consumer<AlgorithmListViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(
                child: Text('发生错误: ${viewModel.error}'),
              );
            }

            if (viewModel.algorithms.isEmpty) {
              return const Center(
                child: Text('没有找到任何算法。'),
              );
            }

            return ListView.builder(
              itemCount: viewModel.algorithms.length,
              itemBuilder: (context, index) {
                final summary = viewModel.algorithms[index];
                return ListTile(
                  title: Text(summary.name),
                  subtitle: Text(summary.description, maxLines: 2, overflow: TextOverflow.ellipsis,),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/edit',
                      arguments: {'id': summary.id},
                    );
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/edit');
          },
          child: const Icon(Icons.add),
          tooltip: '创建新算法',
        ),
      ),
    );
  }
}
