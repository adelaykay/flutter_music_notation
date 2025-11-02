// lib/src/geometry/staff_units.dart

/// All measurements in music notation are based on "staff spaces"
/// (the distance between two adjacent staff lines)
///
/// This class provides type-safe measurements that scale consistently
class StaffUnits {
  final double value;

  const StaffUnits(this.value);

  /// Convert to pixels given a staff space size in pixels
  double toPixels(double staffSpaceSize) => value * staffSpaceSize;

  /// Standard spacing constants based on music engraving practice

  // Notehead dimensions
  static const noteheadWidth = StaffUnits(1.3);
  static const noteheadHeight = StaffUnits(1.0);

  // Stem dimensions
  static const stemThickness = StaffUnits(0.12);
  static const stemLength = StaffUnits(3.5);

  // Accidental dimensions
  static const accidentalWidth = StaffUnits(1.0);
  static const accidentalHeight = StaffUnits(2.0);

  // Spacing
  static const minimumNoteSpacing = StaffUnits(2.0);
  static const accidentalPadding = StaffUnits(0.3);
  static const ledgerLineExtension = StaffUnits(0.4); // How far ledger lines extend beyond notehead

  // Line thicknesses
  static const staffLineThickness = StaffUnits(0.1);
  static const ledgerLineThickness = StaffUnits(0.12);
  static const barlineThickness = StaffUnits(0.15);
  static const thickBarlineThickness = StaffUnits(0.5);
  static const beamThickness = StaffUnits(0.5);

  // Clef sizes
  static const trebleClefHeight = StaffUnits(7.0);
  static const bassClefHeight = StaffUnits(4.0);

  // Dots (for dotted notes)
  static const dotRadius = StaffUnits(0.2);
  static const dotSpacing = StaffUnits(0.7); // Space between note and dot

  // Flag dimensions
  static const flagWidth = StaffUnits(1.2);
  static const flagHeight = StaffUnits(2.0);

  /// Arithmetic operators for convenient calculations
  StaffUnits operator +(StaffUnits other) => StaffUnits(value + other.value);
  StaffUnits operator -(StaffUnits other) => StaffUnits(value - other.value);
  StaffUnits operator *(double factor) => StaffUnits(value * factor);
  StaffUnits operator /(double divisor) => StaffUnits(value / divisor);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StaffUnits && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'StaffUnits($value)';
}