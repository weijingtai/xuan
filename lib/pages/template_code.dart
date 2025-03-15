import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TemplateCode extends StatefulWidget {
  int? intValueFromArgument;
  TemplateCode({super.key, this.intValueFromArgument});

  @override
  State<TemplateCode> createState() => _TemplateCodeState();
}

class _TemplateCodeState extends State<TemplateCode> {
  late ValueNotifier<int?> intValueNotifier;
  late ValueNotifier<String?> stringValueNotifier;

  late ValueNotifier<String?> uiDisplayFinalStringNotifier;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.intValueFromArgument != null) {
      asyncDoSomeLogicCode(widget.intValueFromArgument!).then((strValue) {
        stringValueNotifier = ValueNotifier(strValue);
      });
    } else {
      intValueNotifier = ValueNotifier(widget.intValueFromArgument);
      stringValueNotifier = ValueNotifier(null);
    }
    intValueNotifier.addListener(() {
      if (intValueNotifier.value != null) {
        asyncDoSomeLogicCode(intValueNotifier.value!).then((strValue) {
          stringValueNotifier.value = strValue;
        });
      } else {
        stringValueNotifier.value = null;
      }
    });
    stringValueNotifier.addListener(() {
      if (stringValueNotifier.value != null) {
        uiDisplayFinalStringNotifier.value =
            convertStringToUIString(stringValueNotifier.value!);
      } else {
        uiDisplayFinalStringNotifier.value = null;
      }
    });
  }

  @override
  void dispose() {
    intValueNotifier.dispose();
    stringValueNotifier.dispose();
    uiDisplayFinalStringNotifier.dispose();
    super.dispose();
  }

  Future<String> asyncDoSomeLogicCode(int intValue) async {
    String result = await loadFromDBOrAssetsFile(intValue);
    String finalResult = "do some logic code with result $result";
    return finalResult;
  }

  Future<String> loadFromDBOrAssetsFile(int value) async {
    await Future.delayed(Duration(
        seconds: 1)); // simulate read from assets file or DB or something else

    return "simulate result";
  }

  String convertStringToUIString(String stringValue) {
    // .... do some logic to make raw string value more great for UI Display
    return stringValue;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
          valueListenable: intValueNotifier,
          builder: (ctx, intValue, child) {
            if (intValue != null) {
              return Text("int value is $intValue")
                  .animate(); // using flutter_animate this third-party animation library do animation
            }
            return child!;
          },
          child: Text("display when it's null"),
        ),
      ),
      body: Column(children: [
        ValueListenableBuilder(
          valueListenable: uiDisplayFinalStringNotifier,
          builder: (ctx, finalUIStrValue, child) {
            if (finalUIStrValue != null) {
              return Text(finalUIStrValue)
                  .animate(); // using flutter_animate this third-party animation library do animation
            }
            return child!;
          },
          child: Text("display when it's null"),
        ),
        ElevatedButton(
            onPressed: () {
              if (intValueNotifier.value != null) {
                // call Toast.show("hint info"), third-party library;
              } else {
                intValueNotifier.value = 10;
              }
            },
            child: Text("int value change button")),
        ElevatedButton(
            onPressed: () {
              if (intValueNotifier.value == null) {
                // call Toast.show("hint info"), third-party library;
              } else {
                intValueNotifier.value = null;
              }
            },
            child: Text("reset int value change button"))
      ]),
    ));
  }
}
