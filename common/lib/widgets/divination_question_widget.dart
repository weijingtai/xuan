import 'package:common/viewmodels/dev_enter_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:slide_switcher/slide_switcher.dart';

import '../enums/enum_gender.dart';
import '../enums/enum_jia_zi.dart';
import 'gan_zhi_picker_alert_dialog.dart';

class DivinationQuestionWidget extends StatefulWidget {
  double width;
  ValueNotifier<bool> isExpandedNotifier;

  final DevEnterPageViewModel enterPageViewModel;
  DivinationQuestionWidget(
      {super.key,
      required this.width,
      required this.isExpandedNotifier,
      required this.enterPageViewModel});

  @override
  State<DivinationQuestionWidget> createState() =>
      _DivinationQuestionWidgetState();
}

class _DivinationQuestionWidgetState extends State<DivinationQuestionWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  // final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier<bool>(false);
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  final FocusNode _detailFocusNode = FocusNode();

  final TextEditingController _questionController = TextEditingController();

  final TextEditingController _questionDetailController =
      TextEditingController();

  DevEnterPageViewModel get viewModel => widget.enterPageViewModel;

  ValueNotifier<String?> get _inputQuestionDetailValueNotifier =>
      viewModel.detail;

  ValueNotifier<JiaZi?> get _selectedYearJiaZiNotifier => viewModel.yearJiaZi;

  ValueNotifier<String?> get _inputNameNotifier => viewModel.username;
  ValueNotifier<String?> get _inputNicknameNotifier => viewModel.nickname;

  ValueNotifier<String?> get _inputQuestionStrValueNotifier =>
      viewModel.question;

  ValueNotifier<Gender> get _inputGenderNotifier => viewModel.genderNotifier;

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
      _questionController.text = _inputQuestionStrValueNotifier.value!;
    }

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.5, end: 0.25).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
    super.initState();
  }

  @override
  void dispose() {
    // _inputQuestionStrValueNotifier.dispose();
    // _inputQuestionDetailValueNotifier.dispose();
    // _isExpandedNotifier.dispose();
    _rotationController.dispose();
    _detailFocusNode.dispose();

    _nameController.dispose();
    _nicknameController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.isExpandedNotifier,
        builder: (ctx, isExpanded, _) {
          return buildDivinationQuestion();
        });
  }

  Widget buildDivinationQuestion() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      width: widget.width,
      // color: Colors.amberAccent.withAlpha(100),
      child: Column(
        children: [
          _buildDivinationUserQuestion(),
          const SizedBox(height: 4),
          _buildDivinationQuestion(),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              ValueListenableBuilder(
                valueListenable: widget.isExpandedNotifier,
                builder: (ctx, isExpanded, _) {
                  if (isExpanded) {
                    _rotationController.forward();
                  } else {
                    _rotationController.reverse();
                  }
                  return InkWell(
                      onTap: () {
                        widget.isExpandedNotifier.value =
                            !widget.isExpandedNotifier.value;
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blueAccent.shade100),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RotationTransition(
                              turns: _rotationAnimation,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              " 添加详细描述",
                              style: TextStyle(
                                height: 1,
                                fontSize: 10,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withAlpha(100),
                                    offset: Offset(0, 1),
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ));
                },
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: widget.isExpandedNotifier,
            builder: (ctx, isExpanded, _) {
              return AnimatedCrossFade(
                firstChild: SizedBox(),
                secondChild: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildDivinationQuestionDetail(),
                  ],
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: isExpanded
                    ? Duration(milliseconds: 400)
                    : Duration(milliseconds: 100),
                sizeCurve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivinationUserQuestion() {
    return Container(
      width: widget.width,
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: 180,
              height: 42,
              child: _buildNameInput(
                  "占测人", _inputNicknameNotifier, _nicknameController)),
          _buildGenderSelector(true),
          ValueListenableBuilder(
              valueListenable: _selectedYearJiaZiNotifier,
              builder: (ctx, jiaZi, _) {
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    showJiaZiPicker(context, jiaZi, JiaZi.values)
                        .then((JiaZi? value) {
                      _selectedYearJiaZiNotifier.value = value;
                    });
                  },
                  child: Container(
                    width: 72,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withAlpha(20),
                          blurRadius: 2,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          jiaZi != null ? jiaZi.name : "生年",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        if (jiaZi != null)
                          Text(jiaZi.naYinStr,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white54,
                                  height: 1))
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildNicknameInput() {
    return ValueListenableBuilder(
        valueListenable: _inputNicknameNotifier,
        builder: (ctx, name, _) {
          return TextField(
            controller: _nicknameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              labelText: "占测人昵称",
            ),
            onChanged: (value) {
              _inputNameNotifier.value = value;
            },
          );
        });
  }

  Widget _buildNameInput(String labelText, ValueNotifier<String?> inputNotifier,
      TextEditingController textEditingController) {
    return ValueListenableBuilder(
        valueListenable: inputNotifier,
        builder: (ctx, name, _) {
          return TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              labelText: labelText,
            ),
            onChanged: (value) {
              inputNotifier.value = value;
            },
          );
        });
  }

  void uernameInput(String newUsername) {
    widget.enterPageViewModel.inputUsername(newUsername);
  }

  Widget _buildGenderSelector(bool withUnknown) {
    return Center(
      child: ValueListenableBuilder<Gender>(
        valueListenable: _inputGenderNotifier,
        builder: (ctx, configType, _) {
          return SlideSwitcher(
            initialIndex: configType.index,
            onSelect: (index) {
              Gender gender = Gender.values[index];
              // if (withUnknown) {
              //   if (index == 0) {
              //     gender = Gender.male;
              //   } else if (index == 1) {
              //     gender = Gender.unknown;
              //   } else if (index == 2) {
              //     gender = Gender.female;
              //   }
              // }
              if (gender != _inputGenderNotifier.value) {
                _inputGenderNotifier.value = gender;
              }
            },
            containerHeight: 40,
            containerWight: withUnknown ? 140 : 100,
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
              if (withUnknown)
                Text(
                  "未知",
                  style: configType != Gender.unknown
                      ? _getSwitcherInactivatedStyle()
                      : _getSwitcherActivatedStyle(Colors.blueGrey),
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
            maxLength: 24, // 最大24字符
            decoration: InputDecoration(
              errorText: valueStr != null
                  ? (_validateInput(valueStr) ? "问题不能为空且需≤24字" : null)
                  : null,
              errorStyle: TextStyle(fontSize: 12),
              errorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.red)),
              label: Text.rich(TextSpan(
                  text: "占测问题（必填）",
                  style: TextStyle(color: Colors.black87),
                  children: [
                    TextSpan(
                      text: "※",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  ])),
              hintText: "0~24字以内",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            controller: _questionController,
            onChanged: (value) {
              _inputQuestionStrValueNotifier.value = value;
            },
          );
        });
  }

  Widget _buildDivinationQuestionDetail() {
    return ValueListenableBuilder(
        valueListenable: _inputQuestionDetailValueNotifier,
        builder: (ctx, valueStr, _) {
          return ValueListenableBuilder(
            valueListenable: widget.isExpandedNotifier,
            builder: (ctx, isExpanded, _) {
              if (isExpanded) {
                // 使用 Future.microtask 确保在下一帧时获取焦点
                Future.microtask(() => _detailFocusNode.requestFocus());
              }
              return TextField(
                focusNode: _detailFocusNode,
                maxLength: 240,
                minLines: 5,
                maxLines: 5,
                buildCounter: (context,
                        {required currentLength,
                        required isFocused,
                        required maxLength}) =>
                    Text("$currentLength/$maxLength",
                        style: const TextStyle(color: Colors.grey)),
                decoration: InputDecoration(
                  errorText: valueStr != null
                      ? (valueStr.length > 240 ? "不能超过240字" : null)
                      : null,
                  errorStyle: TextStyle(fontSize: 12),
                  errorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.red)),
                  labelText: "详细描述（可填）",
                  labelStyle: TextStyle(color: Colors.black87),
                  hintText: "请输入详细描述",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                controller: _questionDetailController,
                onChanged: (value) {
                  _inputQuestionDetailValueNotifier.value = value;
                },
              );
            },
          );
        });
  }

  bool _validateInput(String value) {
    return value.isEmpty || value.length > 24;
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
