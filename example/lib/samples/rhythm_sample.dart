import 'package:flutter/material.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';

class RhythmSample extends StatelessWidget {
  const RhythmSample({super.key});

  @override
  Widget build(BuildContext context) {
    // Triplet quarter notes (3 in 2 beats)
    final triplet = const Tuplet(actualNotes: 3, normalNotes: 2);
    final tripletDuration = NoteDuration(
      type: DurationType.quarter,
      tuplet: triplet,
    );

    final notes1 = [
      _note(72, tripletDuration, 0),
      _note(72, tripletDuration, tripletDuration.beats),
      _note(72, tripletDuration, tripletDuration.beats * 2),
      _note(72, const NoteDuration.half(), 2),
    ];

    // Dotted rhythm
    final notes2 = [
      _note(72, const NoteDuration.dottedQuarter(), 0),
      _note(74, const NoteDuration.eighth(), 1.5),
      _note(76, const NoteDuration.eighth(), 2),
      _note(77, const NoteDuration.eighth(), 2.5),
      _note(79, const NoteDuration.quarter(), 3),
    ];

    final measures = [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: notes1,
      ),
      Measure(
        number: 1,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: notes2,
        endBarline: BarlineType.final_,
      ),
    ];

    return Column(
      children: [
        const Text(
          'Rhythm Study (Triplets & Dots)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        NotationView(
          measures: measures,
          config: const NotationConfig(
            leftMargin: 80,
            enableBeaming: true,
            spacingEngine: SpacingPresets.loose,
          ),
        ),
      ],
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
