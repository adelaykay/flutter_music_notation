// lib/src/models/note.dart

import 'pitch.dart';
import 'duration.dart';

/// Represents a single musical note
class Note {
  /// The pitch of the note
  final Pitch pitch;

  /// The duration of the note
  final NoteDuration duration;

  /// Whether to display an accidental for this note
  /// (null means it should be determined by context)
  final bool? forceShowAccidental;

  /// Velocity (loudness) from 0-127 (MIDI convention)
  final int velocity;

  /// The beat position where this note starts
  final double startBeat;

  const Note({
    required this.pitch,
    required this.duration,
    this.forceShowAccidental,
    this.velocity = 64,
    required this.startBeat,
  }) : assert(velocity >= 0 && velocity <= 127, 'Velocity must be 0-127');

  /// The beat position where this note ends
  double get endBeat => startBeat + duration.beats;

  /// Create a copy with modified properties
  Note copyWith({
    Pitch? pitch,
    NoteDuration? duration,
    bool? forceShowAccidental,
    int? velocity,
    double? startBeat,
  }) {
    return Note(
      pitch: pitch ?? this.pitch,
      duration: duration ?? this.duration,
      forceShowAccidental: forceShowAccidental ?? this.forceShowAccidental,
      velocity: velocity ?? this.velocity,
      startBeat: startBeat ?? this.startBeat,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Note &&
              pitch == other.pitch &&
              duration == other.duration &&
              forceShowAccidental == other.forceShowAccidental &&
              velocity == other.velocity &&
              startBeat == other.startBeat;

  @override
  int get hashCode => Object.hash(
    pitch,
    duration,
    forceShowAccidental,
    velocity,
    startBeat,
  );

  @override
  String toString() => 'Note($pitch, ${duration.type.name}, beat: $startBeat)';
}

/// Represents a musical rest
class Rest {
  /// The duration of the rest
  final NoteDuration duration;

  /// The beat position where this rest starts
  final double startBeat;

  const Rest({
    required this.duration,
    required this.startBeat,
  });

  /// The beat position where this rest ends
  double get endBeat => startBeat + duration.beats;

  /// Create a copy with modified properties
  Rest copyWith({
    NoteDuration? duration,
    double? startBeat,
  }) {
    return Rest(
      duration: duration ?? this.duration,
      startBeat: startBeat ?? this.startBeat,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Rest && duration == other.duration && startBeat == other.startBeat;

  @override
  int get hashCode => Object.hash(duration, startBeat);

  @override
  String toString() => 'Rest(${duration.type.name}, beat: $startBeat)';
}

/// Represents a chord (multiple notes played simultaneously)
class Chord {
  /// The notes in the chord (should have same startBeat and duration)
  final List<Note> notes;

  Chord({required this.notes})
      : assert(notes.isNotEmpty, 'Chord must have at least one note') {
    // Verify all notes have same start beat and duration
    final firstBeat = notes.first.startBeat;
    final firstDuration = notes.first.duration;
    for (final note in notes) {
      assert(
      note.startBeat == firstBeat,
      'All notes in chord must have same start beat',
      );
      assert(
      note.duration == firstDuration,
      'All notes in chord must have same duration',
      );
    }
  }

  /// Duration of the chord (same for all notes)
  NoteDuration get duration => notes.first.duration;

  /// Start beat of the chord
  double get startBeat => notes.first.startBeat;

  /// End beat of the chord
  double get endBeat => notes.first.endBeat;

  /// Notes sorted by pitch (lowest to highest)
  List<Note> get sortedNotes => List<Note>.from(notes)
    ..sort((a, b) => a.pitch.midiNumber.compareTo(b.pitch.midiNumber));

  /// The lowest note in the chord
  Note get lowestNote => sortedNotes.first;

  /// The highest note in the chord
  Note get highestNote => sortedNotes.last;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Chord && _listsEqual(notes, other.notes);

  bool _listsEqual(List<Note> a, List<Note> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(notes);

  @override
  String toString() => 'Chord(${notes.map((n) => n.pitch).join(', ')}, beat: $startBeat)';
}