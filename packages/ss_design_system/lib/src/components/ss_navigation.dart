import 'package:flutter/material.dart';

import '../icons/ss_icon.dart';
import '../icons/ss_icons.g.dart';
import '../theme/ss_colors.dart';
import '../tokens/tokens.g.dart';

/// One destination in the bottom bar.
class SsNavDestination {
  const SsNavDestination({
    required this.icon,
    required this.label,
    this.badgeCount,
    this.showDot = false,
  });

  final SsIconData icon;
  final String label;

  /// Unread count. Rendered as a number up to 9, then "9+".
  final int? badgeCount;
  final bool showDot;
}

/// §06.5 Bottom navigation (mobile) — Home · Map · Add · Messages · Profile.
///
/// The selected item switches to the filled icon variant (§05.4) as well as
/// changing colour, so selection is never signalled by colour alone.
class SsBottomNav extends StatelessWidget {
  const SsBottomNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<SsNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavItem(
                    destination: destinations[i],
                    selected: i == currentIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final SsNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final color = selected ? c.primary : c.onSurfaceVariant;
    final count = destination.badgeCount;

    return Semantics(
      button: true,
      selected: selected,
      label: [
        destination.label,
        if (count != null && count > 0) '$count new',
      ].join(', '),
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SsIcon(
                    destination.icon,
                    size: SsIconSize.md,
                    color: color,
                    filled: selected,
                  ),
                  if (count != null && count > 0)
                    Positioned(
                      top: -5,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        constraints: const BoxConstraints(minWidth: 18),
                        decoration: BoxDecoration(
                          color: c.alert,
                          borderRadius: BorderRadius.circular(SsRadius.pill),
                          border: Border.all(color: c.surface, width: 1.5),
                        ),
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          textAlign: TextAlign.center,
                          style: SsTypeScale.caption.copyWith(
                            color: c.onAlert,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            height: 1.4,
                          ),
                        ),
                      ),
                    )
                  else if (destination.showDot)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: c.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.surface, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: SsSpacing.xs),
              Text(
                destination.label,
                style: SsTypeScale.caption.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// §07.4 Segmented tabs — "Available · Requested · Completed · Cancelled".
///
/// A segmented control rather than a [TabBar] where the sections are filters
/// over one list, which is how every list screen in the product uses them.
class SsSegmentedTabs extends StatelessWidget {
  const SsSegmentedTabs({
    super.key,
    required this.labels,
    required this.currentIndex,
    required this.onSelected,
    this.counts = const {},
  });

  final List<String> labels;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  /// Optional per-tab counts — "Pending (3)".
  final Map<int, int> counts;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return Container(
      padding: const EdgeInsets.all(SsSpacing.xs),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(SsRadius.md),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == currentIndex,
                label: labels[i],
                child: ExcludeSemantics(
                  child: GestureDetector(
                    onTap: () => onSelected(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: SsDuration.fast,
                      height: SsA11y.minTapTarget - 8,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == currentIndex ? c.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(SsRadius.sm),
                        boxShadow: i == currentIndex ? SsShadows.sm : null,
                      ),
                      child: FittedBox(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: SsSpacing.sm),
                          child: Text(
                            counts.containsKey(i)
                                ? '${labels[i]} (${counts[i]})'
                                : labels[i],
                            style: SsTypeScale.small.copyWith(
                              color: i == currentIndex ? c.primary : c.onSurfaceVariant,
                              fontWeight: i == currentIndex
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// §06.11 Pagination — for the admin console's lists and search results.
class SsPagination extends StatelessWidget {
  const SsPagination({
    super.key,
    required this.page,
    required this.pageCount,
    required this.onChanged,
    this.maxVisible = 5,
  });

  /// 1-based.
  final int page;
  final int pageCount;
  final ValueChanged<int> onChanged;
  final int maxVisible;

  List<int> get _window {
    if (pageCount <= maxVisible) {
      return [for (var i = 1; i <= pageCount; i++) i];
    }
    final half = maxVisible ~/ 2;
    var start = (page - half).clamp(1, pageCount - maxVisible + 1);
    return [for (var i = 0; i < maxVisible; i++) start + i];
  }

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) return const SizedBox.shrink();

    return Semantics(
      label: 'Page $page of $pageCount',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Step(
              icon: SsIcons.chevronLeft,
              tooltip: 'Previous page',
              onTap: page > 1 ? () => onChanged(page - 1) : null,
            ),
            const SizedBox(width: SsSpacing.xs),
            for (final p in _window) ...[
              _PageDot(page: p, selected: p == page, onTap: () => onChanged(p)),
              const SizedBox(width: SsSpacing.xs),
            ],
            _Step(
              icon: SsIcons.chevronRight,
              tooltip: 'Next page',
              onTap: page < pageCount ? () => onChanged(page + 1) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.page, required this.selected, required this.onTap});

  final int page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Material(
      color: selected ? c.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(SsRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SsRadius.sm),
        child: SizedBox(
          height: SsA11y.minTapTarget,
          width: SsA11y.minTapTarget,
          child: Center(
            child: Text(
              '$page',
              style: SsTypeScale.small.copyWith(
                color: selected ? c.onPrimary : c.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.tooltip, this.onTap});

  final SsIconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(SsRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SsRadius.sm),
          child: SizedBox(
            height: SsA11y.minTapTarget,
            width: SsA11y.minTapTarget,
            child: SsIcon(
              icon,
              size: SsIconSize.sm,
              color: onTap == null ? c.muted : c.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// §07.4 Tabs — the underline variant.
///
/// Used where the tabs switch *what* you are looking at (Available, Requested,
/// Completed, Cancelled). Use [SsSegmentedTabs] instead where they filter one
/// list in place.
class SsTabs extends StatelessWidget {
  const SsTabs({
    super.key,
    required this.labels,
    required this.currentIndex,
    required this.onSelected,
    this.scrollable = false,
  });

  final List<String> labels;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    final row = Row(
      mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
      children: [
        for (var i = 0; i < labels.length; i++)
          _Tab(
            label: labels[i],
            selected: i == currentIndex,
            expand: !scrollable,
            onTap: () => onSelected(i),
          ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: scrollable
          ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: row)
          : row,
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.expand,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool expand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    final tab = Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: SsA11y.minTapTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: SsSpacing.lg,
              vertical: SsSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: selected ? c.primary : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
            child: Center(
              widthFactor: expand ? null : 1,
              child: Text(
                label,
                style: SsTypeScale.small.copyWith(
                  color: selected ? c.primary : c.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return expand ? Expanded(child: tab) : tab;
  }
}

/// §06.5 Top navigation (web).
///
/// The admin console and any future marketing surface share this bar: logo,
/// primary links, then search, notifications and the account menu.
class SsTopNav extends StatelessWidget {
  const SsTopNav({
    super.key,
    required this.logo,
    this.links = const [],
    this.currentIndex,
    this.onLinkSelected,
    this.onSearch,
    this.onNotifications,
    this.hasUnreadNotifications = false,
    this.account,
    this.onAccount,
  });

  /// Pass `SsLogo.horizontal(height: 32)`.
  final Widget logo;

  final List<String> links;
  final int? currentIndex;
  final ValueChanged<int>? onLinkSelected;

  final VoidCallback? onSearch;
  final VoidCallback? onNotifications;
  final bool hasUnreadNotifications;

  /// Pass an `SsAvatar`.
  final Widget? account;
  final VoidCallback? onAccount;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: SsSpacing.xl),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          logo,
          const SizedBox(width: SsSpacing.xxl),
          for (var i = 0; i < links.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: SsSpacing.xl),
              child: Semantics(
                button: true,
                selected: i == currentIndex,
                label: links[i],
                child: ExcludeSemantics(
                  child: InkWell(
                    onTap: () => onLinkSelected?.call(i),
                    borderRadius: BorderRadius.circular(SsRadius.sm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SsSpacing.sm,
                        vertical: SsSpacing.md,
                      ),
                      child: Text(
                        links[i],
                        style: SsTypeScale.body.copyWith(
                          color: i == currentIndex ? c.primary : c.onSurface,
                          fontWeight:
                              i == currentIndex ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const Spacer(),
          if (onSearch != null)
            _NavAction(icon: SsIcons.search, tooltip: 'Search', onPressed: onSearch),
          if (onNotifications != null) ...[
            const SizedBox(width: SsSpacing.sm),
            _NavAction(
              icon: SsIcons.bell,
              tooltip: hasUnreadNotifications
                  ? 'Notifications, unread'
                  : 'Notifications',
              onPressed: onNotifications,
              dot: hasUnreadNotifications,
            ),
          ],
          if (account != null) ...[
            const SizedBox(width: SsSpacing.lg),
            Semantics(
              button: true,
              label: 'Account menu',
              child: ExcludeSemantics(
                child: InkWell(
                  onTap: onAccount,
                  borderRadius: BorderRadius.circular(SsRadius.pill),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      account!,
                      const SizedBox(width: SsSpacing.xs),
                      SsIcon(
                        SsIcons.chevronDown,
                        size: SsIconSize.sm,
                        color: c.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavAction extends StatelessWidget {
  const _NavAction({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.dot = false,
  });

  final SsIconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: ExcludeSemantics(
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              height: SsA11y.minTapTarget,
              width: SsA11y.minTapTarget,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SsIcon(icon, size: SsIconSize.md, color: c.onSurface),
                  if (dot)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: c.alert,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.surface, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
