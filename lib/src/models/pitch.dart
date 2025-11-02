// lib/src/models/pitch.dart

/// Represents the seven natural note names
enum NoteName {
  C,
  D,
  E,
  F,
  G,
  A,
  B;

  /// Get the position within an octave (C=0, D=1, E=2, F=3, G=4, A=5, B=6)
  int get positionInOctave => index;

  /// Get the next note name (wraps around from B to C)
  NoteName get next => NoteName.values[(index + 1) % 7];

  /// Get the previous note name (wraps around from C to B)
  NoteName get previous => NoteName.values[(index - 1 + 7) % 7];
}

/// Represents accidentals (alterations to natural notes)
enum Accidental {
  doubleFlat(-2),
  flat(-1),
  natural(0),
  sharp(1),
  doubleSharp(2);

  const Accidental(this.semitoneOffset);

  /// How many semitones this accidental adds/subtracts
  final int semitoneOffset;

  /// Unicode symbol for display
  String get symbol {
    switch (this) {
      case Accidental.doubleFlat:
        return '𝄫';
      case Accidental.flat:
        return '♭';
      case Accidental.natural:
        return '♮';
      case Accidental.sharp:
        return '♯';
      case Accidental.doubleSharp:
        return '𝄪';
    }
  }
}

/// Represents a musical pitch with note name, accidental, and octave
class Pitch {
  /// The natural note name (C, D, E, F, G, A, B)
  final NoteName noteName;

  /// The accidental applied to the note
  final Accidental accidental;

  /// The octave number (Middle C = C4)
  final int octave;

  const Pitch({
    required this.noteName,
    this.accidental = Accidental.natural,
    required this.octave,
  });

  /// Create a pitch from MIDI note number (0-127)
  /// Middle C (MIDI 60) = C4
  factory Pitch.fromMidiNumber(int midiNumber, {Accidental preferredAccidental = Accidental.natural}) {
    assert(midiNumber >= 0 && midiNumber <= 127, 'MIDI number must be 0-127');

    final octave = (midiNumber ~/ 12) - 1;
    final pitchClass = midiNumber % 12;

    // Map pitch class to note name and accidental
    // For black keys, use the preferred accidental direction
    switch (pitchClass) {
      case 0:
        return Pitch(noteName: NoteName.C, octave: octave);
      case 1:
        return preferredAccidental == Accidental.flat
            ? Pitch(noteName: NoteName.D, accidental: Accidental.flat, octave: octave)
            : Pitch(noteName: NoteName.C, accidental: Accidental.sharp, octave: octave);
      case 2:
        return Pitch(noteName: NoteName.D, octave: octave);
      case 3:
        return preferredAccidental == Accidental.flat
            ? Pitch(noteName: NoteName.E, accidental: Accidental.flat, octave: octave)
            : Pitch(noteName: NoteName.D, accidental: Accidental.sharp, octave: octave);
      case 4:
        return Pitch(noteName: NoteName.E, octave: octave);
      case 5:
        return Pitch(noteName: NoteName.F, octave: octave);
      case 6:
        return preferredAccidental == Accidental.flat
            ? Pitch(noteName: NoteName.G, accidental: Accidental.flat, octave: octave)
            : Pitch(noteName: NoteName.F, accidental: Accidental.sharp, octave: octave);
      case 7:
        return Pitch(noteName: NoteName.G, octave: octave);
      case 8:
        return preferredAccidental == Accidental.flat
            ? Pitch(noteName: NoteName.A, accidental: Accidental.flat, octave: octave)
            : Pitch(noteName: NoteName.G, accidental: Accidental.sharp, octave: octave);
      case 9:
        return Pitch(noteName: NoteName.A, octave: octave);
      case 10:
        return preferredAccidental == Accidental.flat
            ? Pitch(noteName: NoteName.B, accidental: Accidental.flat, octave: octave)
            : Pitch(noteName: NoteName.A, accidental: Accidental.sharp, octave: octave);
      case 11:
        return Pitch(noteName: NoteName.B, octave: octave);
      default:
        throw StateError('Invalid pitch class: $pitchClass');
    }
  }

  /// Convert this pitch to MIDI note number (0-127)
  int get midiNumber {
    // Base MIDI numbers for natural notes in octave 0
    const baseValues = {
      NoteName.C: 0,
      NoteName.D: 2,
      NoteName.E: 4,
      NoteName.F: 5,
      NoteName.G: 7,
      NoteName.A: 9,
      NoteName.B: 11,
    };

    final baseNote = baseValues[noteName]!;
    final octaveOffset = (octave + 1) * 12;
    final accidentalOffset = accidental.semitoneOffset;

    return baseNote + octaveOffset + accidentalOffset;
  }

  /// Scientific pitch notation (e.g., "C4", "F♯5", "B♭3")
  String get scientificName {
    final accidentalStr = accidental == Accidental.natural ? '' : accidental.symbol;
    return '${noteName.name}$accidentalStr$octave';
  }

  /// Create a copy with modified properties
  Pitch copyWith({
    NoteName? noteName,
    Accidental? accidental,
    int? octave,
  }) {
    return Pitch(
      noteName: noteName ?? this.noteName,
      accidental: accidental ?? this.accidental,
      octave: octave ?? this.octave,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Pitch &&
              runtimeType == other.runtimeType &&
              noteName == other.noteName &&
              accidental == other.accidental &&
              octave == other.octave;

  @override
  int get hashCode => Object.hash(noteName, accidental, octave);

  @override
  String toString() => scientificName;
}