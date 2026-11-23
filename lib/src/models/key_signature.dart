// lib/src/models/key_signature.dart

import 'pitch.dart';
import 'note.dart';

/// Represents a musical key signature
class KeySignature {
  /// Number of sharps (positive) or flats (negative)
  /// Range: -7 (7 flats) to +7 (7 sharps)
  final int accidentals;

  /// Whether this is a minor key (vs major)
  final bool isMinor;

  const KeySignature({required this.accidentals, this.isMinor = false})
    : assert(
        accidentals >= -7 && accidentals <= 7,
        'Accidentals must be between -7 and +7',
      );

  /// Common key signatures
  static const cMajor = KeySignature(accidentals: 0);
  static const aMinor = KeySignature(accidentals: 0, isMinor: true);

  static const gMajor = KeySignature(accidentals: 1);
  static const eMinor = KeySignature(accidentals: 1, isMinor: true);

  static const dMajor = KeySignature(accidentals: 2);
  static const bMinor = KeySignature(accidentals: 2, isMinor: true);

  static const aMajor = KeySignature(accidentals: 3);
  static const fSharpMinor = KeySignature(accidentals: 3, isMinor: true);

  static const eMajor = KeySignature(accidentals: 4);
  static const cSharpMinor = KeySignature(accidentals: 4, isMinor: true);

  static const bMajor = KeySignature(accidentals: 5);
  static const gSharpMinor = KeySignature(accidentals: 5, isMinor: true);

  static const fSharpMajor = KeySignature(accidentals: 6);
  static const dSharpMinor = KeySignature(accidentals: 6, isMinor: true);

  static const cSharpMajor = KeySignature(accidentals: 7);
  static const aSharpMinor = KeySignature(accidentals: 7, isMinor: true);

  static const fMajor = KeySignature(accidentals: -1);
  static const dMinor = KeySignature(accidentals: -1, isMinor: true);

  static const bFlatMajor = KeySignature(accidentals: -2);
  static const gMinor = KeySignature(accidentals: -2, isMinor: true);

  static const eFlatMajor = KeySignature(accidentals: -3);
  static const cMinor = KeySignature(accidentals: -3, isMinor: true);

  static const aFlatMajor = KeySignature(accidentals: -4);
  static const fMinor = KeySignature(accidentals: -4, isMinor: true);

  static const dFlatMajor = KeySignature(accidentals: -5);
  static const bFlatMinor = KeySignature(accidentals: -5, isMinor: true);

  static const gFlatMajor = KeySignature(accidentals: -6);
  static const eFlatMinor = KeySignature(accidentals: -6, isMinor: true);

  static const cFlatMajor = KeySignature(accidentals: -7);
  static const aFlatMinor = KeySignature(accidentals: -7, isMinor: true);

  /// Get the name of this key
  String get name {
    const majorKeys = ['C', 'G', 'D', 'A', 'E', 'B', 'F♯', 'C♯'];
    const minorKeys = ['A', 'E', 'B', 'F♯', 'C♯', 'G♯', 'D♯', 'A♯'];
    const flatMajorKeys = ['F', 'B♭', 'E♭', 'A♭', 'D♭', 'G♭', 'C♭'];
    const flatMinorKeys = ['D', 'G', 'C', 'F', 'B♭', 'E♭', 'A♭'];

    if (accidentals >= 0) {
      return isMinor
          ? '${minorKeys[accidentals]} minor'
          : '${majorKeys[accidentals]} major';
    } else {
      final index = (-accidentals) - 1;
      return isMinor
          ? '${flatMinorKeys[index]} minor'
          : '${flatMajorKeys[index]} major';
    }
  }

  /// Whether this key uses sharps (true) or flats (false)
  bool get usesSharps => accidentals >= 0;

  /// Get the pitch classes that are altered in this key signature
  /// Returns MIDI pitch classes (0-11) that should be sharp/flat
  List<int> getAlteredPitchClasses() {
    if (accidentals == 0) return [];

    // Order of sharps: F C G D A E B
    const sharpOrder = [5, 0, 7, 2, 9, 4, 11];
    // Order of flats: B E A D G C F
    const flatOrder = [11, 4, 9, 2, 7, 0, 5];

    if (accidentals > 0) {
      return sharpOrder.take(accidentals).toList();
    } else {
      return flatOrder.take(-accidentals).toList();
    }
  }

  /// The accidental this key signature applies to [letter]
  /// (e.g. F → sharp in G major, B → flat in F major, natural otherwise).
  Accidental accidentalFor(NoteName letter) {
    const sharpOrder = [
      NoteName.F,
      NoteName.C,
      NoteName.G,
      NoteName.D,
      NoteName.A,
      NoteName.E,
      NoteName.B,
    ];
    const flatOrder = [
      NoteName.B,
      NoteName.E,
      NoteName.A,
      NoteName.D,
      NoteName.G,
      NoteName.C,
      NoteName.F,
    ];
    if (accidentals > 0 && sharpOrder.take(accidentals).contains(letter)) {
      return Accidental.sharp;
    }
    if (accidentals < 0 && flatOrder.take(-accidentals).contains(letter)) {
      return Accidental.flat;
    }
    return Accidental.natural;
  }

  /// Whether [pitch] needs a written accidental at the start of a bar in this
  /// key. Key signatures alter letter names, so this compares the pitch's own
  /// accidental with the one the key gives its letter: F♯ in G major needs
  /// none, F♮ in G major needs a natural.
  bool needsAccidental(Pitch pitch) =>
      pitch.accidental != accidentalFor(pitch.noteName);

  /// Which of [notes] (one bar) need a written accidental, following standard
  /// engraving: an accidental lasts until the end of the bar for that letter
  /// and octave, so it is not repeated, and a later note that returns to the
  /// key's (or another) accidental gets one again. Notes are taken in time
  /// order; notes at the same beat are taken low to high.
  Set<Note> notesNeedingAccidentals(Iterable<Note> notes) {
    final ordered = notes.toList()
      ..sort((a, b) {
        final byBeat = a.startBeat.compareTo(b.startBeat);
        return byBeat != 0
            ? byBeat
            : a.pitch.midiNumber.compareTo(b.pitch.midiNumber);
      });
    final current = <(NoteName, int), Accidental>{};
    final result = Set<Note>.identity();
    for (final note in ordered) {
      final letter = note.pitch.noteName;
      final slot = (letter, note.pitch.octave);
      final inForce = current[slot] ?? accidentalFor(letter);
      if (note.pitch.accidental != inForce) {
        result.add(note);
        current[slot] = note.pitch.accidental;
      }
    }
    return result;
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeySignature &&
          accidentals == other.accidentals &&
          isMinor == other.isMinor;

  @override
  int get hashCode => Object.hash(accidentals, isMinor);
}
