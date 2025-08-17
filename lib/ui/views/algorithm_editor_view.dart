import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiebanshenshu/data/repositories/mock_algorithm_repository.dart';
import 'package:tiebanshenshu/ui/viewmodels/algorithm_editor_viewmodel.dart';

class AlgorithmEditorView extends StatefulWidget {
  final String? algorithmId;

  const AlgorithmEditorView({Key? key, this.algorithmId}) : super(key: key);

  @override
  State<AlgorithmEditorView> createState() => _AlgorithmEditorViewState();
}

class _AlgorithmEditorViewState extends State<AlgorithmEditorView> {
  late final AlgorithmEditorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // In a real app, the repository would be provided from a higher-level provider
    _viewModel = AlgorithmEditorViewModel(repository: MockAlgorithmRepository());
    _viewModel.loadAlgorithm(widget.algorithmId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<AlgorithmEditorViewModel>(
            builder: (context, vm, child) {
              return Text(vm.algorithm == null ? '加载中...' : '编辑: ${vm.algorithm!.name}');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                final success = await _viewModel.saveAlgorithm();
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? '保存成功' : '保存失败: ${_viewModel.error}')),
                  );
                }
              },
            ),
          ],
        ),
        body: Consumer<AlgorithmEditorViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading && vm.algorithm == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.error != null && vm.algorithm == null) {
              return Center(child: Text('发生错误: ${vm.error}'));
            }

            if (vm.algorithm == null) {
              return const Center(child: Text('没有加载算法。'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: vm.algorithm!.name,
                    decoration: const InputDecoration(labelText: '算法名称'),
                    onChanged: (value) => vm.updateName(value),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: vm.algorithm!.description,
                    decoration: const InputDecoration(labelText: '算法描述'),
                    maxLines: 3,
                    onChanged: (value) => vm.updateDescription(value),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('执行步骤', style: Theme.of(context).textTheme.titleLarge),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to StepEditorView for a new step
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('添加新步骤')),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('添加步骤'),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (vm.algorithm!.steps.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('还没有任何步骤。')),
                    )
                  else
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vm.algorithm!.steps.length,
                      itemBuilder: (context, index) {
                        final step = vm.algorithm!.steps[index];
                        return Card(
                          key: ValueKey(step.id),
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(step.name),
                            subtitle: Text(step.operationId, style: Theme.of(context).textTheme.bodySmall),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () {
                                    // TODO: Navigate to StepEditorView to edit this step
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('编辑步骤: ${step.id}')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () => vm.deleteStep(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        vm.reorderStep(oldIndex, newIndex);
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
