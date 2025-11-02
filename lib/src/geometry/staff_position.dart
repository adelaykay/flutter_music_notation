// lib/src/geometry/staff_position.dart

import '../models/pitch.dart';

/// Represents a vertical position on a musical staff
///
/// Position is measured in "half-spaces" from the bottom line:
/// - 0 = bottom line (E4 in treble, G2 in bass)
/// - 1 = first space above bottom
/// - 2 = second line
/// - etc.
///
/// Negative values are below the staff, values > 8 are above
class StaffPosition {
  /// The position value (can be fractional for glissando/portamento)
  final double value;

  const StaffPosition(this.value);

  /// Bottom line of the staff
  static const bottomLine = StaffPosition(0);

  /// Top line of the staff
  static const topLine = StaffPosition(8);

  /// Middle line of the staff (commonly used as reference)
  static const middleLine = StaffPosition(4);

  /// Whether this position is on a line (as opposed to a space)
  bool get isLine => value % 2 == 0;

  /// Whether this position is in a space (between lines)
  bool get isSpace => !isLine;

  /// Whether this position requires ledger lines above the staff
  bool get needsLedgerLinesAbove => value > 8;

  /// Whether this position requires ledger lines below the staff
  bool get needsLedgerLinesBelow => value < 0;

  /// Whether this position is within the standard staff (no ledger lines)
  bool get isOnStaff => value >= 0 && value <= 8;

  /// Get all ledger line positions needed for this note
  List<int> getLedgerLinePositions() {
    final ledgerLines = <int>[];

    if (needsLedgerLinesAbove) {
      // Add ledger lines above (10, 12, 14, ...)
      for (int pos = 10; pos <= value; pos += 2) {
        ledgerLines.add(pos);
      }
    } else if (needsLedgerLinesBelow) {
      // Add ledger lines below (-2, -4, -6, ...)
      for (int pos = -2; pos >= value; pos -= 2) {
        ledgerLines.add(pos);
      }
    }

    return ledgerLines;
  }

  /// Calculate staff position for a pitch in a given clef
  static StaffPosition forPitch(Pitch pitch, ClefType clef) {
    // Reference pitches for each clef (what pitch is on the middle line)
    switch (clef) {
      case ClefType.treble:
        return _treblePosition(pitch);
      case ClefType.bass:
        return _bassPosition(pitch);
      case ClefType.alto:
        return _altoPosition(pitch);
      case ClefType.tenor:
        return _tenorPosition(pitch);
    }
  }

  /// Calculate position for treble clef (G clef on 2nd line from bottom)
  /// Middle line (position 4) = B4
  static StaffPosition _treblePosition(Pitch pitch) {
    // B4 is at position 4
    final b4 = Pitch(noteName: NoteName.B, octave: 4);
    final semitonesFromB4 = pitch.midiNumber - b4.midiNumber;

    // Each line/space represents a step in the scale
    // C->D = 2 semitones but 1 step, D->E = 2 semitones but 1 step, etc.
    final steps = _calculateSteps(b4, pitch);
    return StaffPosition(4.0 - steps); // B4 is at 4, so subtract steps
  }

  /// Calculate position for bass clef (F clef on 2nd line from top)
  /// Middle line (position 4) = D3
  static StaffPosition _bassPosition(Pitch pitch) {
    // D3 is at position 4
    final d3 = Pitch(noteName: NoteName.D, octave: 3);
    final steps = _calculateSteps(d3, pitch);
    return StaffPosition(4.0 - steps);
  }

  /// Calculate position for alto clef (C clef on middle line)
  /// Middle line (position 4) = C4 (middle C)
  static StaffPosition _altoPosition(Pitch pitch) {
    final c4 = Pitch(noteName: NoteName.C, octave: 4);
    final steps = _calculateSteps(c4, pitch);
    return StaffPosition(4.0 - steps);
  }

  /// Calculate position for tenor clef (C clef on 2nd line from top)
  /// Position 6 = C4
  static StaffPosition _tenorPosition(Pitch pitch) {
    final c4 = Pitch(noteName: NoteName.C, octave: 4);
    final steps = _calculateSteps(c4, pitch);
    return StaffPosition(6.0 - steps);
  }

  /// Calculate the number of diatonic steps between two pitches
  static double _calculateSteps(Pitch reference, Pitch target) {
    // Calculate steps based on note names and octaves
    final octaveDiff = target.octave - reference.octave;
    final noteSteps = target.noteName.positionInOctave - reference.noteName.positionInOctave;

    return (octaveDiff * 7) + noteSteps.toDouble();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StaffPosition && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'StaffPosition($value)';
}

/// Types of musical clefs
enum ClefType {
  treble,  // G clef (2nd line from bottom is G4)
  bass,    // F clef (2nd line from top is F3)
  alto,    // C clef on middle line (middle line is C4)
  tenor,   // C clef on 4th line (4th line is C4)
}