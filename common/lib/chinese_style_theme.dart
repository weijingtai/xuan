import 'package:flutter/material.dart';

// 自定义按钮样式
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonSize size;

  CustomButton({required this.text, required this.onPressed, required this.size});

  @override
  Widget build(BuildContext context) {
    double width = 0;
    double height = 0;
    double fontSize = 0;
    if (size == ButtonSize.small) {
      width = 80;
      height = 40;
      fontSize = 14;
    } else if (size == ButtonSize.medium) {
      width = 120;
      height = 50;
      fontSize = 16;
    } else if (size == ButtonSize.large) {
      width = 160;
      height = 60;
      fontSize = 18;
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Color(0xFF333333), backgroundColor: Color(0xFFF2E5C9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Color(0xFFC29965), width: 2),
        ),
        minimumSize: Size(width, height),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'HanYiShangWeiShouShu',
          fontSize: fontSize,
        ),
      ),
    );
  }
}

enum ButtonSize { small, medium, large }

// 自定义输入框样式
class CustomInputField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  CustomInputField({required this.hintText, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'SourceHanSerifCN',
          color: Color(0xFF999999),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFFD1C2AE), width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(
        fontFamily: 'SourceHanSerifCN',
        color: Color(0xFF333333),
        fontSize: 16,
      ),
    );
  }
}

// 自定义卡片样式
class CustomCard extends StatelessWidget {
  final Widget child;

  CustomCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Color(0xFFF9F5EE),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: child,
      ),
    );
  }
}

// 首页
class ChineseStyleTheme1HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF2E5C9),
        title: Text(
          '命理占卜',
          style: TextStyle(
            fontFamily: 'HanYiShangWeiShouShu',
            color: Color(0xFF333333),
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Color(0xFF665544)),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'), // 替换为实际的水墨山水背景图片路径
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: '八字测算',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BaZiPage()),
                );
              },
              size: ButtonSize.large,
            ),
            SizedBox(height: 32),
            CustomButton(
              text: '塔罗占卜',
              onPressed: () {},
              size: ButtonSize.large,
            ),
            SizedBox(height: 32),
            CustomButton(
              text: '风水布局',
              onPressed: () {},
              size: ButtonSize.large,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFF2E5C9),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Color(0xFF665544)),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group, color: Color(0xFF665544)),
            label: '社区',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color(0xFF665544)),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

// 八字测算页面
class BaZiPage extends StatelessWidget {
  final TextEditingController yearController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController hourController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF2E5C9),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '八字测算',
          style: TextStyle(
            fontFamily: 'HanYiShangWeiShouShu',
            color: Color(0xFF333333),
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          // image: DecorationImage(
          //   image: AssetImage('assets/background.jpg'), // 替换为实际的水墨山水背景图片路径
          //   fit: BoxFit.cover,
          // ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: CustomInputField(
                  hintText: '请输入出生年份',
                  controller: yearController,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: CustomInputField(
                  hintText: '请输入出生月份',
                  controller: monthController,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: CustomInputField(
                  hintText: '请输入出生日期',
                  controller: dayController,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: CustomInputField(
                  hintText: '请输入出生时辰',
                  controller: hourController,
                ),
              ),
              SizedBox(height: 32),
              CustomButton(
                text: '开始测算',
                onPressed: () {},
                size: ButtonSize.large,
              ),
              SizedBox(height: 32),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '测算结果',
                      style: TextStyle(
                        fontFamily: 'HanYiShangWeiShouShu',
                        color: Color(0xFF333333),
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '这里将显示八字测算的详细结果。',
                      style: TextStyle(
                        fontFamily: 'SourceHanSerifCN',
                        color: Color(0xFF333333),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}