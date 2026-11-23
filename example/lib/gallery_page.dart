import 'package:flutter/material.dart';
import 'samples/folk_sample.dart';
import 'samples/piano_sample.dart';
import 'samples/jazz_sample.dart';
import 'samples/rhythm_sample.dart';
import 'samples/satb_sample.dart';
import 'samples/long_melody_sample.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Notation Gallery'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          GalleryItem(
            title: 'Extended Melody Study',
            description: 'Longer piece testing accidentals, dots, and ledger lines across systems.',
            child: LongMelodySample(),
          ),
          Divider(height: 40),
          GalleryItem(
            title: 'SATB Hymn',
            description: 'Abide With Me (Excerpt) showcasing 4 independent voices and syncopation.',
            child: SATBSample(),
          ),
          Divider(height: 40),
          GalleryItem(
            title: 'Simple Folk Song',
            description: 'Twinkle Twinkle Little Star in C Major',
            child: FolkSample(),
          ),
          Divider(height: 40),
          GalleryItem(
            title: 'Classical Piano',
            description: 'Minuet in G (Excerpt) using Grand Staff',
            child: PianoSample(),
          ),
          Divider(height: 40),
          GalleryItem(
            title: 'Jazz Melody',
            description: 'Blues in C with accidentals',
            child: JazzSample(),
          ),
          Divider(height: 40),
          GalleryItem(
            title: 'Rhythmic Complexity',
            description: 'Showcasing triplets and dotted rhythms',
            child: RhythmSample(),
          ),
        ],
      ),
    );
  }
}

class GalleryItem extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const GalleryItem({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ],
    );
  }
}
