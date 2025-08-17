import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiebanshenshu/ui/viewmodels/algorithm_list_viewmodel.dart';
import 'package:tiebanshenshu/data/repositories/mock_algorithm_repository.dart'; // Using mock for prototype

class AlgorithmListView extends StatelessWidget {
  const AlgorithmListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // In a real app, the repository would be provided from a higher-level provider
      create: (_) => AlgorithmListViewModel(repository: MockAlgorithmRepository())
        ..loadAlgorithms(),
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
                    // TODO: Navigate to AlgorithmEditorView with summary.id
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('导航到编辑页: ${summary.id}')),
                    );
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to AlgorithmEditorView with null id
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('导航到新建算法页')),
            );
          },
          child: const Icon(Icons.add),
          tooltip: '创建新算法',
        ),
      ),
    );
  }
}
