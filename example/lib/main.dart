// example/lib/phase7_complete_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_notation/flutter_music_notation.dart';
import 'gallery_page.dart';

void main() {
  runApp(const MusicNotationApp());
}

class MusicNotationApp extends StatelessWidget {
  const MusicNotationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Music Notation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Music Notation'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GalleryPage()),
              ),
              icon: const Icon(Icons.collections),
              label: const Text('View Music Gallery'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TestPage()),
              ),
              icon: const Icon(Icons.settings),
              label: const Text('MIDI Integration Test'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  MidiData? _midiData;
  List<Measure>? _singleStaffMeasures;
  GrandStaff? _grandStaff;
  bool _isLoading = false;
  String? _error;

  // Configuration toggles
  bool _enableBeaming = true;
  bool _enableTies = false;
  bool _showKeyOnEachSystem = true;
  bool _useUniformSpacing = true;
  RenderMode _renderMode = RenderMode.singleStaff;

  @override
  void initState() {
    super.initState();
    _loadSampleMidi();
  }

  Future<void> _loadSampleMidi() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Try to load MIDI from assets
      final bytes = await rootBundle.load('assets/sample.mid');
      final midiBytes = bytes.buffer.asUint8List();
      final midiData = MidiParser.parse(midiBytes);

      setState(() {
        _midiData = midiData;
        _convertMidi();
        _isLoading = false;
      });
    } catch (e) {
      // If file loading fails, create demo data
      _createDemoMidiData();
    }
  }

  void _createDemoMidiData() {
    // Create simulated MIDI data for demonstration
    final notes = <MidiNote>[
      // Measure 1 - C major scale ascending
      MidiNote(midiNumber: 60, velocity: 80, startTime: 0, endTime: 500),
      MidiNote(midiNumber: 62, velocity: 80, startTime: 500, endTime: 1000),
      MidiNote(midiNumber: 64, velocity: 80, startTime: 1000, endTime: 1500),
      MidiNote(midiNumber: 65, velocity: 80, startTime: 1500, endTime: 2000),

      // Measure 2 - Continuation
      MidiNote(midiNumber: 67, velocity: 80, startTime: 2000, endTime: 2500),
      MidiNote(midiNumber: 69, velocity: 80, startTime: 2500, endTime: 3000),
      MidiNote(midiNumber: 71, velocity: 80, startTime: 3000, endTime: 3500),
      MidiNote(midiNumber: 72, velocity: 80, startTime: 3500, endTime: 4000),

      // Measure 3 - Descending with some chords
      MidiNote(midiNumber: 72, velocity: 80, startTime: 4000, endTime: 5000),
      MidiNote(midiNumber: 64, velocity: 70, startTime: 4000, endTime: 5000),
      MidiNote(midiNumber: 67, velocity: 70, startTime: 5000, endTime: 6000),
      MidiNote(midiNumber: 60, velocity: 70, startTime: 5000, endTime: 6000),

      // Measure 4 - Final cadence
      MidiNote(midiNumber: 65, velocity: 80, startTime: 6000, endTime: 7000),
      MidiNote(midiNumber: 69, velocity: 80, startTime: 7000, endTime: 8000),
      MidiNote(midiNumber: 60, velocity: 90, startTime: 8000, endTime: 10000),
      MidiNote(midiNumber: 64, velocity: 90, startTime: 8000, endTime: 10000),
      MidiNote(midiNumber: 67, velocity: 90, startTime: 8000, endTime: 10000),
    ];

    final midiData = MidiData(
      notes: notes,
      timeSignatureNumerator: 4,
      timeSignatureDenominator: 4,
      keySignatureSharps: 0,
      keySignatureIsMinor: false,
      beatsPerMinute: 120.0,
      ticksPerQuarterNote: 480,
    );

    setState(() {
      _midiData = midiData;
      _convertMidi();
      _isLoading = false;
    });
  }

  void _convertMidi() {
    if (_midiData == null) return;

    final converter = MidiToNotation(midiData: _midiData!);

    switch (_renderMode) {
      case RenderMode.singleStaff:
        _singleStaffMeasures = converter.toSingleStaff(
          clefPreference: ClefPreference.auto,
        );
        _grandStaff = null;
        break;
      case RenderMode.grandStaff:
        _grandStaff = converter.toGrandStaff();
        _singleStaffMeasures = null;
        break;
    }
  }

  void _toggleRenderMode(RenderMode mode) {
    setState(() {
      _renderMode = mode;
      _convertMidi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 7: MIDI Integration Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: _loadSampleMidi,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControlPanel(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rendering Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Render Mode
          Row(
            children: [
              const SizedBox(width: 150, child: Text('Render Mode:')),
              SegmentedButton<RenderMode>(
                segments: const [
                  ButtonSegment(
                    value: RenderMode.singleStaff,
                    label: Text('Single Staff'),
                    icon: Icon(Icons.horizontal_rule),
                  ),
                  ButtonSegment(
                    value: RenderMode.grandStaff,
                    label: Text('Grand Staff'),
                    icon: Icon(Icons.piano),
                  ),
                ],
                selected: {_renderMode},
                onSelectionChanged: (Set<RenderMode> selection) {
                  _toggleRenderMode(selection.first);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Beaming toggle
          _buildToggleRow(
            'Enable Beaming',
            _enableBeaming,
                (value) => setState(() => _enableBeaming = value),
          ),

          // Ties toggle
          _buildToggleRow(
            'Enable Ties',
            _enableTies,
                (value) => setState(() => _enableTies = value),
          ),

          // Key signature toggle
          _buildToggleRow(
            'Show Key on Each System',
            _showKeyOnEachSystem,
                (value) => setState(() => _showKeyOnEachSystem = value),
          ),

          // Spacing toggle
          _buildToggleRow(
            'Use Uniform Spacing',
            _useUniformSpacing,
                (value) => setState(() => _useUniformSpacing = value),
          ),

          if (_midiData != null) ...[
            const Divider(),
            _buildMidiInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Text(label),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMidiInfo() {
    final data = _midiData!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MIDI Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('Notes: ${data.notes.length}'),
        Text('Time: ${data.timeSignatureNumerator}/${data.timeSignatureDenominator}'),
        Text('Key: ${_getKeyName(data.keySignatureSharps, data.keySignatureIsMinor)}'),
        Text('Tempo: ${data.beatsPerMinute.toStringAsFixed(0)} BPM'),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading MIDI file...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildNotation(),
      ),
    );
  }

  Widget _buildNotation() {
    final config = NotationConfig(
      staffSpaceSize: 12,
      leftMargin: 120,
      useSystemLayout: true,
      enableBeaming: _enableBeaming,
      enableTieDetection: _enableTies,
      showKeySignatureOnEachSystem: _showKeyOnEachSystem,
      clefNoteMargin: 25.0,
      spacingEngine: _useUniformSpacing
          ? SpacingPresets.uniform
          : SpacingPresets.loose,
      measureSpacing: 30.0,
    );

    if (_grandStaff != null) {
      return SizedBox(
        height: 500,
        child: NotationView(
          grandStaff: _grandStaff,
          config: config.copyWith(
            showBrace: true,
          ),
        ),
      );
    }

    if (_singleStaffMeasures != null) {
      return SizedBox(
        height: 300,
        child: NotationView(
          measures: _singleStaffMeasures,
          config: config,
        ),
      );
    }

    return const Center(
      child: Text('No notation available'),
    );
  }

  String _getKeyName(int sharps, bool isMinor) {
    const majorKeys = {
      0: 'C', 1: 'G', 2: 'D', 3: 'A', 4: 'E', 5: 'B', 6: 'F♯', 7: 'C♯',
      -1: 'F', -2: 'B♭', -3: 'E♭', -4: 'A♭', -5: 'D♭', -6: 'G♭', -7: 'C♭',
    };

    const minorKeys = {
      0: 'A', 1: 'E', 2: 'B', 3: 'F♯', 4: 'C♯', 5: 'G♯', 6: 'D♯', 7: 'A♯',
      -1: 'D', -2: 'G', -3: 'C', -4: 'F', -5: 'B♭', -6: 'E♭', -7: 'A♭',
    };

    final key = isMinor ? minorKeys[sharps] : majorKeys[sharps];
    return '$key ${isMinor ? 'minor' : 'major'}';
  }
}

enum RenderMode {
  singleStaff,
  grandStaff,
}