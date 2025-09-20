import 'dart:convert';
import 'dart:io';

import 'package:common/features/datetime_details/calculation_strategy_config.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/models/chinese_date_info.dart';
import 'package:common/dev_constant.dart';
import 'package:fl_nodes/fl_nodes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../flnodes/node_register.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/datetime_provider.dart';
import '../utils/snackbar.dart';
import '../widgets/hierarchy.dart';
import '../widgets/instructions.dart';
import '../widgets/search.dart';

class NodeEditorExampleApp extends StatefulWidget {
  const NodeEditorExampleApp({super.key});

  @override
  State<NodeEditorExampleApp> createState() => _NodeEditorExampleAppState();
}

class _NodeEditorExampleAppState extends State<NodeEditorExampleApp> {
  late Locale _locale;

  final locales = ['en', 'it', 'fr', 'es', 'de', 'ja', 'zh', 'ko', 'ru', 'ar'];

  void _cycleLocale() {
    setState(() {
      final currentIndex = locales.indexOf(_locale.languageCode);
      final nextIndex = (currentIndex + 1) % locales.length;
      _locale = Locale(locales[nextIndex]);
    });
  }

  @override
  void initState() {
    super.initState();

    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final supportedLanguageCodes = locales.toSet();
    final defaultLanguageCode =
        supportedLanguageCodes.contains(systemLocale.languageCode)
        ? systemLocale.languageCode
        : 'en';

    _locale = Locale(defaultLanguageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        const FlNodeEditorLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [...locales.map((lang) => Locale(lang))],
      locale: _locale,
      title: 'Fl Nodes Example',
      theme: ThemeData.dark(),
      home: kIsWeb
          ? Listener(
              onPointerDown: (PointerDownEvent event) {
                // 阻止右键的默认行为
                if (event.buttons == kSecondaryMouseButton) {
                  // 可以在这里添加自定义的右键处理逻辑
                }
              },
              child: GestureDetector(
                onSecondaryTap: () {}, // 额外保险
                child: NodeEditorExampleScreen(onLocaleToggle: _cycleLocale),
              ),
            )
          : NodeEditorExampleScreen(onLocaleToggle: _cycleLocale),
      debugShowCheckedModeBanner: kDebugMode,
    );
  }
}

class NodeEditorExampleScreen extends StatefulWidget {
  const NodeEditorExampleScreen({super.key, required this.onLocaleToggle});

  final VoidCallback onLocaleToggle;

  @override
  State<NodeEditorExampleScreen> createState() =>
      NodeEditorExampleScreenState();
}

class NodeEditorExampleScreenState extends State<NodeEditorExampleScreen> {
  late final FlNodeEditorController _nodeEditorController;

  bool isHierarchyCollapsed = true;

  @override
  void initState() {
    super.initState();
    // 实例化日期时间详情包
    // 实例化 DateTimeDetailsBundle，用于处理日期时间相关的信息

    String projectName = 'taixuan_2'; // 可以根据需要修改项目名

    _nodeEditorController = FlNodeEditorController(
      projectSaver: (jsonData) async {
        try {
          if (kIsWeb) {
            // Web平台：POST到指定接口
            final String url = 'http://192.168.0.45:8080/project/$projectName';

            final response = await http.post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(jsonData),
            );

            if (response.statusCode == 200) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('项目存储成功'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              return true;
            } else {
              final String errorMsg =
                  '存储失败: HTTP ${response.statusCode} - ${response.body}';
              print(errorMsg);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMsg),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return false;
            }
          } else {
            // 移动端和桌面端：保存到应用文档目录
            final Directory appDocDir =
                await getApplicationDocumentsDirectory();
            final String filePath = '${appDocDir.path}/node_project.json';

            final File file = File(filePath);
            await file.writeAsString(jsonEncode(jsonData));

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('项目已保存到: $filePath'),
                  backgroundColor: Colors.green,
                ),
              );
            }

            return true;
          }
        } catch (e) {
          final String errorMsg = '保存失败: $e';
          print(errorMsg);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
            );
          }
          return false;
        }
      },
      projectLoader: (isSaved) async {
        if (!isSaved) {
          final bool? proceed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.unsavedChangesTitle),
                content: Text(AppLocalizations.of(context)!.unsavedChangesMsg),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(AppLocalizations.of(context)!.proceed),
                  ),
                ],
              );
            },
          );

          if (proceed != true) return null;
        }

        try {
          String fileContent;

          if (kIsWeb) {
            // Web平台：从HTTP服务器加载
            try {
              // const String projectName = 'my_project'; // 可以根据需要修改项目名
              final String url =
                  'http://192.168.0.45:8080/project/$projectName';

              final response = await http.get(
                Uri.parse(url),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              );

              if (response.statusCode == 200) {
                fileContent = response.body;
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('项目加载成功！'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                // 如果HTTP加载失败，尝试从assets加载默认项目
                print('HTTP加载失败: ${response.statusCode} - ${response.body}');
                try {
                  fileContent = await rootBundle.loadString(
                    'assets/www/node_project.json',
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已加载本地默认项目'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('未找到保存的项目文件'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return null;
                }
              }
            } catch (e) {
              // 网络错误时，尝试从assets加载默认项目
              print('网络错误: $e');
              try {
                fileContent = await rootBundle.loadString(
                  'assets/www/node_project.json',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('网络连接失败，已加载本地项目: $e'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (assetError) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('加载失败: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return null;
              }
            }
          } else {
            // 移动端和桌面端：从应用文档目录加载
            final Directory appDocDir =
                await getApplicationDocumentsDirectory();
            final String filePath = '${appDocDir.path}/node_project.json';
            final File file = File(filePath);

            if (await file.exists()) {
              fileContent = await file.readAsString();
            } else {
              // 如果文档目录没有文件，尝试从assets加载默认项目
              try {
                fileContent = await rootBundle.loadString(
                  'assets/www/node_project.json',
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('未找到保存的项目文件'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                return null;
              }
            }
          }

          return jsonDecode(fileContent);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('加载项目失败: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return null;
        }
      },
      projectCreator: (isSaved) async {
        if (isSaved) return true;

        final bool? proceed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.unsavedChangesTitle),
              content: Text(AppLocalizations.of(context)!.unsavedChangesMsg),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(AppLocalizations.of(context)!.proceed),
                ),
              ],
            );
          },
        );

        return proceed == true;
      },
      onCallback: (type, message) =>
          showNodeEditorSnackbar(context, message, type),
    );

    // Register all the nodes and data handlers
    // registerDataHandlers(_nodeEditorController);
    // registerNodes(context, _nodeEditorController);

    // my_nodes.registerCardNodes(_nodeEditorController);

    registerCardNodes(context, _nodeEditorController);
    _loadSampleProject(projectName);
  }

  Future<void> _loadSampleProject(String projectName) async {
    String projectUrl = 'http://192.168.0.45:8080/project/$projectName';

    try {
      final response = await http.get(
        Uri.parse(projectUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 && mounted) {
        _nodeEditorController.project.load(
          data: jsonDecode(response.body),
          context: context,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('项目加载成功！'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载项目失败: HTTP ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('网络错误: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nodeEditorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            HierarchyWidget(
              controller: _nodeEditorController,
              isCollapsed: isHierarchyCollapsed,
            ),
            Expanded(
              child: FlNodeEditorWidget(
                controller: _nodeEditorController,
                expandToParent: true,
                overlay: () {
                  return [
                    FlOverlayData(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          spacing: 8,
                          children: [
                            // Hierarchy toggle button
                            IconButton.filled(
                              tooltip: AppLocalizations.of(
                                context,
                              )!.toggleHierarchyTooltip,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () => setState(() {
                                isHierarchyCollapsed = !isHierarchyCollapsed;
                              }),
                              icon: Icon(
                                isHierarchyCollapsed
                                    ? Icons.keyboard_arrow_right
                                    : Icons.keyboard_arrow_left,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            // Search widget
                            SearchWidget(controller: _nodeEditorController),
                            const Spacer(),
                            // Locale toggle button
                            IconButton.filled(
                              tooltip: AppLocalizations.of(
                                context,
                              )!.cycleLocaleTooltip,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: widget.onLocaleToggle,
                              icon: const Icon(
                                Icons.translate,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            // Snap to grid toggle button
                            IconButton.filled(
                              tooltip: AppLocalizations.of(
                                context,
                              )!.toggleSnapToGridTooltip,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () =>
                                  _nodeEditorController.enableSnapToGrid(
                                    !_nodeEditorController
                                        .config
                                        .enableSnapToGrid,
                                  ),
                              icon: Icon(
                                _nodeEditorController.config.enableSnapToGrid
                                    ? Icons.grid_on
                                    : Icons.grid_off,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            // Execute graph button
                            IconButton.filled(
                              tooltip: AppLocalizations.of(
                                context,
                              )!.executeGraphTooltip,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () => _nodeEditorController.runner
                                  .executeGraph(context: context),
                              icon: const Icon(
                                Icons.play_arrow,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FlOverlayData(
                      bottom: 0,
                      left: 0,
                      child: const InstructionsWidget(),
                    ),
                  ];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
