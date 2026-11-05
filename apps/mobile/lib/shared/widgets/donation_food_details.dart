import 'package:flutter/material.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../features/donation/domain/donation.dart';
import '../utils/food_labels.dart';

/// Food photo (if any) plus food type, veg/non-veg and expiry tags.
/// Used on both the donor's and the NGO's donation detail screens.
class DonationFoodDetails extends StatelessWidget {
  const DonationFoodDetails({super.key, required this.donation});

  final Donation donation;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final diet = FoodLabels.diet(donation.dietType);
    final imageUrl = donation.imageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(SsRadius.md),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Container(
                        color: c.surface,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
                errorBuilder: (context, _, _) => Container(
                  color: c.surface,
                  alignment: Alignment.center,
                  child: Text(
                    'Photo unavailable',
                    style: SsTypeScale.small.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: SsSpacing.lg),
        ],
        Wrap(
          spacing: SsSpacing.sm,
          runSpacing: SsSpacing.sm,
          children: [
            SsTag(
              label: FoodLabels.category(donation.foodCategory),
              icon: SsIcons.food,
            ),
            if (diet != null)
              SsTag(
                label: diet,
                icon: SsIcons.leaf,
                tone: donation.dietType == 'veg'
                    ? SsTagTone.positive
                    : SsTagTone.warm,
              ),
            if (donation.expiresAt != null)
              SsTag(
                label: FoodLabels.expiry(donation.expiresAt!, DateTime.now()),
                icon: SsIcons.time,
                tone: SsTagTone.info,
              ),
          ],
        ),
        const SizedBox(height: SsSpacing.lg),
      ],
    );
  }
}
