# Flutter Music Notation

A professional music notation rendering library for Flutter with MIDI support and synchronized playback.

**⚠️ ALPHA - Phase 0: Foundation** - This library is under active development. Currently in foundation phase with basic models and staff rendering.

## Features (Roadmap)

### ✅ Phase 0 (Current): Foundation
- [x] Pitch model with MIDI conversion
- [x] Duration model with dots and tuplets
- [x] Note and chord models
- [x] Staff position calculations
- [x] Basic staff rendering

### 🚧 In Progress
- [ ] Notehead rendering
- [ ] Stem rendering
- [ ] Accidental rendering
- [ ] Playback controller

### 📋 Planned
- [ ] Beaming
- [ ] Ties and slurs
- [ ] Multiple staves (grand staff)
- [ ] MIDI file import
- [ ] Synchronized playback
- [ ] Interactive score

## Installation

```yaml
dependencies:
  flutter_music_notation: ^0.1.0
```

## Quick Start

```dart
import 'package:flutter_music_notation/flutter_music_notation.dart';

// Create a pitch
final middleC = Pitch(noteName: NoteName.C, octave: 4);
print(middleC.midiNumber); // 60

// Create a note
final quarterNote = Note(
  pitch: middleC,
  duration: const NoteDuration.quarter(),
  startBeat: 0.0,
);

// Create a chord
final cMajorChord = Chord(notes: [
  Note(pitch: Pitch(noteName: NoteName.C, octave: 4), 
       duration: const NoteDuration.half(), startBeat: 0.0),
  Note(pitch: Pitch(noteName: NoteName.E, octave: 4), 
       duration: const NoteDuration.half(), startBeat: 0.0),
  Note(pitch: Pitch(noteName: NoteName.G, octave: 4), 
       duration: const NoteDuration.half(), startBeat: 0.0),
]);
```

## Architecture

The library follows a component-based architecture:

### Models (`lib/src/models/`)
- **Pitch**: Musical pitches with MIDI conversion
- **Duration**: Note durations with dots and tuplets
- **Note**: Musical notes with pitch and duration
- **Chord**: Multiple simultaneous notes

### Geometry (`lib/src/geometry/`)
- **StaffPosition**: Vertical positioning on staff
- **StaffUnits**: Proportional measurements

### Rendering (`lib/src/rendering/`)
- **StaffRenderer**: Renders staff lines and ledger lines
- More renderers coming in future phases...

## Development Status

This library is being built systematically following a 24-week implementation plan:

- **Phase 0-1** (Weeks 1-3): Foundation ✅ Current
- **Phase 2** (Weeks 4-5): Playback Core
- **Phase 3** (Weeks 6-9): Essential Notation
- **Phase 4** (Weeks 10-12): Layout & Spacing
- **Phase 5** (Weeks 13-14): Grand Staff
- **Phase 6** (Weeks 15-20): Advanced Features
- **Phase 7** (Weeks 21-23): MIDI Integration
- **Phase 8** (Week 24): Polish & Release

See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for detailed roadmap.

## Examples

Run the example app to see current functionality:

```bash
cd example
flutter run
```

## Contributing

This is an open-source project. Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## Attribution

If you use this package in your project, please include attribution:

```
Music notation rendering by flutter_music_notation
```

## License

BSD-3-Clause - see [LICENSE](LICENSE) file for details.

## Author

Created by [Your Name]

## Acknowledgments

- Uses Bravura font (Steinberg Media Technologies GmbH) - SIL Open Font License
- Inspired by music engraving best practices from professional notation software

## Support

- 📝 [Documentation](https://github.com/adelaykay/flutter_music_notation/wiki)
- 🐛 [Issue Tracker](https://github.com/adelaykay/flutter_music_notation/issues)
- 💬 [Discussions](https://github.com/adelaykay/flutter_music_notation/discussions)