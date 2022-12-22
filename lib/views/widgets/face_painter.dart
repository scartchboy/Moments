import 'package:flutter/material.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'dart:ui' as ui;

class FacePainter extends CustomPainter {
  final ui.Image image;
  Face? face;
  bool? isEnd;
  FacePainter(this.image, this.face, this.isEnd);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint initalPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.red;
    final Paint finalPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..color = Colors.green;

    canvas.drawImage(image, Offset.zero, Paint());

    canvas.drawRect(face!.boundingBox, isEnd! ? finalPaint : initalPaint);
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return true;
  }
}
