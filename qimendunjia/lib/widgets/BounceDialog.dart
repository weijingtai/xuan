import 'package:flutter/material.dart';

class BounceDialog extends StatefulWidget {
  const BounceDialog({super.key});

  @override
  _BounceDialogState createState() => _BounceDialogState();
}

class _BounceDialogState extends State<BounceDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: AlertDialog(
        title: const Text('弹出窗口'),
        content: const Text('这是一个带有Q弹效果的弹出窗口。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
