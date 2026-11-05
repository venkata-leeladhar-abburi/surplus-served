import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_design_system/ss_design_system.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/providers.dart';
import '../../../../shared/utils/allocation_status_mapper.dart';
import '../../../../shared/widgets/connectivity_banner.dart';
import '../../../../shared/widgets/text_input_dialog.dart';
import '../../domain/admin_models.dart';
import '../controllers/admin_providers.dart';

/// Admin home: NGO verification, platform overview and recent activity.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ssColors;
    final session = ref.watch(sessionProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          backgroundColor: c.background,
          elevation: 0,
          title: Text(
            'Admin${session != null ? ' · ${session.name}' : ''}',
            style: SsTypeScale.h4.copyWith(color: c.onSurface),
          ),
          actions: [
            IconButton(
              tooltip: 'Log out',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final ok = await SsDialog.confirm(
                  context,
                  title: 'Log out?',
                  message: 'You will need to log in again to manage NGOs.',
                  confirmLabel: 'Log out',
                );
                if (ok == true) {
                  ref.read(sessionProvider.notifier).signOut();
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'NGOs'),
              Tab(text: 'Overview'),
              Tab(text: 'Activity'),
            ],
          ),
        ),
        body: const Column(
          children: [
            ConnectivityBanner(),
            Expanded(
              child: TabBarView(
                children: [
                  _NgoVerificationTab(),
                  _OverviewTab(),
                  _ActivityTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _message(Object error) =>
    error.toString().replaceFirst('Exception: ', '');

String _formatDate(DateTime? d) {
  if (d == null) return '';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}

Widget _errorView(BuildContext context, Object error, VoidCallback onRetry) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(SsSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_message(error), textAlign: TextAlign.center),
          const SizedBox(height: SsSpacing.md),
          SsButton.secondary(label: 'Retry', onPressed: onRetry),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// NGO verification
// ---------------------------------------------------------------------------

class _NgoVerificationTab extends ConsumerStatefulWidget {
  const _NgoVerificationTab();

  @override
  ConsumerState<_NgoVerificationTab> createState() =>
      _NgoVerificationTabState();
}

class _NgoVerificationTabState extends ConsumerState<_NgoVerificationTab> {
  String _status = 'pending';
  String? _busyId;

  void _refresh() {
    ref.invalidate(adminNgosProvider);
    ref.invalidate(adminStatsProvider);
  }

  Future<void> _openCertificate(NgoApplication ngo) async {
    final url = ngo.documentUrl;

    if (url == null || url.isEmpty) {
      _snack('No certificate was uploaded.');
      return;
    }

    if (!ngo.isPdf) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(SsSpacing.md),
                child: Text(
                  'Certificate · ${ngo.organizationName}',
                  style: SsTypeScale.h5,
                ),
              ),
              Flexible(
                child: InteractiveViewer(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : const Padding(
                                padding: EdgeInsets.all(SsSpacing.xl),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                    errorBuilder: (context, _, _) => const Padding(
                      padding: EdgeInsets.all(SsSpacing.xl),
                      child: Text('Could not load the certificate image.'),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _launch(url),
                    child: const Text('Open in browser'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      return;
    }

    await _launch(url);
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http')) {
      _snack('Invalid certificate link.');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened) _snack('Could not open the certificate.');
  }

  void _snack(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  Future<void> _approve(NgoApplication ngo) async {
    final ok = await SsDialog.confirm(
      context,
      title: 'Approve ${ngo.organizationName}?',
      message: 'The NGO will be able to log in and request donations.',
      confirmLabel: 'Approve',
      icon: SsIcons.verified,
    );
    if (ok != true) return;

    await _run(ngo, () async {
      await ref.read(adminRepositoryProvider).approveNgo(ngo.id);
      _snack('${ngo.organizationName} is now verified.');
    });
  }

  Future<void> _reject(NgoApplication ngo) async {
    final reason = await _askReason(ngo);
    if (reason == null) return;

    await _run(ngo, () async {
      await ref.read(adminRepositoryProvider).rejectNgo(ngo.id, reason);
      _snack('${ngo.organizationName} was rejected.');
    });
  }

  Future<void> _run(NgoApplication ngo, Future<void> Function() action) async {
    if (_busyId != null) return;
    setState(() => _busyId = ngo.id);

    try {
      await action();
    } catch (error) {
      _snack(_message(error), error: true);
    } finally {
      if (mounted) {
        setState(() => _busyId = null);
        _refresh();
      }
    }
  }

  Future<String?> _askReason(NgoApplication ngo) {
    return showTextInputDialog(
      context,
      title: 'Reject ${ngo.organizationName}?',
      label: 'Reason (shown to the NGO)',
      confirmLabel: 'Reject',
      maxLines: 3,
      maxLength: 300,
      destructive: true,
      validator: (v) => v.isEmpty ? 'Please enter a reason.' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ngosAsync = ref.watch(adminNgosProvider(_status));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SsSpacing.lg,
            SsSpacing.md,
            SsSpacing.lg,
            0,
          ),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'pending', label: Text('Pending')),
              ButtonSegment(value: 'verified', label: Text('Verified')),
              ButtonSegment(value: 'rejected', label: Text('Rejected')),
            ],
            selected: {_status},
            onSelectionChanged: (s) => setState(() => _status = s.first),
          ),
        ),
        Expanded(
          child: ngosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _errorView(context, e, _refresh),
            data: (ngos) => RefreshIndicator(
              onRefresh: () => ref.refresh(adminNgosProvider(_status).future),
              child: ngos.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: SsSpacing.xxl),
                        SsEmptyState(
                          title: _status == 'pending'
                              ? 'No pending applications'
                              : 'No $_status NGOs',
                          message: _status == 'pending'
                              ? 'New NGO registrations will appear here '
                                  'for review.'
                              : 'Nothing to show yet.',
                          icon: SsIcons.verified,
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(SsSpacing.lg),
                      itemCount: ngos.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: SsSpacing.md),
                      itemBuilder: (context, i) => _ngoCard(ngos[i]),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ngoCard(NgoApplication ngo) {
    final c = context.ssColors;
    final busy = _busyId == ngo.id;
    final anyBusy = _busyId != null;

    return Card(
      color: c.surface,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(SsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ngo.organizationName.isEmpty ? ngo.contactName : ngo.organizationName,
              style: SsTypeScale.h4.copyWith(color: c.onSurface),
            ),
            const SizedBox(height: SsSpacing.xs),
            Text(
              'Reg. no: ${ngo.registrationNumber}\n'
              'Contact: ${ngo.contactName} · ${ngo.email}\n'
              'Applied: ${_formatDate(ngo.createdAt)}',
              style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
            ),
            if (ngo.rejectionReason != null &&
                ngo.verificationStatus == 'rejected') ...[
              const SizedBox(height: SsSpacing.sm),
              SsAlert(
                tone: SsAlertTone.error,
                message: 'Rejected: ${ngo.rejectionReason}',
              ),
            ],
            const SizedBox(height: SsSpacing.md),
            OutlinedButton.icon(
              onPressed: () => _openCertificate(ngo),
              icon: Icon(
                ngo.isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
              ),
              label: const Text('View certificate'),
            ),
            if (ngo.isPending) ...[
              const SizedBox(height: SsSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: SsButton.secondary(
                      label: 'Reject',
                      expand: true,
                      onPressed: anyBusy ? null : () => _reject(ngo),
                    ),
                  ),
                  const SizedBox(width: SsSpacing.md),
                  Expanded(
                    child: SsButton.primary(
                      label: 'Approve',
                      expand: true,
                      isLoading: busy,
                      onPressed: anyBusy ? null : () => _approve(ngo),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overview
// ---------------------------------------------------------------------------

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ssColors;
    final statsAsync = ref.watch(adminStatsProvider);
    final donationsAsync = ref.watch(adminDonationsProvider);

    Future<void> refresh() async {
      ref.invalidate(adminDonationsProvider);
      ref.invalidate(adminStatsProvider);
      await ref.read(adminStatsProvider.future);
    }

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _errorView(context, e, () {
        ref.invalidate(adminStatsProvider);
        ref.invalidate(adminDonationsProvider);
      }),
      data: (s) => RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.all(SsSpacing.lg),
          children: [
            _section(context, 'Users'),
            _grid([
              _tile(context, '${s.donors}', 'Donors'),
              _tile(context, '${s.ngosVerified}', 'Verified NGOs'),
              _tile(context, '${s.ngosPending}', 'Pending NGOs'),
              _tile(context, '${s.ngosRejected}', 'Rejected NGOs'),
            ]),
            _section(context, 'Donations'),
            _grid([
              _tile(context, '${s.donationsTotal}', 'Total'),
              _tile(context, '${s.donationsAvailable}', 'Available'),
              _tile(context, '${s.donationsCollected}', 'Collected'),
              _tile(context, '${s.donationsCancelled}', 'Cancelled'),
            ]),
            _section(context, 'Impact'),
            _grid([
              _tile(context, '${s.portionsServed}', 'Portions served'),
              _tile(context, '${s.requestsActive}', 'Active requests'),
            ]),
            _section(context, 'Recent donations'),
            donationsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(SsSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(_message(e)),
              data: (donations) => donations.isEmpty
                  ? Text(
                      'No donations yet.',
                      style: SsTypeScale.body.copyWith(
                        color: c.onSurfaceVariant,
                      ),
                    )
                  : Column(
                      children: donations
                          .take(30)
                          .map(
                            (d) => SsListTile(
                              dense: true,
                              showChevron: false,
                              title: d.title,
                              subtitle: '${d.donorName} · ${d.locality} · '
                                  '${d.remainingPortions}/${d.portions} left · '
                                  '${_formatDate(d.createdAt)}',
                              trailing: Text(
                                d.status,
                                style: SsTypeScale.small.copyWith(
                                  color: c.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(top: SsSpacing.lg, bottom: SsSpacing.sm),
        child: Text(
          title,
          style: SsTypeScale.h5.copyWith(color: context.ssColors.onSurface),
        ),
      );

  Widget _grid(List<Widget> tiles) => Wrap(
        spacing: SsSpacing.md,
        runSpacing: SsSpacing.md,
        children: tiles,
      );

  Widget _tile(BuildContext context, String value, String label) {
    final c = context.ssColors;

    return Container(
      width: 150,
      padding: const EdgeInsets.all(SsSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: SsTypeScale.h3.copyWith(color: c.onSurface)),
          Text(
            label,
            style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Activity
// ---------------------------------------------------------------------------

class _ActivityTab extends ConsumerWidget {
  const _ActivityTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(adminActivityProvider);

    return activityAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          _errorView(context, e, () => ref.invalidate(adminActivityProvider)),
      data: (items) => RefreshIndicator(
        onRefresh: () => ref.refresh(adminActivityProvider.future),
        child: items.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: SsSpacing.xxl),
                  SsEmptyState(
                    title: 'No activity yet',
                    message: 'Donation requests will show up here.',
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(SsSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: SsSpacing.sm),
                itemBuilder: (context, i) {
                  final a = items[i];
                  return SsListTile(
                    showChevron: false,
                    title: '${a.ngoName} → ${a.donationTitle}',
                    subtitle: 'Donor: ${a.donorName} · ${a.portions} portion(s)'
                        ' · ${_formatDate(a.updatedAt)}',
                    trailing: SsStatusBadge(
                      status: AllocationStatusView.ssStatus(a.status),
                      label: AllocationStatusView.label(a.status),
                      dense: true,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
