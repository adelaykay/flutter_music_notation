// example/lib/phase4_spacing_demo.dart

import 'package:flutter/material.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 4: Spacing Engine Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SpacingDemo(),
    );
  }
}

class SpacingDemo extends StatelessWidget {
  const SpacingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Phase 4: Professional Spacing'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Example 1: Uniform vs Proportional Spacing
            _buildTitle('Uniform Spacing (Legacy)'),
            _buildDescription(
              'All notes get equal horizontal space, regardless of duration',
            ),
            _buildNotation(
              _createMixedDurations(),
              SpacingPresets.uniform,
            ),

            const SizedBox(height: 30),

            _buildTitle('Proportional Spacing (New!)'),
            _buildDescription(
              'Longer notes get more space - whole notes wider than eighths',
            ),
            _buildNotation(
              _createMixedDurations(),
              SpacingPresets.normal,
            ),

            const SizedBox(height: 40),
            const Divider(),

            // Example 2: Spacing Presets
            _buildTitle('Tight Spacing'),
            _buildDescription(
              'Compact layout for fitting more music on screen',
            ),
            _buildNotation(
              _createScale(),
              SpacingPresets.tight,
            ),

            const SizedBox(height: 30),

            _buildTitle('Normal Spacing (Default)'),
            _buildDescription(
              'Balanced spacing for general use',
            ),
            _buildNotation(
              _createScale(),
              SpacingPresets.normal,
            ),

            const SizedBox(height: 30),

            _buildTitle('Loose Spacing'),
            _buildDescription(
              'Generous spacing for easy reading',
            ),
            _buildNotation(
              _createScale(),
              SpacingPresets.loose,
            ),

            const SizedBox(height: 40),
            const Divider(),

            // Example 3: Real-World Comparison
            _buildTitle('Real Melody: "Twinkle Twinkle" - Uniform'),
            _buildNotation(
              _createTwinkleTwinkle(),
              SpacingPresets.uniform,
            ),

            const SizedBox(height: 30),

            _buildTitle('Real Melody: "Twinkle Twinkle" - Proportional'),
            _buildDescription(
              'Notice how the half notes get more space - much more readable!',
            ),
            _buildNotation(
              _createTwinkleTwinkle(),
              SpacingPresets.normal,
            ),

            const SizedBox(height: 40),
            const Divider(),

            // Example 4: Complex Rhythm
            _buildTitle('Complex Rhythm - Proportional Spacing Shines'),
            _buildDescription(
              'Mixed durations: whole, dotted half, quarter, eighth notes',
            ),
            _buildNotation(
              _createComplexRhythm(),
              SpacingPresets.normal,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNotation(List<Measure> measures, SpacingEngine spacingEngine) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: NotationView(
        measures: measures,
        config: NotationConfig(
          useSystemLayout: true,
          staffSpaceSize: 12,
          leftMargin: 80,
          measureSpacing: 40,
          spacingEngine: spacingEngine,
        ),
      ),
    );
  }

  // Example measures

  List<Measure> _createMixedDurations() {
    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          // Whole note (4 beats)
          Note(
            pitch: Pitch(noteName: NoteName.C, octave: 4),
            duration: const NoteDuration.whole(),
            startBeat: 0.0,
          ),
        ],
        endBarline: BarlineType.single,
      ),
      Measure(
        number: 1,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          // Four eighth notes
          Note(
            pitch: Pitch(noteName: NoteName.D, octave: 4),
            duration: const NoteDuration.eighth(),
            startBeat: 0.0,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.E, octave: 4),
            duration: const NoteDuration.eighth(),
            startBeat: 0.5,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.F, octave: 4),
            duration: const NoteDuration.eighth(),
            startBeat: 1.0,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.G, octave: 4),
            duration: const NoteDuration.eighth(),
            startBeat: 1.5,
          ),
          // Two quarter notes
          Note(
            pitch: Pitch(noteName: NoteName.A, octave: 4),
            duration: const NoteDuration.quarter(),
            startBeat: 2.0,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.B, octave: 4),
            duration: const NoteDuration.quarter(),
            startBeat: 3.0,
          ),
        ],
        endBarline: BarlineType.final_,
      ),
    ];
  }

  List<Measure> _createScale() {
    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.eighth(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.eighth(), startBeat: 0.5),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.eighth(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.F, octave: 4), duration: const NoteDuration.eighth(), startBeat: 1.5),
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.eighth(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.A, octave: 4), duration: const NoteDuration.eighth(), startBeat: 2.5),
          Note(pitch: Pitch(noteName: NoteName.B, octave: 4), duration: const NoteDuration.eighth(), startBeat: 3.0),
          Note(pitch: Pitch(noteName: NoteName.C, octave: 5), duration: const NoteDuration.eighth(), startBeat: 3.5),
        ],
        endBarline: BarlineType.final_,
      ),
    ];
  }

  List<Measure> _createTwinkleTwinkle() {
    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.single,
      ),
      Measure(
        number: 1,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.A, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.A, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.half(), startBeat: 2.0),
        ],
        endBarline: BarlineType.double_,
      ),
    ];
  }

  List<Measure> _createComplexRhythm() {
    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          // Whole note
          Note(
            pitch: Pitch(noteName: NoteName.C, octave: 4),
            duration: const NoteDuration.whole(),
            startBeat: 0.0,
          ),
        ],
        endBarline: BarlineType.single,
      ),
      Measure(
        number: 1,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          // Dotted half + quarter
          Note(
            pitch: Pitch(noteName: NoteName.D, octave: 4),
            duration: const NoteDuration(type: DurationType.half, dots: 1),
            startBeat: 0.0,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.E, octave: 4),
            duration: const NoteDuration.quarter(),
            startBeat: 3.0,
          ),
        ],
        endBarline: BarlineType.single,
      ),
      Measure(
        number: 2,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          // Mixed: quarter, eighth, eighth, half
          Note(
            pitch: Pitch(noteName: NoteName.F, octave: 4),
            duration: const NoteDuration.quarter(),
            startBeat: 0.0,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.G, octave: 4),
            duration: const NoteDuration.eighth(),
            startBeat: 1.0,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.A, octave: 4),
            duration: const NoteDuration.eighth(),
            startBeat: 1.5,
          ),
          Note(
            pitch: Pitch(noteName: NoteName.G, octave: 4),
            duration: const NoteDuration.half(),
            startBeat: 2.0,
          ),
        ],
        endBarline: BarlineType.final_,
      ),
    ];
  }
}