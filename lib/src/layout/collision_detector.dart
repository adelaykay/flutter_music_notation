// lib/src/layout/collision_detector.dart

import 'dart:ui';
import '../models/note.dart';
import '../models/pitch.dart';
import '../geometry/staff_position.dart';
import '../geometry/staff_units.dart';
import '../rendering/stem_renderer.dart';

/// Detects and resolves collisions between notation elements
class CollisionDetector {
  final double staffSpaceSize;

  const CollisionDetector({
    required this.staffSpaceSize,
  });

  /// Check if two rectangles collide
  bool rectanglesCollide(Rect a, Rect b, {double padding = 2.0}) {
    return a.inflate(padding).overlaps(b.inflate(padding));
  }

  /// Calculate accidental placement for a chord to avoid collisions
  /// Returns X offset for each note's accidental
  Map<int, double> resolveChordAccidentals(
      List<Note> notes,
      ClefType clef,
      double baseX,
      ) {
    final offsets = <int, double>{};

    // Sort notes by pitch (low to high)
    final sortedNotes = List<Note>.from(notes)
      ..sort((a, b) => a.pitch.midiNumber.compareTo(b.pitch.midiNumber));

    // Group notes by whether they need accidentals
    final notesWithAccidentals = sortedNotes
        .where((n) => n.pitch.accidental != Accidental.natural)
        .toList();

    if (notesWithAccidentals.isEmpty) return offsets;

    // Calculate staff positions
    final positions = notesWithAccidentals
        .map((n) => StaffPosition.forPitch(n.pitch, clef))
        .toList();

    // Stack accidentals to avoid collisions
    final accidentalWidth = StaffUnits.accidentalWidth.toPixels(staffSpaceSize);
    final accidentalHeight = StaffUnits.accidentalHeight.toPixels(staffSpaceSize);
    final minVerticalGap = staffSpaceSize * 0.5;

    // Track occupied vertical spaces
    final occupiedColumns = <int, List<Rect>>{}; // column -> list of rects

    for (int i = 0; i < notesWithAccidentals.length; i++) {
      final note = notesWithAccidentals[i];
      final position = positions[i];
      final midiNumber = note.pitch.midiNumber;

      // Calculate Y position for this accidental
      final noteY = position.value * (staffSpaceSize / 2);

      // Create rect for this accidental
      final accidentalRect = Rect.fromLTWH(
        0, // X will be determined by column
        noteY - accidentalHeight / 2,
        accidentalWidth,
        accidentalHeight,
      );

      // Find the leftmost column where this accidental fits
      int column = 0;
      bool foundColumn = false;

      while (!foundColumn && column < 10) {
        // Check for collisions in this column
        final rectsInColumn = occupiedColumns[column] ?? [];
        bool hasCollision = false;

        for (final existingRect in rectsInColumn) {
          if (_verticallyOverlaps(
            accidentalRect,
            existingRect,
            minVerticalGap,
          )) {
            hasCollision = true;
            break;
          }
        }

        if (!hasCollision) {
          foundColumn = true;
          // Add to this column
          occupiedColumns.putIfAbsent(column, () => []).add(accidentalRect);
          // Calculate X offset
          offsets[midiNumber] = -(column + 1) * (accidentalWidth + staffSpaceSize * 0.3);
        } else {
          column++;
        }
      }
    }

    return offsets;
  }

  /// Check if two rectangles overlap vertically (within a margin)
  bool _verticallyOverlaps(Rect a, Rect b, double margin) {
    return !(a.bottom + margin < b.top || a.top - margin > b.bottom);
  }

  /// Calculate optimal stem direction for a chord to minimize collisions
  StemDirection calculateOptimalStemDirection(
      List<StaffPosition> positions,
      ) {
    if (positions.isEmpty) return StemDirection.up;

    // Calculate average position (4 is middle line)
    final avgPosition = positions
        .map((p) => p.value)
        .reduce((a, b) => a + b) /
        positions.length;

    // Notes above middle line should have stems down
    // Notes below middle line should have stems up
    return avgPosition > 4 ? StemDirection.down : StemDirection.up;
  }

  /// Detect if noteheads in a chord should be offset horizontally
  /// (for seconds - notes one step apart)
  ChordNoteheadOffsets calculateChordNoteheadOffsets(
      List<Note> notes,
      ClefType clef,
      ) {
    final offsets = <int, double>{};

    // Sort notes by pitch
    final sortedNotes = List<Note>.from(notes)
      ..sort((a, b) => a.pitch.midiNumber.compareTo(b.pitch.midiNumber));

    // Calculate staff positions
    final positions = sortedNotes
        .map((n) => StaffPosition.forPitch(n.pitch, clef))
        .toList();

    // Check for seconds (adjacent positions)
    for (int i = 0; i < positions.length - 1; i++) {
      final currentPos = positions[i].value;
      final nextPos = positions[i + 1].value;

      // If notes are on adjacent positions (a second apart)
      if ((nextPos - currentPos).abs() == 1.0) {
        // Offset the higher note to the right
        final higherNote = sortedNotes[i + 1];
        final noteheadWidth = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);
        offsets[higherNote.pitch.midiNumber] = noteheadWidth * 0.6;
      }
    }

    return ChordNoteheadOffsets(offsets: offsets);
  }

  /// Calculate bounding box for a note at a given position
  Rect getNoteheadBounds(
      double centerX,
      double centerY,
      ) {
    final width = StaffUnits.noteheadWidth.toPixels(staffSpaceSize);
    final height = StaffUnits.noteheadHeight.toPixels(staffSpaceSize);

    return Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: width,
      height: height,
    );
  }

  /// Calculate bounding box for an accidental
  Rect getAccidentalBounds(
      double centerX,
      double centerY,
      ) {
    final width = StaffUnits.accidentalWidth.toPixels(staffSpaceSize);
    final height = StaffUnits.accidentalHeight.toPixels(staffSpaceSize);

    return Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: width,
      height: height,
    );
  }

  /// Check if two notes are close enough to potentially collide
  bool notesAreAdjacent(
      StaffPosition pos1,
      StaffPosition pos2,
      ) {
    return (pos1.value - pos2.value).abs() <= 1.0;
  }

  /// Calculate minimum horizontal spacing needed between two elements
  /// to avoid collision
  double calculateMinimumSpacing(
      dynamic element1,
      dynamic element2,
      ClefType clef,
      ) {
    // Base minimum spacing
    double minSpacing = StaffUnits.minimumNoteSpacing.toPixels(staffSpaceSize);

    // Increase spacing if notes have accidentals
    if (element1 is Note && element1.pitch.accidental != Accidental.natural) {
      minSpacing += StaffUnits.accidentalWidth.toPixels(staffSpaceSize);
    }

    // Increase spacing for rests (they need more visual space)
    if (element1 is Rest || element2 is Rest) {
      minSpacing *= 1.2;
    }

    // Check if notes are vertically adjacent (might visually collide)
    if (element1 is Note && element2 is Note) {
      final pos1 = StaffPosition.forPitch(element1.pitch, clef);
      final pos2 = StaffPosition.forPitch(element2.pitch, clef);

      if (notesAreAdjacent(pos1, pos2)) {
        minSpacing *= 1.3;
      }
    }

    return minSpacing;
  }
}

/// Result of chord notehead offset calculation
class ChordNoteheadOffsets {
  /// Map of MIDI number -> horizontal offset
  final Map<int, double> offsets;

  const ChordNoteheadOffsets({
    required this.offsets,
  });

  /// Get offset for a specific note (returns 0 if not offset)
  double getOffset(int midiNumber) {
    return offsets[midiNumber] ?? 0.0;
  }

  /// Whether a note should be offset
  bool isOffset(int midiNumber) {
    return offsets.containsKey(midiNumber);
  }
}

/// Collision detection result
class CollisionResult {
  final bool hasCollision;
  final List<String> collisions;
  final Map<String, double> suggestedOffsets;

  const CollisionResult({
    required this.hasCollision,
    required this.collisions,
    required this.suggestedOffsets,
  });

  /// No collision detected
  static const none = CollisionResult(
    hasCollision: false,
    collisions: [],
    suggestedOffsets: {},
  );
}

/// Helper class for tracking element positions and detecting collisions
class ElementPositionTracker {
  final Map<String, Rect> _elements = {};

  /// Add an element with its bounding box
  void addElement(String id, Rect bounds) {
    _elements[id] = bounds;
  }

  /// Check if a new element would collide with existing elements
  CollisionResult checkCollision(String id, Rect bounds, {double padding = 2.0}) {
    final collisions = <String>[];

    for (final entry in _elements.entries) {
      if (entry.value.inflate(padding).overlaps(bounds.inflate(padding))) {
        collisions.add(entry.key);
      }
    }

    return CollisionResult(
      hasCollision: collisions.isNotEmpty,
      collisions: collisions,
      suggestedOffsets: {},
    );
  }

  /// Clear all tracked elements
  void clear() {
    _elements.clear();
  }

  /// Get bounds for a specific element
  Rect? getBounds(String id) {
    return _elements[id];
  }
}