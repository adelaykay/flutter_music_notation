// lib/src/rendering/brace_renderer.dart

import 'package:flutter/material.dart';

/// Renders a brace connecting two staves (typically for piano)
class BraceRenderer {
  final double staffSpaceSize;
  final Color color;

  const BraceRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Brace width as a fraction of its height, from `frontend/grand-staff.svg`.
  static const double _widthRatio = 0.07760;

  /// Draws the extracted grand-staff brace shape. The path is normalized to a
  /// unit height (y in [0,1], x in [0, ~0.078]) with its origin at the top-left
  /// corner of the brace, so `canvas.scale(totalHeight)` sizes it exactly.
  static final Path _bracePath = Path()
    ..moveTo(0.07022, 0.00007)
    ..cubicTo(0.06720, 0.00025, 0.06399, 0.00345, 0.05853, 0.01130)
    ..cubicTo(0.04748, 0.02594, 0.03162, 0.06021, 0.02529, 0.07807)
    ..cubicTo(0.01579, 0.11556, 0.01268, 0.16115, 0.01584, 0.20516)
    ..cubicTo(0.01739, 0.21978, 0.02051, 0.25232, 0.02529, 0.27838)
    ..cubicTo(0.03318, 0.34033, 0.03480, 0.36639, 0.03480, 0.39245)
    ..cubicTo(0.03318, 0.43480, 0.02217, 0.46896, 0.00472, 0.49177)
    ..cubicTo(0.00156, 0.49502, 0.00000, 0.49828, 0.00000, 0.49995)
    ..cubicTo(0.00000, 0.50162, 0.00156, 0.50488, 0.00472, 0.50813)
    ..cubicTo(0.02217, 0.53094, 0.03318, 0.56508, 0.03480, 0.60584)
    ..cubicTo(0.03480, 0.63348, 0.03318, 0.65951, 0.02529, 0.71979)
    ..cubicTo(0.02051, 0.74752, 0.01739, 0.78010, 0.01584, 0.79313)
    ..cubicTo(0.01268, 0.83872, 0.01579, 0.88433, 0.02529, 0.92015)
    ..cubicTo(0.03318, 0.94947, 0.06170, 1.00000, 0.06965, 1.00000)
    ..cubicTo(0.07281, 1.00000, 0.07599, 0.99670, 0.07599, 0.99343)
    ..cubicTo(0.07599, 0.99178, 0.07281, 0.98695, 0.06965, 0.98203)
    ..cubicTo(0.05065, 0.95438, 0.04269, 0.92666, 0.03952, 0.88432)
    ..cubicTo(0.03952, 0.85826, 0.04114, 0.83380, 0.04902, 0.77192)
    ..cubicTo(0.05219, 0.74753, 0.05536, 0.71821, 0.05697, 0.70677)
    ..cubicTo(0.06331, 0.62860, 0.05067, 0.56182, 0.01901, 0.51298)
    ..cubicTo(0.01423, 0.50645, 0.01106, 0.49996, 0.01106, 0.49996)
    ..cubicTo(0.01106, 0.49996, 0.01423, 0.49340, 0.01901, 0.48688)
    ..cubicTo(0.05067, 0.43803, 0.06331, 0.37124, 0.05697, 0.29141)
    ..cubicTo(0.05536, 0.28164, 0.05219, 0.25236, 0.04902, 0.22631)
    ..cubicTo(0.04114, 0.16609, 0.03952, 0.14159, 0.03952, 0.11553)
    ..cubicTo(0.04268, 0.07319, 0.05065, 0.04547, 0.06965, 0.01782)
    ..cubicTo(0.07598, 0.00805, 0.07760, 0.00483, 0.07443, 0.00158)
    ..cubicTo(0.07294, 0.00056, 0.07160, 0.00000, 0.07022, 0.00008)
    ..close();

  /// Paint a brace connecting two staves
  ///
  /// [canvas] - Canvas to draw on
  /// [x] - Horizontal position of the brace (left tip)
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
    canvas.save();
    canvas.translate(x, topStaffY);
    canvas.scale(totalHeight);
    canvas.drawPath(
      _bracePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  /// Calculate the width the brace occupies for a given height (teaches to the
  /// grand staff spanning `height` pixels, preserving the brace aspect ratio).
  double getWidth({required double height}) {
    return height * _widthRatio;
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
  void paint(Canvas canvas, double x, double topY, double bottomY) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = staffSpaceSize * 0.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final bracketWidth = staffSpaceSize * 1.5;

    // Vertical line
    canvas.drawLine(Offset(x, topY), Offset(x, bottomY), paint);

    // Top horizontal piece
    canvas.drawLine(Offset(x, topY), Offset(x + bracketWidth, topY), paint);

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
