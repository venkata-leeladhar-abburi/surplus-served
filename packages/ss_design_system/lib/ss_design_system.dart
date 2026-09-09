/// Surplus → Served design system.
///
/// The single Flutter entry point. Import this and nothing under `src/`:
///
/// ```dart
/// import 'package:ss_design_system/ss_design_system.dart';
///
/// MaterialApp(
///   theme: SsTheme.light(),
///   darkTheme: SsTheme.dark(),
/// );
/// ```
///
/// Tokens in `src/tokens/tokens.g.dart` are generated from
/// `design/tokens/tokens.json` — never edit them by hand.
library;

export 'src/tokens/tokens.g.dart';

export 'src/artwork/ss_artwork.dart';
export 'src/artwork/ss_artwork.g.dart';

export 'src/icons/ss_icon.dart';
export 'src/icons/ss_icons.g.dart';

export 'src/theme/ss_colors.dart';
export 'src/theme/ss_theme.dart';
export 'src/theme/ss_typography.dart';

export 'src/components/ss_button.dart';
export 'src/components/ss_data_display.dart';
export 'src/components/ss_data_table.dart';
export 'src/components/ss_donation_card.dart';
export 'src/components/ss_feedback.dart';
export 'src/components/ss_inputs.dart';
export 'src/components/ss_navigation.dart';
export 'src/components/ss_overlays.dart';
export 'src/components/ss_selectors.dart';
export 'src/components/ss_status_badge.dart';
