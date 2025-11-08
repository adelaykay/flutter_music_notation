// lib/flutter_music_notation.dart

/// A professional music notation rendering library for Flutter
/// with MIDI support and synchronized playback.
library flutter_music_notation;

// Models
export 'src/models/pitch.dart';
export 'src/models/duration.dart';
export 'src/models/note.dart';
export 'src/models/measure.dart';
export 'src/models/time_signature.dart';
export 'src/models/key_signature.dart';
export 'src/models/grand_staff.dart';

// Geometry
export 'src/geometry/staff_position.dart';
export 'src/geometry/staff_units.dart';

// Layout - NEW Phase 4 exports
export 'src/layout/spacing_engine.dart';
export 'src/layout/collision_detector.dart';
export 'src/layout/line_breaker.dart';
export 'src/layout/system_layout.dart';

// Playback
export 'src/playback/playback_controller.dart';

// Widgets
export 'src/widgets/notation_view.dart';

// Rendering (for advanced users)
export 'src/rendering/staff_renderer.dart';
export 'src/rendering/note_renderer.dart';
export 'src/rendering/rest_renderer.dart';
export 'src/rendering/dot_renderer.dart';
export 'src/rendering/flag_renderer.dart';
export 'src/rendering/clef_renderer.dart';
export 'src/rendering/key_signature_renderer.dart';
export 'src/rendering/time_signature_renderer.dart';
export 'src/rendering/barline_renderer.dart';