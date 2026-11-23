// lib/src/models/tuplet_bracket.dart

import 'note.dart';
import 'duration.dart';

/// Represents a tuplet bracket with number
/// Displays as a bracket with a number (e.g., "3" for triplet)
class TupletBracket {
  /// Notes in this tuplet
  final List<Note> notes;

  /// The tuplet ratio (e.g., Tuplet.triplet for 3:2)
  final Tuplet tuplet;

  /// Whether to show the bracket
  /// Sometimes only the number is shown (when notes are beamed)
  final bool showBracket;

  /// Direction of the bracket (above or below notes)
  final TupletDirection? direction;

  /// Whether to show the ratio (e.g., "3:2" instead of just "3")
  final bool showRatio;

  const TupletBracket({
    required this.notes,
    required this.tuplet,
    this.showBracket = true,
    this.direction,
    this.showRatio = false,
  }) : assert(notes.length >= 2, 'Tuplet must contain at least 2 notes');

  /// Start beat of the tuplet
  double get startBeat => notes.first.startBeat;

  /// End beat of the tuplet
  double get endBeat => notes.last.endBeat;

  /// Total duration of the tuplet
  double get duration => endBeat - startBeat;

  /// Text to display (e.g., "3" or "3:2")
  String get displayText {
    if (showRatio) {
      return '${tuplet.actualNotes}:${tuplet.normalNotes}';
    }
    return tuplet.actualNotes.toString();
  }

  /// Whether notes in this tuplet are beamed
  /// If beamed, bracket is usually omitted
  bool get notesAreBeamed {
    return notes.every((note) => note.duration.needsFlag);
  }

  /// Whether to actually draw the bracket
  /// Often omitted when notes are beamed
  bool get shouldDrawBracket {
    if (!showBracket) return false;
    // Don't show bracket if all notes are beamed
    if (notesAreBeamed) return false;
    return true;
  }

  /// Validate that all notes have the correct tuplet
  bool isValid() {
    return notes.every((note) => note.duration.tuplet == tuplet);
  }

  /// Calculate optimal direction based on note positions
  TupletDirection calculateDirection(List<double> staffPositions) {
    if (direction != null) return direction!;

    // Average position (4.0 is middle line)
    final avgPosition =
        staffPositions.reduce((a, b) => a + b) / staffPositions.length;

    // Place bracket opposite to where notes are
    return avgPosition > 4.0 ? TupletDirection.above : TupletDirection.below;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TupletBracket &&
          _listEquals(notes, other.notes) &&
          tuplet == other.tuplet &&
          showBracket == other.showBracket &&
          direction == other.direction &&
          showRatio == other.showRatio;

  bool _listEquals(List<Note> a, List<Note> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(notes),
    tuplet,
    showBracket,
    direction,
    showRatio,
  );

  @override
  String toString() => 'TupletBracket($displayText, ${notes.length} notes)';
}

/// Direction of tuplet bracket
enum TupletDirection {
  /// Bracket above notes
  above,

  /// Bracket below notes
  below,
}

/// Helper class for working with tuplets
class TupletHelper {
  /// Common tuplet ratios
  static const triplet = Tuplet(actualNotes: 3, normalNotes: 2);
  static const quintuplet = Tuplet(actualNotes: 5, normalNotes: 4);
  static const sextuplet = Tuplet(actualNotes: 6, normalNotes: 4);
  static const septuplet = Tuplet(actualNotes: 7, normalNotes: 4);

  /// Detect tuplet groups in a list of notes
  static List<TupletBracket> detectTuplets(List<Note> notes) {
    final tupletBrackets = <TupletBracket>[];

    // Group consecutive notes with same tuplet
    List<Note> currentGroup = [];
    Tuplet? currentTuplet;

    for (final note in notes) {
      if (note.duration.tuplet != null) {
        if (note.duration.tuplet == currentTuplet) {
          // Continue current group
          currentGroup.add(note);
        } else {
          // Save previous group if exists
          if (currentGroup.length >= 2 && currentTuplet != null) {
            tupletBrackets.add(
              TupletBracket(
                notes: List.from(currentGroup),
                tuplet: currentTuplet,
              ),
            );
          }

          // Start new group
          currentGroup = [note];
          currentTuplet = note.duration.tuplet;
        }
      } else {
        // No tuplet - save previous group if exists
        if (currentGroup.length >= 2 && currentTuplet != null) {
          tupletBrackets.add(
            TupletBracket(
              notes: List.from(currentGroup),
              tuplet: currentTuplet,
            ),
          );
        }
        currentGroup = [];
        currentTuplet = null;
      }
    }

    // Save final group if exists
    if (currentGroup.length >= 2 && currentTuplet != null) {
      tupletBrackets.add(
        TupletBracket(notes: currentGroup, tuplet: currentTuplet),
      );
    }

    return tupletBrackets;
  }

  /// Create a triplet bracket for notes
  static TupletBracket createTriplet(
    List<Note> notes, {
    bool showBracket = true,
    TupletDirection? direction,
  }) {
    return TupletBracket(
      notes: notes,
      tuplet: triplet,
      showBracket: showBracket,
      direction: direction,
    );
  }

  /// Create a quintuplet bracket
  static TupletBracket createQuintuplet(
    List<Note> notes, {
    bool showBracket = true,
    TupletDirection? direction,
  }) {
    return TupletBracket(
      notes: notes,
      tuplet: quintuplet,
      showBracket: showBracket,
      direction: direction,
    );
  }

  /// Calculate the visual duration (in normal beats) for tuplet notes
  /// This is used for spacing calculations
  static double calculateVisualDuration(Note note) {
    if (note.duration.tuplet == null) {
      return note.duration.beats;
    }

    // Remove tuplet modification to get visual duration
    final baseDuration = note.duration.type.baseBeats * 4.0;

    // Apply dots
    double dotMultiplier = 1.0;
    for (int i = 0; i < note.duration.dots; i++) {
      dotMultiplier += (0.5 / (1 << i));
    }

    return baseDuration * dotMultiplier;
  }
}

/// Nested tuplet structure (rare but possible)
class NestedTuplet {
  /// Outer tuplet bracket
  final TupletBracket outerTuplet;

  /// Inner tuplet brackets
  final List<TupletBracket> innerTuplets;

  const NestedTuplet({required this.outerTuplet, required this.innerTuplets});

  /// Whether this nested tuplet is valid
  bool isValid() {
    // All inner tuplets must be contained within outer tuplet
    for (final inner in innerTuplets) {
      if (inner.startBeat < outerTuplet.startBeat ||
          inner.endBeat > outerTuplet.endBeat) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() =>
      'NestedTuplet(outer: ${outerTuplet.displayText}, inner: ${innerTuplets.length})';
}
