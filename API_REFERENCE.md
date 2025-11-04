# API Reference

Complete API documentation for Flutter Music Notation library.

## Table of Contents

- [Widgets](#widgets)
- [Models](#models)
- [Geometry](#geometry)
- [Playback](#playback)
- [Rendering (Advanced)](#rendering-advanced)

---

## Widgets

### NotationView

The main widget for displaying musical notation.

```dart
NotationView({
  Key? key,
  List<Measure>? measures,
  List<Note>? notes,
  List<Rest>? rests,
  PlaybackController? playbackController,
  NotationConfig config = const NotationConfig(),
})
```

**Parameters:**
- `measures` (List<Measure>?) - List of measures to display (preferred mode)
- `notes` (List<Note>?) - List of notes to display (legacy mode)
- `rests` (List<Rest>?) - List of rests to display (legacy mode)
- `playbackController` (PlaybackController?) - Optional controller for playback
- `config` (NotationConfig) - Visual configuration

**Example:**
```dart
NotationView(
  measures: [measure1, measure2],
  config: const NotationConfig(
    staffSpaceSize: 14,
    clef: ClefType.treble,
  ),
)
```

### NotationConfig

Configuration object for customizing notation appearance.

```dart
const NotationConfig({
  double staffSpaceSize = 12.0,
  Color staffLineColor = Colors.black,
  Color noteColor = Colors.black,
  Color activeNoteColor = Colors.green,
  ClefType clef = ClefType.treble,
  double? width,
  double? height,
  EdgeInsets padding = const EdgeInsets.all(20),
  double noteWidth = 60.0,
  double leftMargin = 100.0,
  double measureSpacing = 40.0,
})
```

**Properties:**
- `staffSpaceSize` (double) - Size of space between staff lines in pixels
- `staffLineColor` (Color) - Color of staff lines
- `noteColor` (Color) - Color of notes and symbols
- `activeNoteColor` (Color) - Color of notes during playback
- `clef` (ClefType) - Which clef to display
- `width` (double?) - Optional fixed width
- `height` (double?) - Optional fixed height
- `padding` (EdgeInsets) - Padding around the notation
- `noteWidth` (double) - Horizontal spacing between notes
- `leftMargin` (double) - Left margin for clef, key sig, time sig
- `measureSpacing` (double) - Space between measures

---

## Models

### Measure

Represents a single measure (bar) of music.

```dart
const Measure({
  required int number,
  required TimeSignature timeSignature,
  required KeySignature keySignature,
  List<Note> notes = const [],
  List<Rest> rests = const [],
  BarlineType endBarline = BarlineType.single,
})
```

**Properties:**
- `number` (int) - Measure number (0-indexed)
- `timeSignature` (TimeSignature) - Time signature for this measure
- `keySignature` (KeySignature) - Key signature for this measure
- `notes` (List<Note>) - Notes in this measure
- `rests` (List<Rest>) - Rests in this measure
- `endBarline` (BarlineType) - Type of barline at end

**Methods:**
- `elements` - Returns all notes and rests sorted by start beat
- `isComplete()` - Checks if measure has correct duration
- `isFirstMeasure` - Whether this is measure 0

**Example:**
```dart
final measure = Measure(
  number: 0,
  timeSignature: TimeSignature.fourFour,
  keySignature: KeySignature.gMajor,
  notes: [
    Note(...),
    Note(...),
  ],
  endBarline: BarlineType.double_,
);
```

### Note

Represents a single musical note.

```dart
const Note({
  required Pitch pitch,
  required NoteDuration duration,
  bool? forceShowAccidental,
  int velocity = 64,
  required double startBeat,
})
```

**Properties:**
- `pitch` (Pitch) - The pitch of the note
- `duration` (NoteDuration) - The duration of the note
- `forceShowAccidental` (bool?) - Force accidental display
- `velocity` (int) - MIDI velocity (0-127)
- `startBeat` (double) - Beat position where note starts
- `endBeat` (double, getter) - Beat position where note ends

**Example:**
```dart
final note = Note(
  pitch: Pitch(noteName: NoteName.C, octave: 4),
  duration: const NoteDuration.quarter(),
  startBeat: 0.0,
);
```

### Rest

Represents a musical rest.

```dart
const Rest({
  required NoteDuration duration,
  required double startBeat,
})
```

**Properties:**
- `duration` (NoteDuration) - The duration of the rest
- `startBeat` (double) - Beat position where rest starts
- `endBeat` (double, getter) - Beat position where rest ends

### Chord

Represents multiple notes played simultaneously.

```dart
Chord({
  required List<Note> notes,
})
```

**Properties:**
- `notes` (List<Note>) - Notes in the chord (must have same startBeat and duration)
- `duration` (NoteDuration, getter) - Duration of the chord
- `startBeat` (double, getter) - Start beat of the chord
- `endBeat` (double, getter) - End beat of the chord
- `sortedNotes` (List<Note>, getter) - Notes sorted by pitch (low to high)
- `lowestNote` (Note, getter) - Lowest note in chord
- `highestNote` (Note, getter) - Highest note in chord

### Pitch

Represents a musical pitch.

```dart
const Pitch({
  required NoteName noteName,
  Accidental accidental = Accidental.natural,
  required int octave,
})
```

**Properties:**
- `noteName` (NoteName) - Natural note name (C, D, E, F, G, A, B)
- `accidental` (Accidental) - Sharp, flat, natural, etc.
- `octave` (int) - Octave number (Middle C = C4)
- `midiNumber` (int, getter) - MIDI note number (0-127)
- `scientificName` (String, getter) - e.g., "C4", "F♯5"

**Factory Constructors:**
```dart
Pitch.fromMidiNumber(int midiNumber, {Accidental preferredAccidental})
```

**Example:**
```dart
// Middle C
final middleC = Pitch(noteName: NoteName.C, octave: 4);

// F sharp in octave 5
final fSharp = Pitch(
  noteName: NoteName.F,
  accidental: Accidental.sharp,
  octave: 5,
);

// From MIDI number
final pitch = Pitch.fromMidiNumber(60); // C4
```

### NoteDuration

Represents the duration of a note or rest.

```dart
const NoteDuration({
  required DurationType type,
  int dots = 0,
  Tuplet? tuplet,
})
```

**Properties:**
- `type` (DurationType) - Base duration type
- `dots` (int) - Number of dots (0, 1, or 2)
- `tuplet` (Tuplet?) - Optional tuplet modification
- `beats` (double, getter) - Duration in quarter note beats
- `needsStem` (bool, getter) - Whether note needs a stem
- `needsFlag` (bool, getter) - Whether note needs flags
- `flagCount` (int, getter) - Number of flags needed
- `isFilledNotehead` (bool, getter) - Whether notehead is filled

**Named Constructors:**
```dart
const NoteDuration.whole()
const NoteDuration.half()
const NoteDuration.quarter()
const NoteDuration.eighth()
const NoteDuration.sixteenth()
const NoteDuration.dottedHalf()
const NoteDuration.dottedQuarter()
const NoteDuration.dottedEighth()
```

**Example:**
```dart
// Quarter note
const quarter = NoteDuration.quarter();

// Dotted half note
const dottedHalf = NoteDuration(type: DurationType.half, dots: 1);

// Triplet eighth note
const triplet = NoteDuration(
  type: DurationType.eighth,
  tuplet: Tuplet.triplet,
);
```

### TimeSignature

Represents a musical time signature.

```dart
const TimeSignature({
  required int beats,
  required int beatUnit,
})
```

**Properties:**
- `beats` (int) - Number of beats per measure (numerator)
- `beatUnit` (int) - Note value that gets one beat (denominator)
- `beatsPerMeasure` (double, getter) - Total beats in quarter notes
- `isCompound` (bool, getter) - Whether compound time signature
- `isSimple` (bool, getter) - Whether simple time signature
- `isCommonTime` (bool, getter) - Whether 4/4
- `isCutTime` (bool, getter) - Whether 2/2

**Common Time Signatures:**
```dart
TimeSignature.fourFour    // 4/4
TimeSignature.threeFour   // 3/4
TimeSignature.twoFour     // 2/4
TimeSignature.sixEight    // 6/8
TimeSignature.threeEight  // 3/8
TimeSignature.twelveEight // 12/8
TimeSignature.twoTwo      // 2/2
```

### KeySignature

Represents a musical key signature.

```dart
const KeySignature({
  required int accidentals,
  bool isMinor = false,
})
```

**Properties:**
- `accidentals` (int) - Number of sharps (+) or flats (-), range: -7 to +7
- `isMinor` (bool) - Whether this is a minor key
- `name` (String, getter) - Key name (e.g., "G major")
- `usesSharps` (bool, getter) - Whether key uses sharps vs flats

**Methods:**
- `getAlteredPitchClasses()` - Returns MIDI pitch classes altered in key
- `needsAccidental(Pitch)` - Whether a pitch needs an accidental

**Common Key Signatures:**
```dart
// Major keys with sharps
KeySignature.cMajor      // 0
KeySignature.gMajor      // 1♯
KeySignature.dMajor      // 2♯
KeySignature.aMajor      // 3♯
KeySignature.eMajor      // 4♯
KeySignature.bMajor      // 5♯
KeySignature.fSharpMajor // 6♯
KeySignature.cSharpMajor // 7♯

// Major keys with flats
KeySignature.fMajor      // 1♭
KeySignature.bFlatMajor  // 2♭
KeySignature.eFlatMajor  // 3♭
KeySignature.aFlatMajor  // 4♭
KeySignature.dFlatMajor  // 5♭
KeySignature.gFlatMajor  // 6♭
KeySignature.cFlatMajor  // 7♭

// Minor keys available as well (e.g., KeySignature.aMinor)
```

### Enums

#### NoteName
```dart
enum NoteName { C, D, E, F, G, A, B }
```

#### Accidental
```dart
enum Accidental {
  doubleFlat(-2),
  flat(-1),
  natural(0),
  sharp(1),
  doubleSharp(2),
}
```

#### DurationType
```dart
enum DurationType {
  maxima,      // 8 whole notes
  long,        // 4 whole notes
  breve,       // 2 whole notes
  whole,       // Whole note
  half,        // Half note
  quarter,     // Quarter note
  eighth,      // Eighth note
  sixteenth,   // Sixteenth note
  thirtySecond,// 32nd note
  sixtyFourth, // 64th note
}
```

#### ClefType
```dart
enum ClefType {
  treble,  // G clef
  bass,    // F clef
  alto,    // C clef on middle line
  tenor,   // C clef on 4th line
}
```

#### BarlineType
```dart
enum BarlineType {
  single,      // Regular barline |
  double_,     // Double barline ||
  final_,      // Final barline ||
  repeatStart, // Repeat start |:
  repeatEnd,   // Repeat end :|
  dashed,      // Dashed barline
}
```

---

## Geometry

### StaffPosition

Represents a vertical position on the staff.

```dart
const StaffPosition(double value)
```

**Properties:**
- `value` (double) - Position in half-spaces from bottom line
- `isLine` (bool, getter) - Whether on a staff line
- `isSpace` (bool, getter) - Whether in a space
- `needsLedgerLinesAbove` (bool, getter) - Needs ledger lines above
- `needsLedgerLinesBelow` (bool, getter) - Needs ledger lines below
- `isOnStaff` (bool, getter) - Within standard staff range

**Static Methods:**
```dart
StaffPosition.forPitch(Pitch pitch, ClefType clef)
```

**Methods:**
```dart
List<int> getLedgerLinePositions()
```

### StaffUnits

Type-safe measurement system based on staff spaces.

```dart
const StaffUnits(double value)
```

**Common Constants:**
```dart
StaffUnits.noteheadWidth
StaffUnits.noteheadHeight
StaffUnits.stemThickness
StaffUnits.stemLength
StaffUnits.accidentalWidth
StaffUnits.accidentalHeight
StaffUnits.dotRadius
StaffUnits.dotSpacing
```

**Methods:**
```dart
double toPixels(double staffSpaceSize)
```

---

## Playback

### PlaybackController

Controls playback state and active note tracking.

```dart
PlaybackController({
  required List<Note> notes,
  double beatsPerMinute = 120.0,
})
```

**Properties:**
- `position` (double, getter) - Current beat position
- `isPlaying` (bool, getter) - Whether playback is active
- `activeNotes` (Set<Note>, getter) - Currently playing notes
- `speed` (double, getter) - Playback speed multiplier

**Methods:**
```dart
void play()                    // Start playback
void pause()                   // Pause playback
void stop()                    // Stop and return to start
void seekTo(double beat)       // Seek to specific beat
void setSpeed(double speed)    // Set playback speed (0.1-4.0)
void update(double deltaTime)  // Update position (called each frame)
void onNoteOn(int midiNumber, int velocity)   // External MIDI trigger
void onNoteOff(int midiNumber)                // External MIDI stop
List<Note> getNotesAtBeat(double beat)        // Get notes at position
```

**Example:**
```dart
final controller = PlaybackController(
  notes: myNotes,
  beatsPerMinute: 120,
);

// Start playback
controller.play();

// Pause
controller.pause();

// Jump to beat 4
controller.seekTo(4.0);

// Half speed
controller.setSpeed(0.5);

// Clean up
controller.dispose();
```

---

## Rendering (Advanced)

These classes are for advanced users who need fine-grained control over rendering.

### StaffRenderer
Renders the 5-line staff.

### NoteRenderer
High-level renderer combining notehead, stem, accidental, dots.

### NoteheadRenderer
Renders filled or hollow noteheads.

### StemRenderer
Renders note stems with automatic direction.

### AccidentalRenderer
Renders accidental symbols (♯, ♭, ♮).

### DotRenderer
Renders augmentation dots.

### RestRenderer
Renders rest symbols.

### FlagRenderer
Renders flags for eighth notes and shorter.

### ClefRenderer
Renders clef symbols.

### KeySignatureRenderer
Renders key signature sharps/flats.

### TimeSignatureRenderer
Renders time signature numbers.

### BarlineRenderer
Renders various barline types.

**Note:** These are typically not used directly. Use `NotationView` instead.

---

## Best Practices

### 1. Use Measures for Complete Notation
```dart
// Preferred
NotationView(measures: [measure1, measure2])

// Legacy mode (for simple cases)
NotationView(notes: [note1, note2])
```

### 2. Group Notes by Measure
```dart
// Good - organized by measure
final measure1 = Measure(...);
final measure2 = Measure(...);

// Avoid - loose notes
final looseNotes = [note1, note2, note3];
```

### 3. Use Named Constructors
```dart
// Good
const duration = NoteDuration.quarter();

// Also good
const duration = NoteDuration(type: DurationType.quarter);
```

### 4. Check Measure Completeness
```dart
if (!measure.isComplete()) {
  print('Warning: Measure duration doesn\'t match time signature');
}
```

### 5. Dispose Controllers
```dart
@override
void dispose() {
  playbackController.dispose();
  super.dispose();
}
```

---

## Type Safety

All models are fully type-safe with compile-time checking:

```dart
// ✅ Compile-time safe
final pitch = Pitch(noteName: NoteName.C, octave: 4);

// ❌ Compile error - invalid types
final pitch = Pitch(noteName: "C", octave: "4");

// ✅ Enum exhaustiveness checked
switch (clef) {
  case ClefType.treble: ...
  case ClefType.bass: ...
  case ClefType.alto: ...
  case ClefType.tenor: ...
  // Compiler ensures all cases handled
}
```

---

For more examples, see the [example/](../example/) directory or the main [README](../README.md).