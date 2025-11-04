// lib/src/models/key_signature.dart

import 'pitch.dart';

/// Represents a musical key signature
class KeySignature {
  /// Number of sharps (positive) or flats (negative)
  /// Range: -7 (7 flats) to +7 (7 sharps)
  final int accidentals;

  /// Whether this is a minor key (vs major)
  final bool isMinor;

  const KeySignature({
    required this.accidentals,
    this.isMinor = false,
  }) : assert(accidentals >= -7 && accidentals <= 7,
  'Accidentals must be between -7 and +7');

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

  /// Check if a pitch needs an accidental in this key
  bool needsAccidental(Pitch pitch) {
    final pitchClass = pitch.midiNumber % 12;
    final altered = getAlteredPitchClasses();

    if (altered.contains(pitchClass)) {
      // This pitch is in the key signature
      // Only needs accidental if it differs from key signature
      if (usesSharps) {
        return pitch.accidental != Accidental.sharp;
      } else {
        return pitch.accidental != Accidental.flat;
      }
    } else {
      // This pitch is not in key signature
      // Needs accidental if it's not natural
      return pitch.accidental != Accidental.natural;
    }
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