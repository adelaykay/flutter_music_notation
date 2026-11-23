// lib/src/models/measure.dart

import 'note.dart';
import 'slur.dart';
import 'time_signature.dart';
import 'key_signature.dart';
import 'beam.dart';
import 'tie.dart';
import 'tuplet_bracket.dart';

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

  /// Ties in this measure (optional - auto-detected if null)
  final List<Tie>? ties;

  /// Slurs in this measure (optional - auto-detected if null)
  final List<Slur>? slurs;

  /// Tuplet brackets in this measure (optional - auto-detected if null)
  final List<TupletBracket>? tuplets;
  /// Type of barline at the beginning of this measure (e.g. a left barline
  /// after the brace on a grand staff). `null` means no start barline.
  final BarlineType? startBarline;

  const Measure({
    required this.number,
    required this.timeSignature,
    required this.keySignature,
    this.notes = const [],
    this.rests = const [],
    this.endBarline = BarlineType.single,
    this.ties,
    this.slurs,
    this.tuplets,
    this.startBarline,
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

  /// Automatically calculate beam groups for this measure
  List<BeamGroup> get beamGroups {
    return BeamGroupCalculator.calculateBeamGroups(
      notes,
      timeSignature.beats,
      timeSignature.beatUnit,
    );
  }

  /// Get ties for this measure (auto-detect enabled)
  List<Tie> get tiesInMeasure {
    if (ties != null) return ties!;

    // Auto-detect ties within this measure
    final detectedTies = <Tie>[];

    for (int i = 0; i < notes.length - 1; i++) {
      for (int j = i + 1; j < notes.length; j++) {
        final note1 = notes[i];
        final note2 = notes[j];

        // Check if notes are the same pitch and consecutive
        if (note1.pitch == note2.pitch &&
            (note2.startBeat - note1.endBeat).abs() < 0.01) {
          detectedTies.add(Tie(
            startNote: note1,
            endNote: note2,
          ));
        }
      }
    }

    return detectedTies;
  }

  /// Get explicitly provided ties for this measure (auto-detect disabled)
  List<Tie> get explicitTiesInMeasure {
    return ties ?? [];
  }


  /// Get tuplets for this measure (auto-detect if not provided)
  List<TupletBracket> get tupletsInMeasure {
    if (tuplets != null) return tuplets!;
    return TupletHelper.detectTuplets(notes);
  }

  /// Get slurs for this measure (return provided slurs)
  /// Note: Slurs typically need to be explicitly defined
  List<Slur> get slursInMeasure {
    return slurs ?? [];
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
    List<Tie>? ties,
    List<Slur>? slurs,
    List<TupletBracket>? tuplets,
    BarlineType? startBarline,
  }) {
    return Measure(
      number: number ?? this.number,
      timeSignature: timeSignature ?? this.timeSignature,
      keySignature: keySignature ?? this.keySignature,
      notes: notes ?? this.notes,
      rests: rests ?? this.rests,
      endBarline: endBarline ?? this.endBarline,
      ties: ties ?? this.ties,
      slurs: slurs ?? this.slurs,
      tuplets: tuplets ?? this.tuplets,
      startBarline: startBarline ?? this.startBarline,
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