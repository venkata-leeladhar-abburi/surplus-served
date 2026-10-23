import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';
import '../../../../shared/widgets/connectivity_banner.dart';
import '../../domain/donation.dart';

List<String> _steps(AppLocalizations l10n) => [
  l10n.donorCreateStepDetails,
  l10n.donorCreateStepPortions,
  l10n.donorCreateStepWindow,
  l10n.donorCreateStepAddress,
  l10n.donorCreateStepReview,
];

class CreateDonationScreen extends ConsumerStatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  ConsumerState<CreateDonationScreen> createState() =>
      _CreateDonationScreenState();
}

class _CreateDonationScreenState extends ConsumerState<CreateDonationScreen> {
  int _step = 0;
  bool _posting = false;

  final _titleController = TextEditingController(text: '');
  final _descriptionController = TextEditingController();
  final _portionsController=TextEditingController(text: '20');
  Duration _window = const Duration(hours: 2);
  final _localityController = TextEditingController();

  bool get _canAdvance => switch (_step) {
    0 => _titleController.text.trim().isNotEmpty,
    1 => (int.tryParse(_portionsController.text) ?? 0) > 0,
    2 => true,
    3 => _localityController.text.trim().isNotEmpty,
    _ => true,
  };

  Future<void> _post() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    
    setState(() => _posting = true);
    final now = DateTime.now();

    try {
      final donation = await ref
          .read(donationRepositoryProvider)
          .create(
            donorId: session.userId,
            donorName: session.name,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            portions: int.tryParse(_portionsController.text) ?? 1,
            pickupWindowStart: now,
            pickupWindowEnd: now.add(_window),
            address: PickupAddress(locality: _localityController.text.trim()),
            authToken: session.token, // <-- FIX 1: Pass JWT token here!
          );

      if (!mounted) return;
      context.goNamed('donorDonationDetail', pathParameters: {'id': donation.id});
    } catch (e) {
      if (!mounted) return;
      
      // FIX 2: Show clear SnackBar alert if the backend returns an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post donation: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _posting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final l10n = AppLocalizations.of(context)!;
    final steps = _steps(l10n);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          icon: SsIcon(SsIcons.arrowLeft, color: c.onSurface),
          onPressed: () {
            if (_step == 0) {
              context.pop();
            } else {
              setState(() => _step -= 1);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(SsSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ConnectivityBanner(),
            SsStepper(steps: steps, currentIndex: _step),
            const SizedBox(height: SsSpacing.xl),
            Expanded(child: _buildStep(c, l10n, steps)),
            const SizedBox(height: SsSpacing.lg),
            SsButton.primary(
              label: _step == steps.length - 1
                  ? l10n.donorCreateCta
                  : l10n.commonNext,
              expand: true,
              isLoading: _posting,
              onPressed: _canAdvance && !_posting
                  ? () {
                      if (_step == steps.length - 1) {
                        _post();
                      } else {
                        setState(() => _step += 1);
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(SsColors c, AppLocalizations l10n, List<String> steps) {
    switch (_step) {
      case 0:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                steps[0],
                style: SsTypeScale.h3.copyWith(color: c.onSurface),
              ),
              const SizedBox(height: SsSpacing.lg),
              SsTextField(
                label: l10n.donorCreateFoodLabel,
                hint: l10n.donorCreateFoodHint,
                controller: _titleController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: SsSpacing.md),
              SsTextField(
                label: l10n.donorCreateNotesLabel,
                controller: _descriptionController,
                maxLines: 3,
              ),
            ],
          ),
        );
     case 1:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(steps[1], style: SsTypeScale.h3.copyWith(color: c.onSurface)),
              const SizedBox(height: SsSpacing.xl),
              SsTextField(
                label: l10n.donorCreatePortionsUnit,
                hint: 'Enter number of portions',
                controller: _portionsController,
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: SsSpacing.sm),
              Center(
                child: Text(
                  'Enter the total number of portions available',
                  style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
                ),
              ),
            ],
          ),
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(steps[2], style: SsTypeScale.h3.copyWith(color: c.onSurface)),
            const SizedBox(height: SsSpacing.sm),
            Text(
              l10n.donorCreateWindowSubtitle,
              style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
            ),
            const SizedBox(height: SsSpacing.lg),
            for (final hours in [1, 2, 3, 4])
              Padding(
                padding: const EdgeInsets.only(bottom: SsSpacing.sm),
                child: _WindowOption(
                  label: l10n.donorCreateWindowOption(hours),
                  selected: _window.inHours == hours,
                  onTap: () => setState(() => _window = Duration(hours: hours)),
                ),
              ),
          ],
        );
      case 3:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                steps[3],
                style: SsTypeScale.h3.copyWith(color: c.onSurface),
              ),
              const SizedBox(height: SsSpacing.sm),
              Text(
                l10n.donorCreateAddressPrivacyNote,
                style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: SsSpacing.lg),
              SsTextField(
                label: l10n.commonLocality,
                hint: l10n.donorCreateLocalityHint,
                controller: _localityController,
                prefixIcon: SsIcons.location,
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        );
      case 4:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                steps[4],
                style: SsTypeScale.h3.copyWith(color: c.onSurface),
              ),
              const SizedBox(height: SsSpacing.lg),
              _ReviewRow(
                label: l10n.donorCreateReviewFoodLabel,
                value: _titleController.text,
              ),
              _ReviewRow(
                label: l10n.donorCreateReviewPortionsLabel,
                value: _portionsController.text,
              ),
              _ReviewRow(
                label: l10n.donorCreateReviewWindowLabel,
                value: l10n.donorCreateReviewWindowValue(_window.inHours),
              ),
              _ReviewRow(
                label: l10n.donorCreateReviewLocalityLabel,
                value: _localityController.text,
              ),
              const SizedBox(height: SsSpacing.lg),
              SsAlert(message: l10n.donorCreateLiveAlert),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _WindowOption extends StatelessWidget {
  const _WindowOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Material(
      color: selected ? c.primaryContainer : c.surface,
      borderRadius: BorderRadius.circular(SsRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(SsRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(SsSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? c.primary : c.border),
            borderRadius: BorderRadius.circular(SsRadius.md),
          ),
          child: Row(
            children: [
              SsIcon(
                SsIcons.time,
                color: selected ? c.primary : c.onSurfaceVariant,
              ),
              const SizedBox(width: SsSpacing.md),
              Text(
                label,
                style: SsTypeScale.body.copyWith(
                  color: selected ? c.onPrimaryContainer : c.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const Spacer(),
              if (selected) SsIcon(SsIcons.check, color: c.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: SsSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: SsTypeScale.body.copyWith(
                color: c.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
