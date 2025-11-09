// example/lib/phase6_integration_example.dart

import 'package:flutter/material.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';

void main() {
  runApp(const Phase6IntegrationExample());
}

class Phase6IntegrationExample extends StatelessWidget {
  const Phase6IntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 6 Integration Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Phase6DemoPage(),
    );
  }
}

class Phase6DemoPage extends StatelessWidget {
  const Phase6DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Phase 6: Advanced Features Integration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSection(
                'Example 1: Beamed Eighth Notes',
                _createBeamedExample(),
              ),
              const SizedBox(height: 40),

              _buildSection(
                'Example 2: Tied Notes',
                _createTiedExample(),
              ),
              const SizedBox(height: 40),

              _buildSection(
                'Example 3: Slurred Phrase',
                _createSlurredExample(),
              ),
              const SizedBox(height: 40),

              _buildSection(
                'Example 4: Triplet',
                _createTripletExample(),
              ),
              const SizedBox(height: 40),

              _buildSection(
                'Example 5: Combined Features',
                _createCombinedExample(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Measure> measures) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: NotationView(
            measures: measures,
            config: const NotationConfig(
              staffSpaceSize: 12,
              leftMargin: 80,
              measureSpacing: 40,
            ),
          ),
        ),
      ],
    );
  }

  /// Example 1: Beamed eighth notes
  List<Measure> _createBeamedExample() {
    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          // Four eighth notes - will be automatically beamed
          Note(
            pitch: Pitch(noteName: NoteName.C, octave: 4),
            duration: const NoteDuration.eighth(),
            startBeat: 0.0,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.D, octave: 4),
            duration: const NoteDuration.eighth(),
            startBeat: 0.5,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.E, octave: 4),
            duration: const NoteDuration.eighth(),
            startBeat: 1.0,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.F, octave: 4),
            duration: const NoteDuration.eighth(),
            startBeat: 1.5,
          ),
          // Another group
          Note(
            pitch: Pitch(noteName: NoteName.G, octave: 4),
            duration: const NoteDuration.eighth(),
            startBeat: 2.0,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.A, octave: 4),
            duration: const NoteDuration.eighth(),
            startBeat: 2.5,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.B, octave: 4),
            duration: const NoteDuration.eighth(),
            startBeat: 3.0,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.C, octave: 5),
            duration: const NoteDuration.eighth(),
            startBeat: 3.5,
          ),
        ],
        endBarline: BarlineType.final_,
      ),
    ];
  }

  /// Example 2: Tied notes
  List<Measure> _createTiedExample() {
    final note1 = Note(
      pitch: Pitch(noteName: NoteName.C, octave: 4),
      duration: const NoteDuration.half(),
      startBeat: 0.0,
    );

    final note2 = Note(
      pitch: Pitch(noteName: NoteName.C, octave: 4), // Same pitch
      duration: const NoteDuration.half(),
      startBeat: 2.0,
    );

    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [note1, note2],
        ties: [
          Tie(
            startNote: note1,
            endNote: note2,
            direction: CurveDirection.up,
          ),
        ],
        endBarline: BarlineType.final_,
      ),
    ];
  }

  /// Example 3: Slurred phrase
  List<Measure> _createSlurredExample() {
    final notes = [
      Note(
        pitch: Pitch(noteName: NoteName.C, octave: 4),
        duration: const NoteDuration.quarter(),
        startBeat: 0.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.E, octave: 4),
        duration: const NoteDuration.quarter(),
        startBeat: 1.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.G, octave: 4),
        duration: const NoteDuration.quarter(),
        startBeat: 2.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.C, octave: 5),
        duration: const NoteDuration.quarter(),
        startBeat: 3.0,
      ),
    ];

    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: notes,
        slurs: [
          Slur(
            notes: notes,
            type: SlurType.standard,
          ),
        ],
        endBarline: BarlineType.final_,
      ),
    ];
  }

  /// Example 4: Triplet
  List<Measure> _createTripletExample() {
    final tripletNotes = [
      Note(
        pitch: Pitch(noteName: NoteName.C, octave: 4),
        duration: const NoteDuration(
          type: DurationType.eighth,
          tuplet: Tuplet.triplet,
        ),
        startBeat: 0.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.D, octave: 4),
        duration: const NoteDuration(
          type: DurationType.eighth,
          tuplet: Tuplet.triplet,
        ),
        startBeat: 0.667,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.E, octave: 4),
        duration: const NoteDuration(
          type: DurationType.eighth,
          tuplet: Tuplet.triplet,
        ),
        startBeat: 1.333,
      ),
      // Second triplet
      Note(
        pitch: Pitch(noteName: NoteName.F, octave: 4),
        duration: const NoteDuration(
          type: DurationType.eighth,
          tuplet: Tuplet.triplet,
        ),
        startBeat: 2.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.G, octave: 4),
        duration: const NoteDuration(
          type: DurationType.eighth,
          tuplet: Tuplet.triplet,
        ),
        startBeat: 2.667,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.A, octave: 4),
        duration: const NoteDuration(
          type: DurationType.eighth,
          tuplet: Tuplet.triplet,
        ),
        startBeat: 3.333,
      ),
    ];

    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: tripletNotes,
        // Tuplets will be auto-detected
        endBarline: BarlineType.final_,
      ),
    ];
  }

  /// Example 5: Combined features (beaming + slur + tuplet)
  List<Measure> _createCombinedExample() {
    // Regular beamed notes
    final beamedNotes = [
      Note(
        pitch: Pitch(noteName: NoteName.C, octave: 4),
        duration: const NoteDuration.eighth(),
        startBeat: 0.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.D, octave: 4),
        duration: const NoteDuration.eighth(),
        startBeat: 0.5,
      ),
    ];

    // Triplet with slur
    final tripletNotes = [
      Note(
        pitch: Pitch(noteName: NoteName.E, octave: 4),
        duration: const NoteDuration(
          type: DurationType.eighth,
          tuplet: Tuplet.triplet,
        ),
        startBeat: 1.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.F, octave: 4),
        duration: const NoteDuration(
          type: DurationType.eighth,
          tuplet: Tuplet.triplet,
        ),
        startBeat: 1.667,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.G, octave: 4),
        duration: const NoteDuration(
          type: DurationType.eighth,
          tuplet: Tuplet.triplet,
        ),
        startBeat: 2.333,
      ),
    ];

    // Final tied note
    final tiedNote1 = Note(
      pitch: Pitch(noteName: NoteName.A, octave: 4),
      duration: const NoteDuration.quarter(),
      startBeat: 3.0,
    );

    final allNotes = [...beamedNotes, ...tripletNotes, tiedNote1];

    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: allNotes,
        slurs: [
          Slur(notes: tripletNotes, type: SlurType.standard),
        ],
        endBarline: BarlineType.single,
      ),
      Measure(
        number: 1,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          Note(
            pitch: Pitch(noteName: NoteName.A, octave: 4),
            duration: const NoteDuration.whole(),
            startBeat: 0.0,
          ),
        ],
        ties: [
          Tie(
            startNote: tiedNote1,
            endNote: Note(
              pitch: Pitch(noteName: NoteName.A, octave: 4),
              duration: const NoteDuration.whole(),
              startBeat: 0.0,
            ),
          ),
        ],
        endBarline: BarlineType.final_,
      ),
    ];
  }
}