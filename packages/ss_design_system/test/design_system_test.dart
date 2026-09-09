import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_design_system/ss_design_system.dart';

Widget _host(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: brightness == Brightness.light ? SsTheme.light() : SsTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('theme', () {
    test('light and dark both carry the SsColors extension', () {
      expect(SsTheme.light().extension<SsColors>(), isNotNull);
      expect(SsTheme.dark().extension<SsColors>(), isNotNull);
      expect(SsTheme.light().extension<SsColors>()!.primary, SsPalette.leafGreen);
    });

    test('lerp between light and dark stays well-formed', () {
      final mid = SsColors.light.lerp(SsColors.dark, 0.5);
      expect(mid.natureGradient, hasLength(2));
    });
  });

  group('accessibility contracts', () {
    testWidgets('buttons meet the 44px tap-target floor', (tester) async {
      await tester.pumpWidget(
        _host(SsButton.primary(label: 'Donate Food', onPressed: () {})),
      );
      final size = tester.getSize(find.byType(ElevatedButton));
      expect(size.height, greaterThanOrEqualTo(SsA11y.minTapTarget));
    });

    testWidgets('icon buttons expose their tooltip as a label', (tester) async {
      await tester.pumpWidget(
        _host(SsIconButton(
          icon: SsIcons.donate,
          tooltip: 'Save for later',
          onPressed: () {},
        )),
      );
      expect(find.bySemanticsLabel('Save for later'), findsOneWidget);
    });

    testWidgets('status badge renders icon + label, not colour alone',
        (tester) async {
      await tester.pumpWidget(_host(const SsStatusBadge(status: SsStatus.live)));
      expect(find.text('Live'), findsOneWidget);
      expect(find.byType(SsIcon), findsOneWidget);
      expect(find.bySemanticsLabel('Status: Live'), findsOneWidget);
    });

    testWidgets('freshness ring announces the remaining window', (tester) async {
      await tester.pumpWidget(_host(const SsFreshnessRing(
        remaining: Duration(minutes: 18),
        total: Duration(minutes: 60),
      )));
      expect(find.bySemanticsLabel('Pickup window: 18 min left'), findsOneWidget);
    });

    testWidgets('pickup code is announced digit by digit', (tester) async {
      await tester.pumpWidget(_host(const SsPickupCode(code: '4821')));
      expect(find.bySemanticsLabel('Pickup code 4 8 2 1'), findsOneWidget);
    });
  });

  group('components render in both brightnesses', () {
    for (final brightness in Brightness.values) {
      testWidgets('donation card — ${brightness.name}', (tester) async {
        await tester.pumpWidget(
          _host(
            const SizedBox(
              width: 360,
              child: SsDonationCard(
                title: 'Veg Biryani',
                donorName: 'Green Bites Café',
                imageUrl: null,
                status: SsStatus.live,
                distanceLabel: '2 km away',
                timeLeftLabel: '18 min left',
                servingsLabel: '25 servings',
                isVegetarian: true,
                actionLabel: 'Request',
              ),
            ),
            brightness: brightness,
          ),
        );
        expect(find.text('Veg Biryani'), findsOneWidget);
        // §13 — the container reminder appears on every donation surface.
        expect(find.text('Please bring your own containers.'), findsOneWidget);
      });

      testWidgets('empty state — ${brightness.name}', (tester) async {
        await tester.pumpWidget(
          _host(
            const SsEmptyState(
              title: 'No food nearby',
              message: "We couldn't find any food near your location right now.",
              primaryActionLabel: 'Try a different location',
              suggestions: ['Expand your search area', 'Enable notifications'],
            ),
            brightness: brightness,
          ),
        );
        expect(find.text('No food nearby'), findsOneWidget);
      });

      testWidgets('stepper — ${brightness.name}', (tester) async {
        await tester.pumpWidget(
          _host(
            const SizedBox(
              width: 400,
              child: SsStepper(
                steps: ['Request', 'Confirm', 'Pickup', 'Complete'],
                currentIndex: 1,
              ),
            ),
            brightness: brightness,
          ),
        );
        expect(find.bySemanticsLabel('Step 2 of 4: Confirm'), findsOneWidget);
      });

      testWidgets('alert — ${brightness.name}', (tester) async {
        await tester.pumpWidget(
          _host(
            const SizedBox(
              width: 360,
              child: SsAlert(
                message: 'Food request submitted!',
                tone: SsAlertTone.success,
              ),
            ),
            brightness: brightness,
          ),
        );
        expect(find.text('Food request submitted!'), findsOneWidget);
      });
    }
  });

  group('status vocabulary', () {
    test('models the scope §7 state machine and has no in-transit state', () {
      final names = SsStatus.values.map((s) => s.name).toSet();
      expect(
        names,
        containsAll([
          'draft',
          'pendingCheck',
          'live',
          'allocated',
          'collected',
          'reallocated',
          'unfulfilled',
          'cancelled',
        ]),
      );
      // Self-collect only — there is no delivery leg to track.
      expect(names.any((n) => n.contains('transit')), isFalse);
    });
  });
}
