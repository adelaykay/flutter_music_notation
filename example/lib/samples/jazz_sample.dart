import 'package:flutter/material.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';

class JazzSample extends StatelessWidget {
  const JazzSample({super.key});

  @override
  Widget build(BuildContext context) {
    final measures = [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          _note(60, const NoteDuration.quarter(), 0), // C
          _note(63, const NoteDuration.quarter(), 1, accidental: Accidental.flat), // Eb
          _note(65, const NoteDuration.quarter(), 2), // F
          _note(66, const NoteDuration.quarter(), 3, accidental: Accidental.sharp), // F#
        ],
      ),
      Measure(
        number: 1,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          _note(67, const NoteDuration.dottedQuarter(), 0), // G
          _note(65, const NoteDuration.eighth(), 1.5),      // F
          _note(63, const NoteDuration.quarter(), 2, accidental: Accidental.flat), // Eb
          _note(60, const NoteDuration.quarter(), 3),      // C
        ],
        endBarline: BarlineType.double_,
      ),
    ];

    return Column(
      children: [
        const Text(
          'Blues in C',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        NotationView(
          measures: measures,
          config: const NotationConfig(
            leftMargin: 80,
            enableBeaming: true,
          ),
        ),
      ],
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
