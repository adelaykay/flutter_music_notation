// lib/src/geometry/stem_direction.dart

/// Direction of a note stem
enum StemDirection {
  up, // Stem points upward
  down, // Stem points downward
  none, // No stem (whole notes)
  auto, // Automatic determination based on pitch
}
