// lib/src/models/slur.dart


import 'dart:ui';

import 'note.dart';
import 'tie.dart';

/// Represents a slur connecting multiple notes
/// Slurs indicate legato playing (smooth connection)
class Slur {
  /// Notes connected by this slur (can be different pitches)
  final List<Note> notes;

  /// Direction of the slur curve
  final CurveDirection? direction;

  /// Type of slur (for different musical meanings)
  final SlurType type;

  const Slur({
    required this.notes,
    this.direction,
    this.type = SlurType.standard,
  }) : assert(notes.length >= 2, 'Slur must connect at least 2 notes');

  /// First note in the slur
  Note get startNote => notes.first;

  /// Last note in the slur
  Note get endNote => notes.last;

  /// All intermediate notes
  List<Note> get middleNotes => notes.length > 2
      ? notes.sublist(1, notes.length - 1)
      : [];

  /// Whether slur should curve upward or downward
  CurveDirection getDirection() {
    if (direction != null) return direction!;

    // Default: curve opposite to stem direction of majority of notes
    // This will be refined in renderer
    return CurveDirection.up;
  }

  /// Start beat of the slur
  double get startBeat => startNote.startBeat;

  /// End beat of the slur
  double get endBeat => endNote.endBeat;

  /// Total duration spanned by the slur
  double get duration => endBeat - startBeat;

  /// Whether this slur spans multiple measures
  bool spansMultipleMeasures(int measureBeats) {
    final startMeasure = (startBeat / measureBeats).floor();
    final endMeasure = (endBeat / measureBeats).floor();
    return startMeasure != endMeasure;
  }

  /// Validate that slur makes musical sense
  bool isValid() {
    // Notes should be in chronological order
    for (int i = 0; i < notes.length - 1; i++) {
      if (notes[i].startBeat >= notes[i + 1].startBeat) {
        return false;
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Slur &&
              _listEquals(notes, other.notes) &&
              direction == other.direction &&
              type == other.type;

  bool _listEquals(List<Note> a, List<Note> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(notes), direction, type);

  @override
  String toString() => 'Slur(${notes.length} notes, ${startBeat} → ${endBeat})';
}

/// Direction of a curve (tie or slur)
enum CurveDirection {
  /// Curve above the notes
  up,

  /// Curve below the notes
  down,
}

/// Type of slur
enum SlurType {
  /// Standard legato slur
  standard,

  /// Phrase marking (longer slur, different meaning)
  phrase,

  /// Portamento (smooth glide between pitches)
  portamento,
}

/// Helper class for calculating curve properties
class CurveCalculator {
  /// Calculate optimal direction for a tie/slur based on note positions
  static CurveDirection calculateOptimalDirection(
      List<Note> notes,
      List<double> staffPositions,
      ) {
    if (notes.isEmpty || staffPositions.isEmpty) {
      return CurveDirection.up;
    }

    // Calculate average staff position (4.0 is middle line)
    final avgPosition = staffPositions.reduce((a, b) => a + b) / staffPositions.length;

    // Curve down if notes are above middle, up if below
    return avgPosition > 4.0 ? CurveDirection.down : CurveDirection.up;
  }

  /// Calculate control points for a Bézier curve
  /// Returns [controlPoint1, controlPoint2] for a cubic Bézier
  static List<Offset> calculateBezierControlPoints(
      Offset start,
      Offset end,
      CurveDirection direction,
      double curvature,
      ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;

    // Height of the curve (perpendicular to the line)
    final curveHeight = curvature * (direction == CurveDirection.up ? -1 : 1);

    // Control points at 1/3 and 2/3 along the curve
    final cp1x = start.dx + dx * 0.33;
    final cp1y = start.dy + dy * 0.33 + curveHeight;

    final cp2x = start.dx + dx * 0.67;
    final cp2y = start.dy + dy * 0.67 + curveHeight;

    return [
      Offset(cp1x, cp1y),
      Offset(cp2x, cp2y),
    ];
  }

  /// Calculate optimal curvature based on horizontal distance
  static double calculateCurvature(double horizontalDistance, {bool isTie = false}) {
    // Ties are generally less curved than slurs
    final baseHeight = isTie ? 8.0 : 12.0;

    // Longer curves need more height, but with diminishing returns
    final scaledHeight = baseHeight * (1 + (horizontalDistance / 100).clamp(0, 1));

    return scaledHeight;
  }

  /// Check if curve would collide with any notes
  static bool wouldCollideWithNotes(
      Offset start,
      Offset end,
      List<Offset> notePositions,
      double clearance,
      ) {
    // Simple check: see if any note is too close to the curve path
    // In practice, would use more sophisticated collision detection

    for (final notePos in notePositions) {
      // Check if note is roughly between start and end horizontally
      if (notePos.dx < start.dx || notePos.dx > end.dx) continue;

      // Check vertical distance from straight line between start and end
      final lineY = start.dy + (end.dy - start.dy) *
          ((notePos.dx - start.dx) / (end.dx - start.dx));

      if ((notePos.dy - lineY).abs() < clearance) {
        return true;
      }
    }

    return false;
  }
}

/// Represents a tie that spans across a system break
class SystemSpanningTie {
  /// The tie that's split across systems
  final Tie originalTie;

  /// End point of tie in first system (right edge)
  final Offset firstSystemEnd;

  /// Start point of tie in second system (left edge)
  final Offset secondSystemStart;

  const SystemSpanningTie({
    required this.originalTie,
    required this.firstSystemEnd,
    required this.secondSystemStart,
  });
}

/// Represents a slur that spans across a system break
class SystemSpanningSlur {
  /// The original slur that's split
  final Slur originalSlur;

  /// Notes in the first system
  final List<Note> firstSystemNotes;

  /// Notes in the second system
  final List<Note> secondSystemNotes;

  const SystemSpanningSlur({
    required this.originalSlur,
    required this.firstSystemNotes,
    required this.secondSystemNotes,
  });
}