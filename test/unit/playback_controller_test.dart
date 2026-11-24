import 'package:flutter_music_notation/flutter_music_notation.dart';
import 'package:flutter_test/flutter_test.dart';

/// [bars] bars of the same C-D-E-F quarter notes at 120 bpm, after
/// [silentBars] bars of silence, so every bar holds notes equal to the
/// others'.
MidiData repeatingTune({int bars = 6, int silentBars = 1}) {
  const pattern = [60, 62, 64, 65];
  return MidiData(
    notes: [
      for (var bar = 0; bar < bars; bar++)
        for (var i = 0; i < 4; i++)
          MidiNote(
            midiNumber: pattern[i],
            velocity: 80,
            startTime: (silentBars + bar) * 2000 + i * 500,
            endTime: (silentBars + bar) * 2000 + i * 500 + 480,
          ),
    ],
    ticksPerQuarterNote: 480,
  );
}

Measure bar(int number, List<Note> notes, {TimeSignature? time}) => Measure(
  number: number,
  timeSignature: time ?? TimeSignature.fourFour,
  keySignature: KeySignature.cMajor,
  notes: notes,
);

Note quarter(int midi, double beat) => Note(
  pitch: Pitch.fromMidiNumber(midi),
  duration: const NoteDuration.quarter(),
  startBeat: beat,
);

void main() {
  group('forGrandStaff with converted MIDI', () {
    final converter = MidiToNotation(midiData: repeatingTune());
    final score = converter.toGrandStaff();
    final controller = PlaybackController.forGrandStaff(score);

    test('times notes from the start of the score, bar by bar', () {
      final f = score.upperStaff[4].notes[3];
      expect(controller.startOf(f), 4 * 4 + 3);
      expect(controller.endOf(f), 4 * 4 + 4);
    });

    test('the note playing in a later bar is active, and only that one', () {
      controller.seekTo(4 * 4 + 3.5); // bar 5, fourth beat
      final active = controller.activeNotes;
      expect(active, hasLength(1));
      expect(identical(active.single, score.upperStaff[4].notes[3]), isTrue);
      // Bar 1's F equals bar 5's F but is not playing.
      final firstF = score.upperStaff[0].notes[3];
      expect(firstF, equals(active.single));
      expect(active.contains(firstF), isFalse);
    });

    test('reports the bar being played', () {
      controller.seekTo(0);
      expect(controller.currentMeasureNumber, score.upperStaff[0].number);
      controller.seekTo(4 * 4 + 0.5);
      expect(controller.currentMeasureNumber, score.upperStaff[4].number);
    });

    test('plays to the end of the last bar', () {
      controller.seekTo(1000);
      expect(controller.position, 6 * 4);
    });

    test('droppedLeadingBeats gives the silent bar left out', () {
      expect(converter.droppedLeadingBeats(), 4);
      expect(
        MidiToNotation(
          midiData: repeatingTune(silentBars: 0),
        ).droppedLeadingBeats(),
        0,
      );
    });
  });

  group('forMeasures', () {
    test('bars follow their time signatures', () {
      final measures = [
        bar(0, [quarter(60, 0)], time: TimeSignature.threeFour),
        bar(1, [quarter(62, 0)], time: TimeSignature.threeFour),
        bar(2, [quarter(64, 1)]),
      ];
      final c = PlaybackController.forMeasures(measures);
      expect(c.startOf(measures[1].notes.single), 3);
      expect(c.startOf(measures[2].notes.single), 7);
      expect(c.measureNumberAt(5.9), 1);
      expect(c.measureNumberAt(6), 2);
    });

    test('a pickup bar is as long as pickupBeats', () {
      final measures = [
        bar(0, [quarter(67, 0)]),
        bar(1, [quarter(72, 0)]),
      ];
      final c = PlaybackController.forMeasures(measures, pickupBeats: 1);
      expect(c.startOf(measures[1].notes.single), 1);
      c.seekTo(1.5);
      expect(c.activeNotes.single.pitch.midiNumber, 72);
    });
  });

  group('flat note list (unchanged behaviour)', () {
    test('startBeat counts from the start of the score', () {
      final notes = [quarter(60, 0), quarter(62, 5)];
      final c = PlaybackController(notes: notes);
      c.seekTo(5.5);
      expect(c.activeNotes.single.pitch.midiNumber, 62);
      expect(c.currentMeasureNumber, isNull);
    });

    test('update advances by tempo and stops at the end', () {
      final c = PlaybackController(notes: [quarter(60, 0), quarter(62, 1)])
        ..play();
      c.update(0.75); // 1.5 beats at 120 bpm
      expect(c.position, closeTo(1.5, 1e-9));
      expect(c.activeNotes.single.pitch.midiNumber, 62);
      c.update(10);
      expect(c.position, 2);
      expect(c.isPlaying, isFalse);
    });
  });
}
