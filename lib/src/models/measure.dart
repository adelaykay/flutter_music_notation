// lib/src/models/measure.dart

import 'note.dart';
import 'time_signature.dart';
import 'key_signature.dart';

/// Represents a single measure (bar) of music
class Measure {
  /// Measure number (0-indexed)
  final int number;

  /// Time signature for this measure
  final TimeSignature timeSignature;

  /// Key signature for this measure
  final KeySignature keySignature;

  /// Notes in this measure
  final List<Note> notes;

  /// Rests in this measure
  final List<Rest> rests;

  /// Type of barline at the end of this measure
  final BarlineType endBarline;

  const Measure({
    required this.number,
    required this.timeSignature,
    required this.keySignature,
    this.notes = const [],
    this.rests = const [],
    this.endBarline = BarlineType.single,
  });

  /// All elements (notes and rests) sorted by start beat
  List<dynamic> get elements {
    final combined = <dynamic>[...notes, ...rests];
    combined.sort((a, b) {
      final aStart = a is Note ? a.startBeat : (a as Rest).startBeat;
      final bStart = b is Note ? b.startBeat : (b as Rest).startBeat;
      return aStart.compareTo(bStart);
    });
    return combined;
  }

  /// Check if this measure has the correct duration
  bool isComplete() {
    double totalBeats = 0.0;

    for (final note in notes) {
      totalBeats += note.duration.beats;
    }

    for (final rest in rests) {
      totalBeats += rest.duration.beats;
    }

    return (totalBeats - timeSignature.beatsPerMeasure).abs() < 0.01;
  }

  /// Whether this is the first measure (shows clef, key sig, time sig)
  bool get isFirstMeasure => number == 0;

  Measure copyWith({
    int? number,
    TimeSignature? timeSignature,
    KeySignature? keySignature,
    List<Note>? notes,
    List<Rest>? rests,
    BarlineType? endBarline,
  }) {
    return Measure(
      number: number ?? this.number,
      timeSignature: timeSignature ?? this.timeSignature,
      keySignature: keySignature ?? this.keySignature,
      notes: notes ?? this.notes,
      rests: rests ?? this.rests,
      endBarline: endBarline ?? this.endBarline,
    );
  }
}

/// Types of barlines
enum BarlineType {
  single,      // Regular barline (|)
  double_,     // Double barline (||)
  final_,      // Final barline (||)
  repeatStart, // Repeat start (|:)
  repeatEnd,   // Repeat end (:|)
  dashed,      // Dashed barline (for partial measures)
}