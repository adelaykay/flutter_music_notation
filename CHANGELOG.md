# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Phase 0: Foundation components
  - Pitch model with MIDI conversion
  - Duration model with dots and tuplets support
  - Note and Rest models
  - Chord model for simultaneous notes
  - StaffPosition calculations for treble, bass, alto, and tenor clefs
  - StaffUnits for proportional measurements
  - Basic StaffRenderer for drawing staff lines and ledger lines
  - Example app demonstrating foundation features
  - Comprehensive documentation and implementation plan

- Phase 2: Core Rendering & Playback
  - **PlaybackController** for managing playback state and tracking active notes
  - **NoteheadRenderer** for filled and hollow noteheads with proper rotation
  - **StemRenderer** with automatic direction calculation
  - **AccidentalRenderer** using SMuFL glyphs (♯, ♭, ♮, 𝄪, 𝄫)
  - **GlyphProvider** for Bravura font music symbols
  - **NotationView** widget for displaying interactive notation
  - **NotationPainter** for efficient rendering
  - Real-time note highlighting during playback
  - Chord rendering with proper stem placement
  - Support for treble and bass clefs
  - Ledger lines for notes outside staff range
- Phase 3 Week 6: Rests and Dots
  - **RestRenderer** with proper SMuFL rest symbols
  - **DotRenderer** for augmentation dots (dotted notes)
  - Rest positioning based on duration type
  - Dot positioning that avoids staff lines
  - Support for single and double dots
  - Integrated rest and dot rendering in NotationView
  - Updated example with rests and dotted notes

### Changed
- None yet

### Deprecated
- None yet

### Removed
- None yet

### Fixed
- None yet

### Security
- None yet

## [0.1.0] - 2025-01-XX (Planned)

Initial alpha release with foundation components.

[Unreleased]: https://github.com/adelaykay/flutter_music_notation/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/adelaykay/flutter_music_notation/releases/tag/v0.1.0