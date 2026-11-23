import 'package:flutter/material.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';

class LongMelodySample extends StatelessWidget {
  const LongMelodySample({super.key});

  @override
  Widget build(BuildContext context) {
    final keyD = const KeySignature(accidentals: 2); // D Major
    final time44 = TimeSignature.fourFour;

    final measures = [
      // Measure 1: Basic melody
      _measure(0, time44, keyD, [
        _note(62, const NoteDuration.quarter(), 0), // D4
        _note(66, const NoteDuration.quarter(), 1), // F#4
        _note(69, const NoteDuration.quarter(), 2), // A4
        _note(74, const NoteDuration.quarter(), 3), // D5
      ]),
      // Measure 2: Accidentals and dotted notes
      _measure(1, time44, keyD, [
        _note(73, const NoteDuration.dottedQuarter(), 0), // C#5
        _note(72, const NoteDuration.eighth(), 1.5, accidental: Accidental.natural), // C5 natural
        _note(71, const NoteDuration.quarter(), 2), // B4
        _note(70, const NoteDuration.quarter(), 3, accidental: Accidental.flat), // Bb4
      ]),
      // Measure 3: Beaming and syncopation
      _measure(2, time44, keyD, [
        _note(69, const NoteDuration.eighth(), 0),
        _note(70, const NoteDuration.eighth(), 0.5, accidental: Accidental.flat),
        _note(71, const NoteDuration.eighth(), 1),
        _note(72, const NoteDuration.eighth(), 1.5, accidental: Accidental.natural),
        _note(73, const NoteDuration.half(), 2),
      ]),
      // Measure 4: Mixed durations
      _measure(3, time44, keyD, [
        _note(74, const NoteDuration.dottedHalf(), 0),
        _note(73, const NoteDuration.eighth(), 3),
        _note(74, const NoteDuration.eighth(), 3.5),
      ]),
      // Measure 5: High notes and ledger lines
      _measure(4, time44, keyD, [
        _note(78, const NoteDuration.quarter(), 0), // F#5
        _note(81, const NoteDuration.quarter(), 1), // A5
        _note(86, const NoteDuration.half(), 2),    // D6
      ]),
      // Measure 6: Low notes
      _measure(5, time44, keyD, [
        _note(57, const NoteDuration.quarter(), 0), // A3
        _note(54, const NoteDuration.quarter(), 1), // F#3
        _note(50, const NoteDuration.half(), 2),    // D3
      ]),
      // Measure 7: Final cadence with accidentals
      _measure(6, time44, keyD, [
        _note(61, const NoteDuration.quarter(), 0, accidental: Accidental.natural), // C#4 -> C4 natural
        _note(62, const NoteDuration.quarter(), 1),
        _note(59, const NoteDuration.quarter(), 2, accidental: Accidental.flat), // Bb3
        _note(60, const NoteDuration.quarter(), 3, accidental: Accidental.natural), // C4 natural
      ]),
      // Measure 8: Final note
      _measure(7, time44, keyD, [
        _note(62, const NoteDuration.whole(), 0),
      ], endBarline: BarlineType.final_),
    ];

    return Column(
      children: [
        const Text(
          'Extended Melody Study',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text('Testing long lines, accidentals, dots, and ledger lines.'),
        const SizedBox(height: 20),
        NotationView(
          measures: measures,
          config: const NotationConfig(
            useSystemLayout: false, // Changed to false to test horizontal scrolling
            leftMargin: 80,
            enableBeaming: true,
            showKeySignatureOnEachSystem: true,
            systemSpacing: 40,
          ),
        ),
      ],
    );
  }

  Measure _measure(int number, TimeSignature ts, KeySignature ks, List<Note> notes, {BarlineType endBarline = BarlineType.single}) {
    return Measure(
      number: number,
      timeSignature: ts,
      keySignature: ks,
      notes: notes,
      endBarline: endBarline,
    );
  }

  Note _note(int midi, NoteDuration duration, double startBeat, {Accidental? accidental}) {
    Pitch pitch = Pitch.fromMidiNumber(midi);
    if (accidental != null) {
      pitch = pitch.copyWith(accidental: accidental);
    }
    return Note(
      pitch: pitch,
      duration: duration,
      startBeat: startBeat,
      forceShowAccidental: accidental != null,
    );
  }
}
