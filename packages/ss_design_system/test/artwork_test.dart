import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_design_system/ss_design_system.dart';

Widget host(Widget child) => MaterialApp(
      theme: SsTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('illustration catalogue', () {
    test('covers every §09 set the product actually reaches', () {
      expect(SsIllustrations.all, isNotEmpty);
      expect(
        SsIllustrations.bySet.keys,
        containsAll(['onboarding', 'empty', 'role', 'success', 'error', 'trust']),
      );
    });

    test('every entry names a real asset and a non-empty caption', () {
      for (final entry in SsIllustrations.all.entries) {
        final art = entry.value;
        expect(art.asset, startsWith('assets/illustrations/'));
        expect(art.asset, endsWith('${entry.key}.png'));
        expect(art.caption, isNotEmpty, reason: '${entry.key} has no caption');
        expect(art.nativeWidth, greaterThan(0));
        expect(art.nativeHeight, greaterThan(0));
      }
    });

    test('the empty, error and success states the components use all exist', () {
      for (final name in [
        'noFoodAvailable',
        'noResultsFound',
        'noRequestsYet',
        'somethingWentWrong',
        'offline',
        'requestSubmitted',
        'foodReceived',
        'deliveryCompleted',
        'impactUnlocked',
      ]) {
        expect(SsIllustrations.all.containsKey(name), isTrue, reason: 'missing $name');
      }
    });

    test('brand marks cover the three approved lockups (§02.1)', () {
      expect(SsBrandArt.all.keys,
          containsAll(['logoHorizontal', 'logoStacked', 'logoIcon', 'leafMark']));
    });
  });

  group('SsIllustration', () {
    testWidgets('announces its caption by default', (tester) async {
      await tester.pumpWidget(host(
        const SsIllustration(SsIllustrations.noFoodAvailable, width: 120),
      ));
      expect(
        find.bySemanticsLabel(SsIllustrations.noFoodAvailable.caption),
        findsOneWidget,
      );
    });

    testWidgets('an empty label marks it decorative', (tester) async {
      await tester.pumpWidget(host(
        const SsIllustration(
          SsIllustrations.noFoodAvailable,
          width: 120,
          semanticLabel: '',
        ),
      ));
      expect(
        find.bySemanticsLabel(SsIllustrations.noFoodAvailable.caption),
        findsNothing,
      );
    });

    testWidgets('keeps the artwork aspect ratio', (tester) async {
      const art = SsIllustrations.roleDonor;
      await tester.pumpWidget(host(const SsIllustration(art, width: 120)));
      final size = tester.getSize(find.byType(Image));
      expect(size.width, 120);
      expect(size.height, closeTo(120 / art.aspectRatio, 0.5));
    });
  });

  group('SsLogo', () {
    testWidgets('renders each approved lockup', (tester) async {
      for (final variant in SsLogoVariant.values) {
        await tester.pumpWidget(host(SsLogo(variant: variant, height: 40)));
        expect(tester.takeException(), isNull);
        expect(find.bySemanticsLabel('Surplus → Served'), findsOneWidget);
      }
    });

    testWidgets('never renders below the §02.9 minimum size', (tester) async {
      await tester.pumpWidget(host(const SsLogo.mark(height: 8)));
      expect(
        tester.getSize(find.byType(Image)).height,
        greaterThanOrEqualTo(SsLogoRules.minSize),
      );
    });
  });

  group('SsEmptyState with artwork', () {
    testWidgets('shows the illustration instead of the icon when given one',
        (tester) async {
      await tester.pumpWidget(host(
        const SizedBox(
          width: 360,
          child: SsEmptyState(
            title: 'No food nearby',
            message: "We couldn't find any food near your location right now.",
            illustration: SsIllustrations.noFoodAvailable,
            primaryActionLabel: 'Try a different location',
          ),
        ),
      ));
      expect(find.byType(SsIllustration), findsOneWidget);
      expect(find.text('No food nearby'), findsOneWidget);
    });
  });
}
