# Contributing to Flutter Music Notation

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Project Structure](#project-structure)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of experience level, gender identity, sexual orientation, disability, personal appearance, race, ethnicity, age, religion, or nationality.

### Our Standards

**Examples of encouraged behavior:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what's best for the community
- Showing empathy towards other community members

**Examples of unacceptable behavior:**
- Harassment, trolling, or discriminatory comments
- Publishing others' private information
- Other conduct inappropriate in a professional setting

---

## Getting Started

### Prerequisites

- Flutter 3.0 or higher
- Dart 3.0 or higher
- Git
- A code editor (VS Code, Android Studio, or IntelliJ recommended)

### Finding Issues to Work On

1. Check the [GitHub Issues](https://github.com/adelaykay/flutter_music_notation/issues)
2. Look for issues labeled:
    - `good first issue` - Great for newcomers
    - `help wanted` - We'd love community help
    - `bug` - Something isn't working
    - `enhancement` - New features
    - `documentation` - Improvements to docs

3. Comment on the issue to let others know you're working on it

---

## Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR_USERNAME/flutter_music_notation.git
cd flutter_music_notation
```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-number-description
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation only
- `refactor/` - Code refactoring
- `test/` - Adding tests

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the Example App

```bash
cd example
flutter run
```

### 5. Run Tests

```bash
flutter test
```

---

## How to Contribute

### Reporting Bugs

Before creating a bug report:
1. Check if the issue already exists
2. Update to the latest version
3. Verify it's actually a bug

When creating a bug report, include:
- Clear, descriptive title
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots if applicable
- Flutter/Dart versions
- Device/platform information

**Bug Report Template:**

```markdown
**Description**
A clear description of the bug.

**To Reproduce**
1. Create a measure with...
2. Set the clef to...
3. Run the app
4. See error

**Expected Behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
- Flutter version: [e.g., 3.16.0]
- Dart version: [e.g., 3.2.0]
- Platform: [e.g., iOS 17, Android 14, Web]
- Package version: [e.g., 0.1.0]

**Additional Context**
Any other relevant information.
```

### Suggesting Features

Feature requests should include:
- Clear use case
- Benefits to users
- Possible implementation approach
- Examples from other libraries (if applicable)

### Improving Documentation

Documentation contributions are highly valued! You can help by:
- Fixing typos or unclear wording
- Adding examples
- Improving API documentation
- Translating documentation
- Adding diagrams or screenshots

---

## Coding Standards

### Dart Style Guide

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines.

### Key Principles

1. **Immutability**: All model classes should be immutable
   ```dart
   // Good
   class Note {
     final Pitch pitch;
     final NoteDuration duration;
     const Note({required this.pitch, required this.duration});
   }
   
   // Bad
   class Note {
     Pitch pitch;
     NoteDuration duration;
   }
   ```

2. **Type Safety**: Use strong typing, avoid `dynamic`
   ```dart
   // Good
   List<Note> notes = [];
   
   // Bad
   var notes = [];
   ```

3. **Documentation**: Use DartDoc comments for public APIs
   ```dart
   /// Represents a musical note with pitch and duration.
   ///
   /// Example:
   /// ```dart
   /// final note = Note(
   ///   pitch: Pitch(noteName: NoteName.C, octave: 4),
   ///   duration: const NoteDuration.quarter(),
   ///   startBeat: 0.0,
   /// );
   /// ```
   class Note {
     // ...
   }
   ```

4. **Null Safety**: Embrace sound null safety
   ```dart
   // Good
   final String? optionalValue;
   
   // Use null-aware operators
   final length = optionalValue?.length ?? 0;
   ```

### Code Formatting

Use `dart format`:

```bash
dart format lib/ test/
```

### Linting

Follow the lints defined in `analysis_options.yaml`:

```bash
flutter analyze
```

Fix all warnings before submitting a PR.

---

## Testing

### Writing Tests

Every new feature should include tests:

```dart
// test/models/pitch_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';

void main() {
  group('Pitch', () {
    test('should create middle C correctly', () {
      final pitch = Pitch(noteName: NoteName.C, octave: 4);
      expect(pitch.midiNumber, equals(60));
      expect(pitch.scientificName, equals('C4'));
    });

    test('should convert from MIDI number', () {
      final pitch = Pitch.fromMidiNumber(60);
      expect(pitch.noteName, equals(NoteName.C));
      expect(pitch.octave, equals(4));
    });
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/pitch_test.dart

# Run with coverage
flutter test --coverage
```

### Test Coverage

We aim for 80%+ test coverage. Check coverage:

```bash
# Generate coverage
flutter test --coverage

# View HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Testing Guidelines

1. **Unit Tests**: Test individual classes in isolation
2. **Widget Tests**: Test rendering and interaction
3. **Integration Tests**: Test complete features
4. **Test Names**: Should clearly describe what's being tested
5. **Arrange-Act-Assert**: Follow AAA pattern

```dart
test('should calculate note duration correctly', () {
  // Arrange
  final duration = NoteDuration(type: DurationType.quarter, dots: 1);
  
  // Act
  final beats = duration.beats;
  
  // Assert
  expect(beats, equals(1.5));
});
```

---

## Pull Request Process

### Before Submitting

1. ✅ Run tests: `flutter test`
2. ✅ Run analyzer: `flutter analyze`
3. ✅ Format code: `dart format lib/ test/`
4. ✅ Update documentation if needed
5. ✅ Add tests for new features
6. ✅ Update CHANGELOG.md

### Submitting a PR

1. Push your branch to your fork
2. Open a Pull Request against `main`
3. Fill out the PR template
4. Link related issues (use "Fixes #123")
5. Wait for review

### PR Template

```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Fixes #123

## Testing
How have you tested this?
- [ ] Unit tests added/updated
- [ ] Manual testing performed
- [ ] Example app tested

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests pass locally
- [ ] No new warnings from analyzer
- [ ] CHANGELOG.md updated
```

### Review Process

1. Maintainer will review within 1-2 weeks
2. Address review feedback
3. Once approved, maintainer will merge

### After Merge

Your contribution will be included in the next release. Thank you! 🎉

---

## Project Structure

```
flutter_music_notation/
├── lib/
│   ├── flutter_music_notation.dart    # Main export file
│   └── src/
│       ├── models/                     # Data models
│       │   ├── pitch.dart
│       │   ├── duration.dart
│       │   ├── note.dart
│       │   ├── measure.dart
│       │   ├── key_signature.dart
│       │   └── time_signature.dart
│       ├── geometry/                   # Position calculations
│       │   ├── staff_position.dart
│       │   └── staff_units.dart
│       ├── rendering/                  # Drawing primitives
│       │   ├── staff_renderer.dart
│       │   ├── note_renderer.dart
│       │   ├── clef_renderer.dart
│       │   └── ...
│       ├── playback/                   # Playback control
│       │   └── playback_controller.dart
│       └── widgets/                    # Flutter widgets
│           └── notation_view.dart
├── test/                               # Unit tests
├── example/                            # Example app
├── assets/fonts/                       # Bravura font
├── README.md
├── CHANGELOG.md
├── LICENSE
└── pubspec.yaml
```

### Module Responsibilities

- **Models**: Immutable data structures, no UI logic
- **Geometry**: Math and position calculations
- **Rendering**: Low-level drawing using Canvas
- **Widgets**: Flutter UI components
- **Playback**: State management for playback

---

## Development Tips

### Debugging Rendering

Use Flutter DevTools to inspect rendering:

```dart
// Add debug painting
NotationView(
  measures: measures,
  config: NotationConfig(
    // ... config
  ),
)
```

### Testing Rendering

Use golden tests for visual regression:

```dart
testWidgets('renders C major scale correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: NotationView(measures: [createCMajorScale()]),
    ),
  );
  
  await expectLater(
    find.byType(NotationView),
    matchesGoldenFile('golden/c_major_scale.png'),
  );
});
```

### Performance Profiling

```bash
# Run with performance overlay
flutter run --profile

# Analyze performance
flutter run --trace-startup --profile
```

---

## Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and general discussion
- **Email**: [hello@empyrealworks.com]

---

## Recognition

Contributors will be:
- Listed in CHANGELOG.md for each release
- Mentioned in release notes
- Added to CONTRIBUTORS.md (if significant contribution)

Thank you for contributing to Flutter Music Notation! 🎵

---

## Questions?

Don't hesitate to ask! Create a GitHub Discussion or email the maintainers.

## License

By contributing, you agree that your contributions will be licensed under the BSD-3-Clause License.