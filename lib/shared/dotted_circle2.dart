
import 'package:flutter/material.dart';
import 'package:proto_proj/shared/dotted_circle.dart';


class DottedCircle2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(10, 10),
      painter: DottedCirclePainter(),
    );
  }
}