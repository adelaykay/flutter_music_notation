# Getting Started with Flutter Music Notation

This guide will walk you through your first steps with the Flutter Music Notation library.

## Table of Contents

1. [Installation](#installation)
2. [Your First Notation](#your-first-notation)
3. [Understanding Core Concepts](#understanding-core-concepts)
4. [Common Patterns](#common-patterns)
5. [Next Steps](#next-steps)

---

## Installation

### Step 1: Add Dependency

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_music_notation: ^0.1.0
```

### Step 2: Install

Run in your terminal:

```bash
flutter pub get
```

### Step 3: Import

Add to your Dart file:

```dart
import 'package:flutter_music_notation/flutter_music_notation.dart';
```

That's it! You're ready to start creating notation.

---

## Your First Notation

Let's create a simple "Hello World" of music notation - displaying four quarter notes.

### Complete Example

```dart
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
      title: 'My First Notation',
      home: Scaffold(
        appBar: AppBar(title: const Text('Music Notation')),
        body: Center(
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            child: NotationView(
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
            ),
          ),
        ),
      ),
    );
  }
}
```

**What you should see:**
- A treble clef
- Time signature (4/4)
- Four quarter notes: C, D, E, F
- A final barline at the end

---

## Understanding Core Concepts

### 1. The Measure

Think of a `Measure` as a container that holds everything in one bar of music:

```dart
final measure = Measure(
  number: 0,              // First measure (0-indexed)
  timeSignature: ...,     // How many beats
  keySignature: ...,      // What key we're in
  notes: [...],           // The notes to play
  rests: [...],           // The silences
  endBarline: ...,        // What barline to draw at the end
);
```

### 2. Notes

A `Note` needs three essential pieces of information:

```dart
final note = Note(
  pitch: ...,         // What pitch to play
  duration: ...,      // How long to play it
  startBeat: ...,     // When to start playing
);
```

### 3. Pitch

Pitch tells us **what note** to play:

```dart
// Middle C
final middleC = Pitch(
  noteName: NoteName.C,  // The letter name
  octave: 4,             // Which octave (middle C is octave 4)
);

// G with a sharp
final gSharp = Pitch(
  noteName: NoteName.G,
  accidental: Accidental.sharp,
  octave: 5,
);
```

**Octave numbering:**
- Middle C = C4
- One octave up = C5
- One octave down = C3

### 4. Duration

Duration tells us **how long** to play the note:

```dart
// Common durations with shortcuts
const whole = NoteDuration.whole();      // 4 beats
const half = NoteDuration.half();        // 2 beats
const quarter = NoteDuration.quarter();  // 1 beat
const eighth = NoteDuration.eighth();    // 0.5 beats

// Dotted notes
const dottedHalf = NoteDuration(
  type: DurationType.half,
  dots: 1,  // Adds half the value (2 + 1 = 3 beats)
);
```

### 5. Start Beat

`startBeat` tells us **when** the note starts:

```dart
// In 4/4 time, there are 4 beats per measure
Note(..., startBeat: 0.0),  // First beat
Note(..., startBeat: 1.0),  // Second beat
Note(..., startBeat: 2.0),  // Third beat
Note(..., startBeat: 3.0),  // Fourth beat
```

---

## Common Patterns

### Pattern 1: Creating a Scale

```dart
List<Note> createCMajorScale() {
  final noteNames = [
    NoteName.C,
    NoteName.D,
    NoteName.E,
    NoteName.F,
    NoteName.G,
    NoteName.A,
    NoteName.B,
    NoteName.C,
  ];

  return List.generate(
    noteNames.length,
    (index) => Note(
      pitch: Pitch(
        noteName: noteNames[index],
        octave: index < 7 ? 4 : 5,
      ),
      duration: const NoteDuration.eighth(),
      startBeat: index * 0.5,
    ),
  );
}

// Usage
final measure = Measure(
  number: 0,
  timeSignature: TimeSignature.fourFour,
  keySignature: KeySignature.cMajor,
  notes: createCMajorScale(),
  endBarline: BarlineType.final_,
);
```

### Pattern 2: Adding Rests

```dart
final measure = Measure(
  number: 0,
  timeSignature: TimeSignature.fourFour,
  keySignature: KeySignature.cMajor,
  notes: [
    Note(
      pitch: Pitch(noteName: NoteName.C, octave: 4),
      duration: const NoteDuration.quarter(),
      startBeat: 0.0,
    ),
    // Rest on beat 1 (handled by rests list below)
    Note(
      pitch: Pitch(noteName: NoteName.E, octave: 4),
      duration: const NoteDuration.quarter(),
      startBeat: 2.0,
    ),
  ],
  rests: [
    Rest(
      duration: const NoteDuration.quarter(),
      startBeat: 1.0,  // Quarter rest on beat 1
    ),
    Rest(
      duration: const NoteDuration.quarter(),
      startBeat: 3.0,  // Quarter rest on beat 3
    ),
  ],
  endBarline: BarlineType.single,
);
```

### Pattern 3: Multiple Measures

```dart
final measures = [
  // Measure 1
  Measure(
    number: 0,
    timeSignature: TimeSignature.fourFour,
    keySignature: KeySignature.cMajor,
    notes: [
      Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.whole(), startBeat: 0.0),
    ],
    endBarline: BarlineType.single,
  ),
  
  // Measure 2
  Measure(
    number: 1,
    timeSignature: TimeSignature.fourFour,
    keySignature: KeySignature.cMajor,
    notes: [
      Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.whole(), startBeat: 0.0),
    ],
    endBarline: BarlineType.double_,
  ),
];

// Display
NotationView(measures: measures)
```

### Pattern 4: Changing Key Signature

```dart
final measures = [
  // First measure in C major
  Measure(
    number: 0,
    timeSignature: TimeSignature.fourFour,
    keySignature: KeySignature.cMajor,
    notes: [...],
    endBarline: BarlineType.single,
  ),
  
  // Second measure in G major (1 sharp)
  Measure(
    number: 1,
    timeSignature: TimeSignature.fourFour,
    keySignature: KeySignature.gMajor,  // Key change!
    notes: [...],
    endBarline: BarlineType.final_,
  ),
];
```

### Pattern 5: Different Time Signatures

```dart
// 3/4 time (Waltz)
Measure(
  number: 0,
  timeSignature: TimeSignature.threeFour,  // 3 beats per measure
  keySignature: KeySignature.cMajor,
  notes: [
    Note(..., startBeat: 0.0),  // Beat 1
    Note(..., startBeat: 1.0),  // Beat 2
    Note(..., startBeat: 2.0),  // Beat 3
  ],
  endBarline: BarlineType.single,
)

// 6/8 time
Measure(
  number: 0,
  timeSignature: TimeSignature.sixEight,
  keySignature: KeySignature.cMajor,
  notes: [...],
  endBarline: BarlineType.single,
)
```

### Pattern 6: Using Different Clefs

```dart
// Treble clef (default - for higher instruments)
NotationView(
  measures: measures,
  config: const NotationConfig(clef: ClefType.treble),
)

// Bass clef (for lower instruments like bass, cello)
NotationView(
  measures: measures,
  config: const NotationConfig(clef: ClefType.bass),
)
```

### Pattern 7: Chords (Multiple Notes at Once)

To play multiple notes at the same time, give them the same `startBeat`:

```dart
Measure(
  number: 0,
  timeSignature: TimeSignature.fourFour,
  keySignature: KeySignature.cMajor,
  notes: [
    // C major chord - all start at beat 0
    Note(pitch: Pitch(noteName: NoteName.C, octave: 4), duration: const NoteDuration.whole(), startBeat: 0.0),
    Note(pitch: Pitch(noteName: NoteName.E, octave: 4), duration: const NoteDuration.whole(), startBeat: 0.0),
    Note(pitch: Pitch(noteName: NoteName.G, octave: 4), duration: const NoteDuration.whole(), startBeat: 0.0),
  ],
  endBarline: BarlineType.final_,
)
```

---

## Customizing Appearance

You can customize how the notation looks:

```dart
NotationView(
  measures: measures,
  config: NotationConfig(
    staffSpaceSize: 14.0,         // Larger staff (default: 12)
    noteColor: Colors.blue,       // Blue notes instead of black
    noteWidth: 60.0,              // More spacing between notes
    clef: ClefType.bass,          // Use bass clef
  ),
)
```

---

## Common Mistakes & Solutions

### ❌ Mistake 1: Overlapping notes
```dart
// Wrong - both notes start at beat 0
notes: [
  Note(..., startBeat: 0.0),
  Note(..., startBeat: 0.0),  // This overlaps!
]
```

✅ **Solution:** Use different start beats OR make it a chord if intentional.

### ❌ Mistake 2: Measure doesn't fill time signature
```dart
// Wrong - only 2 beats in 4/4 time
Measure(
  timeSignature: TimeSignature.fourFour,  // Needs 4 beats
  notes: [
    Note(..., duration: NoteDuration.half(), startBeat: 0.0),  // 2 beats
    // Missing 2 beats!
  ],
)
```

✅ **Solution:** Add more notes or rests to fill the measure:
```dart
notes: [
  Note(..., duration: NoteDuration.half(), startBeat: 0.0),
],
rests: [
  Rest(duration: NoteDuration.half(), startBeat: 2.0),  // Fill remaining
]
```

### ❌ Mistake 3: Wrong octave numbers
```dart
// Wrong - Middle C is octave 4, not 0
Pitch(noteName: NoteName.C, octave: 0)
```

✅ **Solution:** Use standard octave numbering:
```dart
Pitch(noteName: NoteName.C, octave: 4)  // Middle C
```

---

## Next Steps

Now that you understand the basics, you can:

1. **Explore Examples**: Check out the [example/](../example/) folder for complete working examples

2. **Read API Reference**: See [API_REFERENCE.md](API_REFERENCE.md) for detailed documentation

3. **Add Playback**: Learn about `PlaybackController` for synchronized playback

4. **Create Complex Pieces**: Combine multiple measures, different keys, and time signatures

5. **Customize Appearance**: Explore all `NotationConfig` options

### Recommended Learning Path

1. ✅ Create simple single-measure pieces
2. ✅ Experiment with different note durations
3. ✅ Try different clefs and key signatures
4. ✅ Add rests to your measures
5. ✅ Create multi-measure pieces
6. ⬜ Add playback with `PlaybackController`
7. ⬜ Explore advanced features (when available in future versions)

---

## Getting Help

- 📖 [Full Documentation](../README.md)
- 💬 [GitHub Issues](https://github.com/adelaykay/flutter_music_notation/issues)
- 📧 Email: hello@empyrealworks.com

## Quick Reference Card

```dart
// Import
import 'package:flutter_music_notation/flutter_music_notation.dart';

// Basic structure
NotationView(
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
      ],
      endBarline: BarlineType.final_,
    ),
  ],
)

// Common durations
NoteDuration.whole()      // 4 beats
NoteDuration.half()       // 2 beats
NoteDuration.quarter()    // 1 beat
NoteDuration.eighth()     // 0.5 beats
NoteDuration.sixteenth()  // 0.25 beats

// Common keys
KeySignature.cMajor       // No sharps/flats
KeySignature.gMajor       // 1 sharp
KeySignature.fMajor       // 1 flat

// Common time signatures
TimeSignature.fourFour    // 4/4
TimeSignature.threeFour   // 3/4
TimeSignature.sixEight    // 6/8

// Clefs
ClefType.treble          // G clef
ClefType.bass            // F clef
```

Happy music making! 🎵