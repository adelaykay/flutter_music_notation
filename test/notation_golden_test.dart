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
    FontLoader('packages/flutter_music_notation/Bravura')
      ..addFont(rootBundle.load('assets/fonts/Bravura.otf')),
    FontLoader('packages/flutter_music_notation/Petaluma')
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
        Note(
          pitch: Pitch(noteName: NoteName.C, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 0.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.D, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 1.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.E, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 2.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.F, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 3.0,
        ),
      ],
      endBarline: BarlineType.single,
    ),
    Measure(
      number: 1,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cFlatMajor,
      notes: [
        Note(
          pitch: Pitch(noteName: NoteName.G, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 0.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.A, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 1.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.B, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 2.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.C, octave: 5),
          duration: const NoteDuration.quarter(),
          startBeat: 3.0,
        ),
      ],
      endBarline: BarlineType.single,
    ),
    Measure(
      number: 2,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cFlatMajor,
      notes: [
        Note(
          pitch: Pitch(noteName: NoteName.C, octave: 5),
          duration: const NoteDuration.eighth(),
          startBeat: 0.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.B, octave: 4),
          duration: const NoteDuration.eighth(),
          startBeat: 0.5,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.A, octave: 4),
          duration: const NoteDuration.eighth(),
          startBeat: 1.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.G, octave: 4),
          duration: const NoteDuration.eighth(),
          startBeat: 1.5,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.F, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 2.0,
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
      number: 3,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cFlatMajor,
      notes: [
        Note(
          pitch: Pitch(noteName: NoteName.D, octave: 4),
          duration: const NoteDuration.half(),
          startBeat: 0.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.C, octave: 4),
          duration: const NoteDuration.half(),
          startBeat: 2.0,
        ),
      ],
      endBarline: BarlineType.double_,
    ),
    Measure(
      number: 4,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cFlatMajor,
      notes: [
        Note(
          pitch: Pitch(noteName: NoteName.E, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 0.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.F, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 1.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.G, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 2.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.A, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 3.0,
        ),
      ],
      endBarline: BarlineType.single,
    ),
    Measure(
      number: 5,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cFlatMajor,
      notes: [
        Note(
          pitch: Pitch(noteName: NoteName.G, octave: 4),
          duration: const NoteDuration.whole(),
          startBeat: 0.0,
        ),
      ],
      endBarline: BarlineType.single,
    ),
    Measure(
      number: 6,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cFlatMajor,
      notes: [
        Note(
          pitch: Pitch(noteName: NoteName.F, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 0.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.E, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 1.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.D, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 2.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.C, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 3.0,
        ),
      ],
      endBarline: BarlineType.single,
    ),
    Measure(
      number: 7,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cFlatMajor,
      notes: [
        Note(
          pitch: Pitch(noteName: NoteName.C, octave: 4),
          duration: const NoteDuration.whole(),
          startBeat: 0.0,
        ),
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
        Note(
          pitch: Pitch(noteName: NoteName.E, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 0.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.D, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 1.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.C, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 2.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.D, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 3.0,
        ),
      ],
    ),
    Measure(
      number: 1,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cFlatMajor,
      notes: [
        Note(
          pitch: Pitch(noteName: NoteName.E, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 0.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.E, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 1.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.E, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 2.0,
        ),
      ],
      rests: [Rest(duration: const NoteDuration.quarter(), startBeat: 3.0)],
    ),
    Measure(
      number: 2,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cFlatMajor,
      notes: [
        Note(
          pitch: Pitch(noteName: NoteName.D, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 0.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.D, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 1.0,
        ),
        Note(
          pitch: Pitch(
            noteName: NoteName.D,
            accidental: Accidental.sharp,
            octave: 4,
          ),
          duration: const NoteDuration.quarter(),
          startBeat: 2.0,
        ),
      ],
      rests: [Rest(duration: const NoteDuration.quarter(), startBeat: 3.0)],
    ),
    Measure(
      number: 3,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cFlatMajor,
      notes: [
        Note(
          pitch: Pitch(noteName: NoteName.E, octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: 0.0,
        ),
        Note(
          pitch: Pitch(noteName: NoteName.G, octave: 4),
          duration: const NoteDuration.half(),
          startBeat: 1.0,
        ),
      ],
      rests: [Rest(duration: const NoteDuration.quarter(), startBeat: 3.0)],
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

/// A short piano performance as it would arrive from a keyboard: timing
/// wobble, a held legato key, a note held across the barline, a pause, and
/// the raised leading note of A minor.
MidiData _performedPiece() {
  const bpm = 90.0;
  const msPerBeat = 60000 / bpm;
  final wobble = [
    0.03,
    -0.04,
    0.02,
    -0.02,
    0.05,
    -0.03,
    0.01,
    0.04,
    -0.05,
    0.02,
  ];
  var w = 0;
  MidiNote n(int midi, double start, double length) {
    final a = wobble[w++ % wobble.length], b = wobble[w++ % wobble.length];
    return MidiNote(
      midiNumber: midi,
      velocity: 80,
      startTime: ((start + a) * msPerBeat).round(),
      endTime: ((start + length + b) * msPerBeat).round(),
    );
  }

  return MidiData(
    notes: [
      // right hand
      n(76, 0, 1.15),
      n(74, 1, 1.1),
      n(72, 2, 0.5),
      n(71, 2.5, 0.5),
      n(72, 3, 2), // tied over the bar
      n(76, 5, 0.5), n(77, 5.5, 0.5), n(76, 6, 1), n(68, 7, 1),
      n(69, 8, 3), // then a rest
      // left hand
      n(45, 0, 2), n(52, 0, 2), n(45, 2, 2), n(52, 2, 2),
      n(50, 4, 4), n(53, 4, 4),
      n(45, 8, 4), n(52, 8, 4),
    ],
    keySignatureSharps: 0,
    keySignatureIsMinor: true,
    beatsPerMinute: bpm,
    ticksPerQuarterNote: 480,
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

  testWidgets('Performed MIDI on a grand staff', (tester) async {
    final boundaryKey = GlobalKey();
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 500);
    final grandStaff = MidiToNotation(
      midiData: _performedPiece(),
    ).toGrandStaff();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: boundaryKey,
              child: NotationView(
                grandStaff: grandStaff,
                config: const NotationConfig(
                  width: 1100,
                  height: 400,
                  useSystemLayout: true,
                  enableBeaming: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byKey(boundaryKey),
      matchesGoldenFile('goldens/performed_grand_staff.png'),
    );
  });

  testWidgets('Hymn in four parts on narrow systems', (tester) async {
    // Two voices per staff with stems up and down, rests that belong to a
    // voice, ties inside a bar and across a bar, a playing bar shaded, and
    // systems broken to fit a phone-width page.
    final boundaryKey = GlobalKey();
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(420, 900);
    const key = KeySignature(accidentals: -2);
    const time = TimeSignature(beats: 3, beatUnit: 4);
    Note n(
      int midi,
      NoteDuration d,
      double beat,
      int voice, {
      bool tie = false,
    }) => Note(
      pitch: Pitch.fromMidiNumber(midi, preferredAccidental: Accidental.flat),
      duration: d,
      startBeat: beat,
      voice: voice,
      stemDirection: voice.isEven ? StemDirection.up : StemDirection.down,
      tieToNext: tie,
    );
    const q = NoteDuration.quarter(),
        h = NoteDuration.half(),
        dh = NoteDuration.dottedHalf(),
        e = NoteDuration.eighth();
    final upper = <Measure>[], lower = <Measure>[];
    for (var b = 0; b < 6; b++) {
      upper.add(
        Measure(
          number: b,
          timeSignature: time,
          keySignature: key,
          notes: [
            if (b == 2) ...[
              n(74, q, 0, 0, tie: true),
              n(74, e, 1, 0),
              n(72, e, 1.5, 0),
              n(70, q, 2, 0),
            ] else ...[
              n(70 + b % 3, h, 0, 0),
              n(72, q, 2, 0, tie: b == 3),
            ],
            n(65, h, 0, 1),
            if (b != 4) n(67, q, 2, 1),
          ],
          rests: [
            if (b == 4)
              const Rest(
                duration: NoteDuration.quarter(),
                startBeat: 2,
                voice: 1,
              ),
          ],
          endBarline: b == 5 ? BarlineType.final_ : BarlineType.single,
        ),
      );
      lower.add(
        Measure(
          number: b,
          timeSignature: time,
          keySignature: key,
          notes: [n(62, q, 0, 2), n(63, h, 1, 2), n(46 + b % 2, dh, 0, 3)],
          endBarline: b == 5 ? BarlineType.final_ : BarlineType.single,
        ),
      );
    }
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: boundaryKey,
              child: SizedBox(
                width: 400,
                child: NotationView(
                  grandStaff: GrandStaff(upperStaff: upper, lowerStaff: lower),
                  config: const NotationConfig(
                    staffSpaceSize: 8,
                    leftMargin: 22,
                    rightMargin: 16,
                    padding: EdgeInsets.zero,
                    useSystemLayout: true,
                    highlightedMeasure: 3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byKey(boundaryKey),
      matchesGoldenFile('goldens/hymn_narrow_systems.png'),
    );
  });
}
