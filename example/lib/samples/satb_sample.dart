import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';

/// A short hymn in four parts on a grand staff: soprano and alto on the
/// treble staff, tenor and bass on the bass staff, each voice with its own
/// stems, ties and rests. Systems break to fit the width, the view sizes
/// itself, and Play shades each bar in turn as a player would.
class SATBSample extends StatefulWidget {
  const SATBSample({super.key});

  @override
  State<SATBSample> createState() => _SATBSampleState();
}

class _SATBSampleState extends State<SATBSample> {
  late final GrandStaff _score = _hymn();
  double _staffSpace = 8;
  int? _bar;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() {
        _timer = null;
        _bar = null;
      });
      return;
    }
    setState(() => _bar = 0);
    // Four beats at 80 bpm per bar.
    _timer = Timer.periodic(const Duration(milliseconds: 3000), (t) {
      final next = (_bar ?? 0) + 1;
      if (next >= _score.measureCount) {
        t.cancel();
        setState(() {
          _timer = null;
          _bar = null;
        });
      } else {
        setState(() => _bar = next);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Hymn in four parts',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Two voices per staff with their own stems, rests and ties. '
          'Systems break to fit the width; Play shades the bar being played.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.icon(
              onPressed: _togglePlay,
              icon: Icon(_timer == null ? Icons.play_arrow : Icons.stop),
              label: Text(_timer == null ? 'Play' : 'Stop'),
            ),
            const SizedBox(width: 16),
            const Text('Staff size'),
            Expanded(
              child: Slider(
                value: _staffSpace,
                min: 6,
                max: 12,
                divisions: 6,
                label: '${_staffSpace.round()} px',
                onChanged: (v) => setState(() => _staffSpace = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // No height: the view lays out its systems at the available width
        // and takes the height they need.
        NotationView(
          grandStaff: _score,
          config: NotationConfig(
            staffSpaceSize: _staffSpace,
            padding: EdgeInsets.zero,
            leftMargin: 28,
            rightMargin: 16,
            topMargin: _staffSpace * 5,
            upperStaffHeight: _staffSpace * 4,
            lowerStaffHeight: _staffSpace * 4,
            grandStaffGap: _staffSpace * 7,
            systemSpacing: _staffSpace * 8,
            measureSpacing: _staffSpace * 1.5,
            useSystemLayout: true,
            highlightedMeasure: _bar,
          ),
        ),
      ],
    );
  }
}

/// Eight bars in E flat major, 4/4. Voices 0 and 1 (soprano, alto) share the
/// upper staff with stems up and down; voices 2 and 3 (tenor, bass) the
/// lower.
GrandStaff _hymn() {
  const key = KeySignature(accidentals: -3);
  const time = TimeSignature(beats: 4, beatUnit: 4);
  const w = NoteDuration.whole(),
      h = NoteDuration.half(),
      q = NoteDuration.quarter();
  const e = NoteDuration.eighth(), dq = NoteDuration.dottedQuarter();

  Note n(
    int midi,
    NoteDuration d,
    double beat,
    int voice, {
    bool tie = false,
  }) => Note(
    pitch: Pitch.fromMidiNumber(midi, preferredAccidental: Accidental.flat),
    duration: d,
    startBeat: beat,
    voice: voice,
    stemDirection: voice.isEven ? StemDirection.up : StemDirection.down,
    tieToNext: tie,
  );

  // [soprano, alto, tenor, bass] for each bar; rests are (beat, duration, voice).
  final bars = <(List<Note>, List<Note>, List<Rest>, List<Rest>)>[
    (
      [
        n(67, h, 0, 0),
        n(70, q, 2, 0),
        n(68, q, 3, 0),
        n(63, h, 0, 1),
        n(63, q, 2, 1),
        n(63, q, 3, 1),
      ],
      [n(58, h, 0, 2), n(58, h, 2, 2), n(51, w, 0, 3)],
      const [],
      const [],
    ),
    (
      [
        n(67, dq, 0, 0),
        n(65, e, 1.5, 0),
        n(63, h, 2, 0),
        n(63, q, 0, 1),
        n(62, q, 1, 1),
        n(58, h, 2, 1),
      ],
      [
        n(55, q, 0, 2),
        n(58, q, 1, 2),
        n(55, h, 2, 2),
        n(48, h, 0, 3),
        n(46, h, 2, 3),
      ],
      const [],
      const [],
    ),
    (
      // The soprano's D is tied across the barline.
      [
        n(70, q, 0, 0),
        n(72, q, 1, 0),
        n(74, h, 2, 0, tie: true),
        n(65, h, 0, 1),
        n(65, h, 2, 1),
      ],
      [n(58, h, 0, 2), n(58, q, 2, 2), n(50, h, 0, 3), n(46, h, 2, 3)],
      const [],
      // The tenor rests on beat 4: its rest sits above the bass.
      const [Rest(duration: NoteDuration.quarter(), startBeat: 3, voice: 2)],
    ),
    (
      [
        n(74, q, 0, 0),
        n(72, q, 1, 0),
        n(70, h, 2, 0),
        n(65, q, 0, 1),
        n(63, q, 1, 1),
        n(62, h, 2, 1),
      ],
      [n(58, h, 0, 2), n(58, h, 2, 2), n(46, w, 0, 3)],
      const [],
      const [],
    ),
    (
      [
        n(75, h, 0, 0),
        n(74, q, 2, 0),
        n(72, q, 3, 0),
        n(67, h, 0, 1),
        n(70, q, 2, 1),
        n(68, q, 3, 1),
      ],
      [
        n(63, h, 0, 2),
        n(62, q, 2, 2),
        n(63, q, 3, 2),
        n(48, h, 0, 3),
        n(46, q, 2, 3),
        n(44, q, 3, 3),
      ],
      const [],
      const [],
    ),
    (
      // A tie inside the bar.
      [
        n(70, q, 0, 0, tie: true),
        n(70, q, 1, 0),
        n(68, h, 2, 0),
        n(63, h, 0, 1),
        n(65, h, 2, 1),
      ],
      [
        n(58, q, 0, 2),
        n(55, q, 1, 2),
        n(60, h, 2, 2),
        n(51, h, 0, 3),
        n(53, h, 2, 3),
      ],
      const [],
      const [],
    ),
    (
      [
        n(67, q, 0, 0),
        n(68, e, 1, 0),
        n(67, e, 1.5, 0),
        n(65, h, 2, 0),
        n(63, h, 0, 1),
        n(62, h, 2, 1),
      ],
      [n(58, h, 0, 2), n(58, h, 2, 2), n(51, h, 0, 3), n(46, h, 2, 3)],
      const [],
      const [],
    ),
    (
      // The alto rests for the last two beats: its rest sits below the soprano.
      [n(63, w, 0, 0), n(58, h, 0, 1)],
      [n(55, w, 0, 2), n(51, w, 0, 3)],
      const [Rest(duration: NoteDuration.half(), startBeat: 2, voice: 1)],
      const [],
    ),
  ];

  final upper = <Measure>[], lower = <Measure>[];
  for (var i = 0; i < bars.length; i++) {
    final (up, lo, upRests, loRests) = bars[i];
    final end = i == bars.length - 1 ? BarlineType.final_ : BarlineType.single;
    upper.add(
      Measure(
        number: i,
        timeSignature: time,
        keySignature: key,
        notes: up,
        rests: upRests,
        endBarline: end,
      ),
    );
    lower.add(
      Measure(
        number: i,
        timeSignature: time,
        keySignature: key,
        notes: lo,
        rests: loRests,
        endBarline: end,
      ),
    );
  }
  return GrandStaff(upperStaff: upper, lowerStaff: lower);
}
