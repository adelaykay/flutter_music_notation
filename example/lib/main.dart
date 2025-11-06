// example/lib/multiline_demo.dart

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
      title: 'Multi-Line System Layout Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MultiLineDemo(),
    );
  }
}

class MultiLineDemo extends StatelessWidget {
  const MultiLineDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Multi-Line System Layout'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 20),

            // Example 1: Single Line vs Multi-Line
            _buildTitle('Single Line (Old Behavior)'),
            _buildDescription('All measures on one line - may overflow'),
            _buildNotation(
              _createLongPiece(),
              useSystemLayout: false,
              height: 200,
            ),

            const SizedBox(height: 40),

            _buildTitle('Multi-Line Layout (New!)'),
            _buildDescription('Automatically breaks into multiple lines'),
            _buildNotation(
              _createLongPiece(),
              useSystemLayout: true,
              height: 500, // Allow space for multiple lines
            ),

            const SizedBox(height: 40),
            const Divider(),

            // Example 2: Line Break Strategies
            _buildTitle('Greedy Strategy'),
            _buildDescription('Maximize measures per line'),
            _buildNotation(
              _createLongPiece(),
              useSystemLayout: true,
              lineBreakConfig: LineBreakConfig(
                strategy: LineBreakStrategy.greedy,
                targetLineWidth: 700,
                minMeasuresPerLine: 2,
                maxMeasuresPerLine: 6,
              ),
              height: 400,
            ),

            const SizedBox(height: 30),

            _buildTitle('Balanced Strategy'),
            _buildDescription('Minimize raggedness (more even lines)'),
            _buildNotation(
              _createLongPiece(),
              useSystemLayout: true,
              lineBreakConfig: LineBreakConfig(
                strategy: LineBreakStrategy.balanced,
                targetLineWidth: 700,
                minMeasuresPerLine: 2,
                maxMeasuresPerLine: 6,
              ),
              height: 400,
            ),

            const SizedBox(height: 40),
            const Divider(),

            // Example 3: Different Spacing Densities
            _buildTitle('Compact Layout (Tight Spacing)'),
            _buildDescription('More measures fit per line'),
            _buildNotation(
              _createLongPiece(),
              useSystemLayout: true,
              spacingEngine: SpacingPresets.tight,
              lineBreakConfig: LineBreakConfig.compact(1000),
              height: 700,
            ),

            const SizedBox(height: 30),

            _buildTitle('Spacious Layout (Loose Spacing)'),
            _buildDescription('Fewer measures per line, easier to read'),
            _buildNotation(
              _createLongPiece(),
              useSystemLayout: true,
              spacingEngine: SpacingPresets.loose,
              lineBreakConfig: LineBreakConfig.spacious(700),
              height: 600,
            ),

            const SizedBox(height: 40),
            const Divider(),

            // Example 4: Complete Piece with Measure Numbers
            _buildTitle('Complete Piece: Ode to Joy'),
            _buildDescription('With measure numbers and multiple systems'),
            _buildNotation(
              _createMaryHadALittleLamb(),
              useSystemLayout: true,
              showMeasureNumbers: true,
              height: 500,
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

  Widget _buildNotation(
      List<Measure> measures, {
        bool useSystemLayout = false,
        SpacingEngine spacingEngine = SpacingPresets.loose,
        LineBreakConfig? lineBreakConfig,
        bool showMeasureNumbers = true,
        double height = 200,
      }) {
    return Container(
      height: height,
      width: 1200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: NotationView(
          measures: measures,
          config: NotationConfig(
            staffSpaceSize: 12,
            leftMargin: 60,
            rightMargin: 20,
            topMargin: 30,
            measureSpacing: 20,
            spacingEngine: spacingEngine,
            useSystemLayout: useSystemLayout,
            systemHeight: 150,
            systemSpacing: 50,
            showMeasureNumbers: showMeasureNumbers,
            lineBreakConfig: lineBreakConfig,
          ),
        ),
      ),
    );
  }

  // Create a longer piece that needs multiple lines
  List<Measure> _createLongPiece() {
    return [
      // Measure 1
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.F, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.single,
      ),
      // Measure 2
      Measure(
        number: 1,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.A, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.B, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.C, octave: 5), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.single,
      ),
      // Measure 3
      Measure(
        number: 2,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.C, octave: 5), duration: const NoteDuration.eighth(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.B, octave: 4), duration: const NoteDuration.eighth(), startBeat: 0.5),
          Note(pitch: Pitch(noteName: NoteName.A, octave: 4), duration: const NoteDuration.eighth(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.eighth(), startBeat: 1.5),
          Note(pitch: Pitch(noteName: NoteName.F, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.single,
      ),
      // Measure 4
      Measure(
        number: 3,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.half(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.half(), startBeat: 2.0),
        ],
        endBarline: BarlineType.double_,
      ),
      // Measure 5
      Measure(
        number: 4,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.F, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.A, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.single,
      ),
      // Measure 6
      Measure(
        number: 5,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.whole(), startBeat: 0.0),
        ],
        endBarline: BarlineType.single,
      ),
      // Measure 7
      Measure(
        number: 6,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.F, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.single,
      ),
      // Measure 8
      Measure(
        number: 7,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.whole(), startBeat: 0.0),
        ],
        endBarline: BarlineType.final_,
      ),
    ];
  }

  // Complete Mary Had a Little Lamb
  List<Measure> _createMaryHadALittleLamb() {
    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
      ),
      Measure(
        number: 1,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
        ],
        rests: [
          Rest(duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
      ),
      Measure(
        number: 2,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.D, accidental: Accidental.sharp, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0), // accidental
        ],
        rests: [
          Rest(duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
      ),
      Measure(
        number: 3,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.half(), startBeat: 1.0),
        ],
        rests: [
          Rest(duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.final_,
      ),
    ];
  }

  // Complete Ode to Joy
  List<Measure> _createOdeToJoy() {
    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.F, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.single,
      ),
      Measure(
        number: 1,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.F, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.single,
      ),
      Measure(
        number: 2,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.single,
      ),
      Measure(
        number: 3,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration(type: DurationType.quarter, dots: 1), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.eighth(), startBeat: 1.5),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.half(), startBeat: 2.0),
        ],
        endBarline: BarlineType.double_,
      ),
      Measure(
        number: 4,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.F, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.single,
      ),
      Measure(
        number: 5,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.F, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.single,
      ),
      Measure(
        number: 6,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.single,
      ),
      Measure(
        number: 7,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cFlatMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration(type: DurationType.quarter, dots: 1), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.eighth(), startBeat: 1.5),
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.half(), startBeat: 2.0),
        ],
        endBarline: BarlineType.final_,
      ),
    ];
  }
}