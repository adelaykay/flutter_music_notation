import 'package:flutter/material.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';

class FolkSample extends StatelessWidget {
  const FolkSample({super.key});

  @override
  Widget build(BuildContext context) {
    final measures = [
      _measure(0, [
        _note(60, const NoteDuration.quarter(), 0), // C
        _note(60, const NoteDuration.quarter(), 1), // C
        _note(67, const NoteDuration.quarter(), 2), // G
        _note(67, const NoteDuration.quarter(), 3), // G
      ]),
      _measure(1, [
        _note(69, const NoteDuration.quarter(), 0), // A
        _note(69, const NoteDuration.quarter(), 1), // A
        _note(67, const NoteDuration.half(), 2),    // G
      ]),
      _measure(2, [
        _note(65, const NoteDuration.quarter(), 0), // F
        _note(65, const NoteDuration.quarter(), 1), // F
        _note(64, const NoteDuration.quarter(), 2), // E
        _note(64, const NoteDuration.quarter(), 3), // E
      ]),
      _measure(3, [
        _note(62, const NoteDuration.quarter(), 0), // D
        _note(62, const NoteDuration.quarter(), 1), // D
        _note(60, const NoteDuration.half(), 2),    // C
      ], endBarline: BarlineType.final_),
    ];

    return Column(
      children: [
        const Text(
          'Twinkle Twinkle Little Star',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        NotationView(
          measures: measures,
          config: const NotationConfig(
            useSystemLayout: true,
            leftMargin: 80,
          ),
        ),
      ],
    );
  }

  Measure _measure(int number, List<Note> notes, {BarlineType endBarline = BarlineType.single}) {
    return Measure(
      number: number,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cMajor,
      notes: notes,
      endBarline: endBarline,
    );
  }

  Note _note(int midi, NoteDuration duration, double startBeat) {
    return Note(
      pitch: Pitch.fromMidiNumber(midi),
      duration: duration,
      startBeat: startBeat,
    );
  }
}
