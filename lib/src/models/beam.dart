// lib/src/models/beam.dart

import 'note.dart';
import 'duration.dart';

/// Represents a beam connecting multiple notes
/// Beams group eighth notes and shorter together
class Beam {
  /// Notes connected by this beam (must be eighth notes or shorter)
  final List<Note> notes;

  /// Whether this is a primary beam (all notes share this)
  /// or a secondary beam (only some notes share this)
  final BeamType type;

  /// For partial beams (fractional beaming)
  /// Which notes in the beam have this level
  final List<int>? noteIndices;

  const Beam({
    required this.notes,
    this.type = BeamType.primary,
    this.noteIndices,
  }) : assert(notes.length >= 2, 'Beam must connect at least 2 notes');

  /// Whether all notes in this beam have the same duration
  bool get hasUniformDuration {
    if (notes.isEmpty) return true;
    final firstDuration = notes.first.duration.type;
    return notes.every((note) => note.duration.type == firstDuration);
  }

  /// Shortest note duration in the beam
  DurationType get shortestDuration {
    return notes
        .map((n) => n.duration.type)
        .reduce((a, b) => a.index > b.index ? a : b);
  }

  /// Number of beam lines needed
  /// Eighth notes = 1 beam, sixteenth = 2 beams, etc.
  int get beamCount {
    switch (shortestDuration) {
      case DurationType.eighth:
        return 1;
      case DurationType.sixteenth:
        return 2;
      case DurationType.thirtySecond:
        return 3;
      case DurationType.sixtyFourth:
        return 4;
      default:
        return 0;
    }
  }

  /// Start beat of the beam (earliest note)
  double get startBeat {
    return notes.map((n) => n.startBeat).reduce((a, b) => a < b ? a : b);
  }

  /// End beat of the beam (latest note end)
  double get endBeat {
    return notes.map((n) => n.endBeat).reduce((a, b) => a > b ? a : b);
  }

  /// Duration span of the beam
  double get duration => endBeat - startBeat;

  /// Validate that all notes can be beamed together
  bool isValid() {
    // All notes must be eighth notes or shorter
    if (!notes.every((n) => n.duration.needsFlag)) {
      return false;
    }

    // Notes should be reasonably close together (within 2 beats)
    if (duration > 2.0) {
      return false;
    }

    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Beam &&
              _listEquals(notes, other.notes) &&
              type == other.type;

  bool _listEquals(List<Note> a, List<Note> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(notes), type);

  @override
  String toString() =>
      'Beam(${notes.length} notes, ${beamCount} beams, beats: $startBeat-$endBeat)';
}

/// Type of beam
enum BeamType {
  /// Primary beam (connects all notes)
  primary,

  /// Secondary beam (connects some notes)
  secondary,

  /// Tertiary beam (for 32nd notes and shorter)
  tertiary,

  /// Quaternary beam (for 64th notes)
  quaternary,
}

/// Represents a beam group (collection of beams for a set of notes)
class BeamGroup {
  /// All beams in this group
  final List<Beam> beams;

  /// The notes being beamed
  final List<Note> notes;

  const BeamGroup({
    required this.beams,
    required this.notes,
  });

  /// Primary beam (always exists)
  Beam get primaryBeam => beams.first;

  /// Secondary beams (if any)
  List<Beam> get secondaryBeams =>
      beams.where((b) => b.type == BeamType.secondary).toList();

  /// Whether this beam group uses fractional beaming
  bool get hasFractionalBeams =>
      beams.any((b) => b.noteIndices != null && b.noteIndices!.length < notes.length);

  @override
  String toString() => 'BeamGroup(${notes.length} notes, ${beams.length} beams)';
}

/// Helper class to calculate beam groupings based on time signature
class BeamGroupCalculator {
  /// Calculate how notes should be beamed based on beat structure
  static List<BeamGroup> calculateBeamGroups(
      List<Note> notes,
      int beatsPerMeasure,
      int beatUnit,
      ) {
    final beamGroups = <BeamGroup>[];

    // Filter only notes that need beaming (eighth and shorter)
    final beamableNotes = notes
        .where((n) => n.duration.needsFlag)
        .toList()
      ..sort((a, b) => a.startBeat.compareTo(b.startBeat));

    if (beamableNotes.isEmpty) return beamGroups;

    // Group notes by beat
    final beatGroups = <int, List<Note>>{};
    for (final note in beamableNotes) {
      final beat = note.startBeat.floor();
      beatGroups.putIfAbsent(beat, () => []).add(note);
    }

    // Create beam groups for each beat
    for (final beat in beatGroups.keys.toList()..sort()) {
      final notesInBeat = beatGroups[beat]!;

      if (notesInBeat.length >= 2) {
        // Create primary beam
        final primaryBeam = Beam(
          notes: notesInBeat,
          type: BeamType.primary,
        );

        // Create secondary beams if needed
        final secondaryBeams = _createSecondaryBeams(notesInBeat);

        beamGroups.add(BeamGroup(
          beams: [primaryBeam, ...secondaryBeams],
          notes: notesInBeat,
        ));
      }
    }

    return beamGroups;
  }

  /// Create secondary beams for sixteenth notes and shorter
  static List<Beam> _createSecondaryBeams(List<Note> notes) {
    final secondaryBeams = <Beam>[];

    // Check if we need secondary beams (sixteenth notes or shorter)
    final needsSecondary = notes.any(
          (n) => n.duration.type.index >= DurationType.sixteenth.index,
    );

    if (!needsSecondary) return secondaryBeams;

    // Group consecutive sixteenth notes (or shorter)
    List<Note> currentGroup = [];

    for (final note in notes) {
      if (note.duration.type.index >= DurationType.sixteenth.index) {
        currentGroup.add(note);
      } else {
        if (currentGroup.length >= 2) {
          secondaryBeams.add(Beam(
            notes: List.from(currentGroup),
            type: BeamType.secondary,
          ));
        }
        currentGroup = [];
      }
    }

    // Add final group if exists
    if (currentGroup.length >= 2) {
      secondaryBeams.add(Beam(
        notes: currentGroup,
        type: BeamType.secondary,
      ));
    }

    return secondaryBeams;
  }

  /// Calculate beam slope based on note positions
  /// Returns angle in radians
  static double calculateBeamSlope(
      List<Note> notes,
      List<double> yPositions,
      ) {
    if (notes.length < 2) return 0.0;

    // Use first and last note for slope calculation
    final firstY = yPositions.first;
    final lastY = yPositions.last;
    final firstX = 0.0;
    final lastX = notes.length - 1.0;

    // Calculate slope
    final slope = (lastY - firstY) / (lastX - firstX);

    // Limit slope to reasonable angles (-15 to +15 degrees)
    const maxSlope = 0.2679; // tan(15 degrees)
    return slope.clamp(-maxSlope, maxSlope);
  }
}