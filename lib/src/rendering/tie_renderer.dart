// lib/src/rendering/tie_renderer.dart

import 'package:flutter/material.dart';
import '../models/tie.dart';
import '../models/slur.dart';
import '../geometry/staff_units.dart';

/// Renders ties (curved lines connecting same-pitch notes)
class TieRenderer {
  final double staffSpaceSize;
  final Color color;

  const TieRenderer({required this.staffSpaceSize, this.color = Colors.black});

  /// Paint a tie between two notes
  void paintTie(
    Canvas canvas,
    Tie tie,
    Offset startNoteheadCenter,
    Offset endNoteheadCenter,
    CurveDirection direction,
  ) {
    // Calculate attachment points (edges of noteheads)
    final noteheadWidth = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);

    // A tie starts just past the notehead, a little to its curved side, so it
    // runs beside the heads rather than through them.
    final lift =
        staffSpaceSize * 0.35 * (direction == CurveDirection.up ? -1 : 1);
    final startPoint = Offset(
      startNoteheadCenter.dx + noteheadWidth * 0.55,
      startNoteheadCenter.dy + lift,
    );

    var endPoint = Offset(
      endNoteheadCenter.dx - noteheadWidth * 0.55,
      endNoteheadCenter.dy + lift,
    );
    // Notes set close together still get a visible tie.
    final minLength = staffSpaceSize * 1.2;
    if (endPoint.dx - startPoint.dx < minLength) {
      endPoint = Offset(startPoint.dx + minLength, endPoint.dy);
    }

    _drawCurve(canvas, startPoint, endPoint, direction, true);
  }

  /// Paint a tie that ends at system edge (for ties crossing systems)
  void paintSystemEndTie(
    Canvas canvas,
    Offset startNoteheadCenter,
    double systemRightEdge,
    CurveDirection direction,
  ) {
    final noteheadWidth = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);

    final startPoint = Offset(
      startNoteheadCenter.dx + noteheadWidth / 2,
      startNoteheadCenter.dy,
    );

    final endPoint = Offset(systemRightEdge, startNoteheadCenter.dy);

    _drawCurve(canvas, startPoint, endPoint, direction, true);
  }

  /// Paint a tie that starts at system edge (for ties crossing systems)
  void paintSystemStartTie(
    Canvas canvas,
    double systemLeftEdge,
    Offset endNoteheadCenter,
    CurveDirection direction,
  ) {
    final noteheadWidth = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);

    final startPoint = Offset(systemLeftEdge, endNoteheadCenter.dy);

    final endPoint = Offset(
      endNoteheadCenter.dx - noteheadWidth / 2,
      endNoteheadCenter.dy,
    );

    _drawCurve(canvas, startPoint, endPoint, direction, true);
  }

  /// Draw the actual tie curve
  void _drawCurve(
    Canvas canvas,
    Offset start,
    Offset end,
    CurveDirection direction,
    bool isTie,
  ) {
    final horizontalDistance = (end.dx - start.dx).abs();

    // Calculate curvature
    var curvature = CurveCalculator.calculateCurvature(
      horizontalDistance,
      isTie: isTie,
    );
    // A tie's arch grows with its length: a short tie is a shallow arc, not a
    // "v". Capped by the staff size so a long one stays flat.
    if (isTie) {
      curvature = (horizontalDistance * 0.28).clamp(
        staffSpaceSize * 0.35,
        staffSpaceSize * 1.1,
      );
    }

    // Calculate control points
    final controlPoints = CurveCalculator.calculateBezierControlPoints(
      start,
      end,
      direction,
      curvature,
    );

    // Draw the curve as a thick path
    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.cubicTo(
      controlPoints[0].dx,
      controlPoints[0].dy,
      controlPoints[1].dx,
      controlPoints[1].dy,
      end.dx,
      end.dy,
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = staffSpaceSize * 0.15
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);

    // Draw second curve slightly offset to create thickness
    final thicknessPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = staffSpaceSize * 0.1
      ..strokeCap = StrokeCap.round;

    final offsetMultiplier = direction == CurveDirection.up ? 1 : -1;
    final thickPath = Path();
    // The thick middle of the curve, scaled with the staff.
    final thick = staffSpaceSize * 0.15 * offsetMultiplier;
    thickPath.moveTo(start.dx, start.dy);
    thickPath.cubicTo(
      controlPoints[0].dx,
      controlPoints[0].dy + thick,
      controlPoints[1].dx,
      controlPoints[1].dy + thick,
      end.dx,
      end.dy,
    );

    canvas.drawPath(thickPath, thicknessPaint);
  }
}
