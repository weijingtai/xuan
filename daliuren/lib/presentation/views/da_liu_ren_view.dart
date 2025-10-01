import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daliuren/presentation/viewmodels/da_liu_ren_viewmodel.dart';
import 'package:daliuren/presentation/views/widgets/datetime_selector_widget.dart';
import 'package:daliuren/presentation/views/widgets/divination_display_widget.dart';
import 'package:daliuren/presentation/views/widgets/loading_widget.dart';
import 'package:daliuren/presentation/views/widgets/error_widget.dart';

class DaLiuRenView extends StatefulWidget {
  const DaLiuRenView({super.key});

  @override
  State<DaLiuRenView> createState() => _DaLiuRenViewState();
}

class _DaLiuRenViewState extends State<DaLiuRenView> {
  @override
  void initState() {
    super.initState();
    // Initialize data when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DaLiuRenViewModel>().initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Consumer<DaLiuRenViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.currentDivination != null &&
                viewModel.juNumber != null) {
              final divination = viewModel.currentDivination!;
              return Text(
                "${divination.dayJiaZi.name}日·${divination.timeJiaZi.diZhi.name}时·"
                "${divination.isDayGuiRen ? "阳" : "阴"}${viewModel.juNumber}局",
              );
            }
            return const Text("大六壬");
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DaLiuRenViewModel>().recalculate();
            },
          ),
        ],
      ),
      body: Consumer<DaLiuRenViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingWidget();
          }

          if (viewModel.isError) {
            return CustomErrorWidget(
              message: viewModel.message,
              onRetry: () => viewModel.initializeData(),
            );
          }

          return const Column(
            children: [
              // Date/Time Selector
              DateTimeSelectorWidget(),

              // Main Divination Display
              Expanded(
                child: DivinationDisplayWidget(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<DaLiuRenViewModel>().resetToNow();
        },
        child: const Icon(Icons.access_time),
      ),
    );
  }
}
