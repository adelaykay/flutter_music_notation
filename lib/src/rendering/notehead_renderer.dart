// lib/src/rendering/notehead_renderer.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../geometry/staff_units.dart';
import '../models/duration.dart';

/// Renders noteheads (filled or hollow ovals)
class NoteheadRenderer {
  final double staffSpaceSize;
  final Color color;

  const NoteheadRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint a notehead at the given center position
  void paint(
      Canvas canvas,
      Offset center, {
        required bool filled,
        bool isActive = false,
      }) {
    final width = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);
    final height = StaffUnits.noteheadHeight.toPixels(staffSpaceSize);

    // Save canvas state for rotation
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Rotate notehead slightly for traditional appearance (-20 degrees)
    canvas.rotate(-20 * math.pi / 180);

    // Create oval path
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );

    final paint = Paint()
      ..color = isActive ? Colors.green : color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = filled ? 0 : 1.5;

    canvas.drawOval(rect, paint);

    // Draw glow for active notes
    if (isActive) {
      final glowPaint = Paint()
        ..color = Colors.green.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..style = PaintingStyle.fill;
      canvas.drawOval(rect, glowPaint);
    }

    // For hollow noteheads, draw inner outline for better definition
    if (!filled) {
      final innerRect = Rect.fromCenter(
        center: Offset.zero,
        width: width - 2,
        height: height - 2,
      );
      canvas.drawOval(innerRect, paint);
    }

    canvas.restore();
  }

  /// Determine if a notehead should be filled based on duration
  static bool shouldBeFilled(NoteDuration duration) {
    // Quarter notes and shorter are filled (black)
    // Half notes and longer are hollow (white)
    return duration.type.isFilledNotehead;
  }

  /// Get the bounds of the notehead (useful for collision detection)
  Rect getBounds(Offset center) {
    final width = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);
    final height = StaffUnits.noteheadHeight.toPixels(staffSpaceSize);

    return Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );
  }
}