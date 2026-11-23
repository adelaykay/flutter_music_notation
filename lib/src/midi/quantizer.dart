// lib/src/midi/quantizer.dart

import 'midi_note.dart';

/// Represents a position in musical time
class MusicalTime {
  final int measure; // 0-indexed
  final double beat; // 0-indexed within measure (0.0 = downbeat)
  final double absoluteBeat; // Total beats from start

  const MusicalTime({
    required this.measure,
    required this.beat,
    required this.absoluteBeat,
  });

  @override
  String toString() => 'M${measure + 1}:B${(beat + 1).toStringAsFixed(2)}';
}

/// Represents a rhythmic duration
enum RhythmicValue {
  whole,
  half,
  quarter,
  eighth,
  sixteenth,
  thirtySecond,
  dottedHalf,
  dottedQuarter,
  dottedEighth,
  dottedSixteenth,
  halfTriplet,
  quarterTriplet,
  eighthTriplet,
}

extension RhythmicValueExtension on RhythmicValue {
  /// Duration in quarter note beats
  double get beats {
    switch (this) {
      case RhythmicValue.whole:
        return 4.0;
      case RhythmicValue.half:
        return 2.0;
      case RhythmicValue.quarter:
        return 1.0;
      case RhythmicValue.eighth:
        return 0.5;
      case RhythmicValue.sixteenth:
        return 0.25;
      case RhythmicValue.thirtySecond:
        return 0.125;
      case RhythmicValue.dottedHalf:
        return 3.0;
      case RhythmicValue.dottedQuarter:
        return 1.5;
      case RhythmicValue.dottedEighth:
        return 0.75;
      case RhythmicValue.dottedSixteenth:
        return 0.375;
      case RhythmicValue.halfTriplet:
        return 4.0 / 3.0;
      case RhythmicValue.quarterTriplet:
        return 2.0 / 3.0;
      case RhythmicValue.eighthTriplet:
        return 1.0 / 3.0;
    }
  }

  bool get isDotted =>
      this == RhythmicValue.dottedHalf ||
      this == RhythmicValue.dottedQuarter ||
      this == RhythmicValue.dottedEighth ||
      this == RhythmicValue.dottedSixteenth;

  bool get isTriplet =>
      this == RhythmicValue.halfTriplet ||
      this == RhythmicValue.quarterTriplet ||
      this == RhythmicValue.eighthTriplet;
}

/// A quantized note with musical time information
class QuantizedNote {
  final int midiNote;
  final int velocity;
  final MusicalTime startTime;
  final MusicalTime endTime;
  final RhythmicValue duration;
  final bool isTied;

  const QuantizedNote({
    required this.midiNote,
    required this.velocity,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.isTied = false,
  });

  double get durationInBeats => endTime.absoluteBeat - startTime.absoluteBeat;

  @override
  String toString() =>
      'Note $midiNote: $startTime → ${endTime.toString()} (${duration.name})';
}

class Quantizer {
  final MidiData midiData;
  final double beatsPerMinute;
  final int timeSignatureNumerator;
  final int timeSignatureDenominator;

  Quantizer({
    required this.midiData,
    required this.beatsPerMinute,
    required this.timeSignatureNumerator,
    required this.timeSignatureDenominator,
  });

  /// Milliseconds per quarter note beat
  double get msPerBeat => 60000.0 / beatsPerMinute;

  /// Beats per measure (in quarter note units)
  double get beatsPerMeasure =>
      (timeSignatureNumerator * 4.0) / timeSignatureDenominator;

  /// Convert milliseconds to absolute beat number
  double millisToBeats(int milliseconds) {
    return milliseconds / msPerBeat;
  }

  /// Convert absolute beat to musical time (measure + beat within measure)
  MusicalTime beatsToMusicalTime(double absoluteBeat) {
    final measure = (absoluteBeat / beatsPerMeasure).floor();
    final beatInMeasure = absoluteBeat % beatsPerMeasure;

    return MusicalTime(
      measure: measure,
      beat: beatInMeasure,
      absoluteBeat: absoluteBeat,
    );
  }

  /// Quantize a beat value to the nearest grid position
  double quantizeBeat(double beat, {double gridResolution = 0.125}) {
    return (beat / gridResolution).round() * gridResolution;
  }

  /// Find the best rhythmic value for a duration
  RhythmicValue findBestRhythmicValue(double durationInBeats) {
    final values = RhythmicValue.values;

    RhythmicValue best = RhythmicValue.quarter;
    double minDifference = double.infinity;

    for (final value in values) {
      final difference = (value.beats - durationInBeats).abs();
      if (difference < minDifference) {
        minDifference = difference;
        best = value;
      }
    }

    return best;
  }

  /// Largest average timing error (in beats) a grid may leave before a finer
  /// grid is tried. Human playing typically wobbles by 0.03-0.07 beats.
  static const double gridTolerance = 0.07;

  /// Largest error any single onset may have on an accepted grid, so one
  /// off-beat note is not swallowed by an otherwise on-beat passage.
  static const double gridMaxError = 0.2;

  /// Picks the coarsest grid that explains the note onsets.
  ///
  /// A finer grid always fits better, so choosing the grid with the smallest
  /// error would always pick the finest one and turn every timing wobble into
  /// a tiny note value. Instead grids are tried from coarse to fine and the
  /// first whose average error is within [gridTolerance] wins.
  double analyzeOptimalGridResolution() {
    const candidates = [1.0, 0.5, 0.25, 0.125];
    if (midiData.notes.length < 2) return 0.25;

    final onsets = midiData.notes
        .map((n) => millisToBeats(n.startTime))
        .toList();
    for (final grid in candidates) {
      var total = 0.0;
      var worst = 0.0;
      for (final onset in onsets) {
        final error = (onset - (onset / grid).round() * grid).abs();
        total += error;
        if (error > worst) worst = error;
      }
      if (total / onsets.length <= gridTolerance && worst <= gridMaxError) {
        return grid;
      }
    }
    return candidates.last;
  }

  /// Quantize all notes in the MIDI data
  List<QuantizedNote> quantizeNotes({double? gridResolution}) {
    final resolution = gridResolution ?? analyzeOptimalGridResolution();
    final quantizedNotes = <QuantizedNote>[];

    for (final midiNote in midiData.notes) {
      // Convert to beats
      final startBeats = millisToBeats(midiNote.startTime);
      final endBeats = millisToBeats(midiNote.endTime);

      // Quantize
      final quantizedStart = quantizeBeat(
        startBeats,
        gridResolution: resolution,
      );
      final quantizedEnd = quantizeBeat(endBeats, gridResolution: resolution);

      // Ensure minimum duration
      final finalEnd = quantizedEnd > quantizedStart
          ? quantizedEnd
          : quantizedStart + resolution;

      // Convert to musical time
      final startTime = beatsToMusicalTime(quantizedStart);
      final endTime = beatsToMusicalTime(finalEnd);

      // Determine rhythmic value
      final durationBeats = finalEnd - quantizedStart;
      final rhythmicValue = findBestRhythmicValue(durationBeats);

      // Check if note crosses measure boundary
      final isTied = startTime.measure != endTime.measure;

      quantizedNotes.add(
        QuantizedNote(
          midiNote: midiNote.midiNumber,
          velocity: midiNote.velocity,
          startTime: startTime,
          endTime: endTime,
          duration: rhythmicValue,
          isTied: isTied,
        ),
      );
    }

    // Sort by start time
    quantizedNotes.sort(
      (a, b) => a.startTime.absoluteBeat.compareTo(b.startTime.absoluteBeat),
    );

    return quantizedNotes;
  }

  /// Group notes that start at the same time (chords)
  List<List<QuantizedNote>> groupChords(List<QuantizedNote> notes) {
    if (notes.isEmpty) return [];

    final chords = <List<QuantizedNote>>[];
    final tolerance = 0.01;

    List<QuantizedNote> currentChord = [notes[0]];

    for (int i = 1; i < notes.length; i++) {
      final note = notes[i];
      final prevNote = currentChord.last;

      final timeDiff =
          (note.startTime.absoluteBeat - prevNote.startTime.absoluteBeat).abs();

      if (timeDiff < tolerance) {
        currentChord.add(note);
      } else {
        chords.add(currentChord);
        currentChord = [note];
      }
    }

    if (currentChord.isNotEmpty) {
      chords.add(currentChord);
    }

    return chords;
  }

  /// Split notes into treble and bass (for piano)
  ({List<QuantizedNote> treble, List<QuantizedNote> bass}) splitByClef(
    List<QuantizedNote> notes, {
    int splitPoint = 60, // Middle C
  }) {
    final treble = <QuantizedNote>[];
    final bass = <QuantizedNote>[];

    for (final note in notes) {
      if (note.midiNote >= splitPoint) {
        treble.add(note);
      } else {
        bass.add(note);
      }
    }

    return (treble: treble, bass: bass);
  }
}
