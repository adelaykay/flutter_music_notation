# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-11-23

Grand staff engraving for hymns and other four-part music, driven by the
eChoir Library app's staff view.

### Fixed
- **Systems no longer run past the right edge.** System layout now reserves room for the clef, key signature and time signature that open each system (`systemPrefixWidth`), and measures each bar with both staves at the configured staff size.
- **Notes on the two staves line up.** Within a bar, notes were placed by their index among their own staff's beats, while spacing was computed over both staves together; a staff whose notes moved at different times drew them in the wrong columns. Notes, beams, ties, slurs and tuplets are now placed by beat on the shared grid.
- `Note.tieToNext` ties to the next note of the same pitch and voice that starts where it ends, inside the bar if there is one (previously only a note at the start of the next bar was considered, so a tie inside a bar landed on an unrelated note).
- Ties on a staff with two voices follow the stems: upper voice above, lower voice below. Short ties are shallow arcs that clear the noteheads instead of "v" shapes through them.
- `maxMeasuresPerLine` applies to every system, including the last.
- The bass staff's key signature on later systems was drawn with the treble clef's positions.
- With `expandWidth`, the final barline is drawn where the bar ends; the last system is justified instead of having its barline moved ahead of the notes.
- Bar numbers sit above the start of the system rather than on the first note's stem.
- A `clamp` in proportional spacing could throw when a bar's glyphs needed more than `maxSpacing`.

### Changed
- Spacing values are given at a 12 px staff space (`SpacingEngine.referenceStaffSpace`) and scale with `staffSpaceSize`, so a smaller staff is also narrower. Output at the default 12 px is unchanged.

### Added
- `NotationView` sizes a grand staff in system layout to its content when `height` is null.
- `GrandStaffLayout.forConfig` (now exported) lays out a grand staff exactly as it is painted, e.g. to size a view.
- `Rest.voice`: on a staff with two voices, an upper voice's rest is drawn higher and a lower voice's lower.
- `NotationConfig.highlightedMeasure` and `highlightColor` to shade a bar, e.g. the one playing.

## [0.3.0] - 2026-11-23

### Added
- Layout options contributed by **Julien Bourgeois** ([@Julien5](https://github.com/Julien5)). All are opt-in, and the defaults keep existing output unchanged:
  - `NotationConfig.showTimeSignature` (default `true`) to hide the time signature
  - `NotationConfig.expandWidth` (default `false`) to stretch the staff across the full widget width, with the final barline flush right
  - `NotationConfig.leadingSpace` (default `0.0`) for space between the time signature (or clef) and the first note
  - `NotationConfig.barlineToClefSpace` (default `0.0`) for space between the start barline and the clef
  - `Measure.startBarline` for a barline at the start of a system (e.g. after a grand-staff brace)
- Golden tests for the example layouts (Julien Bourgeois), now rendered with the real music font
- `KeySignature.accidentalFor(letter)` and `KeySignature.notesNeedingAccidentals(notes)`

- **MIDI import rewritten** for live keyboard input and files:
  - picks the coarsest rhythmic grid that explains the playing (the old detector always chose the finest grid, turning timing wobbles into tiny note values)
  - fills gaps with rests so every bar adds up, and keeps silent bars as whole-bar rests
  - splits notes at barlines and beats and ties the pieces; ties are drawn across barlines and line breaks
  - groups notes pressed together into chords and trims legato overlaps
  - trims silence before the first bar
  - spells pitches from the key, including C♭ major and the raised leading note in minor keys
  - `MidiToNotation.suggestedClef()`, `MidiToNotation.estimateKey()`, `MidiToNotation.spell()` and a `splitPoint` for `toGrandStaff()`
- `Note.tieToNext` for ties that cross a barline

### Changed
- Bars produced from MIDI are numbered from 1
- Requires Flutter 3.35 / Dart 3.9
- The key signature is repeated at the start of every system by default (`showKeySignatureOnEachSystem: true`), as in standard engraving
- A short final system is left ragged instead of being stretched across the full width
- Time signatures use the SMuFL time-signature glyphs from the bundled font

### Fixed
- Accidentals follow letter names, not pitch classes: F♯ in G major no longer gets a redundant sharp, and F♮ in G major (or C♮ in C♭ major) now gets its natural
- Accidentals carry through the bar for each letter and octave, and a note that returns to the key's accidental after a natural shows it again
- Natural signs are drawn (they were never rendered)
- Notes leave room for the next note's accidental, so accidentals no longer collide with the previous note
- Bar widths on multi-system layouts: the first bar of a line was inflated and later bars squeezed
- The time signature font is resolved through the package, so it no longer falls back to the system font in apps
- Grand staff brace rendering (Julien Bourgeois)
- Grand staff spacing considers notes on both staves, so a note on an otherwise empty lower staff is no longer drawn on the barline (Julien Bourgeois)
- MIDI files whose header chunk is longer than 6 bytes are parsed correctly
- `toSingleStaff(clefPreference:)` was ignored; use `suggestedClef()` for the matching clef
- Grand staff layout no longer assumes bar numbers start at 0

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

[Unreleased]: https://github.com/empyrealworks/flutter_music_notation/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/empyrealworks/flutter_music_notation/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/empyrealworks/flutter_music_notation/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/empyrealworks/flutter_music_notation/releases/tag/v0.2.0
[0.1.0]: https://github.com/empyrealworks/flutter_music_notation/releases/tag/v0.1.0
