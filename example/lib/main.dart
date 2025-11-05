// example/lib/main.dart - Comprehensive Phase 3 Demo

import 'package:flutter/material.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';
import 'package:flutter_notation_example/phase4_spacing_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Music Notation - Phase 3 Complete',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SpacingDemo(),
    );
  }
}

class ComprehensiveDemo extends StatefulWidget {
  const ComprehensiveDemo({super.key});

  @override
  State<ComprehensiveDemo> createState() => _ComprehensiveDemoState();
}

class _ComprehensiveDemoState extends State<ComprehensiveDemo> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Music Notation - Complete Demo'),
      ),
      body: Column(
        children: [
          // Tab selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabButton('Clefs', 0),
                _buildTabButton('Key Signatures', 1),
                _buildTabButton('Time Signatures', 2),
                _buildTabButton('Notes & Rests', 3),
                _buildTabButton('Dotted Notes', 4),
                _buildTabButton('Ledger Lines', 5),
                _buildTabButton('Barlines', 6),
                _buildTabButton('Complete Pieces', 7),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedTab = index),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildClefsDemo();
      case 1:
        return _buildKeySignaturesDemo();
      case 2:
        return _buildTimeSignaturesDemo();
      case 3:
        return _buildNotesAndRestsDemo();
      case 4:
        return _buildDottedNotesDemo();
      case 5:
        return _buildLedgerLinesDemo();
      case 6:
        return _buildBarlinesDemo();
      case 7:
        return _buildCompletePiecesDemo();
      default:
        return const SizedBox();
    }
  }

  // ========== TAB 1: CLEFS ==========
  Widget _buildClefsDemo() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildDemoTitle('All Clef Types'),

        _buildSection(
          'Treble Clef (G Clef)',
          _createMeasuresForClef(ClefType.treble),
          clef: ClefType.treble,
        ),

        _buildSection(
          'Bass Clef (F Clef)',
          _createMeasuresForClef(ClefType.bass),
          clef: ClefType.bass,
        ),

        _buildSection(
          'Alto Clef (C Clef on Middle Line)',
          _createMeasuresForClef(ClefType.alto),
          clef: ClefType.alto,
        ),

        _buildSection(
          'Tenor Clef (C Clef on 4th Line)',
          _createMeasuresForClef(ClefType.tenor),
          clef: ClefType.tenor,
        ),
      ],
    );
  }

  List<Measure> _createMeasuresForClef(ClefType clef) {
    // Create scale appropriate for each clef
    final notes = switch (clef) {
      ClefType.treble => [
        Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
        Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
        Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
        Note(pitch: Pitch(noteName: NoteName.F, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
      ],
      ClefType.bass => [
        Note(pitch: Pitch(noteName: NoteName.E, octave: 2), duration: const NoteDuration.quarter(), startBeat: 0.0),
        Note(pitch: Pitch(noteName: NoteName.F, octave: 2), duration: const NoteDuration.quarter(), startBeat: 1.0),
        Note(pitch: Pitch(noteName: NoteName.G, octave: 2), duration: const NoteDuration.quarter(), startBeat: 2.0),
        Note(pitch: Pitch(noteName: NoteName.A, octave: 2), duration: const NoteDuration.quarter(), startBeat: 3.0),
      ],
      ClefType.alto => [
        Note(pitch: Pitch(noteName: NoteName.C, octave: 3), duration: const NoteDuration.quarter(), startBeat: 0.0),
        Note(pitch: Pitch(noteName: NoteName.D, octave: 3), duration: const NoteDuration.quarter(), startBeat: 1.0),
        Note(pitch: Pitch(noteName: NoteName.E, octave: 3), duration: const NoteDuration.quarter(), startBeat: 2.0),
        Note(pitch: Pitch(noteName: NoteName.F, octave: 3), duration: const NoteDuration.quarter(), startBeat: 3.0),
      ],
      ClefType.tenor => [
        Note(pitch: Pitch(noteName: NoteName.A, octave: 2), duration: const NoteDuration.quarter(), startBeat: 0.0),
        Note(pitch: Pitch(noteName: NoteName.B, octave: 2), duration: const NoteDuration.quarter(), startBeat: 1.0),
        Note(pitch: Pitch(noteName: NoteName.C, octave: 3), duration: const NoteDuration.quarter(), startBeat: 2.0),
        Note(pitch: Pitch(noteName: NoteName.D, octave: 3), duration: const NoteDuration.quarter(), startBeat: 3.0),
      ],
    };

    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: notes,
        endBarline: BarlineType.final_,
      ),
    ];
  }

  // ========== TAB 2: KEY SIGNATURES ==========
  Widget _buildKeySignaturesDemo() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildDemoTitle('All Key Signatures'),

        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Sharp Keys (1-7 sharps)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        _buildSection('C Major (0 sharps)', _createKeySignatureMeasure(KeySignature.cMajor)),
        _buildSection('G Major (1 sharp: F♯)', _createKeySignatureMeasure(KeySignature.gMajor)),
        _buildSection('D Major (2 sharps: F♯, C♯)', _createKeySignatureMeasure(KeySignature.dMajor)),
        _buildSection('A Major (3 sharps)', _createKeySignatureMeasure(KeySignature.aMajor)),
        _buildSection('E Major (4 sharps)', _createKeySignatureMeasure(KeySignature.eMajor)),
        _buildSection('B Major (5 sharps)', _createKeySignatureMeasure(KeySignature.bMajor)),
        _buildSection('F♯ Major (6 sharps)', _createKeySignatureMeasure(KeySignature.fSharpMajor)),
        _buildSection('C♯ Major (7 sharps)', _createKeySignatureMeasure(KeySignature.cSharpMajor)),

        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Flat Keys (1-7 flats)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        _buildSection('F Major (1 flat: B♭)', _createKeySignatureMeasure(KeySignature.fMajor)),
        _buildSection('B♭ Major (2 flats)', _createKeySignatureMeasure(KeySignature.bFlatMajor)),
        _buildSection('E♭ Major (3 flats)', _createKeySignatureMeasure(KeySignature.eFlatMajor)),
        _buildSection('A♭ Major (4 flats)', _createKeySignatureMeasure(KeySignature.aFlatMajor)),
        _buildSection('D♭ Major (5 flats)', _createKeySignatureMeasure(KeySignature.dFlatMajor)),
        _buildSection('G♭ Major (6 flats)', _createKeySignatureMeasure(KeySignature.gFlatMajor)),
        _buildSection('C♭ Major (7 flats)', _createKeySignatureMeasure(KeySignature.cFlatMajor)),
      ],
    );
  }

  List<Measure> _createKeySignatureMeasure(KeySignature keySignature) {
    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: keySignature,
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

  // ========== TAB 3: TIME SIGNATURES ==========
  Widget _buildTimeSignaturesDemo() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildDemoTitle('Common Time Signatures'),

        _buildSection('4/4 (Common Time)', _createTimeSignatureMeasure(TimeSignature.fourFour)),
        _buildSection('3/4 (Waltz Time)', _createTimeSignatureMeasure(TimeSignature.threeFour)),
        _buildSection('2/4', _createTimeSignatureMeasure(TimeSignature.twoFour)),
        _buildSection('6/8', _createTimeSignatureMeasure(TimeSignature.sixEight)),
        _buildSection('3/8', _createTimeSignatureMeasure(TimeSignature.threeEight)),
        _buildSection('12/8', _createTimeSignatureMeasure(TimeSignature.twelveEight)),
        _buildSection('2/2 (Cut Time)', _createTimeSignatureMeasure(TimeSignature.twoTwo)),
      ],
    );
  }

  List<Measure> _createTimeSignatureMeasure(TimeSignature timeSignature) {
    // Create notes that fill the measure based on time signature
    final notes = <Note>[];
    final beatsPerMeasure = timeSignature.beatsPerMeasure;

    // Fill with quarter notes (1 beat each in 4/4)
    for (double beat = 0; beat < beatsPerMeasure && notes.length < 4; beat += 1.0) {
      notes.add(
        Note(
          pitch: Pitch(noteName: NoteName.values[notes.length % 7], octave: 4),
          duration: const NoteDuration.quarter(),
          startBeat: beat,
        ),
      );
    }

    return [
      Measure(
        number: 0,
        timeSignature: timeSignature,
        keySignature: KeySignature.cMajor,
        notes: notes,
        endBarline: BarlineType.final_,
      ),
    ];
  }

  // ========== TAB 4: NOTES AND RESTS ==========
  Widget _buildNotesAndRestsDemo() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildDemoTitle('Note Durations and Rests'),

        _buildSection('Whole Notes', _createNoteDurationMeasure(DurationType.whole)),
        _buildSection('Half Notes', _createNoteDurationMeasure(DurationType.half)),
        _buildSection('Quarter Notes', _createNoteDurationMeasure(DurationType.quarter)),
        _buildSection('Eighth Notes', _createNoteDurationMeasure(DurationType.eighth)),
        _buildSection('Sixteenth Notes', _createNoteDurationMeasure(DurationType.sixteenth)),

        const SizedBox(height: 20),
        _buildSection('Mixed Notes and Rests', _createMixedNotesAndRests()),
      ],
    );
  }

  List<Measure> _createNoteDurationMeasure(DurationType durationType) {
    final duration = NoteDuration(type: durationType);
    final notesPerMeasure = (4.0 / duration.beats).floor();

    final notes = <Note>[];
    for (int i = 0; i < notesPerMeasure && i < 8; i++) {
      notes.add(
        Note(
          pitch: Pitch(noteName: NoteName.values[(i + 2) % 7], octave: 4),
          duration: duration,
          startBeat: i * duration.beats,
        ),
      );
    }

    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: notes,
        endBarline: BarlineType.final_,
      ),
    ];
  }

  List<Measure> _createMixedNotesAndRests() {
    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.eighth(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.eighth(), startBeat: 3.0),
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.sixteenth(), startBeat: 3.5),
        ],
        rests: [
          const Rest(duration: NoteDuration.quarter(), startBeat: 1.0),
          const Rest(duration: NoteDuration.eighth(), startBeat: 2.5),
          const Rest(duration: NoteDuration.sixteenth(), startBeat: 3.25),
        ],
        endBarline: BarlineType.final_,
      ),
    ];
  }

  // ========== TAB 5: DOTTED NOTES ==========
  Widget _buildDottedNotesDemo() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildDemoTitle('Dotted Notes'),

        _buildSection('Dotted Half Notes', _createDottedNotesMeasure(DurationType.half, 1)),
        _buildSection('Dotted Quarter Notes', _createDottedNotesMeasure(DurationType.quarter, 1)),
        _buildSection('Dotted Eighth Notes', _createDottedNotesMeasure(DurationType.eighth, 1)),
        _buildSection('Double Dotted Notes', _createDottedNotesMeasure(DurationType.half, 2)),
      ],
    );
  }

  List<Measure> _createDottedNotesMeasure(DurationType durationType, int dots) {
    final duration = NoteDuration(type: durationType, dots: dots);

    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: duration, startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: duration, startBeat: duration.beats),
        ],
        endBarline: BarlineType.final_,
      ),
    ];
  }

  // ========== TAB 6: LEDGER LINES ==========
  Widget _buildLedgerLinesDemo() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildDemoTitle('Ledger Lines'),

        _buildSection('Above Staff (Treble)', _createLedgerLinesMeasure(true, ClefType.treble)),
        _buildSection('Below Staff (Treble)', _createLedgerLinesMeasure(false, ClefType.treble)),
        _buildSection('Above Staff (Bass)', _createLedgerLinesMeasure(true, ClefType.bass), clef: ClefType.bass),
        _buildSection('Below Staff (Bass)', _createLedgerLinesMeasure(false, ClefType.bass), clef: ClefType.bass),
      ],
    );
  }

  List<Measure> _createLedgerLinesMeasure(bool above, ClefType clef) {
    final notes = <Note>[];

    if (above) {
      if (clef == ClefType.treble) {
        notes.addAll([
          Note(pitch: Pitch(noteName: NoteName.A, octave: 5), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.C, octave: 6), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 6), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.G, octave: 6), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ]);
      } else {
        notes.addAll([
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.B, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ]);
      }
    } else {
      if (clef == ClefType.treble) {
        notes.addAll([
          Note(pitch: Pitch(noteName: NoteName.C, octave: 3), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.A, octave: 2), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.F, octave: 2), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 2), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ]);
      } else {
        notes.addAll([
          Note(pitch: Pitch(noteName: NoteName.E, octave: 1), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.C, octave: 1), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.A, octave: 0), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.F, octave: 0), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ]);
      }
    }

    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: notes,
        endBarline: BarlineType.final_,
      ),
    ];
  }

  // ========== TAB 7: BARLINES ==========
  Widget _buildBarlinesDemo() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildDemoTitle('Barline Types'),

        _buildSection('Single Barline', _createBarlineMeasures([BarlineType.single])),
        _buildSection('Double Barline', _createBarlineMeasures([BarlineType.double_])),
        _buildSection('Final Barline', _createBarlineMeasures([BarlineType.final_])),
        _buildSection('Multiple Measures', _createBarlineMeasures([
          BarlineType.single,
          BarlineType.double_,
          BarlineType.final_,
        ])),
      ],
    );
  }

  List<Measure> _createBarlineMeasures(List<BarlineType> barlineTypes) {
    final measures = <Measure>[];

    for (int i = 0; i < barlineTypes.length; i++) {
      measures.add(
        Measure(
          number: i,
          timeSignature: TimeSignature.fourFour,
          keySignature: KeySignature.cMajor,
          notes: [
            Note(
              pitch: Pitch(noteName: NoteName.values[(i + 2) % 7], octave: 4),
              duration: const NoteDuration.whole(),
              startBeat: 0.0,
            ),
          ],
          endBarline: barlineTypes[i],
        ),
      );
    }

    return measures;
  }

  // ========== TAB 8: COMPLETE PIECES ==========
  Widget _buildCompletePiecesDemo() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildDemoTitle('Complete Musical Pieces'),

        _buildSection('Ode to Joy (Theme)', _createOdeToJoy()),
        _buildSection('Mary Had a Little Lamb', _createMaryHadALittleLamb()),
        _buildSection('Twinkle Twinkle Little Star', _createTwinkleTwinkle()),
      ],
    );
  }

  List<Measure> _createOdeToJoy() {
    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
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
        keySignature: KeySignature.cMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.F, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.double_,
      ),
    ];
  }

  List<Measure> _createMaryHadALittleLamb() {
    return [
      Measure(
        number: 0,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
          Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
        ],
        endBarline: BarlineType.single,
      ),
      Measure(
        number: 1,
        timeSignature: TimeSignature.fourFour,
        keySignature: KeySignature.cMajor,
        notes: [
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
          Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.half(), startBeat: 2.0),
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

  // ========== HELPER METHODS ==========
  Widget _buildDemoTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSection(
      String title,
      List<Measure> measures, {
        ClefType clef = ClefType.treble,
        double height = 180,
      }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: NotationView(
            measures: measures,
            config: NotationConfig(
              staffSpaceSize: 12,
              noteWidth: 50,
              leftMargin: 0,
              measureSpacing: 30,
              clef: clef,
              width: _calculateStaffWidth(measures, NotationConfig()),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateStaffWidth(List<Measure> measures, NotationConfig config) {
    // Estimate number of note/rest "slots" per measure
    int totalSlots = measures.fold(0, (sum, m) {
      int noteCount = m.notes.length;
      int restCount = m.rests.length;
      return sum + noteCount + restCount;
    });

    // Left margin + note widths + spacing between measures
    return config.leftMargin +
        (totalSlots * config.noteWidth) +
        ((measures.length - 1) * config.measureSpacing) +
        200; // right padding buffer
  }

}