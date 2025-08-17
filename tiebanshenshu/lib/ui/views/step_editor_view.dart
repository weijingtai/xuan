import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiebanshenshu/algorithm/models/atomic_operation.dart';
import 'package:tiebanshenshu/algorithm/models/execution_step.dart';
import 'package:tiebanshenshu/ui/viewmodels/step_editor_viewmodel.dart';

class StepEditorView extends StatefulWidget {
  final ExecutionStep? editingStep;
  final List<ExecutionStep> precedingSteps;

  const StepEditorView({
    Key? key,
    this.editingStep,
    this.precedingSteps = const [],
  }) : super(key: key);

  @override
  State<StepEditorView> createState() => _StepEditorViewState();
}

class _StepEditorViewState extends State<StepEditorView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StepEditorViewModel(
        atomicOperationRepository: Provider.of(context, listen: false),
        editingStep: widget.editingStep,
        precedingSteps: widget.precedingSteps,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.editingStep == null ? '创建新步骤' : '编辑步骤'),
          actions: [
            Consumer<StepEditorViewModel>(
              builder: (context, vm, _) => IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  final step = vm.buildStep();
                  if (step != null) {
                    Navigator.of(context).pop(step);
                  }
                },
              ),
            )
          ],
        ),
        body: Consumer<StepEditorViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.selectedAtom == null) {
              return _buildAtomSelectionList(vm);
            }

            return _buildStepConfigurationForm(vm);
          },
        ),
      ),
    );
  }

  Widget _buildAtomSelectionList(StepEditorViewModel vm) {
    return ListView.builder(
      itemCount: vm.availableAtoms.length,
      itemBuilder: (context, index) {
        final atom = vm.availableAtoms[index];
        return ListTile(
          title: Text(atom.name),
          subtitle: Text(atom.description),
          onTap: () => vm.selectAtomById(atom.id),
        );
      },
    );
  }

  Widget _buildStepConfigurationForm(StepEditorViewModel vm) {
    final atom = vm.selectedAtom!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(atom.name, style: Theme.of(context).textTheme.headlineSmall),
              subtitle: Text(atom.description),
              trailing: TextButton(
                child: const Text('更换'),
                onPressed: () => vm.selectAtomById(''), // Hack to reset
              ),
            ),
            const Divider(),
            TextFormField(
              initialValue: vm.stepName,
              decoration: const InputDecoration(labelText: '步骤名称'),
              onChanged: vm.updateStepName,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: vm.stepDescription,
              decoration: const InputDecoration(labelText: '步骤描述'),
              onChanged: vm.updateStepDescription,
            ),
            const SizedBox(height: 16),
            if (atom.inputParameters.isNotEmpty) ..._buildSection('输入映射', _buildMappingFields(vm, atom.inputParameters, true)),
            if (atom.configParameters.isNotEmpty) ..._buildSection('参数配置', _buildConfigFields(vm, atom.configParameters)),
            if (atom.outputParameters.isNotEmpty) ..._buildSection('输出映射', _buildMappingFields(vm, atom.outputParameters, false)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSection(String title, List<Widget> fields) {
    return [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      ...fields,
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildMappingFields(StepEditorViewModel vm, Map<String, ParameterDefinition> params, bool isInput) {
    return params.entries.map((entry) {
      final paramName = entry.key;
      final paramDef = entry.value;

      if (isInput) {
        return DropdownButtonFormField<String>(
          value: vm.inputMapping[paramName],
          decoration: InputDecoration(labelText: paramName, hintText: paramDef.description),
          items: vm.availableInputSources.map((source) => DropdownMenuItem(value: source, child: Text(source))).toList(),
          onChanged: (value) => vm.updateInputMapping(paramName, value),
        );
      } else { // Is Output
        return TextFormField(
          initialValue: vm.outputMapping[paramName],
          decoration: InputDecoration(labelText: paramName, hintText: '为输出结果命名 (e.g. my_result)'),
          onChanged: (value) => vm.updateOutputMapping(paramName, value),
        );
      }
    }).toList();
  }

  List<Widget> _buildConfigFields(StepEditorViewModel vm, Map<String, ParameterDefinition> params) {
    return params.entries.map((entry) {
      final paramName = entry.key;
      final paramDef = entry.value;
      // This is a simplified version. A real implementation would have more type checks.
      if (paramDef.type == ParameterType.boolean) {
        return SwitchListTile(
          title: Text(paramName),
          value: vm.configMapping[paramName] ?? paramDef.defaultValue ?? false,
          onChanged: (value) => vm.updateConfigMapping(paramName, value),
        );
      }
      return TextFormField(
        initialValue: (vm.configMapping[paramName] ?? paramDef.defaultValue)?.toString(),
        decoration: InputDecoration(labelText: paramName, hintText: paramDef.description),
        onChanged: (value) {
            // Simple type conversion
            if (paramDef.type == ParameterType.intNum) {
                vm.updateConfigMapping(paramName, int.tryParse(value) ?? value);
            } else {
                vm.updateConfigMapping(paramName, value);
            }
        },
      );
    }).toList();
  }
}
