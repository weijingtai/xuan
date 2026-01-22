import 'package:flutter/material.dart';

class FateCalenderPage extends StatelessWidget {
  const FateCalenderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('命运万年历')),
      body: Center(
        child: Text(
          'TODO: 命运万年历页面',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
