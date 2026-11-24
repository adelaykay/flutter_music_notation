// lib/src/midi/midi_to_notation.dart
//
// Turns performed MIDI (millisecond timings from a keyboard or a file) into
// engraved measures.
//
// Pipeline:
//   1. Quantize onsets and releases to a grid (the coarsest grid that explains
//      the playing; see [Quantizer.analyzeOptimalGridResolution]).
//   2. Drop leading silent bars, so a recording that starts with a pause does
//      not open with empty bars.
//   3. Group notes that start together into chords and trim legato overlaps,
//      so a key held into the next note does not stack up.
//   4. Fill every gap with rests, so each bar adds up to its time signature.
//   5. Split events at barlines and into notatable values aligned to the
//      beat, joining the pieces of a note with ties.
//   6. Spell pitches from the key: notes in the key use its letters, the
//      leading note of a minor key is raised, other notes follow the key's
//      sharp or flat direction.

import 'dart:math' as math;

import '../geometry/staff_position.dart';
import '../models/duration.dart';
import '../models/grand_staff.dart';
import '../models/key_signature.dart';
import '../models/measure.dart';
import '../models/note.dart';
import '../models/pitch.dart';
import '../models/tie.dart';
import '../models/time_signature.dart';
import 'midi_note.dart';
import 'quantizer.dart';
import 'satb_detector.dart';

/// Converts MIDI data to musical notation.
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

  KeySignature get keySignature => KeySignature(
    accidentals: midiData.keySignatureSharps.clamp(-7, 7),
    isMinor: midiData.keySignatureIsMinor,
  );

  TimeSignature get timeSignature => TimeSignature(
    beats: midiData.timeSignatureNumerator,
    beatUnit: midiData.timeSignatureDenominator,
  );

  double get _barLength => quantizer.beatsPerMeasure;

  /// Length of one beat in quarter notes: a dotted quarter in compound
  /// meters (6/8, 9/8, 12/8), otherwise the time signature's beat unit.
  double get _beatLength =>
      timeSignature.isCompound && timeSignature.beatUnit == 8
      ? 1.5
      : 4.0 / timeSignature.beatUnit;

  // ---------------------------------------------------------------- public API

  /// Convert to a single staff. Set [NotationConfig.clef] to [suggestedClef]
  /// (with the same [clefPreference]) when displaying the result.
  List<Measure> toSingleStaff({
    ClefPreference clefPreference = ClefPreference.auto,
    double? gridResolution,
  }) {
    final notes = _quantize(gridResolution);
    return _engrave(notes, _barCount(notes));
  }

  /// The clef that suits this music on a single staff.
  ClefType suggestedClef({ClefPreference preference = ClefPreference.auto}) {
    switch (preference) {
      case ClefPreference.treble:
        return ClefType.treble;
      case ClefPreference.bass:
        return ClefType.bass;
      case ClefPreference.auto:
        if (midiData.notes.isEmpty) return ClefType.treble;
        final avg =
            midiData.notes.map((n) => n.midiNumber).reduce((a, b) => a + b) /
            midiData.notes.length;
        return avg < 60 ? ClefType.bass : ClefType.treble;
    }
  }

  /// Convert to a grand staff (piano). Notes at or above [splitPoint]
  /// (default middle C) go to the upper staff, the rest to the lower.
  GrandStaff toGrandStaff({double? gridResolution, int splitPoint = 60}) {
    final notes = _quantize(gridResolution);
    final bars = _barCount(notes);
    return GrandStaff(
      upperStaff: _engrave(
        notes.where((n) => n.midi >= splitPoint).toList(),
        bars,
      ),
      lowerStaff: _engrave(
        notes.where((n) => n.midi < splitPoint).toList(),
        bars,
      ),
      instrumentName: 'Piano',
      instrumentAbbreviation: 'Pno.',
    );
  }

  /// The whole bars of silence before the first note that the conversion
  /// leaves out, in quarter-note beats. Bar 1 of the result starts this many
  /// beats into the MIDI, so a [PlaybackController] position is
  /// `seconds * beatsPerMinute / 60 - droppedLeadingBeats()`.
  ///
  /// Pass the same [gridResolution] as to the conversion.
  double droppedLeadingBeats({double? gridResolution}) {
    final quantized = quantizer.quantizeNotes(gridResolution: gridResolution);
    return _leadingShift(quantized.map((q) => q.startTime.absoluteBeat));
  }

  /// Attempt to separate four voices (soprano, alto, tenor, bass).
  /// Returns null if detection fails.
  List<List<Measure>>? toSATB({double? gridResolution}) {
    final quantized = quantizer.quantizeNotes(gridResolution: gridResolution);
    final voices = SATBDetector().detectVoices(quantized);
    if (voices == null) return null;

    final shift = _leadingShift(quantized.map((q) => q.startTime.absoluteBeat));
    List<_QNote> convert(List<QuantizedNote> list) => [
      for (final q in list)
        _QNote(
          q.midiNote,
          q.velocity,
          q.startTime.absoluteBeat - shift,
          q.endTime.absoluteBeat - shift,
        ),
    ];
    final parts = [
      voices.soprano.notes,
      voices.alto.notes,
      voices.tenor.notes,
      voices.bass.notes,
    ].map(convert).toList();
    final bars = _barCount(parts.expand((p) => p).toList());
    return [for (final part in parts) _engrave(part, bars)];
  }

  /// Estimates the key from the notes (Krumhansl-Schmuckler key profiles).
  /// Useful when the source has no key signature, e.g. a live recording.
  KeySignature estimateKey() {
    const major = [
      6.35,
      2.23,
      3.48,
      2.33,
      4.38,
      4.09,
      2.52,
      5.19,
      2.39,
      3.66,
      2.29,
      2.88,
    ];
    const minor = [
      6.33,
      2.68,
      3.52,
      5.38,
      2.60,
      3.53,
      2.54,
      4.75,
      3.98,
      2.69,
      3.34,
      3.17,
    ];
    final weights = List<double>.filled(12, 0);
    for (final n in midiData.notes) {
      weights[n.midiNumber % 12] += (n.endTime - n.startTime)
          .clamp(1, 1 << 30)
          .toDouble();
    }
    if (weights.every((w) => w == 0)) return keySignature;

    double correlate(List<double> profile, int tonic) {
      final xs = List<double>.generate(
        12,
        (i) => profile[(i - tonic + 12) % 12],
      );
      final mx = xs.reduce((a, b) => a + b) / 12,
          my = weights.reduce((a, b) => a + b) / 12;
      var num = 0.0, dx = 0.0, dy = 0.0;
      for (var i = 0; i < 12; i++) {
        num += (xs[i] - mx) * (weights[i] - my);
        dx += (xs[i] - mx) * (xs[i] - mx);
        dy += (weights[i] - my) * (weights[i] - my);
      }
      return dx == 0 || dy == 0 ? 0 : num / math.sqrt(dx * dy);
    }

    // Accidentals for each major tonic pitch class (prefer the simpler spelling).
    const majorAccidentals = [0, -5, 2, -3, 4, -1, 6, 1, -4, 3, -2, 5];
    var best = keySignature;
    var bestScore = double.negativeInfinity;
    for (var tonic = 0; tonic < 12; tonic++) {
      final maj = correlate(major, tonic);
      if (maj > bestScore) {
        bestScore = maj;
        best = KeySignature(accidentals: majorAccidentals[tonic]);
      }
      final min = correlate(minor, tonic);
      if (min > bestScore) {
        bestScore = min;
        best = KeySignature(
          accidentals: majorAccidentals[(tonic + 3) % 12],
          isMinor: true,
        );
      }
    }
    return best;
  }

  // ---------------------------------------------------------------- pipeline

  List<_QNote> _quantize(double? gridResolution) {
    final quantized = quantizer.quantizeNotes(gridResolution: gridResolution);
    final shift = _leadingShift(quantized.map((q) => q.startTime.absoluteBeat));
    return [
      for (final q in quantized)
        _QNote(
          q.midiNote,
          q.velocity,
          q.startTime.absoluteBeat - shift,
          q.endTime.absoluteBeat - shift,
        ),
    ];
  }

  /// Whole bars of silence before the first note, to be removed.
  double _leadingShift(Iterable<double> starts) {
    if (starts.isEmpty) return 0;
    final first = starts.reduce((a, b) => a < b ? a : b);
    return (first / _barLength).floor() * _barLength;
  }

  int _barCount(List<_QNote> notes) {
    if (notes.isEmpty) return 1;
    final end = notes.map((n) => n.end).reduce((a, b) => a > b ? a : b);
    return ((end - _eps) / _barLength).floor() + 1;
  }

  static const _eps = 1e-6;

  /// Engraves one staff: chords, rests, barline splits, ties and spelling.
  List<Measure> _engrave(List<_QNote> notes, int barCount) {
    final key = keySignature;
    final time = timeSignature;
    final barLength = _barLength;
    final totalLength = barCount * barLength;

    // Chords: notes starting together, ending at the latest release but never
    // past the next onset (trims legato overlap).
    final byStart = <int, List<_QNote>>{};
    for (final n in notes) {
      byStart.putIfAbsent((n.start * 1000).round(), () => []).add(n);
    }
    final starts = byStart.keys.toList()..sort();
    final events = <_Event>[];
    for (var i = 0; i < starts.length; i++) {
      final group = byStart[starts[i]]!;
      final start = group.first.start;
      var end = group.map((n) => n.end).reduce((a, b) => a > b ? a : b);
      if (i + 1 < starts.length) {
        final next = byStart[starts[i + 1]]!.first.start;
        if (end > next) end = next;
      }
      if (end > totalLength) end = totalLength;
      final pitches = group.map((n) => n.midi).toSet().toList()..sort();
      events.add(_Event(start, end, pitches, group.first.velocity));
    }

    // Rests in every gap, including to the end of the last bar.
    final timeline = <_Event>[];
    var cursor = 0.0;
    for (final e in events) {
      if (e.start > cursor + _eps) {
        timeline.add(_Event(cursor, e.start, const [], 0));
      }
      timeline.add(e);
      cursor = e.end;
    }
    if (totalLength > cursor + _eps) {
      timeline.add(_Event(cursor, totalLength, const [], 0));
    }

    // Split into bars and notatable pieces.
    final barNotes = List.generate(barCount, (_) => <Note>[]);
    final barRests = List.generate(barCount, (_) => <Rest>[]);
    final barTies = List.generate(barCount, (_) => <Tie>[]);

    for (final e in timeline) {
      final pieces = <(int bar, double pos, NoteDuration duration)>[];
      var at = e.start;
      while (at < e.end - _eps) {
        final bar = ((at + _eps) / barLength).floor();
        final barEnd = (bar + 1) * barLength;
        final segmentEnd = e.end < barEnd ? e.end : barEnd;
        final pos = at - bar * barLength;
        final isRest = e.pitches.isEmpty;
        // A rest filling an entire bar is written as a whole-bar rest.
        if (isRest && pos.abs() < _eps && (segmentEnd - barEnd).abs() < _eps) {
          pieces.add((bar, 0.0, const NoteDuration.whole()));
        } else {
          for (final (p, d) in _split(pos, segmentEnd - at)) {
            pieces.add((bar, p, d));
          }
        }
        at = segmentEnd;
      }

      if (e.pitches.isEmpty) {
        for (final (bar, pos, d) in pieces) {
          if (bar < barCount) {
            barRests[bar].add(Rest(duration: d, startBeat: pos));
          }
        }
        continue;
      }

      final previous = <int, Note>{};
      for (var i = 0; i < pieces.length; i++) {
        final (bar, pos, d) = pieces[i];
        if (bar >= barCount) break;
        final last = i == pieces.length - 1;
        for (final midi in e.pitches) {
          final note = Note(
            pitch: spell(midi, key),
            duration: d,
            startBeat: pos,
            velocity: e.velocity.clamp(0, 127),
            tieToNext: !last,
          );
          final before = previous[midi];
          if (before != null && pieces[i - 1].$1 == bar) {
            barTies[bar].add(Tie(startNote: before, endNote: note));
          }
          previous[midi] = note;
          barNotes[bar].add(note);
        }
      }
    }

    return [
      for (var b = 0; b < barCount; b++)
        Measure(
          number: b + 1,
          timeSignature: time,
          keySignature: key,
          notes: barNotes[b],
          rests: barRests[b],
          ties: barTies[b],
          endBarline: b == barCount - 1
              ? BarlineType.final_
              : BarlineType.single,
        ),
    ];
  }

  // Notatable values, longest first (in quarter notes).
  static const List<(double, NoteDuration)> _values = [
    (4.0, NoteDuration.whole()),
    (3.0, NoteDuration.dottedHalf()),
    (2.0, NoteDuration.half()),
    (1.5, NoteDuration.dottedQuarter()),
    (1.0, NoteDuration.quarter()),
    (0.75, NoteDuration.dottedEighth()),
    (0.5, NoteDuration.eighth()),
    (0.375, NoteDuration(type: DurationType.sixteenth, dots: 1)),
    (0.25, NoteDuration.sixteenth()),
    (0.125, NoteDuration(type: DurationType.thirtySecond)),
  ];

  /// Splits a span inside one bar into notatable values. A value is only used
  /// where it starts on a matching subdivision (an eighth on an eighth, a
  /// quarter or longer on a beat), so rhythms read the way they are counted.
  List<(double, NoteDuration)> _split(double pos, double length) {
    final out = <(double, NoteDuration)>[];
    var at = pos;
    var left = length;
    while (left > _eps) {
      (double, NoteDuration)? pick;
      for (final v in _values) {
        if (v.$1 > left + _eps) continue;
        if (_aligned(at, v.$1, v.$2.dots > 0)) {
          pick = v;
          break;
        }
      }
      // Off-grid remainder (e.g. triplet input): fall back to the largest fit.
      pick ??= _values.firstWhere(
        (v) => v.$1 <= left + _eps,
        orElse: () => _values.last,
      );
      out.add((at, pick.$2));
      at += pick.$1;
      left -= pick.$1;
    }
    return out;
  }

  bool _aligned(double at, double value, bool dotted) {
    final beat = _beatLength;
    double unit;
    if (dotted && (value - beat).abs() < _eps) {
      unit = beat; // dotted-quarter beat in compound meter
    } else {
      final undotted = dotted ? value / 1.5 : value;
      unit = undotted < beat ? undotted : beat;
    }
    final r = at % unit;
    if (!(r < _eps || unit - r < _eps)) return false;
    // A value that starts between beats must not run across the next beat,
    // so the beat stays visible (an off-beat dotted eighth becomes e + tied s).
    final intoBeat = at % beat;
    final onBeat = intoBeat < _eps || beat - intoBeat < _eps;
    return onBeat || intoBeat + value <= beat + _eps;
  }

  // ---------------------------------------------------------------- spelling

  static const _naturalPc = {
    NoteName.C: 0,
    NoteName.D: 2,
    NoteName.E: 4,
    NoteName.F: 5,
    NoteName.G: 7,
    NoteName.A: 9,
    NoteName.B: 11,
  };

  /// Spells [midi] in [key]: notes of the key use its letters (so C♭ major
  /// writes C♭, not B), a minor key's leading note is written raised, and
  /// other notes use sharps in sharp keys and flats in flat keys (C major
  /// uses C♯, E♭, F♯, G♯ and B♭).
  static Pitch spell(int midi, KeySignature key) {
    final pc = midi % 12;

    Pitch make(NoteName letter, Accidental acc) {
      final octave =
          ((midi - _naturalPc[letter]! - acc.semitoneOffset) ~/ 12) - 1;
      return Pitch(noteName: letter, accidental: acc, octave: octave);
    }

    // Diatonic notes of the key.
    for (final letter in NoteName.values) {
      final acc = key.accidentalFor(letter);
      if ((_naturalPc[letter]! + acc.semitoneOffset + 12) % 12 == pc) {
        return make(letter, acc);
      }
    }

    // Raised leading note in minor keys.
    if (key.isMinor) {
      final tonicLetter = _minorTonicLetter(key);
      final leading = tonicLetter.previous;
      final raised = Accidental.values.firstWhere(
        (a) =>
            a.semitoneOffset == key.accidentalFor(leading).semitoneOffset + 1,
        orElse: () => Accidental.natural,
      );
      if ((_naturalPc[leading]! + raised.semitoneOffset + 12) % 12 == pc) {
        return make(leading, raised);
      }
    }

    // A natural note whose letter the key alters.
    for (final letter in NoteName.values) {
      if (_naturalPc[letter] == pc) return make(letter, Accidental.natural);
    }

    // Chromatic black-key notes.
    if (key.accidentals > 0) return make(_letterBelow(pc), Accidental.sharp);
    if (key.accidentals < 0) return make(_letterAbove(pc), Accidental.flat);
    switch (pc) {
      case 3:
        return make(NoteName.E, Accidental.flat);
      case 10:
        return make(NoteName.B, Accidental.flat);
      default:
        return make(_letterBelow(pc), Accidental.sharp);
    }
  }

  static NoteName _letterBelow(int pc) =>
      NoteName.values.firstWhere((l) => _naturalPc[l] == (pc + 11) % 12);

  static NoteName _letterAbove(int pc) =>
      NoteName.values.firstWhere((l) => _naturalPc[l] == (pc + 1) % 12);

  static NoteName _minorTonicLetter(KeySignature key) {
    // Major tonic letters around the circle of fifths, from 7 flats to 7 sharps.
    const majors = [
      NoteName.C,
      NoteName.G,
      NoteName.D,
      NoteName.A,
      NoteName.E,
      NoteName.B,
      NoteName.F, // -7..-1
      NoteName.C, // 0
      NoteName.G,
      NoteName.D,
      NoteName.A,
      NoteName.E,
      NoteName.B,
      NoteName.F,
      NoteName.C, // 1..7
    ];
    final majorTonic = majors[key.accidentals + 7];
    return NoteName.values[(majorTonic.index + 5) %
        7]; // relative minor: down a third
  }
}

class _QNote {
  const _QNote(this.midi, this.velocity, this.start, this.end);
  final int midi;
  final int velocity;
  final double start;
  final double end;
}

class _Event {
  const _Event(this.start, this.end, this.pitches, this.velocity);
  final double start;
  final double end;
  final List<int> pitches; // empty for a rest
  final int velocity;
}

/// Preference for clef selection
enum ClefPreference {
  auto, // Automatically determine
  treble, // Force treble clef
  bass, // Force bass clef
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
  GrandStaff toGrandStaff({double? gridResolution, int splitPoint = 60}) {
    final converter = MidiToNotation(midiData: this);
    return converter.toGrandStaff(
      gridResolution: gridResolution,
      splitPoint: splitPoint,
    );
  }
}
