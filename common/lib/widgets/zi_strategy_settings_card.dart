import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:common/features/datetime_details/calculation_strategy_config.dart';
import 'package:common/features/datetime_details/input_info_params.dart';

/// 子时策略设置卡片
class ZiStrategySettingsCard extends StatefulWidget {
  final void Function(ZiShiStrategy strategy)? onStrategyChanged;
  final bool applyOnChange;

  const ZiStrategySettingsCard({
    super.key,
    this.onStrategyChanged,
    this.applyOnChange = true,
  });

  @override
  State<ZiStrategySettingsCard> createState() => _ZiStrategySettingsCardState();
}

class _ZiStrategySettingsCardState extends State<ZiStrategySettingsCard> {
  static const String _spKey = 'calc_zi_strategy';
  static const String _spDefaultKey = 'calc_zi_strategy_default';
  ZiShiStrategy _current = CalculationStrategyConfig.defaultConfig.ziStrategy;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final saved = sp.getString(_spKey);
    // fall back to persisted default if no per-session saved value
    final fallbackDefault = sp.getString(_spDefaultKey);
    setState(() {
      _current = _parse(saved) ?? _parse(fallbackDefault) ?? CalculationStrategyConfig.defaultConfig.ziStrategy;
      _loading = false;
    });
  }

  Future<void> _save(ZiShiStrategy s) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_spKey, _toString(s));
  }

  String _toString(ZiShiStrategy s) {
    switch (s) {
      case ZiShiStrategy.noDistinguishAt23:
        return 'noDistinguishAt23';
      case ZiShiStrategy.distinguishAt0FiveMouse:
        return 'distinguishAt0FiveMouse';
      case ZiShiStrategy.distinguishAt0Fixed:
        return 'distinguishAt0Fixed';
      case ZiShiStrategy.bandsStartAt0:
        return 'bandsStartAt0';
      case ZiShiStrategy.startFrom23:
        return 'startFrom23';
      case ZiShiStrategy.startFrom0:
        return 'startFrom0';
      case ZiShiStrategy.splitedZi:
        return 'splitedZi';
    }
  }

  ZiShiStrategy? _parse(String? s) {
    switch (s) {
      case 'noDistinguishAt23':
        return ZiShiStrategy.noDistinguishAt23;
      case 'distinguishAt0FiveMouse':
        return ZiShiStrategy.distinguishAt0FiveMouse;
      case 'distinguishAt0Fixed':
        return ZiShiStrategy.distinguishAt0Fixed;
      case 'bandsStartAt0':
        return ZiShiStrategy.bandsStartAt0;
      case 'startFrom23':
        return ZiShiStrategy.noDistinguishAt23;
      case 'startFrom0':
      case 'splitedZi':
        return ZiShiStrategy.distinguishAt0FiveMouse;
      default:
        return null;
    }
  }

  void _onSelect(ZiShiStrategy s) async {
    setState(() => _current = s);
    await _save(s);
    if (widget.applyOnChange) {
      widget.onStrategyChanged?.call(s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已应用子时策略：${_label(s)}')),
        );
      }
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
            Row(
              children: [
                const Icon(Icons.schedule, size: 20),
                const SizedBox(width: 8),
                const Text('排盘设置：子时策略', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    await _save(CalculationStrategyConfig.defaultConfig.ziStrategy);
                    setState(() => _current = CalculationStrategyConfig.defaultConfig.ziStrategy);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已重置为默认策略')),
                      );
                    }
                  },
                  child: const Text('重置'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final sp = await SharedPreferences.getInstance();
                    await sp.setString(_spDefaultKey, _toString(_current));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已设为默认：${_label(_current)}')),
                      );
                    }
                  },
                  child: const Text('设为默认'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildOption(
              value: ZiShiStrategy.noDistinguishAt23,
              title: '不区分早晚（23:00 统一次日）',
              subtitle: '23:00–1:00 日柱与时柱均按次日；适合简化排盘。',
            ),
            _buildOption(
              value: ZiShiStrategy.distinguishAt0FiveMouse,
              title: '区分早晚（0:00 为界，五鼠遁）',
              subtitle: '23:00–0:00 日柱当日，时柱按次日；0:00–1:00 日柱与时柱均次日。',
            ),
            _buildOption(
              value: ZiShiStrategy.distinguishAt0Fixed,
              title: '区分早晚（0:00 为界，固定子时）',
              subtitle: '子时段固定地支为子/丑，天干顺序相续：N子 → (N+1)丑。',
            ),
            _buildOption(
              value: ZiShiStrategy.bandsStartAt0,
              title: '全天两小时一支（子从0点起）',
              subtitle: '子(0:00–1:59)、丑(2:00–3:59)…亥(22:00–23:59)；时柱五鼠遁起干。',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  widget.onStrategyChanged?.call(_current);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已应用并保存：${_label(_current)}')),
                  );
                },
                child: const Text('应用并重算'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required ZiShiStrategy value,
    required String title,
    required String subtitle,
  }) {
    return RadioListTile<ZiShiStrategy>(
      value: value,
      groupValue: _current,
      onChanged: (v) => _onSelect(v!),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  String _label(ZiShiStrategy s) {
    switch (s) {
      case ZiShiStrategy.noDistinguishAt23:
        return '不区分早晚（23:00 统一次日）';
      case ZiShiStrategy.distinguishAt0FiveMouse:
        return '区分早晚（0:00 五鼠遁）';
      case ZiShiStrategy.distinguishAt0Fixed:
        return '区分早晚（0:00 固定子时）';
      case ZiShiStrategy.bandsStartAt0:
        return '全天两小时一支（子从0点起）';
      case ZiShiStrategy.startFrom23:
        return '旧：23 起次日';
      case ZiShiStrategy.startFrom0:
        return '旧：0 界';
      case ZiShiStrategy.splitedZi:
        return '旧：分早晚子时';
    }
  }
}
