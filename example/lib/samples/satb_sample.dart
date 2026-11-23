import 'package:flutter/material.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';

class SATBSample extends StatelessWidget {
  const SATBSample({super.key});

  @override
  Widget build(BuildContext context) {
    final keyEb = const KeySignature(accidentals: -3); // Eb Major
    final time44 = TimeSignature.fourFour;

    // Abide With Me (Excerpt)
    // Measure 1
    final s1 = [
      _note(67, const NoteDuration.half(), 0, 0),    // G4
      _note(67, const NoteDuration.quarter(), 2, 0), // G4
      _note(65, const NoteDuration.quarter(), 3, 0), // F4
    ];
    final a1 = [
      _note(63, const NoteDuration.half(), 0, 1),    // Eb4
      _note(63, const NoteDuration.quarter(), 2, 1), // Eb4
      _note(62, const NoteDuration.quarter(), 3, 1), // D4
    ];
    final t1 = [
      _note(58, const NoteDuration.half(), 0, 2),    // Bb3
      _note(58, const NoteDuration.quarter(), 2, 2), // Bb3
      _note(58, const NoteDuration.quarter(), 3, 2), // Bb3
    ];
    final b1 = [
      _note(51, const NoteDuration.half(), 0, 3),    // Eb3
      _note(51, const NoteDuration.quarter(), 2, 3), // Eb3
      _note(51, const NoteDuration.quarter(), 3, 3), // Eb3
    ];

    // Measure 2
    final s2 = [
      _note(63, const NoteDuration.whole(), 0, 0),   // Eb4
    ];
    final a2 = [
      _note(60, const NoteDuration.whole(), 0, 1),   // C4
    ];
    final t2 = [
      _note(55, const NoteDuration.half(), 0, 2),    // G3
      _note(56, const NoteDuration.half(), 2, 2),    // Ab3
    ];
    final b2 = [
      _note(48, const NoteDuration.whole(), 0, 3),   // C3
    ];

    // Measure 3 - Syncopation/Syncopated feel
    final s3 = [
      _note(67, const NoteDuration.dottedQuarter(), 0, 0), // G4
      _note(68, const NoteDuration.eighth(), 1.5, 0),      // Ab4
      _note(70, const NoteDuration.quarter(), 2, 0),      // Bb4
      _note(70, const NoteDuration.quarter(), 3, 0),      // Bb4
    ];
    final a3 = [
      _note(63, const NoteDuration.half(), 0, 1),          // Eb4
      _note(63, const NoteDuration.half(), 2, 1),          // Eb4
    ];
    final t3 = [
      _note(58, const NoteDuration.half(), 0, 2),          // Bb3
      _note(58, const NoteDuration.half(), 2, 2),          // Bb3
    ];
    final b3 = [
      _note(51, const NoteDuration.half(), 0, 3),          // Eb3
      _note(46, const NoteDuration.half(), 2, 3),          // Bb2
    ];

    final upper = [
      Measure(number: 0, timeSignature: time44, keySignature: keyEb, notes: [...s1, ...a1]),
      Measure(number: 1, timeSignature: time44, keySignature: keyEb, notes: [...s2, ...a2]),
      Measure(number: 2, timeSignature: time44, keySignature: keyEb, notes: [...s3, ...a3]),
    ];

    final lower = [
      Measure(number: 0, timeSignature: time44, keySignature: keyEb, notes: [...t1, ...b1]),
      Measure(number: 1, timeSignature: time44, keySignature: keyEb, notes: [...t2, ...b2]),
      Measure(number: 2, timeSignature: time44, keySignature: keyEb, notes: [...t3, ...b3]),
    ];

    final grandStaff = GrandStaff(
      upperStaff: upper,
      lowerStaff: lower,
      instrumentName: 'SATB',
    );

    return Column(
      children: [
        const Text(
          'Abide With Me (SATB Example)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text('Demonstrates 4 voices with independent stems and syncopation.'),
        const SizedBox(height: 20),
        SizedBox(
          height: 400,
          child: NotationView(
            grandStaff: grandStaff,
            config: const NotationConfig(
              leftMargin: 120,
              showBrace: true,
              useSystemLayout: false, // Changed to false to test horizontal scrolling
              systemSpacing: 80,
            ),
          ),
        ),
      ],
    );
  }

  Note _note(int midi, NoteDuration duration, double startBeat, int voice) {
    return Note(
      pitch: Pitch.fromMidiNumber(midi),
      duration: duration,
      startBeat: startBeat,
      voice: voice,
    );
  }
}
