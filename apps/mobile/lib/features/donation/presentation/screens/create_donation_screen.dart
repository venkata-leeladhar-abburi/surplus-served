import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/providers.dart';
import '../../domain/donation.dart';

const _steps = [
  "What's ready to go?",
  'How many portions?',
  'Pickup window',
  'Pickup address',
  'Review and post',
];

class CreateDonationScreen extends ConsumerStatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  ConsumerState<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends ConsumerState<CreateDonationScreen> {
  int _step = 0;
  bool _posting = false;

  final _titleController = TextEditingController(text: '');
  final _descriptionController = TextEditingController();
  int _portions = 20;
  Duration _window = const Duration(hours: 2);
  final _localityController = TextEditingController();

  bool get _canAdvance => switch (_step) {
        0 => _titleController.text.trim().isNotEmpty,
        1 => _portions > 0,
        2 => true,
        3 => _localityController.text.trim().isNotEmpty,
        _ => true,
      };

  Future<void> _post() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    setState(() => _posting = true);
    final now = DateTime.now();
    final donation = await ref.read(donationRepositoryProvider).create(
          donorId: session.userId,
          donorName: session.name,
          title: _titleController.text.trim(),
          description:
              _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          portions: _portions,
          pickupWindowStart: now,
          pickupWindowEnd: now.add(_window),
          address: PickupAddress(locality: _localityController.text.trim()),
        );
    if (!mounted) return;
    context.goNamed('donorDonationDetail', pathParameters: {'id': donation.id});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
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
            SsStepper(steps: _steps, currentIndex: _step),
            const SizedBox(height: SsSpacing.xl),
            Expanded(child: _buildStep(c)),
            const SizedBox(height: SsSpacing.lg),
            SsButton.primary(
              label: _step == _steps.length - 1 ? 'Post surplus food' : 'Next',
              expand: true,
              isLoading: _posting,
              onPressed: _canAdvance && !_posting
                  ? () {
                      if (_step == _steps.length - 1) {
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

  Widget _buildStep(SsColors c) {
    switch (_step) {
      case 0:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_steps[0], style: SsTypeScale.h3.copyWith(color: c.onSurface)),
              const SizedBox(height: SsSpacing.lg),
              SsTextField(
                label: 'What is it?',
                hint: 'e.g. Vegetable biryani, 40 portions',
                controller: _titleController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: SsSpacing.md),
              SsTextField(
                label: 'Anything an NGO should know? (optional)',
                controller: _descriptionController,
                maxLines: 3,
              ),
            ],
          ),
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_steps[1], style: SsTypeScale.h3.copyWith(color: c.onSurface)),
            const SizedBox(height: SsSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SsIconButton(
                  icon: SsIcons.minus,
                  tooltip: 'Fewer portions',
                  onPressed: _portions > 1 ? () => setState(() => _portions -= 5) : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SsSpacing.xl),
                  child: Text('$_portions', style: SsTypeScale.h1.copyWith(color: c.onSurface)),
                ),
                SsIconButton(
                  icon: SsIcons.plus,
                  tooltip: 'More portions',
                  onPressed: () => setState(() => _portions += 5),
                ),
              ],
            ),
            const SizedBox(height: SsSpacing.sm),
            Center(
              child: Text('portions', style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant)),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_steps[2], style: SsTypeScale.h3.copyWith(color: c.onSurface)),
            const SizedBox(height: SsSpacing.sm),
            Text(
              'How long can an NGO safely collect this for?',
              style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
            ),
            const SizedBox(height: SsSpacing.lg),
            for (final hours in [1, 2, 3, 4])
              Padding(
                padding: const EdgeInsets.only(bottom: SsSpacing.sm),
                child: _WindowOption(
                  label: '$hours hour${hours == 1 ? '' : 's'}',
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
              Text(_steps[3], style: SsTypeScale.h3.copyWith(color: c.onSurface)),
              const SizedBox(height: SsSpacing.sm),
              Text(
                'Only the locality is shown until an NGO is matched — the exact '
                'address is shared with them alone (§11).',
                style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: SsSpacing.lg),
              SsTextField(
                label: 'Locality',
                hint: 'e.g. Jubilee Hills, Hyderabad',
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
              Text(_steps[4], style: SsTypeScale.h3.copyWith(color: c.onSurface)),
              const SizedBox(height: SsSpacing.lg),
              _ReviewRow(label: 'Food', value: _titleController.text),
              _ReviewRow(label: 'Portions', value: '$_portions'),
              _ReviewRow(label: 'Pickup window', value: '${_window.inHours} hr from posting'),
              _ReviewRow(label: 'Locality', value: _localityController.text),
              const SizedBox(height: SsSpacing.lg),
              SsAlert(
                message: 'This goes live immediately and is visible to nearby NGOs.',
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _WindowOption extends StatelessWidget {
  const _WindowOption({required this.label, required this.selected, required this.onTap});

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
              SsIcon(SsIcons.time, color: selected ? c.primary : c.onSurfaceVariant),
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
          Expanded(child: Text(label, style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant))),
          Expanded(
            child: Text(value, style: SsTypeScale.body.copyWith(color: c.onSurface, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
