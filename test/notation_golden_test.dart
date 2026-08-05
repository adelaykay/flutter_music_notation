// Golden tests for the notation graphics rendered by the example app.
//
// The demo data and configurations below mirror example/lib/main.dart so that
// these goldens guard the same NotationView rendering paths the example app
// exercises. Measures/config must be kept in sync with main.dart if that demo
// content changes.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_music_notation/flutter_music_notation.dart';

Future<void> _loadNotationFonts() async {
  final loaders = <FontLoader>[
    FontLoader('Bravura')
      ..addFont(rootBundle.load('assets/fonts/Bravura.otf')),
    FontLoader('Petaluma')
      ..addFont(rootBundle.load('assets/fonts/Petaluma.otf')),
  ];
  for (final loader in loaders) {
    await loader.load();
  }
}

List<Measure> _createLongPiece() {
  return [
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
    Measure(
      number: 5,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cFlatMajor,
      notes: [
        Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.whole(), startBeat: 0.0),
      ],
      endBarline: BarlineType.single,
    ),
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
        Note(pitch: Pitch(noteName: NoteName.D, accidental: Accidental.sharp, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
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

Widget _buildNotation(
  List<Measure> measures, {
  required bool useSystemLayout,
  SpacingEngine? spacingEngine,
  LineBreakConfig? lineBreakConfig,
  bool showMeasureNumbers = true,
}) {
  return Container(
    width: 1200,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    child: NotationView(
      measures: measures,
      config: NotationConfig(
        staffSpaceSize: 12,
        leftMargin: 60,
        rightMargin: 20,
        topMargin: 30,
        measureSpacing: 20,
        spacingEngine: spacingEngine ?? SpacingPresets.loose,
        useSystemLayout: useSystemLayout,
        systemHeight: 150,
        systemSpacing: 50,
        showMeasureNumbers: showMeasureNumbers,
        lineBreakConfig: lineBreakConfig,
      ),
    ),
  );
}

Future<void> _pumpGolden(
  WidgetTester tester,
  String name, {
  required List<Measure> measures,
  required bool useSystemLayout,
  SpacingEngine? spacingEngine,
  LineBreakConfig? lineBreakConfig,
  bool showMeasureNumbers = true,
}) async {
  final boundaryKey = GlobalKey();

  addTearDown(tester.view.reset);

  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(1400, 1800);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            key: boundaryKey,
            child: _buildNotation(
              measures,
              useSystemLayout: useSystemLayout,
              spacingEngine: spacingEngine,
              lineBreakConfig: lineBreakConfig,
              showMeasureNumbers: showMeasureNumbers,
            ),
          ),
        ),
      ),
    ),
  );

  await expectLater(
    find.byKey(boundaryKey),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  setUpAll(_loadNotationFonts);

  testWidgets('Single Line (Old Behavior)', (tester) async {
    await _pumpGolden(
      tester,
      'single_line',
      measures: _createLongPiece(),
      useSystemLayout: false,
    );
  });

  testWidgets('Multi-Line Layout', (tester) async {
    await _pumpGolden(
      tester,
      'multi_line',
      measures: _createLongPiece(),
      useSystemLayout: true,
    );
  });

  testWidgets('Greedy strategy', (tester) async {
    await _pumpGolden(
      tester,
      'greedy_strategy',
      measures: _createLongPiece(),
      useSystemLayout: true,
      lineBreakConfig: LineBreakConfig(
        strategy: LineBreakStrategy.greedy,
        targetLineWidth: 700,
        minMeasuresPerLine: 2,
        maxMeasuresPerLine: 6,
      ),
    );
  });

  testWidgets('Balanced strategy', (tester) async {
    await _pumpGolden(
      tester,
      'balanced_strategy',
      measures: _createLongPiece(),
      useSystemLayout: true,
      lineBreakConfig: LineBreakConfig(
        strategy: LineBreakStrategy.balanced,
        targetLineWidth: 700,
        minMeasuresPerLine: 2,
        maxMeasuresPerLine: 6,
      ),
    );
  });

  testWidgets('Compact layout', (tester) async {
    await _pumpGolden(
      tester,
      'compact_layout',
      measures: _createLongPiece(),
      useSystemLayout: true,
      spacingEngine: SpacingPresets.tight,
      lineBreakConfig: LineBreakConfig.compact(1000),
    );
  });

  testWidgets('Spacious layout', (tester) async {
    await _pumpGolden(
      tester,
      'spacious_layout',
      measures: _createLongPiece(),
      useSystemLayout: true,
      spacingEngine: SpacingPresets.loose,
      lineBreakConfig: LineBreakConfig.spacious(700),
    );
  });

  testWidgets('Mary Had a Little Lamb', (tester) async {
    await _pumpGolden(
      tester,
      'mary_had_a_little_lamb',
      measures: _createMaryHadALittleLamb(),
      useSystemLayout: true,
      showMeasureNumbers: true,
    );
  });
}