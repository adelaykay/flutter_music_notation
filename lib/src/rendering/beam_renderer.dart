// lib/src/rendering/beam_renderer.dart

import 'package:flutter/material.dart';
import '../models/beam.dart';
import '../models/note.dart';
import '../geometry/staff_units.dart';
import '../geometry/staff_position.dart';
import 'stem_renderer.dart';

/// Renders beams connecting eighth notes and shorter
class BeamRenderer {
  final double staffSpaceSize;
  final Color color;

  const BeamRenderer({
    required this.staffSpaceSize,
    this.color = Colors.black,
  });

  /// Paint a beam group
  void paintBeamGroup(
      Canvas canvas,
      BeamGroup beamGroup,
      List<Offset> stemEndPositions,
      StemDirection stemDirection,
      ) {
    if (beamGroup.beams.isEmpty || stemEndPositions.length < 2) return;

    // Paint primary beam
    _paintBeam(
      canvas,
      stemEndPositions,
      0, // Primary beam at stem end level
      stemDirection,
    );

    // Paint secondary beams
    final beamSpacing = staffSpaceSize * 0.5;

    for (int i = 1; i < beamGroup.beams.length; i++) {
      final beam = beamGroup.beams[i];
      final offset = i * beamSpacing;

      // For partial beams, only draw for specified notes
      if (beam.noteIndices != null) {
        _paintPartialBeam(
          canvas,
          stemEndPositions,
          beam.noteIndices!,
          offset,
          stemDirection,
        );
      } else {
        _paintBeam(
          canvas,
          stemEndPositions,
          offset,
          stemDirection,
        );
      }
    }
  }

  /// Paint a full beam connecting all notes
  void _paintBeam(
      Canvas canvas,
      List<Offset> stemEndPositions,
      double verticalOffset,
      StemDirection stemDirection,
      ) {
    if (stemEndPositions.length < 2) return;

    final beamThickness = StaffUnits.beamThickness.toPixels(staffSpaceSize);

    // Calculate beam slope
    final startPos = stemEndPositions.first;
    final endPos = stemEndPositions.last;

    // Adjust for stem direction (beams go away from noteheads)
    final offsetDirection = stemDirection == StemDirection.up ? -1 : 1;
    final adjustedOffset = verticalOffset * offsetDirection;

    // Define beam as a trapezoid
    final path = Path();

    // Top left
    path.moveTo(
      startPos.dx,
      startPos.dy + adjustedOffset,
    );

    // Top right
    path.lineTo(
      endPos.dx,
      endPos.dy + adjustedOffset,
    );

    // Bottom right
    path.lineTo(
      endPos.dx,
      endPos.dy + adjustedOffset + (beamThickness * offsetDirection),
    );

    // Bottom left
    path.lineTo(
      startPos.dx,
      startPos.dy + adjustedOffset + (beamThickness * offsetDirection),
    );

    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  /// Paint a partial beam (for fractional beaming)
  void _paintPartialBeam(
      Canvas canvas,
      List<Offset> allStemEnds,
      List<int> noteIndices,
      double verticalOffset,
      StemDirection stemDirection,
      ) {
    if (noteIndices.length < 2) {
      // Single note partial beam (hook)
      _paintBeamHook(
        canvas,
        allStemEnds[noteIndices.first],
        verticalOffset,
        stemDirection,
        // Determine hook direction based on surrounding notes
        noteIndices.first > 0, // Hook left if not first note
      );
      return;
    }

    // Multiple notes - draw full beam for these notes only
    final selectedStems = noteIndices.map((i) => allStemEnds[i]).toList();
    _paintBeam(canvas, selectedStems, verticalOffset, stemDirection);
  }

  /// Paint a beam hook (for single partial beam)
  void _paintBeamHook(
      Canvas canvas,
      Offset stemEnd,
      double verticalOffset,
      StemDirection stemDirection,
      bool hookLeft,
      ) {
    final beamThickness = StaffUnits.beamThickness.toPixels(staffSpaceSize);
    final hookLength = staffSpaceSize * 0.8;

    final offsetDirection = stemDirection == StemDirection.up ? -1 : 1;
    final adjustedOffset = verticalOffset * offsetDirection;

    final path = Path();

    if (hookLeft) {
      // Hook extends to the left
      path.moveTo(stemEnd.dx, stemEnd.dy + adjustedOffset);
      path.lineTo(stemEnd.dx - hookLength, stemEnd.dy + adjustedOffset);
      path.lineTo(
        stemEnd.dx - hookLength,
        stemEnd.dy + adjustedOffset + (beamThickness * offsetDirection),
      );
      path.lineTo(
        stemEnd.dx,
        stemEnd.dy + adjustedOffset + (beamThickness * offsetDirection),
      );
    } else {
      // Hook extends to the right
      path.moveTo(stemEnd.dx, stemEnd.dy + adjustedOffset);
      path.lineTo(stemEnd.dx + hookLength, stemEnd.dy + adjustedOffset);
      path.lineTo(
        stemEnd.dx + hookLength,
        stemEnd.dy + adjustedOffset + (beamThickness * offsetDirection),
      );
      path.lineTo(
        stemEnd.dx,
        stemEnd.dy + adjustedOffset + (beamThickness * offsetDirection),
      );
    }

    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  /// Calculate optimal beam positions for a group of notes
  List<Offset> calculateStemEnds(
      List<Note> notes,
      List<Offset> noteheadCenters,
      List<StaffPosition> staffPositions,
      StemDirection stemDirection,
      ) {
    if (notes.isEmpty) return [];

    final stemLength = StaffUnits.stemLength.toPixels(staffSpaceSize);
    final noteheadWidth = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);

    // Calculate base stem ends
    final baseStemEnds = <Offset>[];

    for (int i = 0; i < notes.length; i++) {
      final center = noteheadCenters[i];
      final position = staffPositions[i];

      double stemX;
      double stemY;

      if (stemDirection == StemDirection.up) {
        stemX = center.dx + noteheadWidth / 2;
        stemY = center.dy - stemLength;
      } else {
        stemX = center.dx - noteheadWidth / 2;
        stemY = center.dy + stemLength;
      }

      baseStemEnds.add(Offset(stemX, stemY));
    }

    // Adjust for beam slope
    final adjustedEnds = _adjustForBeamSlope(baseStemEnds, stemDirection);

    return adjustedEnds;
  }

  /// Adjust stem ends to create proper beam slope
  List<Offset> _adjustForBeamSlope(
      List<Offset> stemEnds,
      StemDirection stemDirection,
      ) {
    if (stemEnds.length < 2) return stemEnds;

    // Calculate average Y position
    final avgY = stemEnds.map((p) => p.dy).reduce((a, b) => a + b) / stemEnds.length;

    // Find highest and lowest points
    final sortedByY = List<Offset>.from(stemEnds)
      ..sort((a, b) => a.dy.compareTo(b.dy));

    final highestY = sortedByY.first.dy;
    final lowestY = sortedByY.last.dy;
    final range = (lowestY - highestY).abs();

    // If range is small, use horizontal beam
    if (range < staffSpaceSize) {
      return stemEnds.map((p) => Offset(p.dx, avgY)).toList();
    }

    // Calculate slope
    final firstX = stemEnds.first.dx;
    final lastX = stemEnds.last.dx;
    final firstY = stemEnds.first.dy;
    final lastY = stemEnds.last.dy;

    final slope = (lastY - firstY) / (lastX - firstX);

    // Limit slope (max ~15 degrees)
    final maxSlope = 0.2679; // tan(15 degrees)
    final limitedSlope = slope.clamp(-maxSlope, maxSlope);

    // Apply slope to all stem ends
    final adjustedEnds = <Offset>[];

    for (final stemEnd in stemEnds) {
      final dx = stemEnd.dx - firstX;
      final adjustedY = firstY + (dx * limitedSlope);
      adjustedEnds.add(Offset(stemEnd.dx, adjustedY));
    }

    return adjustedEnds;
  }

  /// Calculate which notes should be beamed together
  static List<BeamGroup> calculateBeamGroups(
      List<Note> notes,
      int beatsPerMeasure,
      int beatUnit,
      ) {
    return BeamGroupCalculator.calculateBeamGroups(
      notes,
      beatsPerMeasure,
      beatUnit,
    );
  }
}