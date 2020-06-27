import 'package:flutter/material.dart';
import 'dart:core';

class CircularProgress extends StatefulWidget {
  final double size;
  final Color backgroundColor;
  final Color color;
  final Duration duration;
  CircularProgress({@required this.size, @required this.duration, this.backgroundColor = Colors.transparent, this.color = Colors.blue});

  @override
  _CircularProgress createState() => _CircularProgress();
}

class _CircularProgress extends State<CircularProgress> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  Duration duration;

  @override
  void initState() {
    super.initState();
    duration = widget.duration;
    controller = AnimationController(vsync: this, duration: duration);
    animation = Tween(begin: 0.0, end: 360.0).animate(controller);
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        CustomPaint(
          painter: CircularCanvas(progress: animation.value, backgroundColor: widget.backgroundColor, color: widget.color),
          size: Size(widget.size, widget.size),
        ),
        Text(
          '${(animation.value / 360 * 100).round()}%',
          style: TextStyle(color: widget.color, fontSize: widget.size / 5, fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}

class CircularCanvas extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color color;

  CircularCanvas({this.progress, this.backgroundColor = Colors.grey, this.color = Colors.blue});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint
      ..color = backgroundColor
      ..strokeWidth = 1.0 //size.width/50
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    paint..strokeWidth = size.width / 15;
    canvas.drawArc(Offset(0.0, 0.0) & Size(size.width, size.width), -90.0 * 0.0174533, progress * 0.0174533, false, paint..color = color);
  }

  @override
  bool shouldRepaint(CircularCanvas oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
