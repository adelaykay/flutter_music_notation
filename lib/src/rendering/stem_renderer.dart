// lib/src/rendering/stem_renderer.dart

import 'package:flutter/material.dart';
import '../geometry/staff_position.dart';
import '../geometry/staff_units.dart';

/// Direction of a note stem
enum StemDirection {
  up,   // Stem points upward
  down, // Stem points downward
  none, // No stem (whole notes)
}

/// Renders note stems
class StemRenderer {
  final double staffSpaceSize;
  final Color color;

  const StemRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint a stem from the notehead and return the stem end position
  Offset paint(
      Canvas canvas,
      Offset noteheadCenter, {
        required StemDirection direction,
        bool isActive = false,
      }) {
    if (direction == StemDirection.none) return noteheadCenter;

    final thickness = StaffUnits.stemThickness.toPixels(staffSpaceSize);
    final length = StaffUnits.stemLength.toPixels(staffSpaceSize);
    final noteheadWidth = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);

    final paint = Paint()
      ..color = isActive ? Colors.green : color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Offset stemStart;
    Offset stemEnd;

    if (direction == StemDirection.up) {
      // Stem attaches to right side of notehead, goes up
      stemStart = Offset(noteheadCenter.dx + noteheadWidth / 2, noteheadCenter.dy);
      stemEnd = Offset(stemStart.dx, stemStart.dy - length);
    } else {
      // Stem attaches to left side of notehead, goes down
      stemStart = Offset(noteheadCenter.dx - noteheadWidth / 2, noteheadCenter.dy);
      stemEnd = Offset(stemStart.dx, stemStart.dy + length);
    }

    canvas.drawLine(stemStart, stemEnd, paint);

    return stemEnd; // Return stem end for flag attachment
  }

  /// Determine stem direction based on note position on staff
  /// Notes above the middle line have stems down, below have stems up
  static StemDirection determineStemDirection(StaffPosition position) {
    // Middle line is position 4
    if (position.value > 4) {
      return StemDirection.down; // High notes have stems down
    } else if (position.value < 4) {
      return StemDirection.up; // Low notes have stems up
    } else {
      // Notes on middle line: traditionally stem up, but we'll use up as default
      return StemDirection.up;
    }
  }

  /// Determine stem direction for a chord (multiple notes)
  /// Based on the average position of all notes
  static StemDirection determineStemDirectionForChord(List<StaffPosition> positions) {
    if (positions.isEmpty) return StemDirection.up;

    final averagePosition = positions
        .map((p) => p.value)
        .reduce((a, b) => a + b) / positions.length;

    return averagePosition > 4 ? StemDirection.down : StemDirection.up;
  }

  /// Get the endpoint of the stem (useful for attaching flags or beams)
  Offset getStemEnd(
      Offset noteheadCenter,
      StemDirection direction,
      ) {
    if (direction == StemDirection.none) return noteheadCenter;

    final length = StaffUnits.stemLength.toPixels(staffSpaceSize);
    final noteheadWidth = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);

    if (direction == StemDirection.up) {
      final stemX = noteheadCenter.dx + noteheadWidth / 2;
      return Offset(stemX, noteheadCenter.dy - length);
    } else {
      final stemX = noteheadCenter.dx - noteheadWidth / 2;
      return Offset(stemX, noteheadCenter.dy + length);
    }
  }
}