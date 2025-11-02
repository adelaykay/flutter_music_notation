// example/lib/main.dart (Phase 2 Demo)

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
      title: 'Music Notation Phase 2 Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Phase2Demo(),
    );
  }
}

class Phase2Demo extends StatefulWidget {
  const Phase2Demo({super.key});

  @override
  State<Phase2Demo> createState() => _Phase2DemoState();
}

class _Phase2DemoState extends State<Phase2Demo> {
  late PlaybackController _playbackController;
  late List<Note> _notes;

  @override
  void initState() {
    super.initState();
    _notes = _createSampleMelody();
    _playbackController = PlaybackController(
      notes: _notes,
      beatsPerMinute: 120.0,
    );
  }

  @override
  void dispose() {
    _playbackController.dispose();
    super.dispose();
  }

  /// Create a simple melody: C D E F G (quarter notes)
  List<Note> _createSampleMelody() {
    return [
      // C4
      Note(
        pitch: Pitch(noteName: NoteName.C, octave: 4),
        duration: const NoteDuration.quarter(),
        startBeat: 0.0,
      ),
      // D4
      Note(
        pitch: Pitch(noteName: NoteName.D, octave: 4),
        duration: const NoteDuration.quarter(),
        startBeat: 1.0,
      ),
      // E4
      Note(
        pitch: Pitch(noteName: NoteName.E, octave: 4),
        duration: const NoteDuration.quarter(),
        startBeat: 2.0,
      ),
      // F4
      Note(
        pitch: Pitch(noteName: NoteName.F, octave: 4),
        duration: const NoteDuration.quarter(),
        startBeat: 3.0,
      ),
      // G4
      Note(
        pitch: Pitch(noteName: NoteName.G, octave: 4),
        duration: const NoteDuration.half(),
        startBeat: 4.0,
      ),
      // C major chord
      Note(
        pitch: Pitch(noteName: NoteName.C, octave: 4),
        duration: const NoteDuration.whole(),
        startBeat: 6.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.E, octave: 4),
        duration: const NoteDuration.whole(),
        startBeat: 6.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.G, octave: 4),
        duration: const NoteDuration.whole(),
        startBeat: 6.0,
      ),
    ];
  }

  List<Note> _createScaleWithAccidentals() {
    return [
      // C major scale with some accidentals
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
        pitch: Pitch(noteName: NoteName.F, accidental: Accidental.sharp, octave: 4),
        duration: const NoteDuration.eighth(),
        startBeat: 1.5,
      ),
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
        pitch: Pitch(noteName: NoteName.B, accidental: Accidental.flat, octave: 4),
        duration: const NoteDuration.eighth(),
        startBeat: 3.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.C, octave: 5),
        duration: const NoteDuration.quarter(),
        startBeat: 3.5,
      ),
    ];
  }

  List<Note> _createBassNotes() {
    return [
      Note(
        pitch: Pitch(noteName: NoteName.E, octave: 2),
        duration: const NoteDuration.quarter(),
        startBeat: 0.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.G, octave: 2),
        duration: const NoteDuration.quarter(),
        startBeat: 1.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.B, octave: 2),
        duration: const NoteDuration.quarter(),
        startBeat: 2.0,
      ),
      Note(
        pitch: Pitch(noteName: NoteName.D, octave: 3),
        duration: const NoteDuration.half(),
        startBeat: 3.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Phase 2: Note Rendering & Playback'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Playback controls
            _buildPlaybackControls(),

            const Divider(height: 40),

            // Notation view with simple melody
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Simple Melody with Playback',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.white,
              ),
              child: NotationView(
                notes: _notes,
                playbackController: _playbackController,
                config: const NotationConfig(
                  staffSpaceSize: 12,
                  pixelsPerNote: 40,
                  activeNoteColor: Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Scale with accidentals (no playback)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Scale with Accidentals (F♯, B♭)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.white,
              ),
              child: NotationView(
                notes: _createScaleWithAccidentals(),
                config: const NotationConfig(
                  staffSpaceSize: 12,
                  pixelsPerNote: 40,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Bass clef example
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Bass Clef Notes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.white,
              ),
              child: NotationView(
                notes: _createBassNotes(),
                config: const NotationConfig(
                  staffSpaceSize: 12,
                  pixelsPerNote: 50,
                  clef: ClefType.bass,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Widget _buildPlaybackControls() {
    return ListenableBuilder(
      listenable: _playbackController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[200],
          child: Column(
            children: [
              // Position slider
              Row(
                children: [
                  Text('Beat: ${_playbackController.position.toStringAsFixed(1)}'),
                  Expanded(
                    child: Slider(
                      value: _playbackController.position,
                      max: 10.0,
                      onChanged: (value) {
                        _playbackController.seekTo(value);
                      },
                    ),
                  ),
                ],
              ),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _playbackController.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 40,
                    ),
                    onPressed: () {
                      if (_playbackController.isPlaying) {
                        _playbackController.pause();
                      } else {
                        _playbackController.play();
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.stop, size: 40),
                    onPressed: () {
                      _playbackController.stop();
                    },
                  ),
                  const SizedBox(width: 20),
                  Text('Speed: ${_playbackController.speed.toStringAsFixed(1)}x'),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      _playbackController.setSpeed(_playbackController.speed - 0.1);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _playbackController.setSpeed(_playbackController.speed + 0.1);
                    },
                  ),
                ],
              ),

              // Active notes display
              if (_playbackController.activeNotes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Playing: ${_playbackController.activeNotes.map((n) => n.pitch.scientificName).join(", ")}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}