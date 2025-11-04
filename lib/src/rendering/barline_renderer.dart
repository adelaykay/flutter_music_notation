// lib/src/rendering/barline_renderer.dart

import 'package:flutter/material.dart';
import '../models/measure.dart';
import '../geometry/staff_units.dart';

/// Renders barlines between measures
class BarlineRenderer {
  final double staffSpaceSize;
  final Color color;

  const BarlineRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint a barline
  void paint(
      Canvas canvas,
      double x,
      double topY,
      double bottomY,
      BarlineType type,
      ) {
    switch (type) {
      case BarlineType.single:
        _drawSingleBarline(canvas, x, topY, bottomY);
        break;
      case BarlineType.double_:
        _drawDoubleBarline(canvas, x, topY, bottomY, isFinal: false);
        break;
      case BarlineType.final_:
        _drawDoubleBarline(canvas, x, topY, bottomY, isFinal: true);
        break;
      case BarlineType.repeatStart:
        _drawRepeatBarline(canvas, x, topY, bottomY, isStart: true);
        break;
      case BarlineType.repeatEnd:
        _drawRepeatBarline(canvas, x, topY, bottomY, isStart: false);
        break;
      case BarlineType.dashed:
        _drawDashedBarline(canvas, x, topY, bottomY);
        break;
    }
  }

  /// Draw a single barline
  void _drawSingleBarline(Canvas canvas, double x, double topY, double bottomY) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = StaffUnits.barlineThickness.toPixels(staffSpaceSize)
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(x, topY),
      Offset(x, bottomY),
      paint,
    );
  }

  /// Draw a double barline (or final barline with thick line)
  void _drawDoubleBarline(
      Canvas canvas,
      double x,
      double topY,
      double bottomY, {
        required bool isFinal,
      }) {
    final thinThickness = StaffUnits.barlineThickness.toPixels(staffSpaceSize);
    final thickThickness = StaffUnits.thickBarlineThickness.toPixels(staffSpaceSize);
    final spacing = staffSpaceSize * 0.4;

    if (isFinal) {
      // Thin line on left, thick line on right
      final thinPaint = Paint()
        ..color = color
        ..strokeWidth = thinThickness
        ..style = PaintingStyle.stroke;

      final thickPaint = Paint()
        ..color = color
        ..strokeWidth = thickThickness
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(x - spacing / 2, topY),
        Offset(x - spacing / 2, bottomY),
        thinPaint,
      );

      canvas.drawLine(
        Offset(x + spacing / 2, topY),
        Offset(x + spacing / 2, bottomY),
        thickPaint,
      );
    } else {
      // Two thin lines
      final paint = Paint()
        ..color = color
        ..strokeWidth = thinThickness
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(x - spacing / 2, topY),
        Offset(x - spacing / 2, bottomY),
        paint,
      );

      canvas.drawLine(
        Offset(x + spacing / 2, topY),
        Offset(x + spacing / 2, bottomY),
        paint,
      );
    }
  }

  /// Draw a repeat barline (with dots)
  void _drawRepeatBarline(
      Canvas canvas,
      double x,
      double topY,
      double bottomY, {
        required bool isStart,
      }) {
    final thinThickness = StaffUnits.barlineThickness.toPixels(staffSpaceSize);
    final thickThickness = StaffUnits.thickBarlineThickness.toPixels(staffSpaceSize);
    final spacing = staffSpaceSize * 0.4;

    // Draw barlines (thick on the side closest to content)
    final thinPaint = Paint()
      ..color = color
      ..strokeWidth = thinThickness
      ..style = PaintingStyle.stroke;

    final thickPaint = Paint()
      ..color = color
      ..strokeWidth = thickThickness
      ..style = PaintingStyle.stroke;

    if (isStart) {
      // Thick line on left, thin on right
      canvas.drawLine(
        Offset(x - spacing / 2, topY),
        Offset(x - spacing / 2, bottomY),
        thickPaint,
      );
      canvas.drawLine(
        Offset(x + spacing / 2, topY),
        Offset(x + spacing / 2, bottomY),
        thinPaint,
      );
    } else {
      // Thin line on left, thick on right
      canvas.drawLine(
        Offset(x - spacing / 2, topY),
        Offset(x - spacing / 2, bottomY),
        thinPaint,
      );
      canvas.drawLine(
        Offset(x + spacing / 2, topY),
        Offset(x + spacing / 2, bottomY),
        thickPaint,
      );
    }

    // Draw dots
    final dotRadius = staffSpaceSize * 0.2;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final staffMiddle = (topY + bottomY) / 2;
    final dotX = isStart ? x + spacing + staffSpaceSize * 0.3 : x - spacing - staffSpaceSize * 0.3;

    // Two dots, in spaces above and below middle line
    canvas.drawCircle(
      Offset(dotX, staffMiddle - staffSpaceSize),
      dotRadius,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(dotX, staffMiddle + staffSpaceSize),
      dotRadius,
      dotPaint,
    );
  }

  /// Draw a dashed barline
  void _drawDashedBarline(Canvas canvas, double x, double topY, double bottomY) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = StaffUnits.barlineThickness.toPixels(staffSpaceSize)
      ..style = PaintingStyle.stroke;

    final dashHeight = staffSpaceSize * 0.5;
    final gapHeight = staffSpaceSize * 0.3;

    double currentY = topY;
    while (currentY < bottomY) {
      final endY = (currentY + dashHeight).clamp(topY, bottomY);
      canvas.drawLine(
        Offset(x, currentY),
        Offset(x, endY),
        paint,
      );
      currentY += dashHeight + gapHeight;
    }
  }
}