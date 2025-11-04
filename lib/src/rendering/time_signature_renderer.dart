// lib/src/rendering/time_signature_renderer.dart

import 'package:flutter/material.dart';
import '../models/time_signature.dart';

/// Renders time signature symbols (numbers or symbols)
class TimeSignatureRenderer {
  final double staffSpaceSize;
  final Color color;

  const TimeSignatureRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint the time signature
  void paint(
      Canvas canvas,
      double x,
      double staffTopY,
      TimeSignature timeSignature,
      ) {
    // Use symbols for common time and cut time
    if (timeSignature.isCommonTime) {
      _drawCommonTimeSymbol(canvas, x, staffTopY);
      return;
    }

    if (timeSignature.isCutTime) {
      _drawCutTimeSymbol(canvas, x, staffTopY);
      return;
    }

    // Draw stacked numbers
    _drawNumbers(canvas, x, staffTopY, timeSignature);
  }

  /// Draw common time symbol (C)
  void _drawCommonTimeSymbol(Canvas canvas, double x, double staffTopY) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'C',
        style: TextStyle(
          fontSize: staffSpaceSize * 3.0,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final y = staffTopY + (staffSpaceSize * 2) - textPainter.height / 2;
    textPainter.paint(canvas, Offset(x, y));
  }

  /// Draw cut time symbol (¢)
  void _drawCutTimeSymbol(Canvas canvas, double x, double staffTopY) {
    // Draw C with vertical line through it
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'C',
        style: TextStyle(
          fontSize: staffSpaceSize * 3.0,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final y = staffTopY + (staffSpaceSize * 2) - textPainter.height / 2;
    textPainter.paint(canvas, Offset(x, y));

    // Draw vertical line through the C
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final centerX = x + textPainter.width / 2;
    canvas.drawLine(
      Offset(centerX, y),
      Offset(centerX, y + textPainter.height),
      paint,
    );
  }

  /// Draw time signature as stacked numbers
  void _drawNumbers(
      Canvas canvas,
      double x,
      double staffTopY,
      TimeSignature timeSignature,
      ) {
    final fontSize = staffSpaceSize * 2.6;

    // Draw numerator (top number)
    final numeratorPainter = TextPainter(
      text: TextSpan(
        text: timeSignature.beats.toString(),
        style: TextStyle(
          fontFamily: 'Bravura',
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.bold,
          height: 1.9
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Draw denominator (bottom number)
    final denominatorPainter = TextPainter(
      text: TextSpan(
        text: timeSignature.beatUnit.toString(),
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.bold,
          height: 1.0
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Position: centered on staff
    final staffMiddle = staffTopY + (staffSpaceSize * 2);

    // Numerator above middle line
    final numeratorY = staffMiddle - staffSpaceSize * 0.7;
    numeratorPainter.paint(
      canvas,
      Offset(x, numeratorY - numeratorPainter.height / 2),
    );

    // Denominator below middle line
    final denominatorY = staffMiddle + staffSpaceSize * 1.2;
    denominatorPainter.paint(
      canvas,
      Offset(x, denominatorY - denominatorPainter.height / 2),
    );
  }

  /// Calculate the width occupied by the time signature
  double getWidth(TimeSignature timeSignature) {
    if (timeSignature.isCommonTime || timeSignature.isCutTime) {
      return staffSpaceSize * 2.5;
    }

    // Use the wider of the two numbers
    final fontSize = staffSpaceSize * 2.0;

    final numeratorPainter = TextPainter(
      text: TextSpan(
        text: timeSignature.beats.toString(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final denominatorPainter = TextPainter(
      text: TextSpan(
        text: timeSignature.beatUnit.toString(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    return (numeratorPainter.width > denominatorPainter.width
        ? numeratorPainter.width
        : denominatorPainter.width) +
        staffSpaceSize;
  }
}