// lib/src/models/time_signature.dart

/// Represents a musical time signature
class TimeSignature {
  /// Number of beats per measure (numerator)
  final int beats;

  /// Note value that gets one beat (denominator)
  /// 2 = half note, 4 = quarter note, 8 = eighth note, etc.
  final int beatUnit;

  const TimeSignature({
    required this.beats,
    required this.beatUnit,
  }) : assert(beats > 0, 'Beats must be positive'),
        assert(beatUnit == 1 || beatUnit == 2 || beatUnit == 4 ||
            beatUnit == 8 || beatUnit == 16 || beatUnit == 32,
        'Beat unit must be 1, 2, 4, 8, 16, or 32');

  /// Common time signatures
  static const fourFour = TimeSignature(beats: 4, beatUnit: 4);
  static const threeFour = TimeSignature(beats: 3, beatUnit: 4);
  static const twoFour = TimeSignature(beats: 2, beatUnit: 4);
  static const sixEight = TimeSignature(beats: 6, beatUnit: 8);
  static const threeEight = TimeSignature(beats: 3, beatUnit: 8);
  static const twelveEight = TimeSignature(beats: 12, beatUnit: 8);
  static const twoTwo = TimeSignature(beats: 2, beatUnit: 2);

  /// Get beats per measure in quarter note units
  /// (for consistent beat counting across different time signatures)
  double get beatsPerMeasure {
    return (beats * 4.0) / beatUnit;
  }

  /// Whether this is a compound time signature (beats divisible by 3, except 3)
  bool get isCompound {
    return beats > 3 && beats % 3 == 0;
  }

  /// Whether this is a simple time signature
  bool get isSimple => !isCompound;

  /// Display as common time symbol (C) for 4/4
  bool get isCommonTime => beats == 4 && beatUnit == 4;

  /// Display as cut time symbol (¢) for 2/2
  bool get isCutTime => beats == 2 && beatUnit == 2;

  @override
  String toString() => '$beats/$beatUnit';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TimeSignature &&
              beats == other.beats &&
              beatUnit == other.beatUnit;

  @override
  int get hashCode => Object.hash(beats, beatUnit);
}