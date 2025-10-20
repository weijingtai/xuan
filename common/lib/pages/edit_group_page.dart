import 'package:common/models/pillar_group.dart';
import 'package:common/viewmodels/bazi_card_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/edit_group_widget.dart';

class EditGroupPage extends StatelessWidget {
  final String groupId;

  const EditGroupPage({Key? key, required this.groupId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BaziCardViewModel>(
      builder: (context, viewModel, _) {
        final group = viewModel.pillarGroups.firstWhere((g) => g.id == groupId);
        return Scaffold(
          appBar: AppBar(
            title: Text('编辑分组: ${group.title}'),
          ),
          body: EditGroupWidget(group: group),
        );
      },
    );
  }
}
