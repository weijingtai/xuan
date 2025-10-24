import 'package:flutter/material.dart';
import 'package:common/features/datetime_details/jieqi_entry_strategy_store.dart';

class JieQiEntrySettingsCard extends StatefulWidget {
  final void Function(JieQiEntryPrecision p)? onChanged;
  final bool applyOnChange;
  const JieQiEntrySettingsCard({super.key, this.onChanged, this.applyOnChange = true});

  @override
  State<JieQiEntrySettingsCard> createState() => _JieQiEntrySettingsCardState();
}

class _JieQiEntrySettingsCardState extends State<JieQiEntrySettingsCard> {
  JieQiEntryPrecision _current = JieQiEntryStrategyStore.current;

  void _select(JieQiEntryPrecision p) {
    setState(() => _current = p);
    JieQiEntryStrategyStore.current = p;
    if (widget.applyOnChange) {
      widget.onChanged?.call(p);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已应用交节精度：${_label(p)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.timeline, size: 20),
              const SizedBox(width: 8),
              const Text('排盘设置：交节方案', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await JieQiEntryStrategyStore.persistDefault(_current);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已设为默认交节精度')));
                  }
                },
                child: const Text('设为默认'),
              ),
            ]),
            const SizedBox(height: 8),
            RadioListTile<JieQiEntryPrecision>(
              value: JieQiEntryPrecision.shichen,
              groupValue: _current,
              onChanged: (v) => _select(v!),
              title: const Text('按时辰交节'),
              subtitle: const Text('两小时一段；与子时日界有关。'),
            ),
            RadioListTile<JieQiEntryPrecision>(
              value: JieQiEntryPrecision.hour,
              groupValue: _current,
              onChanged: (v) => _select(v!),
              title: const Text('按小时交节'),
            ),
            RadioListTile<JieQiEntryPrecision>(
              value: JieQiEntryPrecision.minute,
              groupValue: _current,
              onChanged: (v) => _select(v!),
              title: const Text('按分钟交节（推荐）'),
              subtitle: const Text('现代科学计算，精确到分钟。'),
            ),
            RadioListTile<JieQiEntryPrecision>(
              value: JieQiEntryPrecision.second,
              groupValue: _current,
              onChanged: (v) => _select(v!),
              title: const Text('按秒交节'),
              subtitle: const Text('最严格判定，精确到秒。'),
            ),
          ],
        ),
      ),
    );
  }

  String _label(JieQiEntryPrecision p) => switch (p) {
        JieQiEntryPrecision.shichen => '按时辰',
        JieQiEntryPrecision.hour => '按小时',
        JieQiEntryPrecision.minute => '按分钟（推荐）',
        JieQiEntryPrecision.second => '按秒',
      };
}
