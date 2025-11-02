// lib/src/rendering/staff_renderer.dart

import 'package:flutter/material.dart';
import '../geometry/staff_position.dart';
import '../geometry/staff_units.dart';

/// Renders a musical staff (5 horizontal lines)
class StaffRenderer {
  final double staffSpaceSize;
  final Color lineColor;
  final int lineCount;

  const StaffRenderer({
    this.staffSpaceSize = 10.0,
    this.lineColor = Colors.black,
    this.lineCount = 5,
  });

  /// Total height of the staff in pixels
  double get height => staffSpaceSize * (lineCount - 1);

  /// Paint the staff lines
  void paint(Canvas canvas, Offset topLeft, double width) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = StaffUnits.staffLineThickness.toPixels(staffSpaceSize)
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < lineCount; i++) {
      final y = topLeft.dy + (i * staffSpaceSize);
      canvas.drawLine(
        Offset(topLeft.dx, y),
        Offset(topLeft.dx + width, y),
        paint,
      );
    }
  }

  /// Convert a staff position to Y coordinate (pixels from top of staff)
  double positionToY(StaffPosition position) {
    // Position 0 is bottom line, position 8 is top line
    // Invert so higher positions are higher on screen
    final invertedPosition = 8.0 - position.value;
    return (invertedPosition * staffSpaceSize) / 2;
  }

  /// Paint ledger lines for a note at the given position
  void paintLedgerLines(Canvas canvas, Offset noteCenter, StaffPosition position) {
    final ledgerPositions = position.getLedgerLinePositions();
    if (ledgerPositions.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = StaffUnits.ledgerLineThickness.toPixels(staffSpaceSize)
      ..style = PaintingStyle.stroke;

    final noteheadWidth = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);
    final extension = StaffUnits.ledgerLineExtension.toPixels(staffSpaceSize);
    final lineWidth = noteheadWidth + (2 * extension);

    for (final ledgerPos in ledgerPositions) {
      final y = positionToY(StaffPosition(ledgerPos.toDouble())) + noteCenter.dy - positionToY(position);
      canvas.drawLine(
        Offset(noteCenter.dx - lineWidth / 2, y),
        Offset(noteCenter.dx + lineWidth / 2, y),
        paint,
      );
    }
  }
}