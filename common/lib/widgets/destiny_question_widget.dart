import 'package:common/viewmodels/dev_enter_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slide_switcher/slide_switcher.dart';

import '../enums/enum_gender.dart';
import 'gan_zhi_picker_alert_dialog.dart';

class DestinyQuestionWidget extends StatefulWidget {
  double width;
  DevEnterPageViewModel enterPageViewModel;
  DestinyQuestionWidget(
      {super.key, required this.width, required this.enterPageViewModel});

  @override
  State<DestinyQuestionWidget> createState() => _DestinyQuestionWidgetState();
}

class _DestinyQuestionWidgetState extends State<DestinyQuestionWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  // final ValueNotifier<String?> _inputQuestionStrValueNotifier =
  //     ValueNotifier<String?>(null);
  final FocusNode _detailFocusNode = FocusNode();

  final TextEditingController _reasonController = TextEditingController();

  // final ValueNotifier<String?> _inputQuestionDetailValueNotifier =
  //     ValueNotifier<String?>(null);

  // final ValueNotifier<JiaZi?> _selectedYearJiaZiNotifier =
  //     ValueNotifier<JiaZi?>(null);

  // final ValueNotifier<String?> _inputNameNotifier =
  //     ValueNotifier<String?>(null);
  // final ValueNotifier<String?> _inputNicknameNotifier =
  //     ValueNotifier<String?>(null);

  // DevEnterPageViewModel viewModel => widget.enterPageViewModel;

  // ValueNotifier<JiaZi?> get _selectedYearJiaZiNotifier => viewModel.yearJiaZi;

  ValueNotifier<String?> get _inputNameNotifier => viewModel.username;
  ValueNotifier<String?> get _inputNicknameNotifier => viewModel.nickname;

  ValueNotifier<String?> get _inputQuestionStrValueNotifier =>
      viewModel.question;

  ValueNotifier<Gender> get _inputGenderNotifier => viewModel.genderNotifier;

  DevEnterPageViewModel get viewModel => widget.enterPageViewModel;

  @override
  void initState() {
    _nameController = TextEditingController();
    _nicknameController = TextEditingController();
    if (_inputNicknameNotifier.value != null) {
      _nicknameController.text = _inputNicknameNotifier.value!;
    }
    if (_inputNameNotifier.value != null) {
      _nameController.text = _inputNameNotifier.value!;
    }
    if (_inputQuestionStrValueNotifier.value != null) {
      _reasonController.text = _inputQuestionStrValueNotifier.value!;
    }

    super.initState();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    // _inputQuestionStrValueNotifier.dispose();
    // _inputQuestionDetailValueNotifier.dispose();
    // _selectedYearJiaZiNotifier.dispose();
    // _isExpandedNotifier.dispose();
    _detailFocusNode.dispose();

    // _inputNameNotifier.dispose();

    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildDestinyQuestion();
    // return Container(
    // width: widget.width,
    // color: Colors.blue.withAlpha(100),
    // child: ),
    // );
  }

  Widget buildDestinyQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // color: Colors.grey,
          // width: double.infinity,
          margin: EdgeInsets.only(bottom: 12),
          child: _buildDestinyQuestion(),
        ),
        // const SizedBox(height: 12),
        Container(
          // color: Colors.grey,
          // width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: _buildDivinationQuestion(),
        ),
        // const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildDestinyQuestion() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.center,
      children: [
        _buildNameInput(),
        Container(
            // color: Colors.amber,
            width: 80,
            height: 42,
            child: _buildGenderSelector()),
        _buildNicknameInput()
      ],
    );
  }

  Widget _buildNicknameInput() {
    return Container(
      height: 60, // 固定父容器高度
      width: 200,
      child: ValueListenableBuilder(
        valueListenable: _inputNicknameNotifier,
        builder: (ctx, name, _) {
          return TextField(
            controller: _nicknameController,
            maxLines: 1,
            maxLength: 12,
            keyboardType: TextInputType.text,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              height: 1.2, // 行高统一
              fontSize: 16,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\n')),
            ],
            decoration: InputDecoration(
              isCollapsed: true, // 高度包裹模式
              contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 12), // 垂直居中
              errorText: name != null
                  ? (_validateInput(name, 12) ? "需在0~12字之间" : null)
                  : null,
              errorStyle: TextStyle(fontSize: 12, height: 1),
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Colors.red),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black87),
              ),
              label: Text.rich(TextSpan(
                text: "命主昵称",
                style: TextStyle(color: Colors.black54),
                children: [
                  TextSpan(
                    text: "※",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  )
                ],
              )), // 原标签代码
              hintText: "12字以内",
            ),
            onChanged: (value) {
              _inputNicknameNotifier.value = value;
            },
          );
        },
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      height: 60, // 固定父容器高度
      width: 120,
      child: ValueListenableBuilder(
        valueListenable: _inputNameNotifier,
        builder: (ctx, name, _) {
          return TextField(
            controller: _nameController,
            maxLines: 1,
            // maxLength: 12,
            keyboardType: TextInputType.text,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              height: 1.2, // 行高统一
              fontSize: 16,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\n')),
            ],
            decoration: InputDecoration(
              isCollapsed: true, // 高度包裹模式
              contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 12), // 垂直居中
              errorText: name != null
                  ? (name.trim().length > 6 ? "6字之内" : null)
                  : null,
              errorStyle: TextStyle(fontSize: 12, height: 1),
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Colors.red),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              label: Text.rich(TextSpan(
                text: "命主姓名",
                style: TextStyle(color: Colors.black54),
              )), // 原标签代码
              hintText: "6字以内",
            ),
            onChanged: (value) {
              _inputNameNotifier.value = value;
            },
          );
        },
      ),
    );
  }

  Widget _buildNicknameInput2() {
    return ValueListenableBuilder(
        valueListenable: _inputNicknameNotifier,
        builder: (ctx, name, _) {
          return TextField(
            controller: _nicknameController,
            maxLines: 1,
            keyboardType: TextInputType.text,
            style: TextStyle(overflow: TextOverflow.ellipsis),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\n')), // 禁止输入换行符
            ],
            // maxLength: 12,
            decoration: InputDecoration(
              errorText: name != null
                  ? (_validateInput(name, 12) ? "需在0~12字之间" : null)
                  : null,
              errorStyle: TextStyle(fontSize: 12, height: 1),
              errorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.red)),
              // floatingLabelBehavior: FloatingLabelBehavior.always,
              floatingLabelAlignment: FloatingLabelAlignment.start,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // labelText: labelText,
              label: Text.rich(TextSpan(
                text: "命主昵称",
                style: TextStyle(color: Colors.black54),
                children: [
                  TextSpan(
                    text: "※",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  )
                ],
              )),
              hintText: "12字以内",
            ),
            onChanged: (value) {
              _inputNicknameNotifier.value = value;
            },
          );
        });
  }

  Widget _buildNameInput2(Text labelText, ValueNotifier<String?> inputNotifier,
      TextEditingController textEditingController, bool isRequired) {
    return ValueListenableBuilder(
        valueListenable: inputNotifier,
        builder: (ctx, name, _) {
          return TextField(
            controller: textEditingController,
            maxLines: 1,
            keyboardType: TextInputType.text,
            style: TextStyle(overflow: TextOverflow.ellipsis),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\n')), // 禁止输入换行符
            ],
            // maxLength: 12,
            decoration: InputDecoration(
              isCollapsed: true,
              errorText: !isRequired
                  ? null
                  : (name != null
                      ? (_validateInput(name, 6) ? "需在0~6字之间" : null)
                      : null),
              errorStyle: TextStyle(fontSize: 12, height: 1),
              errorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.red)),
              // floatingLabelBehavior: FloatingLabelBehavior.always,
              floatingLabelAlignment: FloatingLabelAlignment.start,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // labelText: labelText,
              label: labelText,
              hintText: "12字以内",
            ),
            onChanged: (value) {
              inputNotifier.value = value;
            },
          );
        });
  }

  Widget _buildGenderSelector() {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: _inputGenderNotifier,
        builder: (ctx, configType, _) {
          return SlideSwitcher(
            initialIndex: configType.index,
            onSelect: (index) {
              Gender gender = Gender.values[index];
              if (gender != _inputGenderNotifier.value) {
                _inputGenderNotifier.value = gender;
              }
            },
            containerHeight: 36,
            containerWight: 80,
            indents: 4,
            containerColor: Colors.black12.withAlpha(50),
            slidersColors: const [Color(0xfff7f5f7)],
            containerBoxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 2,
                spreadRadius: 4,
              )
            ],
            children: [
              Text(
                "男",
                style: configType != Gender.male
                    ? _getSwitcherInactivatedStyle()
                    : _getSwitcherActivatedStyle(Colors.blueAccent),
              ),
              Text(
                "女",
                style: configType != Gender.female
                    ? _getSwitcherInactivatedStyle()
                    : _getSwitcherActivatedStyle(Colors.pinkAccent),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDivinationQuestion() {
    return ValueListenableBuilder(
        valueListenable: _inputQuestionStrValueNotifier,
        builder: (ctx, valueStr, _) {
          return TextField(
            buildCounter: null,
            // maxLength: 24, // 最大24字符
            decoration: InputDecoration(
              errorText: valueStr != null
                  ? (_validateInput(valueStr, 24) ? "问题不能为空且需≤24字" : null)
                  : null,
              errorStyle: TextStyle(fontSize: 12),
              errorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.red)),
              label: Text.rich(TextSpan(
                text: "占测问题",
                style: TextStyle(color: Colors.black87),
              )),
              hintText: "0~24字以内",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            controller: _reasonController,
            onChanged: (value) {
              _inputQuestionStrValueNotifier.value = value;
            },
          );
        });
  }

  bool _validateInput(String value, int maxLength) {
    final tmpValue = value.trim();
    return tmpValue.isEmpty || tmpValue.length > maxLength;
  }

  /// 获取滑块未激活状态的文本样式
  TextStyle _getSwitcherInactivatedStyle() {
    return const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Colors.black87,
        fontFamily: "NotoSansSC-Regular"
        // color: AppTheme.secondaryText,
        );
  }

  /// 获取滑块激活状态的文本样式
  TextStyle _getSwitcherActivatedStyle(Color color) {
    return TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
        fontFamily: "NotoSansSC-Regular"
        // color: AppTheme.primaryColor,
        );
  }
}
