/// Display text for the donation food fields.
///
/// Keys match the backend enums in apps/backend/models/Donation.js.
abstract final class FoodLabels {
  static const categories = <String, String>{
    'cooked_meal': 'Cooked meal',
    'bakery': 'Bakery',
    'fruits_vegetables': 'Fruits & vegetables',
    'dairy': 'Dairy',
    'groceries': 'Groceries',
    'beverages': 'Beverages',
    'other': 'Other',
  };

  static const diets = <String, String>{
    'veg': 'Veg',
    'non_veg': 'Non-veg',
  };

  static String category(String key) => categories[key] ?? 'Other';

  static String? diet(String? key) => key == null ? null : diets[key];

  /// e.g. "Safe until 14:30" or "Safe until 06/11 09:00" if not today.
  static String expiry(DateTime expiresAt, DateTime now) {
    final local = expiresAt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    final time = '${two(local.hour)}:${two(local.minute)}';
    final sameDay = local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;

    if (!local.isAfter(now)) return 'Expired';

    return sameDay
        ? 'Safe until $time'
        : 'Safe until ${two(local.day)}/${two(local.month)} $time';
  }
}
