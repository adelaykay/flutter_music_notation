# Examples

Complete code examples demonstrating various features of Flutter Music Notation.

## Table of Contents

1. [Basic Examples](#basic-examples)
2. [Clefs](#clefs)
3. [Key Signatures](#key-signatures)
4. [Time Signatures](#time-signatures)
5. [Note Durations](#note-durations)
6. [Rests](#rests)
7. [Chords](#chords)
8. [Complete Pieces](#complete-pieces)
9. [Playback](#playback)
10. [Advanced](#advanced)

---

## Basic Examples

### Hello World - Four Quarter Notes

```dart
import 'package:flutter/material.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';

class HelloNotation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NotationView(
      measures: [
        Measure(
          number: 0,
          timeSignature: TimeSignature.fourFour,
          keySignature: KeySignature.cMajor,
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
          endBarline: BarlineType.final_,
        ),
      ],
    );
  }
}
```

### C Major Scale

```dart
Measure createCMajorScale() {
  final notes = [
    Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.eighth(), startBeat: 0.0),
    Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.eighth(), startBeat: 0.5),
    Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.eighth(), startBeat: 1.0),
    Note(pitch: Pitch(noteName: NoteName.F, octave: 4), duration: const NoteDuration.eighth(), startBeat: 1.5),
    Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.eighth(), startBeat: 2.0),
    Note(pitch: Pitch(noteName: NoteName.A, octave: 4), duration: const NoteDuration.eighth(), startBeat: 2.5),
    Note(pitch: Pitch(noteName: NoteName.B, octave: 4), duration: const NoteDuration.eighth(), startBeat: 3.0),
    Note(pitch: Pitch(noteName: NoteName.C, octave: 5), duration: const NoteDuration.eighth(), startBeat: 3.5),
  ];

  return Measure(
    number: 0,
    timeSignature: TimeSignature.fourFour,
    keySignature: KeySignature.cMajor,
    notes: notes,
    endBarline: BarlineType.final_,
  );
}
```

---

## Clefs

### Treble Clef (G Clef)

```dart
NotationView(
  measures: [createMeasure()],
  config: const NotationConfig(
    clef: ClefType.treble,
  ),
)
```

### Bass Clef (F Clef)

```dart
// Bass clef typically uses lower pitches
Measure createBassClefMeasure() {
  return Measure(
    number: 0,
    timeSignature: TimeSignature.fourFour,
    keySignature: KeySignature.cMajor,
    notes: [
      Note(pitch: Pitch(noteName: NoteName.E, octave: 2), duration: const NoteDuration.quarter(), startBeat: 0.0),
      Note(pitch: Pitch(noteName: NoteName.G, octave: 2), duration: const NoteDuration.quarter(), startBeat: 1.0),
      Note(pitch: Pitch(noteName: NoteName.B, octave: 2), duration: const NoteDuration.quarter(), startBeat: 2.0),
      Note(pitch: Pitch(noteName: NoteName.D, octave: 3), duration: const NoteDuration.quarter(), startBeat: 3.0),
    ],
    endBarline: BarlineType.final_,
  );
}

NotationView(
  measures: [createBassClefMeasure()],
  config: const NotationConfig(
    clef: ClefType.bass,
  ),
)
```

### Alto Clef (C Clef)

```dart
NotationView(
  measures: [createMeasure()],
  config: const NotationConfig(
    clef: ClefType.alto,
  ),
)
```

### Tenor Clef

```dart
NotationView(
  measures: [createMeasure()],
  config: const NotationConfig(
    clef: ClefType.tenor,
  ),
)
```

---

## Key Signatures

### Sharp Keys

```dart
// G Major (1 sharp: F#)
Measure(
  keySignature: KeySignature.gMajor,
  notes: [
    Note(pitch: Pitch(noteName: NoteName.G, octave: 4), ...),
    Note(pitch: Pitch(noteName: NoteName.A, octave: 4), ...),
    Note(pitch: Pitch(noteName: NoteName.B, octave: 4), ...),
    // F# is implied by key signature
  ],
  ...
)

// D Major (2 sharps: F#, C#)
Measure(
  keySignature: KeySignature.dMajor,
  ...
)

// A Major (3 sharps: F#, C#, G#)
Measure(
  keySignature: KeySignature.aMajor,
  ...
)
```

### Flat Keys

```dart
// F Major (1 flat: Bb)
Measure(
  keySignature: KeySignature.fMajor,
  notes: [
    Note(pitch: Pitch(noteName: NoteName.F, octave: 4), ...),
    Note(pitch: Pitch(noteName: NoteName.G, octave: 4), ...),
    Note(pitch: Pitch(noteName: NoteName.A, octave: 4), ...),
    Note(pitch: Pitch(noteName: NoteName.B, accidental: Accidental.flat, octave: 4), ...),
  ],
  ...
)

// Bb Major (2 flats: Bb, Eb)
Measure(
  keySignature: KeySignature.bFlatMajor,
  ...
)

// Eb Major (3 flats: Bb, Eb, Ab)
Measure(
  keySignature: KeySignature.eFlatMajor,
  ...
)
```

### Key Change Mid-Piece

```dart
List<Measure> createKeyChangePiece() {
  return [
    // Start in C major
    Measure(
      number: 0,
      keySignature: KeySignature.cMajor,
      timeSignature: TimeSignature.fourFour,
      notes: [...],
      endBarline: BarlineType.single,
    ),
    
    // Modulate to G major
    Measure(
      number: 1,
      keySignature: KeySignature.gMajor,  // Key change!
      timeSignature: TimeSignature.fourFour,
      notes: [...],
      endBarline: BarlineType.final_,
    ),
  ];
}
```

---

## Time Signatures

### Common Time (4/4)

```dart
Measure(
  timeSignature: TimeSignature.fourFour,
  // or TimeSignature(beats: 4, beatUnit: 4)
  notes: [
    Note(..., startBeat: 0.0),  // Beat 1
    Note(..., startBeat: 1.0),  // Beat 2
    Note(..., startBeat: 2.0),  // Beat 3
    Note(..., startBeat: 3.0),  // Beat 4
  ],
  ...
)
```

### Waltz Time (3/4)

```dart
Measure(
  timeSignature: TimeSignature.threeFour,
  notes: [
    Note(..., startBeat: 0.0),  // Beat 1
    Note(..., startBeat: 1.0),  // Beat 2
    Note(..., startBeat: 2.0),  // Beat 3
  ],
  ...
)
```

### Compound Time (6/8)

```dart
Measure(
  timeSignature: TimeSignature.sixEight,
  notes: [
    // 6 eighth notes
    Note(..., duration: const NoteDuration.eighth(), startBeat: 0.0),
    Note(..., duration: const NoteDuration.eighth(), startBeat: 0.5),
    Note(..., duration: const NoteDuration.eighth(), startBeat: 1.0),
    Note(..., duration: const NoteDuration.eighth(), startBeat: 1.5),
    Note(..., duration: const NoteDuration.eighth(), startBeat: 2.0),
    Note(..., duration: const NoteDuration.eighth(), startBeat: 2.5),
  ],
  ...
)
```

### Cut Time (2/2)

```dart
Measure(
  timeSignature: TimeSignature.twoTwo,
  notes: [
    Note(..., duration: const NoteDuration.half(), startBeat: 0.0),
    Note(..., duration: const NoteDuration.half(), startBeat: 2.0),
  ],
  ...
)
```

### Irregular Time Signatures

```dart
// 5/4 time
Measure(
  timeSignature: const TimeSignature(beats: 5, beatUnit: 4),
  notes: [...],  // 5 quarter notes worth
  ...
)

// 7/8 time
Measure(
  timeSignature: const TimeSignature(beats: 7, beatUnit: 8),
  notes: [...],  // 7 eighth notes worth
  ...
)
```

---

## Note Durations

### All Standard Durations

```dart
// Whole note (4 beats in 4/4)
Note(..., duration: const NoteDuration.whole(), startBeat: 0.0)

// Half note (2 beats)
Note(..., duration: const NoteDuration.half(), startBeat: 0.0)

// Quarter note (1 beat)
Note(..., duration: const NoteDuration.quarter(), startBeat: 0.0)

// Eighth note (0.5 beats)
Note(..., duration: const NoteDuration.eighth(), startBeat: 0.0)

// Sixteenth note (0.25 beats)
Note(..., duration: const NoteDuration.sixteenth(), startBeat: 0.0)
```

### Dotted Notes

```dart
// Dotted half note (3 beats)
Note(
  pitch: Pitch(noteName: NoteName.C, octave: 4),
  duration: const NoteDuration(type: DurationType.half, dots: 1),
  startBeat: 0.0,
)

// Dotted quarter note (1.5 beats)
Note(
  pitch: Pitch(noteName: NoteName.E, octave: 4),
  duration: const NoteDuration(type: DurationType.quarter, dots: 1),
  startBeat: 0.0,
)

// Double dotted note (rare)
Note(
  pitch: Pitch(noteName: NoteName.G, octave: 4),
  duration: const NoteDuration(type: DurationType.half, dots: 2),
  startBeat: 0.0,
)
```

### Rhythm Pattern Example

```dart
// Classic dotted eighth + sixteenth pattern
Measure(
  timeSignature: TimeSignature.fourFour,
  keySignature: KeySignature.cMajor,
  notes: [
    Note(
      pitch: Pitch(noteName: NoteName.C, octave: 4),
      duration: const NoteDuration(type: DurationType.eighth, dots: 1),
      startBeat: 0.0,
    ),
    Note(
      pitch: Pitch(noteName: NoteName.D, octave: 4),
      duration: const NoteDuration.sixteenth(),
      startBeat: 0.75,
    ),
    // Repeat pattern
    Note(
      pitch: Pitch(noteName: NoteName.E, octave: 4),
      duration: const NoteDuration(type: DurationType.eighth, dots: 1),
      startBeat: 1.0,
    ),
    Note(
      pitch: Pitch(noteName: NoteName.F, octave: 4),
      duration: const NoteDuration.sixteenth(),
      startBeat: 1.75,
    ),
  ],
  endBarline: BarlineType.single,
)
```

---

## Rests

### Adding Rests to Measures

```dart
Measure(
  timeSignature: TimeSignature.fourFour,
  keySignature: KeySignature.cMajor,
  notes: [
    Note(..., startBeat: 0.0),
    // Rest on beat 1 (defined in rests list)
    Note(..., startBeat: 2.0),
  ],
  rests: [
    Rest(
      duration: const NoteDuration.quarter(),
      startBeat: 1.0,
    ),
    Rest(
      duration: const NoteDuration.quarter(),
      startBeat: 3.0,
    ),
  ],
  endBarline: BarlineType.single,
)
```

### Rest Durations

```dart
// Whole rest
Rest(duration: const NoteDuration.whole(), startBeat: 0.0)

// Half rest
Rest(duration: const NoteDuration.half(), startBeat: 0.0)

// Quarter rest
Rest(duration: const NoteDuration.quarter(), startBeat: 0.0)

// Eighth rest
Rest(duration: const NoteDuration.eighth(), startBeat: 0.0)

// Dotted rest
Rest(
  duration: const NoteDuration(type: DurationType.quarter, dots: 1),
  startBeat: 0.0,
)
```

---

## Chords

### Simple Triads

```dart
// C major chord (C-E-G)
Measure(
  timeSignature: TimeSignature.fourFour,
  keySignature: KeySignature.cMajor,
  notes: [
    // All three notes start at beat 0
    Note(
      pitch: Pitch(noteName: NoteName.C, octave: 4),
      duration: const NoteDuration.whole(),
      startBeat: 0.0,
    ),
    Note(
      pitch: Pitch(noteName: NoteName.E, octave: 4),
      duration: const NoteDuration.whole(),
      startBeat: 0.0,
    ),
    Note(
      pitch: Pitch(noteName: NoteName.G, octave: 4),
      duration: const NoteDuration.whole(),
      startBeat: 0.0,
    ),
  ],
  endBarline: BarlineType.final_,
)
```

### Chord Progression

```dart
List<Measure> createChordProgression() {
  return [
    // I - C major
    Measure(
      number: 0,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cMajor,
      notes: [
        Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.whole(), startBeat: 0.0),
        Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.whole(), startBeat: 0.0),
        Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.whole(), startBeat: 0.0),
      ],
      endBarline: BarlineType.single,
    ),
    
    // IV - F major
    Measure(
      number: 1,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cMajor,
      notes: [
        Note(pitch: Pitch(noteName: NoteName.F, octave: 3), duration: const NoteDuration.whole(), startBeat: 0.0),
        Note(pitch: Pitch(noteName: NoteName.A, octave: 4), duration: const NoteDuration.whole(), startBeat: 0.0),
        Note(pitch: Pitch(noteName: NoteName.C, octave: 5), duration: const NoteDuration.whole(), startBeat: 0.0),
      ],
      endBarline: BarlineType.single,
    ),
    
    // V - G major
    Measure(
      number: 2,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cMajor,
      notes: [
        Note(pitch: Pitch(noteName: NoteName.G, octave: 3), duration: const NoteDuration.whole(), startBeat: 0.0),
        Note(pitch: Pitch(noteName: NoteName.B, octave: 4), duration: const NoteDuration.whole(), startBeat: 0.0),
        Note(pitch: Pitch(noteName: NoteName.D, octave: 5), duration: const NoteDuration.whole(), startBeat: 0.0),
      ],
      endBarline: BarlineType.final_,
    ),
  ];
}
```

---

## Complete Pieces

### Ode to Joy (Beethoven)

```dart
List<Measure> createOdeToJoy() {
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
      endBarline: BarlineType.single,
    ),
    Measure(
      number: 2,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cMajor,
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
      keySignature: KeySignature.cMajor,
      notes: [
        Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration(type: DurationType.quarter, dots: 1), startBeat: 0.0),
        Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.eighth(), startBeat: 1.5),
        Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.half(), startBeat: 2.0),
      ],
      endBarline: BarlineType.double_,
    ),
  ];
}
```

### Mary Had a Little Lamb

```dart
List<Measure> createMaryHadALittleLamb() {
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
```

---

## Playback

### Basic Playback Setup

```dart
class MusicPlayerWidget extends StatefulWidget {
  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  late PlaybackController _controller;
  late List<Note> _notes;

  @override
  void initState() {
    super.initState();
    _notes = _createNotes();
    _controller = PlaybackController(
      notes: _notes,
      beatsPerMinute: 120.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Notation with playback highlighting
        NotationView(
          measures: [_createMeasure()],
          playbackController: _controller,
        ),
        
        // Playback controls
        _buildControls(),
      ],
    );
  }

  Widget _buildControls() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _controller.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                if (_controller.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () => _controller.stop(),
            ),
            Text('Beat: ${_controller.position.toStringAsFixed(1)}'),
          ],
        );
      },
    );
  }

  List<Note> _createNotes() {
    return [
      Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.quarter(), startBeat: 0.0),
      Note(pitch: Pitch(noteName: NoteName.D, octave: 4), duration: const NoteDuration.quarter(), startBeat: 1.0),
      Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.quarter(), startBeat: 2.0),
      Note(pitch: Pitch(noteName: NoteName.F, octave: 4), duration: const NoteDuration.quarter(), startBeat: 3.0),
    ];
  }

  Measure _createMeasure() {
    return Measure(
      number: 0,
      timeSignature: TimeSignature.fourFour,
      keySignature: KeySignature.cMajor,
      notes: _notes,
      endBarline: BarlineType.final_,
    );
  }
}
```

---

## Advanced

### Custom Configuration

```dart
NotationView(
  measures: measures,
  config: NotationConfig(
    staffSpaceSize: 16.0,          // Larger staff
    staffLineColor: Colors.grey[800]!,
    noteColor: Colors.blue,
    activeNoteColor: Colors.amber,
    clef: ClefType.bass,
    noteWidth: 70.0,
    leftMargin: 120.0,
    measureSpacing: 50.0,
    padding: const EdgeInsets.all(30),
  ),
)
```

### Dynamic Measure Creation

```dart
List<Measure> createScaleInKey(KeySignature key, ClefType clef) {
  // Implementation of scale generation based on key and clef
  // This is a simplified example
  final notes = <Note>[];
  // Add logic to create appropriate scale notes...
  
  return [
    Measure(
      number: 0,
      timeSignature: TimeSignature.fourFour,
      keySignature: key,
      notes: notes,
      endBarline: BarlineType.final_,
    ),
  ];
}
```

---

For more examples, run the example app:

```bash
cd example
flutter run
```