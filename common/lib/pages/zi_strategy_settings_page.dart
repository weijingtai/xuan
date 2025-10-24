import 'package:flutter/material.dart';
import 'package:common/widgets/zi_strategy_settings_card.dart';

class ZiStrategySettingsPage extends StatelessWidget {
  const ZiStrategySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('排盘设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ZiStrategySettingsCard(),
        ],
      ),
    );
  }
}

