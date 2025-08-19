import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'tmp_dart/lib/providers/app_providers.dart';
import 'tmp_dart/lib/views/pages/algorithm_editor_page.dart';
import 'tmp_dart/lib/views/widgets/common/colors.dart';

void main() {
  runApp(const DevAligorthmsUI());
}

class DevAligorthmsUI extends StatelessWidget {
  const DevAligorthmsUI({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp(
        title: '原子算法编辑器',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: AppColors.primary,
          fontFamily: 'Inter',
          useMaterial3: true,
        ),
        home: const AlgorithmEditorPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
