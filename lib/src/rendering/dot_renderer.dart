// lib/src/rendering/dot_renderer.dart

import 'package:flutter/material.dart';
import '../geometry/staff_position.dart';
import '../geometry/staff_units.dart';

/// Renders augmentation dots for dotted notes
class DotRenderer {
  final double staffSpaceSize;
  final Color color;

  const DotRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint dot(s) after a note
  /// Dots are placed to the right of the notehead
  void paintNoteDots(
      Canvas canvas,
      Offset noteheadCenter,
      StaffPosition staffPosition,
      int dotCount,
      ) {
    if (dotCount == 0) return;

    final radius = StaffUnits.dotRadius.toPixels(staffSpaceSize);
    final noteheadWidth = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);
    final spacing = StaffUnits.dotSpacing.toPixels(staffSpaceSize);

    // Dots are placed to the right of the notehead
    double xOffset = noteheadWidth / 2 + spacing;

    // If note is on a line, move dot up to the space above
    final yOffset = staffPosition.isLine ? -staffSpaceSize / 2 : 0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw each dot
    for (int i = 0; i < dotCount; i++) {
      final dotCenter = Offset(
        noteheadCenter.dx + xOffset,
        noteheadCenter.dy + yOffset,
      );

      canvas.drawCircle(dotCenter, radius, paint);

      // Space subsequent dots
      xOffset += spacing;
    }
  }

  /// Paint dot(s) after a rest
  void paintRestDots(
      Canvas canvas,
      Offset restCenter,
      int dotCount,
      ) {
    if (dotCount == 0) return;

    final radius = StaffUnits.dotRadius.toPixels(staffSpaceSize);
    final spacing = StaffUnits.dotSpacing.toPixels(staffSpaceSize);

    // Dots are placed to the right of the rest
    double xOffset = spacing * 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw each dot
    for (int i = 0; i < dotCount; i++) {
      final dotCenter = Offset(
        restCenter.dx + xOffset,
        restCenter.dy,
      );

      canvas.drawCircle(dotCenter, radius, paint);

      // Space subsequent dots
      xOffset += spacing;
    }
  }

  /// Calculate total width occupied by dots (for spacing calculations)
  double getDotsWidth(int dotCount) {
    if (dotCount == 0) return 0;

    final spacing = StaffUnits.dotSpacing.toPixels(staffSpaceSize);
    return spacing * (dotCount + 1); // Space before first dot + spaces between
  }
}