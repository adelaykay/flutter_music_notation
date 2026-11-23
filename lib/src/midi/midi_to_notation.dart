// lib/src/midi/midi_to_notation.dart

import '../models/note.dart';
import '../models/measure.dart';
import '../models/duration.dart';
import '../models/pitch.dart';
import '../models/time_signature.dart';
import '../models/key_signature.dart';
import '../models/grand_staff.dart';
import '../geometry/staff_position.dart';
import 'midi_note.dart';
import 'midi_parser.dart';
import 'quantizer.dart';
import 'satb_detector.dart';

/// Converts MIDI data to musical notation
class MidiToNotation {
  final MidiData midiData;
  final Quantizer quantizer;

  MidiToNotation({required this.midiData})
      : quantizer = Quantizer(
    midiData: midiData,
    beatsPerMinute: midiData.beatsPerMinute,
    timeSignatureNumerator: midiData.timeSignatureNumerator,
    timeSignatureDenominator: midiData.timeSignatureDenominator,
  );

  /// Convert to single staff notation
  List<Measure> toSingleStaff({
    ClefPreference clefPreference = ClefPreference.auto,
    double? gridResolution,
  }) {
    final quantizedNotes = quantizer.quantizeNotes(gridResolution: gridResolution);

    // Determine clef based on average pitch
    final clef = _determineClef(quantizedNotes, clefPreference);

    // Group notes by measure
    final notesByMeasure = _groupNotesByMeasure(quantizedNotes);

    // Create measures
    final measures = <Measure>[];
    for (var entry in notesByMeasure.entries) {
      final measureNumber = entry.key;
      final notesInMeasure = entry.value;

      measures.add(_createMeasure(
        measureNumber: measureNumber,
        quantizedNotes: notesInMeasure,
      ));
    }

    return measures;
  }

  /// Convert to grand staff (piano) notation
  GrandStaff toGrandStaff({double? gridResolution}) {
    final quantizedNotes = quantizer.quantizeNotes(gridResolution: gridResolution);

    // Split by pitch (middle C = 60)
    final split = quantizer.splitByClef(quantizedNotes, splitPoint: 60);

    // Group by measure for each staff
    final upperMeasures = _createMeasuresFromNotes(split.treble);
    final lowerMeasures = _createMeasuresFromNotes(split.bass);

    // Ensure both staves have the same number of measures
    final maxMeasures = upperMeasures.length > lowerMeasures.length
        ? upperMeasures.length
        : lowerMeasures.length;

    // Pad shorter staff with empty measures
    while (upperMeasures.length < maxMeasures) {
      upperMeasures.add(_createEmptyMeasure(upperMeasures.length));
    }
    while (lowerMeasures.length < maxMeasures) {
      lowerMeasures.add(_createEmptyMeasure(lowerMeasures.length));
    }

    return GrandStaff(
      upperStaff: upperMeasures,
      lowerStaff: lowerMeasures,
      instrumentName: 'Piano',
      instrumentAbbreviation: 'Pno.',
    );
  }

  /// Attempt to detect SATB voices
  /// Returns null if detection fails
  List<List<Measure>>? toSATB({double? gridResolution}) {
    final quantizedNotes = quantizer.quantizeNotes(gridResolution: gridResolution);

    final detector = SATBDetector();
    final voices = detector.detectVoices(quantizedNotes);

    if (voices == null) return null;

    return [
      _createMeasuresFromNotes(voices.soprano.notes),
      _createMeasuresFromNotes(voices.alto.notes),
      _createMeasuresFromNotes(voices.tenor.notes),
      _createMeasuresFromNotes(voices.bass.notes),
    ];
  }

  /// Create measures from quantized notes
  List<Measure> _createMeasuresFromNotes(List<QuantizedNote> quantizedNotes) {
    final notesByMeasure = _groupNotesByMeasure(quantizedNotes);

    final measures = <Measure>[];
    for (var entry in notesByMeasure.entries) {
      measures.add(_createMeasure(
        measureNumber: entry.key,
        quantizedNotes: entry.value,
      ));
    }

    return measures;
  }

  /// Group notes by measure number
  Map<int, List<QuantizedNote>> _groupNotesByMeasure(List<QuantizedNote> notes) {
    final byMeasure = <int, List<QuantizedNote>>{};

    for (final note in notes) {
      final measure = note.startTime.measure;
      byMeasure.putIfAbsent(measure, () => []).add(note);
    }

    return byMeasure;
  }

  /// Create a single measure
  Measure _createMeasure({
    required int measureNumber,
    required List<QuantizedNote> quantizedNotes,
  }) {
    // Create key signature first (needed for pitch conversion)
    final keySignature = KeySignature(
      accidentals: midiData.keySignatureSharps,
      isMinor: midiData.keySignatureIsMinor,
    );

    // Convert quantized notes to Note objects
    final notes = <Note>[];

    for (final qNote in quantizedNotes) {
      // Convert MIDI number to Pitch with key-aware accidental
      final pitch = _convertMidiToPitchWithKey(
        qNote.midiNote,
        keySignature,
      );

      // Convert rhythmic value to NoteDuration
      final duration = _rhythmicValueToDuration(qNote.duration);

      notes.add(Note(
        pitch: pitch,
        duration: duration,
        startBeat: qNote.startTime.beat,
        velocity: qNote.velocity,
      ));
    }

    // Sort by start beat
    notes.sort((a, b) => a.startBeat.compareTo(b.startBeat));

    // Create time signature
    final timeSignature = TimeSignature(
      beats: midiData.timeSignatureNumerator,
      beatUnit: midiData.timeSignatureDenominator,
    );

    // Determine end barline
    final endBarline = _isLastMeasure(measureNumber)
        ? BarlineType.final_
        : BarlineType.single;

    return Measure(
      number: measureNumber,
      timeSignature: timeSignature,
      keySignature: keySignature,
      notes: notes,
      endBarline: endBarline,
    );
  }

  /// Convert MIDI number to pitch respecting key signature
  /// This prevents redundant accidentals (e.g., B♭ in F major)
  Pitch _convertMidiToPitchWithKey(int midiNumber, KeySignature keySignature) {
    // Get pitch classes altered by key signature
    final alteredPitchClasses = keySignature.getAlteredPitchClasses();
    final pitchClass = midiNumber % 12;

    // Determine if this pitch class is in the key signature
    final isInKeySignature = alteredPitchClasses.contains(pitchClass);

    if (isInKeySignature) {
      // This note is already altered by the key signature
      // Use the key's preferred accidental
      final preferredAccidental = keySignature.usesSharps
          ? Accidental.sharp
          : Accidental.flat;

      return Pitch.fromMidiNumber(
        midiNumber,
        preferredAccidental: preferredAccidental,
      );
    } else {
      // Not in key signature, determine appropriate spelling
      return Pitch.fromMidiNumber(
        midiNumber,
        preferredAccidental: _getPreferredAccidental(),
      );
    }
  }

  /// Create an empty measure (for padding)
  Measure _createEmptyMeasure(int measureNumber) {
    return Measure(
      number: measureNumber,
      timeSignature: TimeSignature(
        beats: midiData.timeSignatureNumerator,
        beatUnit: midiData.timeSignatureDenominator,
      ),
      keySignature: KeySignature(
        accidentals: midiData.keySignatureSharps,
        isMinor: midiData.keySignatureIsMinor,
      ),
      notes: const [],
      rests: [
        Rest(
          duration: const NoteDuration.whole(),
          startBeat: 0.0,
        ),
      ],
      endBarline: BarlineType.single,
    );
  }

  /// Convert RhythmicValue to NoteDuration
  NoteDuration _rhythmicValueToDuration(RhythmicValue value) {
    switch (value) {
      case RhythmicValue.whole:
        return const NoteDuration.whole();
      case RhythmicValue.half:
        return const NoteDuration.half();
      case RhythmicValue.quarter:
        return const NoteDuration.quarter();
      case RhythmicValue.eighth:
        return const NoteDuration.eighth();
      case RhythmicValue.sixteenth:
        return const NoteDuration.sixteenth();
      case RhythmicValue.thirtySecond:
        return const NoteDuration(type: DurationType.thirtySecond);
      case RhythmicValue.dottedHalf:
        return const NoteDuration(type: DurationType.half, dots: 1);
      case RhythmicValue.dottedQuarter:
        return const NoteDuration(type: DurationType.quarter, dots: 1);
      case RhythmicValue.dottedEighth:
        return const NoteDuration(type: DurationType.eighth, dots: 1);
      case RhythmicValue.dottedSixteenth:
        return const NoteDuration(type: DurationType.sixteenth, dots: 1);
      case RhythmicValue.halfTriplet:
        return const NoteDuration(
          type: DurationType.half,
          tuplet: Tuplet(actualNotes: 3, normalNotes: 2),
        );
      case RhythmicValue.quarterTriplet:
        return const NoteDuration(
          type: DurationType.quarter,
          tuplet: Tuplet.triplet,
        );
      case RhythmicValue.eighthTriplet:
        return const NoteDuration(
          type: DurationType.eighth,
          tuplet: Tuplet.triplet,
        );
    }
  }

  /// Determine preferred accidental based on key signature
  Accidental _getPreferredAccidental() {
    return midiData.keySignatureSharps >= 0
        ? Accidental.sharp
        : Accidental.flat;
  }

  /// Determine appropriate clef based on average pitch
  ClefType _determineClef(
      List<QuantizedNote> notes,
      ClefPreference preference,
      ) {
    if (preference != ClefPreference.auto) {
      return preference == ClefPreference.treble
          ? ClefType.treble
          : ClefType.bass;
    }

    if (notes.isEmpty) return ClefType.treble;

    // Calculate average MIDI number
    final avgMidi = notes
        .map((n) => n.midiNote)
        .reduce((a, b) => a + b) / notes.length;

    // Middle C = 60
    // Use bass clef if average is below C4
    return avgMidi < 60 ? ClefType.bass : ClefType.treble;
  }

  /// Check if this is the last measure
  bool _isLastMeasure(int measureNumber) {
    if (midiData.notes.isEmpty) return true;

    final lastNote = midiData.notes.last;
    final lastBeat = quantizer.millisToBeats(lastNote.endTime);
    final lastMeasure = (lastBeat / quantizer.beatsPerMeasure).floor();

    return measureNumber >= lastMeasure;
  }
}

/// Preference for clef selection
enum ClefPreference {
  auto,   // Automatically determine
  treble, // Force treble clef
  bass,   // Force bass clef
}

/// Configuration for MIDI conversion
class MidiConversionConfig {
  /// Grid resolution for quantization (null = auto-detect)
  final double? gridResolution;

  /// Clef preference
  final ClefPreference clefPreference;

  /// Whether to attempt voice separation
  final bool attemptVoiceSeparation;

  /// Split point for grand staff (MIDI number)
  final int grandStaffSplitPoint;

  const MidiConversionConfig({
    this.gridResolution,
    this.clefPreference = ClefPreference.auto,
    this.attemptVoiceSeparation = false,
    this.grandStaffSplitPoint = 60, // Middle C
  });
}

/// Extension for easy MIDI file conversion
extension MidiDataExtension on MidiData {
  /// Quick conversion to single staff
  List<Measure> toMeasures({
    ClefPreference clef = ClefPreference.auto,
    double? gridResolution,
  }) {
    final converter = MidiToNotation(midiData: this);
    return converter.toSingleStaff(
      clefPreference: clef,
      gridResolution: gridResolution,
    );
  }

  /// Quick conversion to grand staff
  GrandStaff toGrandStaff({double? gridResolution}) {
    final converter = MidiToNotation(midiData: this);
    return converter.toGrandStaff(gridResolution: gridResolution);
  }
}