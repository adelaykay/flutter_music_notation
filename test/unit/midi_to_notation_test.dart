import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';

/// Builds performed MIDI at [bpm]: each entry is (midi, startBeat, lengthBeats),
/// with optional human timing jitter (in beats) on both press and release.
MidiData played(
  List<(int, double, double)> notes, {
  double bpm = 100,
  double jitter = 0,
  int seed = 1,
  int keySharps = 0,
  bool minor = false,
  int beats = 4,
  int unit = 4,
}) {
  final rng = Random(seed);
  final msPerBeat = 60000 / bpm;
  double wobble() => jitter == 0 ? 0 : (rng.nextDouble() * 2 - 1) * jitter;
  return MidiData(
    notes: [
      for (final (midi, start, length) in notes)
        MidiNote(
          midiNumber: midi,
          velocity: 80,
          startTime: ((start + wobble()) * msPerBeat).round().clamp(0, 1 << 30),
          endTime: ((start + length + wobble()) * msPerBeat).round(),
        ),
    ],
    timeSignatureNumerator: beats,
    timeSignatureDenominator: unit,
    keySignatureSharps: keySharps,
    keySignatureIsMinor: minor,
    beatsPerMinute: bpm,
    ticksPerQuarterNote: 480,
  );
}

/// Sum of durations in a bar, counting each start beat once (chords).
double filled(Measure m) {
  final byStart = <double, double>{};
  for (final n in m.notes) {
    byStart[n.startBeat] = n.duration.beats;
  }
  for (final r in m.rests) {
    byStart[r.startBeat] = r.duration.beats;
  }
  return byStart.values.fold(0.0, (a, b) => a + b);
}

void main() {
  group('quantizing human playing', () {
    test('quarter notes played slightly off the beat come out as quarters', () {
      final data = played([
        for (var i = 0; i < 8; i++) (60 + i % 5, i.toDouble(), 0.9),
      ], jitter: 0.06);
      final bars = MidiToNotation(midiData: data).toSingleStaff();
      expect(bars, hasLength(2));
      for (final bar in bars) {
        expect(
          bar.notes.map((n) => n.duration.type),
          everyElement(DurationType.quarter),
        );
        expect(bar.rests, isEmpty);
      }
    });

    test('a single off-beat eighth pair is not swallowed by the beat grid', () {
      final data = played([
        (60, 0, 1),
        (62, 1, 1),
        (64, 2, 0.5),
        (65, 2.5, 0.5),
        (67, 3, 1),
        for (var i = 4; i < 12; i++) (60, i.toDouble(), 1),
      ], jitter: 0.03);
      final first = MidiToNotation(midiData: data).toSingleStaff().first;
      expect(first.notes.map((n) => n.startBeat), [0.0, 1.0, 2.0, 2.5, 3.0]);
    });
  });

  group('every bar adds up', () {
    test('gaps become rests', () {
      final data = played([(60, 0, 1), (64, 2, 1)]);
      final bar = MidiToNotation(midiData: data).toSingleStaff().single;
      expect(bar.rests.map((r) => r.startBeat), containsAll([1.0, 3.0]));
      expect(filled(bar), closeTo(4, 1e-9));
    });

    test('silent bars are kept as whole-bar rests', () {
      final data = played([(60, 0, 1), (62, 8, 1)]);
      final bars = MidiToNotation(midiData: data).toSingleStaff();
      expect(bars, hasLength(3));
      expect(bars[1].notes, isEmpty);
      expect(bars[1].rests.single.duration.type, DurationType.whole);
      for (final bar in bars) {
        expect(filled(bar), closeTo(4, 1e-9));
      }
    });

    test('leading silence before the first note is trimmed to the bar', () {
      final data = played([(60, 9, 1)]);
      final bars = MidiToNotation(midiData: data).toSingleStaff();
      expect(bars, hasLength(1));
      expect(bars.single.notes.single.startBeat, 1.0);
    });

    test('random performances always fill each bar exactly', () {
      final rng = Random(42);
      for (var trial = 0; trial < 50; trial++) {
        final notes = <(int, double, double)>[];
        var t = 0.0;
        while (t < 16) {
          final len = [0.5, 1.0, 1.5, 2.0, 0.25][rng.nextInt(5)];
          if (rng.nextDouble() < 0.8) {
            notes.add((
              55 + rng.nextInt(20),
              t,
              len * (0.7 + rng.nextDouble() * 0.5),
            ));
          }
          t += len;
        }
        if (notes.isEmpty) continue;
        final bars = MidiToNotation(
          midiData: played(notes, jitter: 0.04, seed: trial),
        ).toSingleStaff();
        for (final bar in bars) {
          expect(
            filled(bar),
            closeTo(4, 1e-6),
            reason: 'trial $trial bar ${bar.number}',
          );
        }
      }
    });
  });

  group('ties and overlaps', () {
    test('a note crossing the barline is split and tied', () {
      final data = played([(60, 3, 2)]);
      final bars = MidiToNotation(midiData: data).toSingleStaff();
      expect(bars, hasLength(2));
      final end = bars[0].notes.single, start = bars[1].notes.single;
      expect(end.startBeat, 3.0);
      expect(end.tieToNext, isTrue);
      expect(start.startBeat, 0.0);
      expect(start.tieToNext, isFalse);
    });

    test(
      'an off-beat long note is split on the beat with a tie inside the bar',
      () {
        final data = played([(60, 0.5, 1.5), (62, 2, 2)]);
        final bar = MidiToNotation(midiData: data).toSingleStaff().single;
        final cs = bar.notes.where((n) => n.pitch.midiNumber == 60).toList();
        expect(cs.map((n) => (n.startBeat, n.duration.beats)), [
          (0.5, 0.5),
          (1.0, 1.0),
        ]);
        expect(bar.ties, hasLength(1));
      },
    );

    test('legato overlap is trimmed instead of stacking', () {
      final data = played([(60, 0, 1.3), (62, 1, 1.3), (64, 2, 2)]);
      final bar = MidiToNotation(midiData: data).toSingleStaff().single;
      expect(bar.notes.map((n) => n.startBeat), [0.0, 1.0, 2.0]);
      expect(
        bar.notes.take(2).map((n) => n.duration.type),
        everyElement(DurationType.quarter),
      );
    });

    test('notes pressed together form one chord', () {
      final data = played([
        (60, 0, 2),
        (64, 0.02, 2),
        (67, 0, 1.95),
      ], jitter: 0);
      final bar = MidiToNotation(midiData: data).toSingleStaff().single;
      final atZero = bar.notes.where((n) => n.startBeat == 0).toList();
      expect(atZero, hasLength(3));
      expect(atZero.map((n) => n.duration.type).toSet(), {DurationType.half});
    });
  });

  group('pitch spelling', () {
    Pitch sp(int midi, KeySignature key) => MidiToNotation.spell(midi, key);

    test('diatonic notes use the key letters', () {
      expect(sp(66, KeySignature.gMajor).noteName, NoteName.F);
      expect(sp(66, KeySignature.gMajor).accidental, Accidental.sharp);
      expect(sp(70, KeySignature.fMajor).noteName, NoteName.B);
      expect(sp(70, KeySignature.fMajor).accidental, Accidental.flat);
    });

    test('C flat major writes C flat and F flat', () {
      final cb = sp(71, KeySignature.cFlatMajor);
      expect(
        (cb.noteName, cb.accidental, cb.midiNumber),
        (NoteName.C, Accidental.flat, 71),
      );
      final fb = sp(64, KeySignature.cFlatMajor);
      expect(
        (fb.noteName, fb.accidental, fb.midiNumber),
        (NoteName.F, Accidental.flat, 64),
      );
    });

    test('minor keys raise the leading note', () {
      final gs = sp(68, KeySignature.aMinor);
      expect((gs.noteName, gs.accidental), (NoteName.G, Accidental.sharp));
      final cs = sp(61, KeySignature.dMinor);
      expect((cs.noteName, cs.accidental), (NoteName.C, Accidental.sharp));
    });

    test('chromatic notes follow the key direction and keep their pitch', () {
      for (var midi = 48; midi < 84; midi++) {
        for (var k = -7; k <= 7; k++) {
          expect(
            sp(midi, KeySignature(accidentals: k)).midiNumber,
            midi,
            reason: 'midi $midi key $k',
          );
        }
      }
      expect(sp(70, KeySignature.cMajor).noteName, NoteName.B); // B flat in C
      expect(sp(61, KeySignature.dMajor).noteName, NoteName.C); // C sharp in D
    });
  });

  group('grand staff', () {
    test(
      'both staves have the same bars and the split follows the split point',
      () {
        final data = played([
          (48, 0, 4),
          (72, 0, 1),
          (74, 1, 1),
          (76, 2, 2),
          (50, 4, 4),
          (77, 4, 4),
        ]);
        final gs = MidiToNotation(midiData: data).toGrandStaff();
        expect(gs.upperStaff.length, gs.lowerStaff.length);
        expect(
          gs.upperStaff
              .expand((m) => m.notes)
              .every((n) => n.pitch.midiNumber >= 60),
          isTrue,
        );
        expect(
          gs.lowerStaff
              .expand((m) => m.notes)
              .every((n) => n.pitch.midiNumber < 60),
          isTrue,
        );
      },
    );
  });

  test('suggestedClef honours the preference', () {
    final low = MidiToNotation(midiData: played([(43, 0, 1), (45, 1, 1)]));
    expect(low.suggestedClef(), ClefType.bass);
    expect(
      low.suggestedClef(preference: ClefPreference.treble),
      ClefType.treble,
    );
  });

  test('estimateKey finds G major from a G major scale', () {
    final scale = [67, 69, 71, 72, 74, 76, 78, 79];
    final data = played([
      for (var i = 0; i < scale.length; i++) (scale[i], i.toDouble(), 1),
    ]);
    expect(MidiToNotation(midiData: data).estimateKey().accidentals, 1);
  });

  test('6/8 groups in dotted quarters', () {
    final data = played([(60, 0, 1.5), (62, 1.5, 1.5)], beats: 6, unit: 8);
    final bar = MidiToNotation(midiData: data).toSingleStaff().single;
    expect(bar.notes.map((n) => n.duration.beats), [1.5, 1.5]);
  });
}
