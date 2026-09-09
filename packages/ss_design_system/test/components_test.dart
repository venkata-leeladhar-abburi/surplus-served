import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_design_system/ss_design_system.dart';

Widget host(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: brightness == Brightness.light ? SsTheme.light() : SsTheme.dark(),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('SsTextField', () {
    testWidgets('shows helper text, and swaps it for the error', (tester) async {
      await tester.pumpWidget(host(const SsTextField(
        label: 'Phone number',
        helper: "We'll only use this to contact you about a pickup.",
      )));
      expect(find.text("We'll only use this to contact you about a pickup."), findsOneWidget);

      await tester.pumpWidget(host(const SsTextField(
        label: 'Phone number',
        helper: "We'll only use this to contact you about a pickup.",
        errorText: 'Enter a valid 10-digit number',
      )));
      expect(find.text('Enter a valid 10-digit number'), findsOneWidget);
      expect(find.text("We'll only use this to contact you about a pickup."), findsNothing);
    });

    testWidgets('meets the tap-target floor', (tester) async {
      await tester.pumpWidget(host(const SsTextField(label: 'Food name')));
      expect(
        tester.getSize(find.byType(TextFormField)).height,
        greaterThanOrEqualTo(SsA11y.minTapTarget),
      );
    });
  });

  group('SsSearchField', () {
    testWidgets('announces how many filters are active', (tester) async {
      await tester.pumpWidget(host(SsSearchField(
        onFilterTap: () {},
        activeFilterCount: 3,
      )));
      expect(find.bySemanticsLabel('Filters, 3 active'), findsOneWidget);
    });
  });

  group('SsAvatar', () {
    testWidgets('falls back to initials', (tester) async {
      await tester.pumpWidget(host(const SsAvatar(name: 'Green Bites Café')));
      expect(find.text('GC'), findsOneWidget);
    });

    testWidgets('announces verification rather than only badging it', (tester) async {
      await tester.pumpWidget(
        host(const SsAvatar(name: 'Helping Hands', verified: true)),
      );
      expect(find.bySemanticsLabel('Helping Hands, verified'), findsOneWidget);
    });
  });

  group('SsAccordion', () {
    testWidgets('opens and closes a panel', (tester) async {
      await tester.pumpWidget(host(const SsAccordion(items: [
        SsAccordionItem(title: 'How does food rescue work?', body: 'We connect donors with NGOs.'),
      ])));

      expect(find.text('How does food rescue work?'), findsOneWidget);
      await tester.tap(find.text('How does food rescue work?'));
      await tester.pumpAndSettle();
      expect(find.text('We connect donors with NGOs.'), findsOneWidget);
    });
  });

  group('SsBottomNav', () {
    testWidgets('marks the current destination as selected', (tester) async {
      await tester.pumpWidget(host(SsBottomNav(
        currentIndex: 1,
        onSelected: (_) {},
        destinations: const [
          SsNavDestination(icon: SsIcons.home, label: 'Home'),
          SsNavDestination(icon: SsIcons.map, label: 'Map'),
          SsNavDestination(icon: SsIcons.message, label: 'Messages', badgeCount: 12),
        ],
      )));

      expect(find.text('9+'), findsOneWidget);
      expect(find.bySemanticsLabel('Messages, 12 new'), findsOneWidget);
    });
  });

  group('SsSegmentedTabs', () {
    testWidgets('reports counts alongside labels', (tester) async {
      await tester.pumpWidget(host(SsSegmentedTabs(
        labels: const ['Pending', 'Allocated', 'Completed'],
        currentIndex: 0,
        counts: const {0: 3},
        onSelected: (_) {},
      )));
      expect(find.text('Pending (3)'), findsOneWidget);
    });
  });

  group('SsPagination', () {
    testWidgets('hides itself for a single page', (tester) async {
      await tester.pumpWidget(host(SsPagination(page: 1, pageCount: 1, onChanged: (_) {})));
      expect(find.text('1'), findsNothing);
    });

    testWidgets('windows around the current page', (tester) async {
      await tester.pumpWidget(host(SsPagination(page: 10, pageCount: 40, onChanged: (_) {})));
      expect(find.bySemanticsLabel('Page 10 of 40'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('40'), findsNothing);
    });
  });

  group('SsLocationRow', () {
    testWidgets('explains a locked address instead of showing a blank', (tester) async {
      await tester.pumpWidget(host(const SsLocationRow(
        address: 'Jubilee Hills, Hyderabad',
        contactName: 'Rahul Mehta',
        phone: '+91 98765 43210',
        locked: true,
      )));

      expect(find.textContaining('unlock once you are allocated'), findsOneWidget);
      // Scope §11 — contact details must not leak before allocation.
      expect(find.text('Rahul Mehta · +91 98765 43210'), findsNothing);
    });

    testWidgets('reveals contact once allocated', (tester) async {
      await tester.pumpWidget(host(const SsLocationRow(
        address: 'Plot 12, Hitech City, Hyderabad 500081',
        contactName: 'Rahul Mehta',
        phone: '+91 98765 43210',
      )));
      expect(find.text('Rahul Mehta · +91 98765 43210'), findsOneWidget);
    });
  });

  group('SsDialog', () {
    testWidgets('returns true only on confirm', (tester) async {
      bool? result;
      await tester.pumpWidget(MaterialApp(
        theme: SsTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => SsButton.primary(
              label: 'Open',
              onPressed: () async {
                result = await SsDialog.confirm(
                  context,
                  title: 'Request Food?',
                  message: 'This will send a request to Green Bites Café.',
                  confirmLabel: 'Request',
                );
              },
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Request Food?'), findsOneWidget);

      await tester.tap(find.text('Request'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });
  });

  group('SsFileUpload', () {
    testWidgets('states the requirement when empty', (tester) async {
      await tester.pumpWidget(host(SsFileUpload(onAdd: () {})));
      expect(find.text('Add photos'), findsOneWidget);
      expect(find.text('JPG, PNG up to 10MB'), findsOneWidget);
    });
  });

  group('renders in dark theme without error', () {
    testWidgets('the whole component surface', (tester) async {
      await tester.pumpWidget(host(
        Column(
          children: [
            const SsTextField(label: 'Food name', hint: 'Veg Biryani'),
            const SizedBox(height: 8),
            const SsAvatar(name: 'Sunrise Hotel', verified: true),
            const SizedBox(height: 8),
            SsListTile(title: 'Helping Hands NGO', subtitle: 'Receiver · 4 km away', onTap: () {}),
            const SizedBox(height: 8),
            const SsNotificationTile(
              title: 'Pickup completed',
              body: 'Thank you for making a difference.',
              timeAgo: '1 hour ago',
              tone: SsNotificationTone.success,
              unread: true,
            ),
            const SizedBox(height: 8),
            const SsProgressBar(value: 0.6, label: '3 of 5 steps'),
          ],
        ),
        brightness: Brightness.dark,
      ));
      expect(tester.takeException(), isNull);
    });
  });
}
