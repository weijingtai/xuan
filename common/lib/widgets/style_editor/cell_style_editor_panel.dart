import 'package:flutter/material.dart';

class CellStyleEditorPanel extends StatelessWidget {
  const CellStyleEditorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('请选择单元格进行编辑'),
        SizedBox(height: 8),
        Text('在卡片中双击单元格以打开编辑，或在此处展示选中单元格的样式与装饰。'),
      ],
    );
  }
}

