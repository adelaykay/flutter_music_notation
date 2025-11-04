// lib/flutter_music_notation.dart

/// A professional music notation rendering library for Flutter
/// with MIDI support and synchronized playback.
library flutter_music_notation;

// Models
export 'src/models/pitch.dart';
export 'src/models/duration.dart';
export 'src/models/note.dart';

// Geometry
export 'src/geometry/staff_position.dart';
export 'src/geometry/staff_units.dart';

// Playback
export 'src/playback/playback_controller.dart';

// Widgets
export 'src/widgets/notation_view.dart';

// Rendering (for advanced users)
export 'src/rendering/staff_renderer.dart';
export 'src/rendering/note_renderer.dart';
export 'src/rendering/rest_renderer.dart';
export 'src/rendering/dot_renderer.dart';