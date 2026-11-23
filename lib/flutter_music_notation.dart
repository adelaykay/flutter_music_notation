// lib/flutter_music_notation.dart

/// A professional music notation rendering library for Flutter
/// with MIDI support and synchronized playback.
library;

// Models
export 'src/models/pitch.dart';
export 'src/models/duration.dart';
export 'src/models/note.dart';
export 'src/models/measure.dart';
export 'src/models/time_signature.dart';
export 'src/models/key_signature.dart';
export 'src/models/grand_staff.dart';
// Phase 6 Models
export 'src/models/beam.dart';
export 'src/models/tie.dart';
export 'src/models/slur.dart';
export 'src/models/tuplet_bracket.dart';

// Geometry
export 'src/geometry/staff_position.dart';
export 'src/geometry/staff_units.dart';
export 'src/geometry/stem_direction.dart';

// Layout - Phase 4 exports
export 'src/layout/spacing_engine.dart';
export 'src/layout/collision_detector.dart';
export 'src/layout/line_breaker.dart';
export 'src/layout/system_layout.dart';
export 'src/layout/grand_staff_layout.dart';
export 'src/layout/system_prefix.dart';

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
// Phase 6 Renderers
export 'src/rendering/beam_renderer.dart';
export 'src/rendering/tie_renderer.dart';
export 'src/rendering/slur_renderer.dart';
export 'src/rendering/tuplet_renderer.dart';
// Midi to Notation
export 'src/midi/midi_note.dart';
export 'src/midi/midi_parser.dart';
export 'src/midi/midi_to_notation.dart';
export 'src/midi/satb_detector.dart';
export 'src/midi/quantizer.dart';
