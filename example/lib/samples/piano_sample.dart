import 'package:flutter/material.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';

class PianoSample extends StatelessWidget {
  const PianoSample({super.key});

  @override
  Widget build(BuildContext context) {
    final keyG = const KeySignature(accidentals: 1);
    final time34 = const TimeSignature(beats: 3, beatUnit: 4);

    final upper = [
      Measure(
        number: 0,
        timeSignature: time34,
        keySignature: keyG,
        notes: [
          _note(79, const NoteDuration.quarter(), 0), // G5
          _note(74, const NoteDuration.eighth(), 1), // D5
          _note(76, const NoteDuration.eighth(), 1.5), // E5
          _note(77, const NoteDuration.eighth(), 2), // F#5 (in key)
          _note(79, const NoteDuration.eighth(), 2.5), // G5
        ],
      ),
      Measure(
        number: 1,
        timeSignature: time34,
        keySignature: keyG,
        notes: [
          _note(74, const NoteDuration.quarter(), 0), // D5
          _note(74, const NoteDuration.quarter(), 1), // D5
          _note(74, const NoteDuration.quarter(), 2), // D5
        ],
      ),
    ];

    final lower = [
      Measure(
        number: 0,
        timeSignature: time34,
        keySignature: keyG,
        notes: [
          _note(55, const NoteDuration.half(), 0), // G3
          _note(59, const NoteDuration.quarter(), 2), // B3
        ],
      ),
      Measure(
        number: 1,
        timeSignature: time34,
        keySignature: keyG,
        notes: [
          _note(50, const NoteDuration.half(), 0), // D3
          _note(54, const NoteDuration.quarter(), 2), // F#3
        ],
      ),
    ];

    final grandStaff = GrandStaff(
      upperStaff: upper,
      lowerStaff: lower,
      instrumentName: 'Piano',
    );

    return Column(
      children: [
        const Text(
          'Minuet in G (Excerpt)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: NotationView(
            grandStaff: grandStaff,
            config: const NotationConfig(leftMargin: 120, showBrace: true),
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
