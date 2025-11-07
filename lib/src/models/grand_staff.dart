// lib/src/models/grand_staff.dart

import 'measure.dart';
import 'time_signature.dart';
import 'key_signature.dart';

/// Represents a grand staff (two staves connected, typically for piano)
class GrandStaff {
  /// Measures for the upper staff (typically treble clef)
  final List<Measure> upperStaff;

  /// Measures for the lower staff (typically bass clef)
  final List<Measure> lowerStaff;

  /// Optional name/label for the staff (e.g., "Piano", "Keyboard")
  final String? instrumentName;

  /// Optional abbreviated name for subsequent systems
  final String? instrumentAbbreviation;

  const GrandStaff({
    required this.upperStaff,
    required this.lowerStaff,
    this.instrumentName,
    this.instrumentAbbreviation,
  }) : assert(
  upperStaff.length == lowerStaff.length,
  'Upper and lower staves must have the same number of measures',
  );

  /// Number of measures in the grand staff
  int get measureCount => upperStaff.length;

  /// Whether this grand staff is empty
  bool get isEmpty => upperStaff.isEmpty && lowerStaff.isEmpty;

  /// Get upper and lower measures at a specific index
  GrandStaffMeasurePair getMeasurePair(int index) {
    assert(index >= 0 && index < measureCount, 'Index out of bounds');
    return GrandStaffMeasurePair(
      upper: upperStaff[index],
      lower: lowerStaff[index],
    );
  }

  /// Get all measure pairs
  List<GrandStaffMeasurePair> get measurePairs {
    return List.generate(
      measureCount,
          (index) => GrandStaffMeasurePair(
        upper: upperStaff[index],
        lower: lowerStaff[index],
      ),
    );
  }

  /// Validate that time signatures match across both staves
  bool validateTimeSignatures() {
    for (int i = 0; i < measureCount; i++) {
      if (upperStaff[i].timeSignature != lowerStaff[i].timeSignature) {
        return false;
      }
    }
    return true;
  }

  /// Validate that key signatures match across both staves
  /// (They can differ, but this checks if they do)
  bool keySignaturesMatch() {
    for (int i = 0; i < measureCount; i++) {
      if (upperStaff[i].keySignature != lowerStaff[i].keySignature) {
        return false;
      }
    }
    return true;
  }

  /// Create a copy with modified properties
  GrandStaff copyWith({
    List<Measure>? upperStaff,
    List<Measure>? lowerStaff,
    String? instrumentName,
    String? instrumentAbbreviation,
  }) {
    return GrandStaff(
      upperStaff: upperStaff ?? this.upperStaff,
      lowerStaff: lowerStaff ?? this.lowerStaff,
      instrumentName: instrumentName ?? this.instrumentName,
      instrumentAbbreviation: instrumentAbbreviation ?? this.instrumentAbbreviation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GrandStaff &&
              _listEquals(upperStaff, other.upperStaff) &&
              _listEquals(lowerStaff, other.lowerStaff) &&
              instrumentName == other.instrumentName &&
              instrumentAbbreviation == other.instrumentAbbreviation;

  bool _listEquals(List<Measure> a, List<Measure> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(upperStaff),
    Object.hashAll(lowerStaff),
    instrumentName,
    instrumentAbbreviation,
  );

  @override
  String toString() =>
      'GrandStaff(measures: $measureCount, instrument: ${instrumentName ?? "Piano"})';
}

/// Represents a pair of measures (upper and lower) at the same time position
class GrandStaffMeasurePair {
  final Measure upper;
  final Measure lower;

  GrandStaffMeasurePair({
    required this.upper,
    required this.lower,
  }) : assert(
  upper.number == lower.number,
  'Upper and lower measures must have the same measure number',
  );

  /// Measure number (same for both)
  int get measureNumber => upper.number;

  /// Time signature (should be the same for both)
  TimeSignature get timeSignature => upper.timeSignature;

  /// Whether time signatures match
  bool get timeSignaturesMatch => upper.timeSignature == lower.timeSignature;

  /// Whether key signatures match
  bool get keySignaturesMatch => upper.keySignature == lower.keySignature;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GrandStaffMeasurePair &&
              upper == other.upper &&
              lower == other.lower;

  @override
  int get hashCode => Object.hash(upper, lower);

  @override
  String toString() => 'GrandStaffMeasurePair(measure: $measureNumber)';
}

/// Factory methods for creating common grand staff configurations
class GrandStaffFactory {
  /// Create a grand staff for piano with matching key signatures
  static GrandStaff createPiano({
    required List<Measure> upperMeasures,
    required List<Measure> lowerMeasures,
  }) {
    return GrandStaff(
      upperStaff: upperMeasures,
      lowerStaff: lowerMeasures,
      instrumentName: 'Piano',
      instrumentAbbreviation: 'Pno.',
    );
  }

  /// Create an empty grand staff with the given number of measures
  static GrandStaff createEmpty({
    required int measureCount,
    required TimeSignature timeSignature,
    required KeySignature keySignature,
  }) {
    final upperMeasures = List.generate(
      measureCount,
          (index) => Measure(
        number: index,
        timeSignature: timeSignature,
        keySignature: keySignature,
        notes: const [],
        rests: const [],
        endBarline: index == measureCount - 1 ? BarlineType.final_ : BarlineType.single,
      ),
    );

    final lowerMeasures = List.generate(
      measureCount,
          (index) => Measure(
        number: index,
        timeSignature: timeSignature,
        keySignature: keySignature,
        notes: const [],
        rests: const [],
        endBarline: index == measureCount - 1 ? BarlineType.final_ : BarlineType.single,
      ),
    );

    return GrandStaff(
      upperStaff: upperMeasures,
      lowerStaff: lowerMeasures,
      instrumentName: 'Piano',
    );
  }

  /// Create a grand staff from a single melody line, splitting notes by register
  /// Notes above middle C go to treble, below go to bass
  static GrandStaff fromMelody({
    required List<Measure> measures,
    int splitPoint = 60, // Middle C (MIDI 60)
  }) {
    final upperMeasures = <Measure>[];
    final lowerMeasures = <Measure>[];

    for (final measure in measures) {
      // Split notes by pitch
      final upperNotes = measure.notes
          .where((note) => note.pitch.midiNumber >= splitPoint)
          .toList();
      final lowerNotes = measure.notes
          .where((note) => note.pitch.midiNumber < splitPoint)
          .toList();

      upperMeasures.add(measure.copyWith(notes: upperNotes));
      lowerMeasures.add(measure.copyWith(notes: lowerNotes));
    }

    return GrandStaff(
      upperStaff: upperMeasures,
      lowerStaff: lowerMeasures,
    );
  }
}