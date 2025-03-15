import 'package:common/widgets/query_time_input_card.dart';
import 'package:flutter/material.dart';

import 'widgets/eight_chars_input_card.dart';

class DevEnterPage extends StatefulWidget {
  const DevEnterPage({super.key});

  @override
  State<DevEnterPage> createState() => _DevEnterPageState();
}

class _DevEnterPageState extends State<DevEnterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dev Widget")),
      body: const Center(
        child: QueryTimeInputCard(
          defaultTimeZone: "America/Los_Angeles",
          defaultPageType: PageType.datetime,
        ),
      ),
    );
  }
}
