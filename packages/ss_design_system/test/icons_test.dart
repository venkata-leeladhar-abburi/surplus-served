import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_design_system/ss_design_system.dart';

void main() {
  group('icon set', () {
    test('every icon parses into a non-empty path, both variants', () {
      expect(SsIcons.all, isNotEmpty);

      for (final entry in SsIcons.all.entries) {
        final icon = entry.value;

        final outline = SsIconPath.resolve(icon, filled: false);
        expect(
          outline.computeMetrics().isNotEmpty,
          isTrue,
          reason: '${entry.key} outline parsed to an empty path',
        );

        if (icon.hasFilled) {
          final filled = SsIconPath.resolve(icon, filled: true);
          expect(
            filled.computeMetrics().isNotEmpty,
            isTrue,
            reason: '${entry.key} filled parsed to an empty path',
          );
        }
      }
    });

    test('every icon stays inside the 24pt grid with room for the stroke', () {
      const slack = 1.2; // half the 2px stroke, plus antialiasing

      for (final entry in SsIcons.all.entries) {
        for (final filled in [false, true]) {
          if (filled && !entry.value.hasFilled) continue;
          final bounds = SsIconPath.resolve(entry.value, filled: filled).getBounds();
          expect(bounds.left, greaterThanOrEqualTo(-slack), reason: '${entry.key} left');
          expect(bounds.top, greaterThanOrEqualTo(-slack), reason: '${entry.key} top');
          expect(bounds.right, lessThanOrEqualTo(24 + slack), reason: '${entry.key} right');
          expect(bounds.bottom, lessThanOrEqualTo(24 + slack), reason: '${entry.key} bottom');
        }
      }
    });

    test('the core set is the fifteen the design document lists', () {
      expect(SsIcons.coreNames, hasLength(15));
      expect(
        SsIcons.coreNames,
        containsAll(['home', 'search', 'addFood', 'donate', 'receive', 'map',
                     'calendar', 'bell', 'message', 'user', 'leaf', 'truck',
                     'package', 'share', 'settings']),
      );
    });

    test('every core icon has a filled variant (§05.4)', () {
      for (final name in SsIcons.coreNames) {
        expect(SsIcons.all[name]!.hasFilled, isTrue, reason: '$name has no filled variant');
      }
    });

    test('every status carries an AA-safe tone for both themes', () {
      // Dark mode tints the chip with the status hue; the light-mode pair is
      // not a substitute. Eight of ten badges failed AA on dark before the
      // `dark` tone existed, so this asserts the two are genuinely distinct
      // wherever the light tone is too dark to survive on a dark ground.
      for (final status in SsStatus.values) {
        expect(status.text.a, 1.0, reason: '${status.name} text is translucent');
        expect(status.dark.a, 1.0, reason: '${status.name} dark is translucent');
      }

      final light = SsColors.light;
      final dark = SsColors.dark;
      for (final status in SsStatus.values) {
        expect(light.statusColors(status).fg, status.text);
        expect(dark.statusColors(status).fg, status.dark);
      }
    });

    test('every status token points at an icon that exists', () {
      for (final status in SsStatus.values) {
        expect(
          SsIcons.all.containsKey(status.iconName),
          isTrue,
          reason: '${status.name} references missing icon "${status.iconName}"',
        );
      }
    });
  });

  group('SsIcon widget', () {
    Widget host(Widget child) => MaterialApp(
          theme: SsTheme.light(),
          home: Scaffold(body: Center(child: child)),
        );

    testWidgets('renders at the requested size', (tester) async {
      await tester.pumpWidget(host(const SsIcon(SsIcons.leaf, size: SsIconSize.lg)));
      expect(tester.getSize(find.byType(SsIcon)), const Size(32, 32));
    });

    testWidgets('is hidden from screen readers unless labelled', (tester) async {
      await tester.pumpWidget(host(const SsIcon(SsIcons.leaf)));
      expect(find.bySemanticsLabel('Fresh food'), findsNothing);

      await tester.pumpWidget(host(const SsIcon(SsIcons.leaf, semanticLabel: 'Fresh food')));
      expect(find.bySemanticsLabel('Fresh food'), findsOneWidget);
    });

    testWidgets('named lookup falls back rather than throwing', (tester) async {
      await tester.pumpWidget(host(SsIcon.named('no-such-icon')));
      expect(find.byType(SsIcon), findsOneWidget);
    });

    testWidgets('centres itself when a parent forces a larger size', (tester) async {
      // A fixed-size avatar circle, thumbnail or badge gives its child tight
      // constraints. The glyph must sit in the middle of that box, not in its
      // top-left corner.
      await tester.pumpWidget(
        host(
          const SizedBox(
            height: 48,
            width: 48,
            child: SsIcon(SsIcons.leaf, size: SsIconSize.sm),
          ),
        ),
      );

      final box = tester.getRect(find.byType(SizedBox).last);
      final painted = tester.getRect(find.byType(CustomPaint).last);
      expect(painted.center.dx, closeTo(box.center.dx, 0.5), reason: 'not centred horizontally');
      expect(painted.center.dy, closeTo(box.center.dy, 0.5), reason: 'not centred vertically');
      expect(painted.width, closeTo(SsIconSize.sm, 0.5), reason: 'icon was stretched');
    });

    testWidgets('renders every icon in the set without error', (tester) async {
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 320,
            child: Wrap(
              children: [
                for (final icon in SsIcons.all.values) SsIcon(icon, size: SsIconSize.sm),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(SsIcon), findsNWidgets(SsIcons.all.length));
    });
  });
}
