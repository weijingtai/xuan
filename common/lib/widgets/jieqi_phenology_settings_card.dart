import 'package:flutter/material.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/features/datetime_details/jieqi_phenology_store.dart';

/// 节气与物候策略设置卡片
class JieQiPhenologySettingsCard extends StatefulWidget {
  final void Function(JieQiType jieQiType, PhenologyStrategy phenologyStrategy)? onChanged;
  final bool applyOnChange;

  const JieQiPhenologySettingsCard({
    super.key,
    this.onChanged,
    this.applyOnChange = true,
  });

  @override
  State<JieQiPhenologySettingsCard> createState() => _JieQiPhenologySettingsCardState();
}

// 联动组选项：平气法+固定物候、定气法+精准物候（顶层枚举，便于类型解析）
enum _CombinedOption { levelingFixed, stabilizingDynamic }

class _JieQiPhenologySettingsCardState extends State<JieQiPhenologySettingsCard> {

  late _CombinedOption _selected;
  late JieQiType _jieQiType;
  late PhenologyStrategy _phenologyStrategy;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // 将当前 store 中的选择“同步”为一组：
    // 若存在不一致，按 jieQiType 推导对应物候策略，从而强制同步
    if (JieQiPhenologyStore.jieQiType == JieQiType.leveling) {
      _selected = _CombinedOption.levelingFixed;
      _jieQiType = JieQiType.leveling;
      _phenologyStrategy = PhenologyStrategy.levelingBased;
    } else {
      _selected = _CombinedOption.stabilizingDynamic;
      _jieQiType = JieQiType.stabilizing;
      _phenologyStrategy = PhenologyStrategy.stabilizingBased;
    }
  }

  Future<void> _persistDefault() async {
    await JieQiPhenologyStore.persistDefaults(jq: _jieQiType, ph: _phenologyStrategy);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已设为默认：节气/物候联动策略')),
      );
    }
  }

  void _apply() {
    // 同步写入 store
    JieQiPhenologyStore.jieQiType = _jieQiType;
    JieQiPhenologyStore.phenologyStrategy = _phenologyStrategy;
    widget.onChanged?.call(_jieQiType, _phenologyStrategy);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已应用：${_labelCombined(_selected)}')),
    );
  }

  void _onSelect(_CombinedOption v) {
    setState(() {
      _selected = v;
      if (v == _CombinedOption.levelingFixed) {
        _jieQiType = JieQiType.leveling;
        _phenologyStrategy = PhenologyStrategy.levelingBased;
      } else {
        _jieQiType = JieQiType.stabilizing;
        _phenologyStrategy = PhenologyStrategy.stabilizingBased;
      }
    });
    if (widget.applyOnChange) {
      _apply();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()));
    }
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.event, size: 20),
              const SizedBox(width: 8),
              const Text('排盘设置：节气与物候（联动）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(onPressed: _persistDefault, child: const Text('设为默认')),
            ]),
            const SizedBox(height: 8),
            RadioListTile<_CombinedOption>(
              value: _CombinedOption.levelingFixed,
              groupValue: _selected,
              onChanged: (v) => _onSelect(v!),
              title: const Text('平气法 + 传统固定物候'),
              subtitle: const Text('节气恒定间隔；物候以节气起点按 n×5 天固定划分。'),
            ),
            RadioListTile<_CombinedOption>(
              value: _CombinedOption.stabilizingDynamic,
              groupValue: _selected,
              onChanged: (v) => _onSelect(v!),
              title: const Text('定气法 + 现代精准物候'),
              subtitle: const Text('节气依黄经；物候以交节起点按 n×5 天动态划分。'),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _apply,
                child: const Text('应用并重算'),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _labelCombined(_CombinedOption o) =>
      o == _CombinedOption.levelingFixed ? '平气法 + 固定物候' : '定气法 + 精准物候';
}
