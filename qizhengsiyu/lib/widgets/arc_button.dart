import 'package:flutter/material.dart';

@Deprecated("not finished")
class ArcButton extends StatefulWidget {
  const ArcButton({super.key});

  @override
  _ArcButtonState createState() => _ArcButtonState();
}

class _ArcButtonState extends State<ArcButton> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          debugPrint('isExpanded: $_isExpanded');
        },
        child: ClipPath(
          clipper: AnnularClipper(
            startAngle: -0.75 * 3.14,
            endAngle: -0.25 * 3.14,
            outerRadius: 50,
            innerRadius: 30,
          ),
          child: Container(
            width: 100,
            height: 100,
            alignment: Alignment.topCenter,
            // padding: EdgeInsets.only(top: 4),
            color: Colors.orange,
            child: const Text(
              '狮子',
              style: TextStyle(color: Colors.white, height: 1.2),
            ),
          ),
          // child: CustomPaint(
          //   painter: ArcPainter(),
          //   child: Container(
          //     width: 100,
          //     height: 100,
          //     alignment: Alignment.center,
          //     // color: Colors.red,
          //     child: Text(
          //       'Click Me',
          //       style: TextStyle(color: Colors.white),
          //     ),
          //   ),
          // ),
        ),
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  ArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 50);
    const startAngle = -0.5 * 3.14; // 90 degrees in radians
    const endAngle = 0.5 * 3.14;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawArc(rect, startAngle, endAngle, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ArcClipper extends CustomClipper<Path> {
  bool isExpanded;
  ArcClipper({this.isExpanded = true});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    final rect = Rect.fromCircle(center: const Offset(50, 50), radius: 50);
    const startAngle = -0.5 * 3.14; // 90 degrees in radians
    // final endAngle = isExpanded ? 0.5 * 3.14 : 0.0;
    const endAngle = 0.5 * 3.14;
    path.addArc(rect, startAngle, endAngle);

    // final paint = Paint()
    //   ..color = Colors.blue
    //   ..style = PaintingStyle.fill;

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    // throw UnimplementedError();
    return true;
  }
}

class AnnularClipper extends CustomClipper<Path> {
  final double startAngle;
  final double endAngle;
  final double outerRadius;
  final double innerRadius;

  AnnularClipper({
    required this.startAngle,
    required this.endAngle,
    required this.outerRadius,
    required this.innerRadius,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final rect =
        Rect.fromCircle(center: size.center(Offset.zero), radius: outerRadius);

    path.arcTo(rect, startAngle, endAngle - startAngle, false);

    // 添加内部的圆弧
    final innerRect =
        Rect.fromCircle(center: size.center(Offset.zero), radius: innerRadius);
    path.arcTo(innerRect, endAngle, startAngle - endAngle, false);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
