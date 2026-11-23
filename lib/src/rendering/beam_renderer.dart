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

    // Use the actual stem end positions (which already have slope applied)
    final startPos = stemEndPositions.first;
    final endPos = stemEndPositions.last;

    // Adjust for stem direction (beams go away from noteheads)
    final offsetDirection = stemDirection == StemDirection.up ? -1 : 1;
    final adjustedOffset = verticalOffset * offsetDirection;

    // Define beam as a filled rectangle
    final path = Path();

    // Top edge
    path.moveTo(startPos.dx, startPos.dy + adjustedOffset);
    path.lineTo(endPos.dx, endPos.dy + adjustedOffset);

    // Bottom edge
    path.lineTo(
      endPos.dx,
      endPos.dy + adjustedOffset + (beamThickness * offsetDirection),
    );
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
  /// This is the KEY method - it calculates stem ends WITH proper slope
  List<Offset> calculateStemEnds(
      List<Note> notes,
      List<Offset> noteheadCenters,
      List<StaffPosition> staffPositions,
      StemDirection stemDirection,
      ) {
    if (notes.isEmpty) return [];

    final stemLength = StaffUnits.stemLength.toPixels(staffSpaceSize);
    final noteheadWidth = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);

    // Step 1: Calculate initial stem ends (without slope adjustment)
    final initialStemEnds = <Offset>[];

    for (int i = 0; i < notes.length; i++) {
      final center = noteheadCenters[i];

      double stemX;
      double stemY;

      if (stemDirection == StemDirection.up) {
        stemX = center.dx + noteheadWidth / 2;
        stemY = center.dy - stemLength;
      } else {
        stemX = center.dx - noteheadWidth / 2;
        stemY = center.dy + stemLength;
      }

      initialStemEnds.add(Offset(stemX, stemY));
    }

    // Step 2: Apply slope adjustment
    final adjustedEnds = _adjustForBeamSlope(
      initialStemEnds,
      staffPositions,
      stemDirection,
    );

    return adjustedEnds;
  }

  /// Adjust stem ends to create proper beam slope
  /// This is where the magic happens!
  List<Offset> _adjustForBeamSlope(
      List<Offset> stemEnds,
      List<StaffPosition> staffPositions,
      StemDirection stemDirection,
      ) {
    if (stemEnds.length < 2) return stemEnds;

    // Get Y positions of noteheads (not stem ends)
    final noteheadYPositions = staffPositions.map((pos) => pos.value).toList();

    // Calculate the slope based on notehead positions
    final firstNoteheadY = noteheadYPositions.first;
    final lastNoteheadY = noteheadYPositions.last;
    final noteheadYDiff = lastNoteheadY - firstNoteheadY;

    // Calculate horizontal distance
    final firstX = stemEnds.first.dx;
    final lastX = stemEnds.last.dx;
    final horizontalDistance = lastX - firstX;

    if (horizontalDistance == 0) return stemEnds;

    // Calculate slope based on notehead positions
    // The beam should roughly parallel the notes
    final rawSlope = (noteheadYDiff * staffSpaceSize / 2) / horizontalDistance;

    // For stems down, we need to invert the visual slope since stems go down
    final adjustedSlope = stemDirection == StemDirection.down ? -rawSlope : rawSlope;

    // Limit slope to reasonable angles (approximately ±15 degrees)
    const maxSlope = 1.5;
    final limitedSlope = adjustedSlope.clamp(-maxSlope, maxSlope);

    // If notes are relatively flat, make beam horizontal
    if (noteheadYDiff.abs() <= 1) {
      // Notes within one staff position - use horizontal beam
      final averageY = stemEnds.map((p) => p.dy).reduce((a, b) => a + b) / stemEnds.length;
      return stemEnds.map((p) => Offset(p.dx, averageY)).toList();
    }

    // Apply the slope to all stem ends
    final adjustedEnds = <Offset>[];
    final firstStemY = stemEnds.first.dy;

    for (final stemEnd in stemEnds) {
      final dx = stemEnd.dx - firstX;
      final slopedY = firstStemY + (dx * limitedSlope);
      adjustedEnds.add(Offset(stemEnd.dx, slopedY));
    }

    // Verify minimum stem lengths are maintained
    return _ensureMinimumStemLengths(
      adjustedEnds,
      stemEnds, // original positions
      stemDirection,
    );
  }

  /// Ensure all stems meet minimum length requirements
  List<Offset> _ensureMinimumStemLengths(
      List<Offset> slopedEnds,
      List<Offset> originalEnds,
      StemDirection stemDirection,
      ) {
    final minStemLength = StaffUnits.stemLength.toPixels(staffSpaceSize) * 0.8;
    final adjustedEnds = <Offset>[];

    for (int i = 0; i < slopedEnds.length; i++) {
      final slopedEnd = slopedEnds[i];
      final originalEnd = originalEnds[i];

      // Calculate the notehead Y position (where stem starts)
      final noteheadY = stemDirection == StemDirection.up
          ? originalEnd.dy + StaffUnits.stemLength.toPixels(staffSpaceSize)
          : originalEnd.dy - StaffUnits.stemLength.toPixels(staffSpaceSize);

      // Calculate current stem length
      final currentLength = (slopedEnd.dy - noteheadY).abs();

      if (currentLength < minStemLength) {
        // Extend stem to minimum length
        final adjustment = minStemLength - currentLength;
        final newY = stemDirection == StemDirection.up
            ? slopedEnd.dy - adjustment
            : slopedEnd.dy + adjustment;

        adjustedEnds.add(Offset(slopedEnd.dx, newY));
      } else {
        adjustedEnds.add(slopedEnd);
      }
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