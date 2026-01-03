import 'package:common/models/pillar_data.dart';
import 'package:common/utils/constant_values_utils.dart';
import 'package:flutter/material.dart';

class PillarCard extends StatelessWidget {
  final PillarData pillar;
  final VoidCallback onDelete;

  const PillarCard({
    Key? key,
    required this.pillar,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      child: Stack(
        children: [
          Container(
            width: 160,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(pillar.label, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
                const SizedBox(height: 8),
                FittedBox(
                  child: Text(
                    pillar.jiaZi.tianGan.value,
                    style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                ),
                Text(FourZhuText.riYuan,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.secondary)),
                const Divider(height: 24),
                FittedBox(
                  child: Text(
                    pillar.jiaZi.diZhi.value,
                    style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                ),
                const Spacer(),
                Text('空亡: 戌亥', style: theme.textTheme.bodySmall),
                Text('藏干: 戊乙癸', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
