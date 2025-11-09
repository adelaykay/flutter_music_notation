// lib/src/rendering/slur_renderer.dart

import 'package:flutter/material.dart';

import '../models/slur.dart';
import '../geometry/staff_units.dart';

/// Renders slurs (curved lines connecting different notes for legato)
class SlurRenderer {
  final double staffSpaceSize;
  final Color color;

  const SlurRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint a slur over multiple notes
  void paintSlur(
      Canvas canvas,
      Slur slur,
      List<Offset> noteheadCenters,
      CurveDirection direction,
      ) {
    if (noteheadCenters.length < 2) return;

    final startCenter = noteheadCenters.first;
    final endCenter = noteheadCenters.last;

    // Calculate slur attachment points
    final startPoint = _calculateSlurAttachment(
      startCenter,
      direction,
      true, // isStart
    );

    final endPoint = _calculateSlurAttachment(
      endCenter,
      direction,
      false, // isEnd
    );

    // Check if slur would collide with middle notes
    final hasCollision = _wouldCollideWithMiddleNotes(
      startPoint,
      endPoint,
      noteheadCenters.sublist(1, noteheadCenters.length - 1),
      direction,
    );

    // Adjust curvature if there's collision
    final horizontalDistance = (endPoint.dx - startPoint.dx).abs();
    var curvature = CurveCalculator.calculateCurvature(
      horizontalDistance,
      isTie: false,
    );

    if (hasCollision) {
      curvature *= 1.5; // Make it more curved to avoid notes
    }

    _drawCurve(canvas, startPoint, endPoint, direction, curvature, slur.type);
  }

  /// Paint a phrase marking (longer, more gradual slur)
  void paintPhraseMarking(
      Canvas canvas,
      Slur slur,
      List<Offset> noteheadCenters,
      CurveDirection direction,
      ) {
    if (noteheadCenters.length < 2) return;

    final startCenter = noteheadCenters.first;
    final endCenter = noteheadCenters.last;

    final startPoint = _calculateSlurAttachment(startCenter, direction, true);
    final endPoint = _calculateSlurAttachment(endCenter, direction, false);

    // Phrase markings are more gradual
    final horizontalDistance = (endPoint.dx - startPoint.dx).abs();
    final curvature = horizontalDistance * 0.08; // Gentler curve

    _drawCurve(canvas, startPoint, endPoint, direction, curvature, slur.type);
  }

  /// Calculate where slur attaches to a notehead
  Offset _calculateSlurAttachment(
      Offset noteheadCenter,
      CurveDirection direction,
      bool isStart,
      ) {
    final noteheadWidth = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);
    final noteheadHeight = StaffUnits.noteheadHeight.toPixels(staffSpaceSize);

    // Vertical offset based on direction
    final verticalOffset = direction == CurveDirection.up
        ? -(noteheadHeight / 2 + staffSpaceSize * 0.3)
        : (noteheadHeight / 2 + staffSpaceSize * 0.3);

    // Horizontal position
    final horizontalOffset = isStart
        ? noteheadWidth * 0.3
        : -noteheadWidth * 0.3;

    return Offset(
      noteheadCenter.dx + horizontalOffset,
      noteheadCenter.dy + verticalOffset,
    );
  }

  /// Check if slur would collide with middle notes
  bool _wouldCollideWithMiddleNotes(
      Offset start,
      Offset end,
      List<Offset> middleNotes,
      CurveDirection direction,
      ) {
    if (middleNotes.isEmpty) return false;

    final clearance = staffSpaceSize * 1.5;
    return CurveCalculator.wouldCollideWithNotes(
      start,
      end,
      middleNotes,
      clearance,
    );
  }

  /// Draw the slur curve
  void _drawCurve(
      Canvas canvas,
      Offset start,
      Offset end,
      CurveDirection direction,
      double curvature,
      SlurType type,
      ) {
    // Calculate control points
    final controlPoints = CurveCalculator.calculateBezierControlPoints(
      start,
      end,
      direction,
      curvature,
    );

    // Draw main curve
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

    // Stroke width depends on type
    final strokeWidth = type == SlurType.phrase
        ? staffSpaceSize * 0.12
        : staffSpaceSize * 0.15;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);

    // Add thickness for standard slurs
    if (type == SlurType.standard) {
      final thicknessPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = staffSpaceSize * 0.1
        ..strokeCap = StrokeCap.round;

      final offsetMultiplier = direction == CurveDirection.up ? 1 : -1;
      final thickPath = Path();
      thickPath.moveTo(start.dx, start.dy + (2 * offsetMultiplier));
      thickPath.cubicTo(
        controlPoints[0].dx,
        controlPoints[0].dy + (2 * offsetMultiplier),
        controlPoints[1].dx,
        controlPoints[1].dy + (2 * offsetMultiplier),
        end.dx,
        end.dy + (2 * offsetMultiplier),
      );

      canvas.drawPath(thickPath, thicknessPaint);
    }
  }

  /// Paint a slur that spans across systems
  void paintSystemSpanningSlur(
      Canvas canvas,
      SystemSpanningSlur slur,
      List<Offset> firstSystemNotes,
      List<Offset> secondSystemNotes,
      double firstSystemRightEdge,
      double secondSystemLeftEdge,
      CurveDirection direction,
      ) {
    // Draw first part (to system edge)
    if (firstSystemNotes.isNotEmpty) {
      final startPoint = _calculateSlurAttachment(
        firstSystemNotes.first,
        direction,
        true,
      );
      final endPoint = Offset(firstSystemRightEdge, startPoint.dy);

      final curvature = CurveCalculator.calculateCurvature(
        (endPoint.dx - startPoint.dx).abs(),
        isTie: false,
      );

      _drawCurve(canvas, startPoint, endPoint, direction, curvature, slur.originalSlur.type);
    }

    // Draw second part (from system edge)
    if (secondSystemNotes.isNotEmpty) {
      final startPoint = Offset(secondSystemLeftEdge, secondSystemNotes.first.dy);
      final endPoint = _calculateSlurAttachment(
        secondSystemNotes.last,
        direction,
        false,
      );

      final curvature = CurveCalculator.calculateCurvature(
        (endPoint.dx - startPoint.dx).abs(),
        isTie: false,
      );

      _drawCurve(canvas, startPoint, endPoint, direction, curvature, slur.originalSlur.type);
    }
  }
}