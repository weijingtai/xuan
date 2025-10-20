import 'package:common/datamodel/divination_request_info_datamodel.dart';
import 'package:flutter/material.dart';
import 'package:common/database/app_database.dart';
import 'package:common/database/tables/tables.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:provider/provider.dart';
import 'package:common/datamodel/seeker_model.dart';

import '../enums/enum_gender.dart';

class DivinationHistoryRecordPage extends StatefulWidget {
  const DivinationHistoryRecordPage({super.key});

  @override
  State<DivinationHistoryRecordPage> createState() =>
      _DivinationHistoryRecordPageState();
}

class _DivinationHistoryRecordPageState
    extends State<DivinationHistoryRecordPage> {
  late Stream<List<DivinationRequestInfoDataModel>> _divinationsStream;
  late Stream<List<SeekerModel>> _seekersStream;

  @override
  void initState() {
    super.initState();
    final db = context.read<AppDatabase>();

    // 创建实时监控的查询流
    _divinationsStream = (db.select(db.divinations)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();

    _seekersStream = (db.select(db.seekers)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('占卜历史记录'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '占卜记录'),
              Tab(text: '求测人记录'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 占卜记录列表
            StreamBuilder<List<DivinationRequestInfoDataModel>>(
              stream: _divinationsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('错误: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final divinations = snapshot.data!;
                return ListView.builder(
                  itemCount: divinations.length,
                  itemBuilder: (context, index) {
                    final divination = divinations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          divination.question ?? "<未注明>",
                          style: TextStyle(
                              color: divination.question == null
                                  ? Colors.grey
                                  : Colors.black87),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('创建时间: ${divination.createdAt}'),
                            Text('预测: ${divination.tinyPredict}'),
                            Text('直断: ${divination.directlyPredict}'),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),

            // 求测人记录列表
            StreamBuilder<List<SeekerModel>>(
              stream: _seekersStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('错误: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final seekers = snapshot.data!;
                return ListView.builder(
                  itemCount: seekers.length,
                  itemBuilder: (context, index) {
                    final seeker = seekers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title:
                            Text(seeker.nickname ?? seeker.username ?? '未命名'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('创建时间: ${seeker.createdAt}'),
                            Text(
                                '性别: ${seeker.gender == Gender.male ? '男' : '女'}'),
                            Text('出生时间: ${seeker.datetime}'),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
