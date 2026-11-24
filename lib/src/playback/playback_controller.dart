// lib/src/playback/playback_controller.dart

import 'dart:collection';

import 'package:flutter/foundation.dart';
import '../models/grand_staff.dart';
import '../models/measure.dart';
import '../models/note.dart';

/// Controls playback state and tracks active notes for visual feedback.
///
/// Positions are in quarter-note beats from the start of the score.
///
/// Notes are tracked by identity, not by value: two bars can hold notes that
/// compare equal (same pitch, length and beat in the bar), and only the one
/// being played is active.
class PlaybackController extends ChangeNotifier {
  /// All notes in the score
  final List<Note> notes;

  /// Beats per minute (tempo)
  final double beatsPerMinute;

  /// Each note's start, in beats from the start of the score.
  final Map<Note, double> _starts;

  /// Each bar's start, in beats from the start of the score, with its
  /// [Measure.number]. Empty when built from a flat note list.
  final List<(double start, double end, int number)> _bars;

  /// Current playback position in beats
  double _position = 0.0;

  /// Whether playback is active
  bool _isPlaying = false;

  /// Notes currently being played
  final Set<Note> _activeNotes = HashSet<Note>.identity();

  /// Playback speed multiplier (1.0 = normal speed)
  double _speed = 1.0;

  /// A controller for [notes] whose [Note.startBeat] counts from the start of
  /// the score.
  ///
  /// Notes in a [Measure] (including everything [MidiToNotation] produces)
  /// count from the start of their bar; use [PlaybackController.forMeasures]
  /// or [PlaybackController.forGrandStaff] for those.
  PlaybackController({required this.notes, this.beatsPerMinute = 120.0})
    : _starts = _identityMap({for (final n in notes) n: n.startBeat}),
      _bars = const [];

  /// A controller for a single staff of [measures].
  ///
  /// Bars follow one another, each as long as its time signature, except
  /// the first when [pickupBeats] gives the length of a pickup (anacrusis).
  /// A pickup's notes count from the start of the short bar.
  factory PlaybackController.forMeasures(
    List<Measure> measures, {
    double beatsPerMinute = 120.0,
    double? pickupBeats,
  }) => PlaybackController._timed(
    [measures],
    beatsPerMinute: beatsPerMinute,
    pickupBeats: pickupBeats,
  );

  /// A controller for both staves of [grandStaff], timed bar by bar as in
  /// [PlaybackController.forMeasures].
  factory PlaybackController.forGrandStaff(
    GrandStaff grandStaff, {
    double beatsPerMinute = 120.0,
    double? pickupBeats,
  }) => PlaybackController._timed(
    [grandStaff.upperStaff, grandStaff.lowerStaff],
    beatsPerMinute: beatsPerMinute,
    pickupBeats: pickupBeats,
  );

  PlaybackController._internal({
    required this.notes,
    required this.beatsPerMinute,
    required Map<Note, double> starts,
    required List<(double, double, int)> bars,
  }) : _starts = starts,
       _bars = bars;

  factory PlaybackController._timed(
    List<List<Measure>> staves, {
    required double beatsPerMinute,
    double? pickupBeats,
  }) {
    final count = staves.fold(0, (m, s) => s.length > m ? s.length : m);
    final notes = <Note>[];
    final starts = _identityMap(<Note, double>{});
    final bars = <(double, double, int)>[];
    var offset = 0.0;
    for (var i = 0; i < count; i++) {
      final measure = staves.firstWhere((s) => i < s.length)[i];
      final length = i == 0 && pickupBeats != null
          ? pickupBeats
          : measure.timeSignature.beatsPerMeasure;
      bars.add((offset, offset + length, measure.number));
      for (final staff in staves) {
        if (i >= staff.length) continue;
        for (final note in staff[i].notes) {
          notes.add(note);
          starts[note] = offset + note.startBeat;
        }
      }
      offset += length;
    }
    return PlaybackController._internal(
      notes: notes,
      beatsPerMinute: beatsPerMinute,
      starts: starts,
      bars: bars,
    );
  }

  static Map<Note, double> _identityMap(Map<Note, double> from) =>
      LinkedHashMap<Note, double>.identity()..addAll(from);

  // Getters
  double get position => _position;
  bool get isPlaying => _isPlaying;

  /// The notes sounding at [position]. Compare with `contains`, which here
  /// matches by identity.
  Set<Note> get activeNotes =>
      UnmodifiableSetView(HashSet<Note>.identity()..addAll(_activeNotes));
  double get speed => _speed;

  /// The [Measure.number] of the bar at [position], e.g. for
  /// [NotationConfig.highlightedMeasure]. Null for a controller built from a
  /// flat note list.
  int? get currentMeasureNumber => measureNumberAt(_position);

  /// The [Measure.number] of the bar at [beat], or null for a controller
  /// built from a flat note list.
  int? measureNumberAt(double beat) {
    if (_bars.isEmpty) return null;
    for (final (start, end, number) in _bars) {
      if (beat < end) return beat < start ? _bars.first.$3 : number;
    }
    return _bars.last.$3;
  }

  /// Where [note] starts, in beats from the start of the score.
  double startOf(Note note) => _starts[note] ?? note.startBeat;

  /// Where [note] ends, in beats from the start of the score.
  double endOf(Note note) => startOf(note) + note.duration.beats;

  /// Start playback from current position
  void play() {
    _isPlaying = true;
    notifyListeners();
  }

  /// Pause playback
  void pause() {
    _isPlaying = false;
    notifyListeners();
  }

  /// Stop playback and return to start
  void stop() {
    _isPlaying = false;
    _position = 0.0;
    _activeNotes.clear();
    notifyListeners();
  }

  /// Seek to a specific beat position
  void seekTo(double beat) {
    _position = beat.clamp(0.0, _getLastBeat());
    _updateActiveNotes();
    notifyListeners();
  }

  /// Set playback speed (0.5 = half speed, 2.0 = double speed)
  void setSpeed(double speed) {
    _speed = speed.clamp(0.1, 4.0);
    notifyListeners();
  }

  /// Update playback position (called every frame during playback)
  /// deltaTime is in seconds
  void update(double deltaTime) {
    if (!_isPlaying) return;

    // Convert delta time to beats
    final beatsPerSecond = beatsPerMinute / 60.0;
    final deltaBeats = deltaTime * beatsPerSecond * _speed;

    _position += deltaBeats;

    // Stop at end
    final lastBeat = _getLastBeat();
    if (_position >= lastBeat) {
      _position = lastBeat;
      _isPlaying = false;
    }

    _updateActiveNotes();
    notifyListeners();
  }

  /// Called when external MIDI player triggers note on
  void onNoteOn(int midiNumber, int velocity) {
    // Find and activate notes with this MIDI number at current position
    const tolerance = 0.1; // 0.1 beat tolerance

    for (final note in notes) {
      if (note.pitch.midiNumber == midiNumber &&
          (startOf(note) - _position).abs() < tolerance) {
        _activeNotes.add(note);
      }
    }

    notifyListeners();
  }

  /// Called when external MIDI player triggers note off
  void onNoteOff(int midiNumber) {
    _activeNotes.removeWhere((note) => note.pitch.midiNumber == midiNumber);
    notifyListeners();
  }

  /// Update which notes should be highlighted based on current position
  void _updateActiveNotes() {
    _activeNotes
      ..clear()
      ..addAll(getNotesAtBeat(_position));
  }

  /// Get the last beat in the score
  double _getLastBeat() {
    var last = _bars.isEmpty ? 0.0 : _bars.last.$2;
    for (final note in notes) {
      final end = endOf(note);
      if (end > last) last = end;
    }
    return last;
  }

  /// Get notes sounding at a specific beat position (from the start of the
  /// score).
  List<Note> getNotesAtBeat(double beat, {double tolerance = 0.01}) {
    return notes
        .where((note) => startOf(note) <= beat && endOf(note) > beat)
        .toList();
  }

  @override
  void dispose() {
    _activeNotes.clear();
    super.dispose();
  }
}
