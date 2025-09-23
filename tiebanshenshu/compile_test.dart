// 简单的编译测试脚本
// 用于验证项目的基本编译状态

import 'package:flutter/material.dart';

// 导入主要的项目文件来测试编译
import 'lib/main.dart';
import 'lib/presentation/pages/tai_xuan_interactive_page.dart';
import 'lib/utils/tiao_wen_calculator.dart';

void main() {
  print('编译测试开始...');

  // 基本的编译测试
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('编译测试')),
        body: Center(child: Text('如果看到这个页面，说明基本编译成功')),
      ),
    ),
  );

  print('编译测试完成');
}
