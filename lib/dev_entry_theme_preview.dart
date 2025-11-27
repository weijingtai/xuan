import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:common/viewmodels/four_zhu_editor_view_model.dart';
import 'package:common/repositories/layout_template_repository_impl.dart';
import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/domain/usecases/layout_templates/get_all_templates_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import 'package:common/domain/usecases/layout_templates/save_template_use_case.dart';
import 'package:common/domain/usecases/layout_templates/delete_template_use_case.dart';
import 'package:common/widgets/editor_sidebar_v2.dart';

void main() {
  runApp(const DevThemePreviewApp());
}

class DevThemePreviewApp extends StatelessWidget {
  const DevThemePreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DevThemePreviewPage(),
    );
  }
}

class DevThemePreviewPage extends StatefulWidget {
  const DevThemePreviewPage({super.key});

  @override
  State<DevThemePreviewPage> createState() => _DevThemePreviewPageState();
}

class _DevThemePreviewPageState extends State<DevThemePreviewPage> {
  late final FourZhuEditorViewModel _viewModel;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    final repo = LayoutTemplateRepositoryImpl(const LayoutTemplateLocalDataSource());
    _viewModel = FourZhuEditorViewModel(
      getAllTemplatesUseCase: GetAllTemplatesUseCase(repo),
      getTemplateByIdUseCase: GetTemplateByIdUseCase(repo),
      saveTemplateUseCase: SaveTemplateUseCase(repo),
      deleteTemplateUseCase: DeleteTemplateUseCase(repo),
    );
    _initFuture = _viewModel.initialize(collectionId: 'default');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        return ChangeNotifierProvider<FourZhuEditorViewModel>.value(
          value: _viewModel,
          child: Scaffold(
            appBar: AppBar(title: const Text('侧栏：主题编辑与预览（开发入口）')),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const EditorSidebarV2(),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: Center(
                      child: Text(
                        '右侧为占位区。请在左侧栏使用“主题编辑与预览”。',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}