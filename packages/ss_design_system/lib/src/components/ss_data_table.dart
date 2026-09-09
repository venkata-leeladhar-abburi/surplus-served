import 'package:flutter/material.dart';

import '../icons/ss_icon.dart';
import '../icons/ss_icons.g.dart';
import '../theme/ss_colors.dart';
import '../tokens/tokens.g.dart';

/// One column of an [SsDataTable].
class SsColumn<T> {
  const SsColumn({
    required this.header,
    required this.cell,
    this.width,
    this.align = TextAlign.left,
    this.numeric = false,
  });

  final String header;

  /// Builds the cell body. Return a [Text] for plain values, or any widget —
  /// the status column returns an [SsStatusBadge].
  final Widget Function(BuildContext, T) cell;

  /// Fixed width, or null to share the remaining space equally.
  final double? width;

  final TextAlign align;
  final bool numeric;
}

/// §07.1 Data table.
///
/// Built for the admin console's verification queue and live-ops feed: a
/// select-all checkbox, a leading thumbnail beside the primary value, a status
/// column, and a row overflow menu.
///
/// Scrolls horizontally inside itself so the page never does.
class SsDataTable<T> extends StatelessWidget {
  const SsDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowId,
    this.selectable = false,
    this.selected = const {},
    this.onSelectionChanged,
    this.onRowTap,
    this.onRowMenu,
    this.leading,
    this.minWidth = 720,
    this.emptyState,
  });

  final List<SsColumn<T>> columns;
  final List<T> rows;

  /// Stable identity for a row — used for selection and as the widget key.
  final String Function(T) rowId;

  final bool selectable;
  final Set<String> selected;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final void Function(T)? onRowTap;

  /// Renders the trailing "···" menu when provided.
  final void Function(T)? onRowMenu;

  /// Leading visual for each row — the food thumbnail in §07.1.
  final Widget Function(BuildContext, T)? leading;

  final double minWidth;
  final Widget? emptyState;

  bool get _allSelected => rows.isNotEmpty && selected.length == rows.length;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    if (rows.isEmpty && emptyState != null) {
      return Container(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.border),
          borderRadius: BorderRadius.circular(SsRadius.lg),
        ),
        child: emptyState,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(SsRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      // The width has to be resolved OUTSIDE the horizontal scroll view:
      // inside it the constraint is unbounded, and flexible cells cannot lay
      // out against infinity.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? (constraints.maxWidth > minWidth ? constraints.maxWidth : minWidth)
              : minWidth;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _header(context, c),
                  for (var i = 0; i < rows.length; i++) _row(context, c, rows[i], i),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, SsColors c) {
    return Container(
      color: c.surfaceAlt,
      padding: const EdgeInsets.symmetric(
        horizontal: SsSpacing.lg,
        vertical: SsSpacing.md,
      ),
      child: Row(
        children: [
          if (selectable) ...[
            _SelectBox(
              value: _allSelected,
              indeterminate: selected.isNotEmpty && !_allSelected,
              semanticLabel: 'Select all rows',
              onChanged: (on) => onSelectionChanged?.call(
                on ? rows.map(rowId).toSet() : <String>{},
              ),
            ),
            const SizedBox(width: SsSpacing.lg),
          ],
          for (final col in columns)
            _cellBox(
              col,
              Text(
                col.header,
                textAlign: col.align,
                style: SsTypeScale.small.copyWith(
                  color: c.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (onRowMenu != null)
            SizedBox(
              width: 56,
              child: Text(
                'Actions',
                style: SsTypeScale.small.copyWith(
                  color: c.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, SsColors c, T row, int index) {
    final id = rowId(row);
    final isSelected = selected.contains(id);

    return Material(
      color: isSelected ? c.primaryContainer.withValues(alpha: 0.4) : c.surface,
      child: InkWell(
        onTap: onRowTap == null ? null : () => onRowTap!(row),
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.border)),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: SsSpacing.lg,
            vertical: SsSpacing.md,
          ),
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              if (selectable) ...[
                _SelectBox(
                  value: isSelected,
                  semanticLabel: 'Select row ${index + 1}',
                  onChanged: (on) {
                    final next = Set<String>.of(selected);
                    on ? next.add(id) : next.remove(id);
                    onSelectionChanged?.call(next);
                  },
                ),
                const SizedBox(width: SsSpacing.lg),
              ],
              for (var i = 0; i < columns.length; i++)
                _cellBox(
                  columns[i],
                  i == 0 && leading != null
                      ? Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(SsRadius.sm),
                              child: SizedBox(
                                height: 36,
                                width: 36,
                                child: leading!(context, row),
                              ),
                            ),
                            const SizedBox(width: SsSpacing.md),
                            Expanded(child: columns[i].cell(context, row)),
                          ],
                        )
                      : columns[i].cell(context, row),
                ),
              if (onRowMenu != null)
                SizedBox(
                  width: 56,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => onRowMenu!(row),
                      tooltip: 'More actions',
                      icon: SsIcon(
                        SsIcons.more,
                        size: SsIconSize.sm,
                        color: c.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cellBox(SsColumn<T> col, Widget child) {
    final aligned = Align(
      alignment: switch (col.align) {
        TextAlign.right => Alignment.centerRight,
        TextAlign.center => Alignment.center,
        _ => Alignment.centerLeft,
      },
      child: child,
    );
    return col.width != null
        ? SizedBox(width: col.width, child: aligned)
        : Expanded(child: aligned);
  }
}

class _SelectBox extends StatelessWidget {
  const _SelectBox({
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    this.indeterminate = false,
  });

  final bool value;
  final bool indeterminate;
  final ValueChanged<bool> onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final on = value || indeterminate;

    return Semantics(
      checked: value,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(SsRadius.xs + 2),
          child: Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              color: on ? c.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(SsRadius.xs + 2),
              border: Border.all(color: on ? c.primary : c.border, width: 1.5),
            ),
            child: on
                ? SsIcon(
                    indeterminate ? SsIcons.minus : SsIcons.check,
                    size: 14,
                    color: c.onPrimary,
                    strokeWidth: 3,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
