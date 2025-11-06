# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-11-06

### Added
- **Phase 4: Layout & Spacing Engine**
  - **SpacingEngine** for intelligent proportional spacing
    - Logarithmic scaling for natural visual distribution
    - Configurable minimum and maximum spacing
    - Automatically assigns more space to longer note values
  - **SpacingPresets**: `tight`, `normal`, `loose`, and `uniform` presets for flexible layout control
  - **CollisionDetector** for element overlap management
    - Detects accidental and notehead collisions
    - Calculates optimal horizontal offsets for chords and seconds
    - Determines optimal stem direction based on spacing and context
  - **MeasureSpacing** and **LineSpacing** models for layout computation
  - **NotationConfig** now supports proportional spacing mode (enabled by default)
  - **NotationPainter** integrates with the spacing engine for automatic layout adjustment
  - Backward compatibility maintained with `uniform` mode for simpler rendering

### Changed
- **NotationView** now defaults to proportional spacing mode for more natural rendering
- Improved alignment between clef, key signature, and time signature within measures
- Optimized rendering pipeline for smoother performance on complex scores

### Fixed
- Minor ledger line alignment issues on high and low notes
- Rest positioning refined for multi-measure layouts

## [0.1.0] - 2025-11-04
### Added
- **Phase 0-1: Foundation** (Complete)
  - Pitch model with MIDI conversion
  - Duration model with dots and tuplets support
  - Note and Rest models
  - Chord model for simultaneous notes
  - StaffPosition calculations for treble, bass, alto, and tenor clefs
  - StaffUnits for proportional measurements
  - Basic StaffRenderer for drawing staff lines and ledger lines
  - Comprehensive documentation and implementation plan

- **Phase 2: Core Rendering & Playback** (Complete)
  - PlaybackController for managing playback state and tracking active notes
  - NoteheadRenderer for filled and hollow noteheads with proper rotation
  - StemRenderer with automatic direction calculation
  - AccidentalRenderer using SMuFL glyphs (♯, ♭, ♮, 𝄪, 𝄫)
  - GlyphProvider for Bravura font music symbols
  - NotationView widget for displaying interactive notation
  - NotationPainter for efficient rendering
  - Real-time note highlighting during playback
  - Chord rendering with proper stem placement
  - Support for treble and bass clefs
  - Ledger lines for notes outside staff range

- **Phase 3: Essential Notation Elements** (Complete)
  - Week 6: Rests and Dots
    - RestRenderer with proper SMuFL rest symbols
    - DotRenderer for augmentation dots (dotted notes)
    - Rest positioning based on duration type
    - Dot positioning that avoids staff lines
    - Support for single and double dots

  - Week 7: Flags
    - FlagRenderer for eighth, sixteenth, thirty-second, and sixty-fourth notes
    - SMuFL flag glyphs with proper direction (up/down)
    - Fallback path-based flag rendering
    - Automatic flag attachment to stem ends
    - Multiple flags for shorter durations

  - Week 8-9: Measures and Barlines
    - **Measure model** for complete musical measures
    - **TimeSignature model** with common time signatures (4/4, 3/4, 6/8, etc.)
    - **KeySignature model** for all 15 major/minor keys (-7 to +7 accidentals)
    - **BarlineRenderer** for all barline types (single, double, final, repeat start/end, dashed)
    - **ClefRenderer** for treble, bass, alto, and tenor clefs using SMuFL glyphs
    - **KeySignatureRenderer** with proper sharp/flat positioning for all clefs
    - **TimeSignatureRenderer** with number stacks and common/cut time symbols
    - **Complete measure layout** with clef, key signature, and time signature
    - **Intelligent accidental display** based on key signature context
    - **Multi-measure rendering** with proper spacing
    - Updated NotationView to accept both measures (new) and notes (legacy)
    - Updated NotationPainter to render complete measures with all elements

- **Phase 4: Layout & Spacing Engine** (In Progress)
  - Week 10: Proportional Spacing (Complete)
    - **SpacingEngine** with intelligent proportional spacing algorithm
      - Logarithmic scaling for natural-looking distribution
      - Longer notes automatically get more horizontal space
      - Prevents extreme spacing differences
      - Configurable min/max spacing constraints
    - **SpacingPresets** (tight, normal, loose, uniform)
    - **CollisionDetector** for detecting and resolving element collisions
      - Accidental collision detection and stacking
      - Chord notehead offset calculation for seconds
      - Optimal stem direction calculation
      - Minimum spacing calculation
    - **MeasureSpacing** and **LineSpacing** classes for layout information
    - Integration with NotationPainter for automatic proportional spacing
    - NotationConfig extended with spacing engine options
    - Backward compatible with uniform spacing mode

  - Week 11: Multi-Measure Layout (Next)
    - Line breaking algorithm
    - System layout
    - Justified spacing across lines

  - Week 12: Performance Optimization (Planned)
    - Viewport culling
    - Caching optimizations
    - Performance profiling

### Changed
- NotationView now supports both `List<Measure>` (preferred) and `List<Note>` (legacy) modes
- NotationPainter intelligently handles measure-based vs note-based rendering
- Key signature accidentals are only shown when notes differ from the key
- **Spacing is now proportional by default** (can revert to uniform with SpacingPresets.uniform)

### Deprecated
- None yet

### Removed
- None yet

### Fixed
- None yet

### Security
- None yet

## Roadmap

### Phase 4: Layout & Spacing Engine
- Proportional spacing algorithm
- Collision detection for accidentals
- Multi-measure layout with line breaks
- Viewport culling for performance

### Phase 5: Grand Staff
- Two-staff piano notation
- Brace rendering
- Synchronized measures across staves

### Phase 6: Advanced Features
- Beaming for eighth notes and shorter
- Ties and slurs
- Tuplets (triplets, quintuplets, etc.)

### Phase 7: MIDI Integration
- Complete MIDI file parser
- Quantization and voice separation
- Full MIDI-to-notation conversion

### Phase 8: Polish & Beta Release
- Comprehensive documentation
- 80%+ test coverage
- pub.dev beta release

[Unreleased]: https://github.com/adelaykay/flutter_music_notation/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/adelaykay/flutter_music_notation/releases/tag/v0.2.0
[0.1.0]: https://github.com/adelaykay/flutter_music_notation/releases/tag/v0.1.0