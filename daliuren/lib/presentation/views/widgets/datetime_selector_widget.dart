import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:daliuren/presentation/viewmodels/da_liu_ren_viewmodel.dart';

class DateTimeSelectorWidget extends StatelessWidget {
  const DateTimeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择时间',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Consumer<DaLiuRenViewModel>(
              builder: (context, viewModel, child) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${viewModel.selectedDateTime.year}-'
                        '${viewModel.selectedDateTime.month.toString().padLeft(2, '0')}-'
                        '${viewModel.selectedDateTime.day.toString().padLeft(2, '0')} '
                        '${viewModel.selectedDateTime.hour.toString().padLeft(2, '0')}:'
                        '${viewModel.selectedDateTime.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showDateTimePicker(context, viewModel),
                      child: const Text('选择时间'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer<DaLiuRenViewModel>(
              builder: (context, viewModel, child) {
                return TextField(
                  decoration: const InputDecoration(
                    labelText: '问题（可选）',
                    hintText: '请输入您想要占卜的问题',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    viewModel.updateQuestion(value.isEmpty ? null : value);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDateTimePicker(BuildContext context, DaLiuRenViewModel viewModel) {
    showBoardDateTimePicker(
      context: context,
      initialDate: viewModel.selectedDateTime,
      pickerType: DateTimePickerType.datetime,
      minimumDate: DateTime(1900),
      maximumDate: DateTime(2100),
      onResult: (Object? result) {
        if (result is DateTime) {
          viewModel.updateDateTime(result);
        }
      },
    );
  }
}