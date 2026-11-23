import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_notation_example/samples/satb_sample.dart';

void main() {
  // The four-part sample builds, lays out its systems and plays without errors.
  testWidgets('SATB sample renders', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(420, 1100);
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: key,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: SATBSample(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Play'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byKey(key), findsOneWidget);
    await tester.tap(find.text('Stop'));
    await tester.pump();
  });
}
