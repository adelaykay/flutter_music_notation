import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';

Note _n(NoteName name, Accidental acc, double beat, {int octave = 4}) => Note(
      pitch: Pitch(noteName: name, octave: octave, accidental: acc),
      duration: const NoteDuration.quarter(),
      startBeat: beat,
    );

void main() {
  group('needsAccidental follows letter names', () {
    test('notes that match the key need nothing', () {
      expect(KeySignature.gMajor.needsAccidental(Pitch(noteName: NoteName.F, octave: 4, accidental: Accidental.sharp)), isFalse);
      expect(KeySignature.fMajor.needsAccidental(Pitch(noteName: NoteName.B, octave: 4, accidental: Accidental.flat)), isFalse);
      expect(KeySignature.cFlatMajor.needsAccidental(Pitch(noteName: NoteName.C, octave: 4, accidental: Accidental.flat)), isFalse);
    });
    test('notes that contradict the key need one', () {
      expect(KeySignature.gMajor.needsAccidental(Pitch(noteName: NoteName.F, octave: 4)), isTrue);
      expect(KeySignature.fMajor.needsAccidental(Pitch(noteName: NoteName.B, octave: 4)), isTrue);
      expect(KeySignature.cFlatMajor.needsAccidental(Pitch(noteName: NoteName.C, octave: 4)), isTrue);
      expect(KeySignature.cMajor.needsAccidental(Pitch(noteName: NoteName.E, octave: 4, accidental: Accidental.flat)), isTrue);
    });
  });

  group('bar-scoped accidentals', () {
    test('an accidental is not repeated in the same bar and octave', () {
      final a = _n(NoteName.F, Accidental.sharp, 0), b = _n(NoteName.F, Accidental.sharp, 1);
      final shown = KeySignature.cMajor.notesNeedingAccidentals([a, b]);
      expect(shown.contains(a), isTrue);
      expect(shown.contains(b), isFalse);
    });
    test('a different octave needs its own accidental', () {
      final a = _n(NoteName.F, Accidental.sharp, 0), b = _n(NoteName.F, Accidental.sharp, 1, octave: 5);
      final shown = KeySignature.cMajor.notesNeedingAccidentals([a, b]);
      expect(shown, containsAll([a, b]));
    });
    test('returning to the key after a natural shows the key accidental again', () {
      final nat = _n(NoteName.F, Accidental.natural, 0), sharp = _n(NoteName.F, Accidental.sharp, 1);
      final shown = KeySignature.gMajor.notesNeedingAccidentals([sharp, nat]);
      expect(shown, containsAll([nat, sharp]));
    });
    test('order follows beats, not input order', () {
      final first = _n(NoteName.C, Accidental.sharp, 0), second = _n(NoteName.C, Accidental.sharp, 2);
      final shown = KeySignature.cMajor.notesNeedingAccidentals([second, first]);
      expect(shown.contains(first), isTrue);
      expect(shown.contains(second), isFalse);
    });
  });
}
