import 'package:flutter/material.dart';

class ArkClipper extends CustomClipper<Path> {

  static const double twoPi = 6.2831854820251465;
  final double progress;
  final double startAngle;
  final double sweepAngle;
  

  ArkClipper({
    required this.progress, 
    this.startAngle = 0.0, 
    this.sweepAngle = ArkClipper.twoPi
  });
  
  @override
  Path getClip(Size size) {
    var path = Path();

    var progress = this.progress;
    if(progress > 1) progress = 1;
    double halfWidth = size.width / 2;
    double halfHeight = size.height / 2;
    var center = Offset(halfWidth, halfHeight);
    double radius = halfWidth > halfHeight ? halfWidth : halfHeight;
    Rect oval = Rect.fromCircle(center: center, radius: radius);
    double endAngle = (sweepAngle - startAngle) * progress;

    path.addArc(oval, startAngle, endAngle);
    path.lineTo(halfWidth, halfHeight);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}