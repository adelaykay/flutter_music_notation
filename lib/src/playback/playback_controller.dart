// lib/src/playback/playback_controller.dart

import 'package:flutter/foundation.dart';
import '../models/note.dart';

/// Controls playback state and tracks active notes for visual feedback
class PlaybackController extends ChangeNotifier {
  /// All notes in the score
  final List<Note> notes;

  /// Current playback position in beats
  double _position = 0.0;

  /// Whether playback is active
  bool _isPlaying = false;

  /// Notes currently being played
  final Set<Note> _activeNotes = {};

  /// Playback speed multiplier (1.0 = normal speed)
  double _speed = 1.0;

  /// Beats per minute (tempo)
  final double beatsPerMinute;

  PlaybackController({
    required this.notes,
    this.beatsPerMinute = 120.0,
  });

  // Getters
  double get position => _position;
  bool get isPlaying => _isPlaying;
  Set<Note> get activeNotes => Set.unmodifiable(_activeNotes);
  double get speed => _speed;

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
    final tolerance = 0.1; // 0.1 beat tolerance

    for (final note in notes) {
      if (note.pitch.midiNumber == midiNumber &&
          (note.startBeat - _position).abs() < tolerance) {
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
    _activeNotes.clear();

    for (final note in notes) {
      if (note.startBeat <= _position && note.endBeat > _position) {
        _activeNotes.add(note);
      }
    }
  }

  /// Get the last beat in the score
  double _getLastBeat() {
    if (notes.isEmpty) return 0.0;
    return notes.map((n) => n.endBeat).reduce((a, b) => a > b ? a : b);
  }

  /// Get notes at a specific beat position
  List<Note> getNotesAtBeat(double beat, {double tolerance = 0.01}) {
    return notes
        .where((note) => note.startBeat <= beat && note.endBeat > beat)
        .toList();
  }

  @override
  void dispose() {
    _activeNotes.clear();
    super.dispose();
  }
}