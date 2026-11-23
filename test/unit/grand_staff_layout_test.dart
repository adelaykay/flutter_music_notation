import 'package:flutter/material.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';
import 'package:flutter_test/flutter_test.dart';

Note _n(int midi, NoteDuration d, double beat, int voice, StemDirection stem) =>
    Note(
      pitch: Pitch.fromMidiNumber(midi),
      duration: d,
      startBeat: beat,
      voice: voice,
      stemDirection: stem,
    );

/// A four-part hymn of [bars] bars in 3/4 with B flat major, where the upper
/// and lower staves move at different times (so their beats differ).
GrandStaff _hymn(int bars) {
  const key = KeySignature(accidentals: -2);
  const time = TimeSignature(beats: 3, beatUnit: 4);
  final upper = <Measure>[], lower = <Measure>[];
  for (var b = 0; b < bars; b++) {
    final busy = b % 3 == 1;
    upper.add(
      Measure(
        number: b,
        timeSignature: time,
        keySignature: key,
        notes: [
          if (busy) ...[
            for (var i = 0; i < 6; i++)
              _n(
                70 + i % 3,
                const NoteDuration.eighth(),
                i * 0.5,
                0,
                StemDirection.up,
              ),
          ] else ...[
            _n(70, const NoteDuration.half(), 0, 0, StemDirection.up),
            _n(72, const NoteDuration.quarter(), 2, 0, StemDirection.up),
          ],
          _n(65, const NoteDuration.dottedHalf(), 0, 1, StemDirection.down),
        ],
      ),
    );
    lower.add(
      Measure(
        number: b,
        timeSignature: time,
        keySignature: key,
        notes: [
          _n(58, const NoteDuration.quarter(), 0, 2, StemDirection.up),
          _n(60, const NoteDuration.half(), 1, 2, StemDirection.up),
          _n(46, const NoteDuration.dottedHalf(), 0, 3, StemDirection.down),
        ],
      ),
    );
  }
  return GrandStaff(upperStaff: upper, lowerStaff: lower);
}

void main() {
  for (final width in [320.0, 400.0, 600.0, 900.0]) {
    for (final space in [6.8, 8.0, 10.0, 12.0]) {
      test('systems fit the page at $width px, staff space $space', () {
        final config = NotationConfig(
          staffSpaceSize: space,
          useSystemLayout: true,
          leftMargin: 22,
          rightMargin: 16,
          padding: EdgeInsets.zero,
        );
        final layout = GrandStaffLayout.forConfig(_hymn(17), config, width);
        expect(layout.systems.expand((s) => s.upperStaffMeasures).length, 17);
        for (final s in layout.systems) {
          final end = s.spacing.measureSpacings.last.endX;
          // A system may only overrun if a single bar is wider than the page.
          if (s.measureCount > 1) {
            expect(
              end,
              lessThanOrEqualTo(width - config.rightMargin + 0.5),
              reason: 'system ${s.systemNumber}',
            );
          }
          // Bars start after the clef, key and time signature reserved for them.
          final pre = systemPrefixWidth(
            config,
            s.upperStaffMeasures.first,
            firstSystem: s.isFirstSystem,
          );
          expect(
            s.spacing.measureSpacings.first.startX,
            closeTo(config.leftMargin + pre, 0.001),
          );
        }
      });
    }
  }

  test('every system respects maxMeasuresPerLine, including the last', () {
    final config = NotationConfig(
      useSystemLayout: true,
      staffSpaceSize: 6,
      lineBreakConfig: const LineBreakConfig(
        targetLineWidth: 2000,
        maxMeasuresPerLine: 3,
      ),
    );
    final layout = GrandStaffLayout.forConfig(_hymn(10), config, 2000);
    expect(layout.systems.map((s) => s.measureCount), [3, 3, 3, 1]);
  });

  test('both staves share one beat grid per bar', () {
    final layout = GrandStaffLayout.forConfig(
      _hymn(2),
      const NotationConfig(useSystemLayout: true),
      1200,
    );
    final grid = layout.systems.first.spacingBeats;
    expect(grid[0], [0.0, 1.0, 2.0]); // upper 0, 2 and lower 0, 1
    expect(grid[1], [0.0, 0.5, 1.0, 1.5, 2.0, 2.5]);
  });

  testWidgets('NotationView sizes a grand staff to its layout', (tester) async {
    const config = NotationConfig(
      useSystemLayout: true,
      padding: EdgeInsets.zero,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 400,
              child: NotationView(grandStaff: _hymn(12), config: config),
            ),
          ),
        ),
      ),
    );
    final layout = GrandStaffLayout.forConfig(_hymn(12), config, 400);
    final size = tester.getSize(find.byType(NotationView));
    expect(size.width, 400);
    expect(
      size.height,
      closeTo(layout.totalHeight + config.staffSpaceSize * 4, 0.01),
    );
  });
}
