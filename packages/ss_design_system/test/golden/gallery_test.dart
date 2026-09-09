@Tags(['golden'])
library;


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_design_system/ss_design_system.dart';

/// Renders every component in the system to a golden image.
///
///   flutter test --update-goldens test/golden      # regenerate the sheets
///   flutter test test/golden                       # check nothing drifted
///
/// These double as the gallery: `test/golden/goldens/*.png` is what the design
/// system actually looks like, rendered by Flutter rather than mocked up.
Future<void> _loadFonts() async {
  for (final family in const {
    'Inter': ['assets/fonts/Inter-Variable.ttf'],
    'Lora': ['assets/fonts/Lora-Variable.ttf', 'assets/fonts/Lora-Italic-Variable.ttf'],
    'NotoSansTelugu': ['assets/fonts/NotoSansTelugu-Variable.ttf'],
  }.entries) {
    final loader = FontLoader(family.key);
    for (final path in family.value) {
      loader.addFont(rootBundle.load(path));
    }
    await loader.load();
  }
}

/// Wraps a sheet in the theme and gives it a fixed, deterministic size.
Widget _sheet({
  required String title,
  required Widget child,
  required double height,
  Brightness brightness = Brightness.light,
  double width = 900,
}) {
  final theme = brightness == Brightness.light ? SsTheme.light() : SsTheme.dark();
  final colors = theme.extension<SsColors>()!;

  return MediaQuery(
    data: MediaQueryData(size: Size(width, height), devicePixelRatio: 1),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        backgroundColor: colors.background,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(SsSpacing.xxl),
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: SsTypeScale.h3.copyWith(color: colors.onSurface)),
                  const SizedBox(height: SsSpacing.xl),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _section(BuildContext context, String label, Widget child) {
  final c = context.ssColors;
  return Padding(
    padding: const EdgeInsets.only(bottom: SsSpacing.xxl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: SsTypography.overline.copyWith(color: c.primary),
        ),
        const SizedBox(height: SsSpacing.md),
        child,
      ],
    ),
  );
}

Future<void> _expectGolden(
  WidgetTester tester,
  Widget widget,
  String name, {
  required double height,
}) async {
  await tester.binding.setSurfaceSize(Size(900, height));
  await tester.pumpWidget(widget);

  // Artwork is loaded from real PNG assets, so give the image stream a turn of
  // the real event loop before capturing.
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final image = element.widget as Image;
      await precacheImage(image.image, element);
    }
    await Future<void>.delayed(const Duration(milliseconds: 60));
  });

  // Not pumpAndSettle: the sheet deliberately includes a loading button, whose
  // spinner never settles. A few fixed frames land every other animation.
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }

  await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFonts();
  });

  testWidgets('01 foundations', (tester) async {
    await _expectGolden(
      tester,
      _sheet(
        height: 920,
        title: 'Foundations — colour and type',
        child: Builder(
          builder: (context) {
            final c = context.ssColors;
            Widget swatch(String name, String hex, Color color, Color on) => Container(
                  width: 132,
                  height: 92,
                  padding: const EdgeInsets.all(SsSpacing.md),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(SsRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(name, style: SsTypeScale.small.copyWith(color: on, fontWeight: FontWeight.w600)),
                      Text(hex, style: SsTypeScale.caption.copyWith(color: on)),
                    ],
                  ),
                );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(context, 'Primary colours', Wrap(spacing: SsSpacing.md, runSpacing: SsSpacing.md, children: [
                  swatch('Leaf Green', '#1F6B4A', SsPalette.leafGreen, Colors.white),
                  swatch('Sage Green', '#4CAF7A', SsPalette.sageGreen, Colors.white),
                  swatch('Harvest Orange', '#E39A1F', SsPalette.harvestOrange, SsPalette.ink),
                  swatch('Tomato Red', '#C2402B', SsPalette.tomatoRed, Colors.white),
                  swatch('Sunrise Yellow', '#F6C453', SsPalette.sunriseYellow, SsPalette.ink),
                  swatch('Earth Brown', '#6B4F3B', SsPalette.earthBrown, Colors.white),
                ])),
                _section(context, 'Green scale', Row(children: [
                  for (final s in [
                    ('900', SsPalette.green900), ('700', SsPalette.green700),
                    ('500', SsPalette.green500), ('300', SsPalette.green300),
                    ('100', SsPalette.green100), ('50', SsPalette.green50),
                  ])
                    Expanded(child: Container(height: 56, color: s.$2, alignment: Alignment.center,
                      child: Text(s.$1, style: SsTypeScale.caption.copyWith(
                        color: ['900','700','500'].contains(s.$1) ? Colors.white : SsPalette.ink)))),
                ])),
                _section(context, 'Type scale', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('The food we save', style: SsTypeScale.h1.copyWith(color: c.onSurface)),
                  Text('Good food brings people together.', style: SsTypeScale.h2.copyWith(color: c.onSurface)),
                  Text('Stronger communities, less waste.', style: SsTypeScale.h3.copyWith(color: c.onSurface)),
                  Text('Fresh food. Real impact.', style: SsTypeScale.h4.copyWith(color: c.onSurface)),
                  Text('Small actions create big change.', style: SsTypeScale.h5.copyWith(color: c.onSurface)),
                  const SizedBox(height: SsSpacing.sm),
                  Text('Body — Food connects us all. By reducing waste, we create healthier communities.',
                      style: SsTypeScale.body.copyWith(color: c.onSurface)),
                  Text('Small — Together, we can make sure good food always finds a home.',
                      style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant)),
                  Text('Caption — Pick up · Share · Nourish',
                      style: SsTypeScale.caption.copyWith(color: c.onSurfaceVariant)),
                  const SizedBox(height: SsSpacing.md),
                  Text('Good food should be shared, not wasted.',
                      style: SsTypeScale.display.copyWith(color: c.onSurface)),
                  Text('"A kinder tomorrow is written in the choices we make today."',
                      style: SsTypeScale.quote.copyWith(color: c.onSurfaceVariant)),
                ])),
                _section(context, 'Logo (§02.1)', Wrap(spacing: SsSpacing.xxl, runSpacing: SsSpacing.lg,
                  crossAxisAlignment: WrapCrossAlignment.center, children: const [
                    SsLogo.horizontal(height: 44),
                    SsLogo.stacked(height: 72),
                    SsLogo.mark(height: 44),
                  ])),
              ],
            );
          },
        ),
      ),
      '01_foundations',
      height: 920,
    );
  });

  for (final brightness in Brightness.values) {
    testWidgets('02 components — ${brightness.name}', (tester) async {
      await _expectGolden(
        tester,
        _sheet(
          brightness: brightness,
          height: 1700,
          title: 'Components — ${brightness.name}',
          child: Builder(
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(context, 'Buttons (§06.1)', Wrap(spacing: SsSpacing.md, runSpacing: SsSpacing.md, children: [
                  SsButton.primary(label: 'Donate Food', icon: SsIcons.addFood, onPressed: () {}),
                  SsButton.secondary(label: 'Find Nearby', onPressed: () {}),
                  SsButton.tertiary(label: 'Learn More', trailingIcon: SsIcons.arrowRight, onPressed: () {}),
                  SsButton.danger(label: 'Cancel Listing', onPressed: () {}),
                  const SsButton.primary(label: 'Disabled'),
                  const SsButton.primary(label: 'Loading', isLoading: true),
                  SsIconButton(icon: SsIcons.donate, tooltip: 'Save', onPressed: () {}),
                  SsIconButton(icon: SsIcons.share, tooltip: 'Share', filled: true, onPressed: () {}),
                ])),

                _section(context, 'Status badges (§06.4)', Wrap(spacing: SsSpacing.sm, runSpacing: SsSpacing.sm,
                  children: [for (final s in SsStatus.values) SsStatusBadge(status: s)])),

                _section(context, 'Tags', const Wrap(spacing: SsSpacing.sm, runSpacing: SsSpacing.sm, children: [
                  SsTag(label: 'Vegetarian', icon: SsIcons.leaf, tone: SsTagTone.positive),
                  SsTag(label: 'High Demand', icon: SsIcons.alert, tone: SsTagTone.warm),
                  SsTag(label: 'Verified', icon: SsIcons.verified, tone: SsTagTone.info),
                  SsTag(label: 'Bulk'),
                  SsTag(label: 'Nearby', icon: SsIcons.location),
                ])),

                _section(context, 'Inputs (§06.2, §07.3, §07.8)', Column(children: [
                  const SsTextField(label: 'Food name', hint: 'e.g. Veg Biryani', prefixIcon: SsIcons.meals),
                  const SizedBox(height: SsSpacing.lg),
                  const SsTextField(
                    label: 'Pickup address', hint: 'Hyderabad, India', prefixIcon: SsIcons.location,
                    helper: "Shown as an approximate area until you're allocated.",
                  ),
                  const SizedBox(height: SsSpacing.lg),
                  const SsTextField(
                    label: 'Phone number', hint: '+91', prefixIcon: SsIcons.phone,
                    errorText: 'Enter a valid 10-digit number',
                  ),
                  const SizedBox(height: SsSpacing.lg),
                  SsSearchField(onFilterTap: () {}, activeFilterCount: 3),
                  const SizedBox(height: SsSpacing.lg),
                  SsDateTimeField(label: 'Best before', value: DateTime(2026, 9, 8, 18), onChanged: (_) {}),
                ])),

                _section(context, 'Filters and tabs (§07.3, §07.4)', Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    SsFilterChips<String>(
                      options: const ['All', 'Meals', 'Fruits & Veg', 'Bakery', 'Dairy'],
                      selected: const {'Meals'}, onChanged: (_) {},
                    ),
                    const SizedBox(height: SsSpacing.lg),
                    SsSegmentedTabs(
                      labels: const ['Pending', 'Allocated', 'Completed'],
                      currentIndex: 0, counts: const {0: 3}, onSelected: (_) {},
                    ),
                  ])),

                _section(context, 'Progress (§06.9, §07.6)', Column(children: [
                  const SsProgressBar(value: 0.6, label: '3 of 5 steps'),
                  const SizedBox(height: SsSpacing.xl),
                  const SsStepper(steps: ['Request', 'Confirm', 'Pickup', 'Complete'], currentIndex: 1),
                ])),

                _section(context, 'Alerts (§06.6)', Column(children: [
                  for (final tone in SsAlertTone.values) ...[
                    SsAlert(
                      tone: tone,
                      onDismiss: () {},
                      message: switch (tone) {
                        SsAlertTone.success => 'Food request submitted!',
                        SsAlertTone.info => 'Pickup scheduled for today.',
                        SsAlertTone.warning => 'This item is in high demand.',
                        SsAlertTone.error => 'Something went wrong. Try again.',
                      },
                    ),
                    const SizedBox(height: SsSpacing.sm),
                  ],
                ])),

                _section(context, 'Handover proof (§12)', const Center(
                  child: SsPickupCode(code: '4821', caption: 'Show this code to the NGO on arrival.'))),
              ],
            ),
          ),
        ),
        '02_components_${brightness.name}',
        height: 1700,
      );
    });
  }

  testWidgets('03 cards, lists and navigation', (tester) async {
    await _expectGolden(
      tester,
      _sheet(
        height: 1840,
        title: 'Cards, lists and navigation',
        child: Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section(context, 'Donation card (§06.3)', Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 300, child: SsDonationCard(
                    title: 'Veg Biryani', donorName: 'Green Bites Café', imageUrl: null,
                    status: SsStatus.live, distanceLabel: '2 km away', timeLeftLabel: '18 min left',
                    servingsLabel: '25 servings', isVegetarian: true,
                    actionLabel: 'Request', onAction: () {}, onToggleSave: () {},
                  )),
                  const SizedBox(width: SsSpacing.xl),
                  SizedBox(width: 300, child: SsDonationCard(
                    title: 'Mixed Vegetables', donorName: 'Sunrise Hotel', imageUrl: null,
                    status: SsStatus.allocated, distanceLabel: '5 km away', timeLeftLabel: '42 min left',
                    servingsLabel: '30 servings', isVegetarian: false, isSaved: true,
                    onToggleSave: () {},
                    tags: const [SsTag(label: 'Bulk'), SsTag(label: 'Splittable', tone: SsTagTone.info)],
                  )),
                  const SizedBox(width: SsSpacing.xl),
                  const Column(children: [
                    SsFreshnessRing(remaining: Duration(minutes: 42), total: Duration(minutes: 60)),
                    SizedBox(height: SsSpacing.lg),
                    SsFreshnessRing(remaining: Duration(minutes: 8), total: Duration(minutes: 60)),
                  ]),
                ])),

              _section(context, 'Avatars (§07.11)', const Wrap(
                spacing: SsSpacing.lg, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  SsAvatar(name: 'Rahul Mehta', size: 56),
                  SsAvatar(name: 'Green Bites Café', size: 56, verified: true),
                  SsAvatar(name: 'Helping Hands', size: 56, verified: true, online: true),
                  SsAvatar(name: 'Priya Verma', size: 40),
                  SsAvatar(name: 'FreshMart', size: 32),
                ])),

              _section(context, 'List items (§07.2)', Column(children: [
                SsListTile(
                  title: 'Green Bites Café', subtitle: 'Donor · 2 km away',
                  leading: const SsAvatar(name: 'Green Bites Café', size: 44, verified: true),
                  onTap: () {}),
                const Divider(),
                SsListTile(
                  title: 'Helping Hands NGO', subtitle: 'Receiver · 4 km away',
                  leading: const SsAvatar(name: 'Helping Hands', size: 44),
                  trailing: const SsStatusBadge(status: SsStatus.allocated, dense: true),
                  onTap: () {}),
              ])),

              _section(context, 'Notifications (§07.14)', Column(children: [
                const SsNotificationTile(
                  title: 'New food available near you', body: 'Fresh vegetables at FreshMart, 3 km away.',
                  timeAgo: '2 min ago', icon: SsIcons.bell, unread: true),
                const SizedBox(height: SsSpacing.sm),
                const SsNotificationTile(
                  title: 'Your request was confirmed', body: 'Green Bites Café will have it ready by 4:00 PM.',
                  timeAgo: '10 min ago', icon: SsIcons.check, tone: SsNotificationTone.success),
              ])),

              _section(context, 'Location (§07.10, §11)', Row(children: [
                Expanded(child: SsLocationRow(
                  address: 'Jubilee Hills, Hyderabad', contactName: 'Rahul Mehta',
                  phone: '+91 98765 43210', locked: true)),
                const SizedBox(width: SsSpacing.lg),
                Expanded(child: SsLocationRow(
                  address: 'Plot 12, Hitech City, Hyderabad 500081',
                  contactName: 'Rahul Mehta', phone: '+91 98765 43210',
                  onDirections: () {}, onCall: () {})),
              ])),

              _section(context, 'Accordion (§07.5)', const SsAccordion(
                initiallyExpanded: 0,
                items: [
                  SsAccordionItem(
                    title: 'How does food rescue work?',
                    body: 'We connect food donors with nearby verified organisations to reduce food waste.'),
                  SsAccordionItem(title: 'What types of food can be shared?', body: ''),
                  SsAccordionItem(title: 'Is the food safe to consume?', body: ''),
                ])),

              _section(context, 'Bottom navigation (§06.5)', SsBottomNav(
                currentIndex: 0, onSelected: (_) {},
                destinations: const [
                  SsNavDestination(icon: SsIcons.home, label: 'Home'),
                  SsNavDestination(icon: SsIcons.map, label: 'Map'),
                  SsNavDestination(icon: SsIcons.addFood, label: 'Add'),
                  SsNavDestination(icon: SsIcons.message, label: 'Messages', badgeCount: 12),
                  SsNavDestination(icon: SsIcons.user, label: 'Profile'),
                ])),

              _section(context, 'Pagination (§06.11)', SsPagination(
                page: 3, pageCount: 12, onChanged: (_) {})),

              _section(context, 'File upload (§07.9)', SsFileUpload(onAdd: () {})),
            ],
          ),
        ),
      ),
      '03_cards_lists_nav',
      height: 1840,
    );
  });

  testWidgets('04 empty states and artwork', (tester) async {
    await _expectGolden(
      tester,
      _sheet(
        height: 1500,
        title: 'Empty states, illustrations and icons',
        child: Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section(context, 'Empty states with §09 artwork', Row(children: [
                Expanded(child: SsEmptyState(
                  illustration: SsIllustrations.noFoodAvailable,
                  title: 'No food nearby',
                  message: "We couldn't find any food near your location right now.",
                  primaryActionLabel: 'Try a different location',
                  onPrimaryAction: () {},
                  suggestions: const ['Expand your search area', 'Enable notifications'],
                )),
                Expanded(child: SsEmptyState(
                  illustration: SsIllustrations.noRequestsYet,
                  title: 'No requests yet',
                  message: 'Start by requesting food from nearby donors.',
                  primaryActionLabel: 'Request Food',
                  onPrimaryAction: () {},
                )),
                Expanded(child: SsEmptyState(
                  illustration: SsIllustrations.somethingWentWrong,
                  title: 'Something went wrong',
                  message: "We couldn't load the food items. Please check your connection.",
                  secondaryActionLabel: 'Try Again',
                  onSecondaryAction: () {},
                )),
              ])),

              _section(context, 'Illustrations (§09) — success and trust', Wrap(
                spacing: SsSpacing.xl, runSpacing: SsSpacing.lg, children: [
                  for (final art in [
                    SsIllustrations.requestSubmitted, SsIllustrations.foodReceived,
                    SsIllustrations.deliveryCompleted, SsIllustrations.impactUnlocked,
                    SsIllustrations.safeFood, SsIllustrations.verifiedDonor,
                    SsIllustrations.communityTrust, SsIllustrations.offline,
                  ])
                    SsIllustration(art, width: 110),
                ])),

              _section(context, 'Illustrations — roles and onboarding', Wrap(
                spacing: SsSpacing.xl, runSpacing: SsSpacing.lg, children: [
                  for (final art in [
                    SsIllustrations.roleDonor, SsIllustrations.roleReceiver,
                    SsIllustrations.roleVolunteer, SsIllustrations.roleAdmin,
                    SsIllustrations.onboardingWelcome, SsIllustrations.healthierPlanet,
                    SsIllustrations.lessFoodWaste,
                  ])
                    SsIllustration(art, width: 110),
                ])),

              _section(context, 'Icons (§05) — core, outline and filled', Builder(
                builder: (context) {
                  final c = context.ssColors;
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Wrap(spacing: SsSpacing.xl, runSpacing: SsSpacing.md, children: [
                      for (final n in SsIcons.coreNames)
                        SsIcon(SsIcons.all[n]!, size: SsIconSize.lg, color: c.onSurface),
                    ]),
                    const SizedBox(height: SsSpacing.lg),
                    Wrap(spacing: SsSpacing.xl, runSpacing: SsSpacing.md, children: [
                      for (final n in SsIcons.coreNames)
                        SsIcon(SsIcons.all[n]!, size: SsIconSize.lg, color: c.primary, filled: true),
                    ]),
                  ]);
                })),

              _section(context, 'Icons — category and UI', Builder(
                builder: (context) {
                  final c = context.ssColors;
                  final rest = SsIcons.all.entries.where((e) => !SsIcons.coreNames.contains(e.key));
                  return Wrap(spacing: SsSpacing.xl, runSpacing: SsSpacing.md, children: [
                    for (final e in rest) SsIcon(e.value, size: SsIconSize.md, color: c.onSurfaceVariant),
                  ]);
                })),
            ],
          ),
        ),
      ),
      '04_states_and_artwork',
      height: 1500,
    );
  });
  testWidgets('05 selectors, table, map', (tester) async {
    await _expectGolden(
      tester,
      _sheet(
        height: 1980,
        title: 'Selectors, table, map',
        child: Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section(context, 'Dropdowns & selectors (§06.8)', Column(children: [
                Row(children: [
                  Expanded(child: SsDropdown<String>(
                    label: 'Dropdown', hint: 'Select location',
                    prefixIcon: SsIcons.location,
                    items: const ['Hyderabad', 'Secunderabad'], onChanged: (_) {})),
                  const SizedBox(width: SsSpacing.xl),
                  Expanded(child: SsDropdown<String>(
                    label: 'Select (with options)', hint: 'Food Type',
                    prefixIcon: SsIcons.meals,
                    items: const ['Cooked Meals', 'Bakery'], onChanged: (_) {})),
                ]),
                const SizedBox(height: SsSpacing.lg),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Checkbox', style: SsTypeScale.small.copyWith(
                      color: context.ssColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                    SsCheckbox(value: true, onChanged: (_) {},
                      label: 'I agree to the', linkText: 'terms and conditions'),
                    const SizedBox(height: SsSpacing.md),
                    Text('Radio Buttons', style: SsTypeScale.small.copyWith(
                      color: context.ssColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                    SsRadioGroup<String>(
                      options: const ['Individual', 'Organization'],
                      value: 'Individual', onChanged: (_) {}),
                  ])),
                  const SizedBox(width: SsSpacing.xxl),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Toggle Switch', style: SsTypeScale.small.copyWith(
                      color: context.ssColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                    const SizedBox(height: SsSpacing.sm),
                    SsSwitch(value: true, onChanged: (_) {},
                      label: 'Notifications', caption: 'Receive notifications'),
                  ])),
                ]),
              ])),

              _section(context, 'Selection controls — all states (§07.15)', Row(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SsCheckbox(value: false, onChanged: (_) {}, label: 'Unchecked'),
                    SsCheckbox(value: true, onChanged: (_) {}, label: 'Checked'),
                    const SsCheckbox(value: false, onChanged: null, label: 'Disabled', enabled: false),
                  ])),
                  Expanded(child: SsRadioGroup<String>(
                    axis: Axis.vertical,
                    options: const ['Option 1', 'Option 2', 'Disabled'],
                    disabledOptions: const {'Disabled'},
                    value: 'Option 2', onChanged: (_) {})),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SsSwitch(value: true, onChanged: (_) {}, label: 'Enabled'),
                    const SsSwitch(value: false, onChanged: null, label: 'Disabled', enabled: false),
                    SsSwitch(value: true, onChanged: (_) {},
                      label: 'With label', caption: 'Receive notifications'),
                  ])),
                ])),

              _section(context, 'Slider (§07.7) and date & time (§07.8)', Row(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: SsSlider(
                    label: 'Distance', value: 25, min: 0, max: 50,
                    formatValue: (v) => '${v.round()} km', onChanged: (_) {})),
                  const SizedBox(width: SsSpacing.xxl),
                  Expanded(child: Column(children: [
                    SsDateTimeField(value: DateTime(2026, 9, 8), onChanged: (_) {}),
                    const SizedBox(height: SsSpacing.md),
                    SsDateTimeField(mode: SsDateTimeMode.time,
                      value: DateTime(2026, 9, 8, 10, 30), onChanged: (_) {}),
                  ])),
                ])),

              _section(context, 'Search & filters (§07.3) and tabs (§07.4)', Column(children: [
                SsSearchField(onFilterTap: () {}),
                const SizedBox(height: SsSpacing.lg),
                SsFilterBar(
                  onSelectAll: () {}, onClearAll: () {},
                  chips: [
                    SsFilterDropdownChip(label: 'Food Type', onTap: () {}),
                    SsFilterDropdownChip(label: 'Distance', onTap: () {}),
                    SsFilterDropdownChip(label: 'Availability', onTap: () {}),
                    SsFilterDropdownChip(label: 'Donor Type', onTap: () {}),
                    SsFilterDropdownChip(label: 'Expiry Time', onTap: () {}),
                  ]),
                const SizedBox(height: SsSpacing.lg),
                SsTabs(
                  labels: const ['Available', 'Requested', 'Completed', 'Cancelled'],
                  currentIndex: 0, onSelected: (_) {}),
              ])),

              _section(context, 'Top navigation (§06.5 web)', SsTopNav(
                logo: const SsLogo.horizontal(height: 34),
                links: const ['Find Food', 'Donate', 'Impact'],
                currentIndex: 0, onLinkSelected: (_) {},
                onSearch: () {}, onNotifications: () {}, hasUnreadNotifications: true,
                account: const SsAvatar(name: 'Aditi Sharma', size: 36), onAccount: () {})),

              _section(context, 'Data table (§07.1)', SsDataTable<_Food>(
                selectable: true, selected: const {'2'},
                onSelectionChanged: (_) {}, onRowMenu: (_) {},
                rowId: (f) => f.id,
                leading: (context, f) => ColoredBox(
                  color: context.ssColors.primaryContainer,
                  child: SsIllustration(f.art, width: 30, semanticLabel: '')),
                rows: const [
                  _Food('1', 'Veg Pulao', 'Green Bites Café', '12 kg', SsStatus.live,
                      'Aug 12, 2024', SsIllustrations.goodFoodShared),
                  _Food('2', 'Samosas', 'Hotel Sunrise', '50 pcs', SsStatus.allocated,
                      'Aug 12, 2024', SsIllustrations.foodReceived),
                  _Food('3', 'Fresh Fruits', 'FreshMart', '20 kg', SsStatus.collected,
                      'Aug 11, 2024', SsIllustrations.lessFoodWaste),
                  _Food('4', 'Bread Loaves', 'Daily Bakery', '30 pcs', SsStatus.pendingCheck,
                      'Aug 11, 2024', SsIllustrations.nourishPeople),
                ],
                columns: [
                  SsColumn(header: 'Food Item', cell: (ctx, f) => Text(f.name,
                    style: SsTypeScale.small.copyWith(
                      color: ctx.ssColors.onSurface, fontWeight: FontWeight.w600))),
                  SsColumn(header: 'Donor', cell: (ctx, f) => Text(f.donor,
                    style: SsTypeScale.small.copyWith(color: ctx.ssColors.onSurfaceVariant))),
                  SsColumn(header: 'Quantity', width: 90, cell: (ctx, f) => Text(f.qty,
                    style: SsTypeScale.small.copyWith(color: ctx.ssColors.onSurfaceVariant))),
                  SsColumn(header: 'Status', width: 140,
                    cell: (ctx, f) => SsStatusBadge(status: f.status, dense: true)),
                  SsColumn(header: 'Date', width: 120, cell: (ctx, f) => Text(f.date,
                    style: SsTypeScale.small.copyWith(color: ctx.ssColors.onSurfaceVariant))),
                ])),

              _section(context, 'Map & location (§07.10) and stat cards (§06.3)', Row(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: SsMapCard(
                    calloutTitle: 'Green Bites Café', calloutSubtitle: '2 km away',
                    onAction: () {}, onZoomIn: () {}, onZoomOut: () {})),
                  const SizedBox(width: SsSpacing.xl),
                  const Expanded(flex: 2, child: SsStatCard(
                    value: '1,240 kg', label: 'Food Saved This Month',
                    sparkline: [3, 4, 3.5, 5, 4.5, 6, 5.5, 7, 8],
                    delta: '+18% from last month', deltaDirection: SsDelta.up)),
                ])),
            ],
          ),
        ),
      ),
      '05_selectors_table_map',
      height: 1980,
    );
  });
}

class _Food {
  const _Food(this.id, this.name, this.donor, this.qty, this.status, this.date, this.art);
  final String id, name, donor, qty, date;
  final SsStatus status;
  final SsArtwork art;
}
