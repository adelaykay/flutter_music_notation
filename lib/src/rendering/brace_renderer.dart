// lib/src/rendering/brace_renderer.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Renders a brace connecting two staves (typically for piano)
class BraceRenderer {
  final double staffSpaceSize;
  final Color color;

  const BraceRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint a brace connecting two staves
  ///
  /// [canvas] - Canvas to draw on
  /// [x] - Horizontal position of the brace
  /// [topStaffY] - Y position of the top staff
  /// [bottomStaffY] - Y position of the bottom staff (bottom line)
  /// [staffHeight] - Height of a single staff
  void paint(
      Canvas canvas,
      double x,
      double topStaffY,
      double bottomStaffY,
      double staffHeight,
      ) {
    final totalHeight = (bottomStaffY + staffHeight) - topStaffY;
    final centerY = topStaffY + (totalHeight / 2);

    // Use SMuFL brace glyph if available, otherwise draw path
    _drawBracePath(canvas, x, topStaffY, totalHeight);
  }

  /// Draw brace using a custom path (Bézier curves)
  void _drawBracePath(Canvas canvas, double x, double y, double height) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Brace width based on staff space size
    final braceWidth = staffSpaceSize * 2.5;
    final centerY = y + height / 2;

    // Top curve (pointing left)
    path.moveTo(x + braceWidth, y);
    path.cubicTo(
      x + braceWidth * 0.3, y + height * 0.1,
      x, y + height * 0.2,
      x, centerY - staffSpaceSize * 0.5,
    );

    // Middle point (tip of brace pointing left)
    path.lineTo(x - staffSpaceSize * 0.3, centerY);

    // Bottom curve (pointing left)
    path.lineTo(x, centerY + staffSpaceSize * 0.5);
    path.cubicTo(
      x, y + height * 0.8,
      x + braceWidth * 0.3, y + height * 0.9,
      x + braceWidth, y + height,
    );

    // Right edge (straight line closing the shape)
    path.lineTo(x + braceWidth * 0.85, y + height);
    path.cubicTo(
      x + braceWidth * 0.5, y + height * 0.85,
      x + braceWidth * 0.3, y + height * 0.7,
      x + braceWidth * 0.3, centerY + staffSpaceSize * 0.3,
    );

    // Inner middle point
    path.lineTo(x + braceWidth * 0.2, centerY);

    // Top inner curve
    path.lineTo(x + braceWidth * 0.3, centerY - staffSpaceSize * 0.3);
    path.cubicTo(
      x + braceWidth * 0.3, y + height * 0.3,
      x + braceWidth * 0.5, y + height * 0.15,
      x + braceWidth * 0.85, y,
    );

    path.close();

    canvas.drawPath(path, paint);
  }

  /// Alternative: Use SMuFL glyph (if Bravura font supports it)
  void _drawBraceGlyph(Canvas canvas, double x, double y, double height) {
    // SMuFL brace glyph: U+E000 (brace)
    // This would use TextPainter with Bravura font
    // For now, we use the path-based approach above

    final textPainter = TextPainter(
      text: TextSpan(
        text: '\uE000', // SMuFL brace glyph
        style: TextStyle(
          fontFamily: 'Bravura',
          fontSize: height,
          color: color,
          package: 'flutter_music_notation',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(x - textPainter.width, y));
  }

  /// Calculate the width the brace will occupy
  double getWidth() {
    return staffSpaceSize * 2.5;
  }
}

/// Renders a bracket connecting multiple staves (for orchestral scores)
class BracketRenderer {
  final double staffSpaceSize;
  final Color color;

  const BracketRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint a bracket connecting multiple staves
  void paint(
      Canvas canvas,
      double x,
      double topY,
      double bottomY,
      ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = staffSpaceSize * 0.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final bracketWidth = staffSpaceSize * 1.5;

    // Vertical line
    canvas.drawLine(
      Offset(x, topY),
      Offset(x, bottomY),
      paint,
    );

    // Top horizontal piece
    canvas.drawLine(
      Offset(x, topY),
      Offset(x + bracketWidth, topY),
      paint,
    );

    // Bottom horizontal piece
    canvas.drawLine(
      Offset(x, bottomY),
      Offset(x + bracketWidth, bottomY),
      paint,
    );
  }

  /// Calculate the width the bracket will occupy
  double getWidth() {
    return staffSpaceSize * 1.5;
  }
}