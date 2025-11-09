// lib/src/models/tie.dart

import 'note.dart';
import 'slur.dart';

/// Represents a tie connecting two notes of the same pitch
/// Ties indicate that the note should be held across both durations
class Tie {
  /// The first note (where tie starts)
  final Note startNote;

  /// The second note (where tie ends)
  final Note endNote;

  /// Direction of the tie curve (above or below noteheads)
  final CurveDirection? direction;

  const Tie({
    required this.startNote,
    required this.endNote,
    this.direction,
  });

  /// Validate that this is a valid tie
  /// Ties must connect notes of the same pitch
  bool isValid() {
    return startNote.pitch == endNote.pitch;
  }

  /// Whether tie should curve upward (above notes) or downward (below notes)
  /// If not specified, determined automatically based on note position
  CurveDirection getDirection() {
    if (direction != null) return direction!;

    // Default: curve up if notes are below middle line, down if above
    // This will be refined based on staff position in renderer
    return CurveDirection.up;
  }

  /// Total duration spanned by the tie (from start to end of second note)
  double get totalDuration => (endNote.endBeat - startNote.startBeat);

  /// Whether this tie crosses a measure boundary
  /// (will need special handling for rendering)
  bool crossesMeasure(int measureBeats) {
    final startMeasure = (startNote.startBeat / measureBeats).floor();
    final endMeasure = (endNote.startBeat / measureBeats).floor();
    return startMeasure != endMeasure;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Tie &&
              startNote == other.startNote &&
              endNote == other.endNote &&
              direction == other.direction;

  @override
  int get hashCode => Object.hash(startNote, endNote, direction);

  @override
  String toString() => 'Tie(${startNote.pitch}, ${startNote.startBeat} → ${endNote.endBeat})';
}