// lib/src/models/duration.dart

/// Represents the type of note duration
enum DurationType {
  maxima(8.0),         // 8 whole notes
  long(4.0),           // 4 whole notes (rarely used)
  breve(2.0),          // 2 whole notes (double whole note)
  whole(1.0),          // Whole note (semibreve)
  half(0.5),           // Half note (minim)
  quarter(0.25),       // Quarter note (crotchet)
  eighth(0.125),       // Eighth note (quaver)
  sixteenth(0.0625),   // Sixteenth note (semiquaver)
  thirtySecond(0.03125), // 32nd note (demisemiquaver)
  sixtyFourth(0.015625); // 64th note (hemidemisemiquaver)

  const DurationType(this.baseBeats);

  /// Duration in whole notes (1.0 = whole note)
  final double baseBeats;

  /// Whether this duration needs a stem
  bool get needsStem => this != DurationType.whole && this != DurationType.breve;

  /// Whether this duration needs flags (if not beamed)
  bool get needsFlag => index >= DurationType.eighth.index;

  /// How many flags this duration needs
  int get flagCount {
    switch (this) {
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

  /// Whether the notehead should be filled (black)
  bool get isFilledNotehead => index >= DurationType.quarter.index;

  /// Get the next shorter duration (e.g., quarter -> eighth)
  DurationType? get shorter {
    final nextIndex = index + 1;
    if (nextIndex < DurationType.values.length) {
      return DurationType.values[nextIndex];
    }
    return null;
  }

  /// Get the next longer duration (e.g., quarter -> half)
  DurationType? get longer {
    final prevIndex = index - 1;
    if (prevIndex >= 0) {
      return DurationType.values[prevIndex];
    }
    return null;
  }
}

/// Represents a tuplet (e.g., triplet, quintuplet)
class Tuplet {
  /// Number of notes actually played (e.g., 3 in a triplet)
  final int actualNotes;

  /// Number of notes that would normally occupy the space (e.g., 2 in a triplet)
  final int normalNotes;

  const Tuplet({
    required this.actualNotes,
    required this.normalNotes,
  }) : assert(actualNotes > 0 && normalNotes > 0, 'Tuplet values must be positive');

  /// Common tuplet: triplet (3 in the time of 2)
  static const triplet = Tuplet(actualNotes: 3, normalNotes: 2);

  /// Quintuplet (5 in the time of 4)
  static const quintuplet = Tuplet(actualNotes: 5, normalNotes: 4);

  /// Sextuplet (6 in the time of 4)
  static const sextuplet = Tuplet(actualNotes: 6, normalNotes: 4);

  /// The ratio by which to multiply the duration
  double get ratio => normalNotes / actualNotes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Tuplet &&
              actualNotes == other.actualNotes &&
              normalNotes == other.normalNotes;

  @override
  int get hashCode => Object.hash(actualNotes, normalNotes);

  @override
  String toString() => '$actualNotes:$normalNotes';
}

/// Represents a musical duration with type, dots, and optional tuplet
class NoteDuration {
  /// The base duration type
  final DurationType type;

  /// Number of dots (0, 1, or 2)
  final int dots;

  /// Optional tuplet modification
  final Tuplet? tuplet;

  const NoteDuration({
    required this.type,
    this.dots = 0,
    this.tuplet,
  }) : assert(dots >= 0 && dots <= 2, 'Dots must be 0, 1, or 2');

  /// Common durations (convenience constructors)
  const NoteDuration.whole() : type = DurationType.whole, dots = 0, tuplet = null;
  const NoteDuration.half() : type = DurationType.half, dots = 0, tuplet = null;
  const NoteDuration.quarter() : type = DurationType.quarter, dots = 0, tuplet = null;
  const NoteDuration.eighth() : type = DurationType.eighth, dots = 0, tuplet = null;
  const NoteDuration.sixteenth() : type = DurationType.sixteenth, dots = 0, tuplet = null;

  /// Dotted durations
  const NoteDuration.dottedHalf() : type = DurationType.half, dots = 1, tuplet = null;
  const NoteDuration.dottedQuarter() : type = DurationType.quarter, dots = 1, tuplet = null;
  const NoteDuration.dottedEighth() : type = DurationType.eighth, dots = 1, tuplet = null;

  /// Calculate total duration in quarter notes
  /// A quarter note = 1.0
  double get beats {
    // Start with base duration converted to quarter notes
    double totalBeats = type.baseBeats * 4.0;

    // Add dots (each dot adds half of the previous value)
    double dotValue = totalBeats / 2;
    for (int i = 0; i < dots; i++) {
      totalBeats += dotValue;
      dotValue /= 2;
    }

    // Apply tuplet ratio if present
    if (tuplet != null) {
      totalBeats *= tuplet!.ratio;
    }

    return totalBeats;
  }

  /// Whether this duration needs a stem
  bool get needsStem => type.needsStem;

  /// Whether this duration needs flags (if not beamed)
  bool get needsFlag => type.needsFlag;

  /// Number of flags needed
  int get flagCount => type.flagCount;

  /// Whether the notehead should be filled
  bool get isFilledNotehead => type.isFilledNotehead;

  /// Create a copy with modified properties
  NoteDuration copyWith({
    DurationType? type,
    int? dots,
    Tuplet? tuplet,
  }) {
    return NoteDuration(
      type: type ?? this.type,
      dots: dots ?? this.dots,
      tuplet: tuplet ?? this.tuplet,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NoteDuration &&
              type == other.type &&
              dots == other.dots &&
              tuplet == other.tuplet;

  @override
  int get hashCode => Object.hash(type, dots, tuplet);

  @override
  String toString() {
    final buffer = StringBuffer(type.name);
    if (dots > 0) buffer.write(' ($dots dot${dots > 1 ? 's' : ''})');
    if (tuplet != null) buffer.write(' tuplet: $tuplet');
    return buffer.toString();
  }
}