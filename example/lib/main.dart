// example/lib/main.dart

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
      title: 'Music Notation Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MusicNotationDemo(),
    );
  }
}

class MusicNotationDemo extends StatefulWidget {
  const MusicNotationDemo({super.key});

  @override
  State<MusicNotationDemo> createState() => _MusicNotationDemoState();
}

class _MusicNotationDemoState extends State<MusicNotationDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Music Notation Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phase 0: Foundation Tests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Test 1: Pitch Model
            _buildTestSection(
              'Pitch Model',
              _testPitchModel(),
            ),

            // Test 2: Duration Model
            _buildTestSection(
              'Duration Model',
              _testDurationModel(),
            ),

            // Test 3: Note Model
            _buildTestSection(
              'Note Model',
              _testNoteModel(),
            ),

            // Test 4: Staff Position
            _buildTestSection(
              'Staff Position',
              _testStaffPosition(),
            ),

            // Test 5: Visual Staff Rendering
            const Text(
              'Staff Rendering',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.white,
              ),
              child: CustomPaint(
                painter: SimpleStaffPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            content,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _testPitchModel() {
    final c4 = Pitch(noteName: NoteName.C, octave: 4);
    final fSharp5 = Pitch(noteName: NoteName.F, accidental: Accidental.sharp, octave: 5);
    final bFlat3 = Pitch.fromMidiNumber(58, preferredAccidental: Accidental.flat);

    return '''
Middle C: $c4 (MIDI: ${c4.midiNumber})
F♯5: $fSharp5 (MIDI: ${fSharp5.midiNumber})
MIDI 58 as flat: $bFlat3

Accidental symbols:
Sharp: ${Accidental.sharp.symbol}
Flat: ${Accidental.flat.symbol}
Natural: ${Accidental.natural.symbol}
''';
  }

  String _testDurationModel() {
    const quarter = NoteDuration.quarter();
    const dottedHalf = NoteDuration.dottedHalf();
    final triplet = NoteDuration(
      type: DurationType.eighth,
      tuplet: Tuplet.triplet,
    );

    return '''
Quarter note: ${quarter.beats} beats
Dotted half: ${dottedHalf.beats} beats
Eighth triplet: ${triplet.beats} beats

Quarter needs stem: ${quarter.needsStem}
Quarter needs flag: ${quarter.needsFlag}
Eighth needs flag: ${const NoteDuration.eighth().needsFlag}
''';
  }

  String _testNoteModel() {
    final note1 = Note(
      pitch: Pitch(noteName: NoteName.E, octave: 4),
      duration: const NoteDuration.quarter(),
      startBeat: 0.0,
    );

    final note2 = Note(
      pitch: Pitch(noteName: NoteName.G, accidental: Accidental.sharp, octave: 4),
      duration: const NoteDuration.eighth(),
      startBeat: 1.0,
      velocity: 100,
    );

    final chord = Chord(notes: [
      Note(
        pitch: Pitch(noteName: NoteName.C, octave: 4),
        duration: const NoteDuration.half(),
        startBeat: 2.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.E, octave: 4),
        duration: const NoteDuration.half(),
        startBeat: 2.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.G, octave: 4),
        duration: const NoteDuration.half(),
        startBeat: 2.0,
      ),
    ]);

    return '''
$note1
  Start: ${note1.startBeat}, End: ${note1.endBeat}

$note2
  Velocity: ${note2.velocity}

$chord
  Lowest: ${chord.lowestNote.pitch}
  Highest: ${chord.highestNote.pitch}
''';
  }

  String _testStaffPosition() {
    final c4 = Pitch(noteName: NoteName.C, octave: 4);
    final treblePos = StaffPosition.forPitch(c4, ClefType.treble);
    final bassPos = StaffPosition.forPitch(c4, ClefType.bass);

    final e5 = Pitch(noteName: NoteName.E, octave: 5);
    final e5Pos = StaffPosition.forPitch(e5, ClefType.treble);

    final a2 = Pitch(noteName: NoteName.A, octave: 2);
    final a2Pos = StaffPosition.forPitch(a2, ClefType.bass);

    return '''
Middle C (C4):
  Treble: ${treblePos.value} ${treblePos.needsLedgerLinesBelow ? '(ledger below)' : ''}
  Bass: ${bassPos.value} ${bassPos.needsLedgerLinesAbove ? '(ledger above)' : ''}

E5 in treble: ${e5Pos.value} ${e5Pos.isLine ? '(line)' : '(space)'}
A2 in bass: ${a2Pos.value} ${a2Pos.needsLedgerLinesBelow ? '(ledger below)' : ''}

Ledger lines for C4 in treble: ${treblePos.getLedgerLinePositions()}
''';
  }
}

/// Simple painter to demonstrate staff rendering
class SimpleStaffPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final staffRenderer = StaffRenderer(staffSpaceSize: 12.0);

    // Draw staff in the center
    final staffY = (size.height - staffRenderer.height) / 2;
    staffRenderer.paint(canvas, Offset(20, staffY), size.width - 40);

    // Draw a few test ledger lines
    final middleC = StaffPosition.forPitch(
      Pitch(noteName: NoteName.C, octave: 4),
      ClefType.treble,
    );

    staffRenderer.paintLedgerLines(
      canvas,
      Offset(100, staffY + staffRenderer.positionToY(middleC)),
      middleC,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}