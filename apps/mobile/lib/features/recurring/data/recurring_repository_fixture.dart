import 'dart:async';

import '../../donation/domain/donation.dart';
import '../../donation/domain/donation_repository.dart';
import '../domain/recurring_template.dart';
import '../domain/recurring_repository.dart';

class RecurringRepositoryFixture implements RecurringRepository {
  RecurringRepositoryFixture(this._donationRepository) {
    _seed();
  }

  final DonationRepository _donationRepository;
  final _templates = <String, RecurringTemplate>{};
  final _controller = StreamController<List<RecurringTemplate>>.broadcast();

  void _seed() {
    _put(
      const RecurringTemplate(
        id: 'rt-1',
        donorId: 'donor-demo',
        donorName: 'Green Leaf Caterers',
        title: 'Leftover lunch buffet',
        portions: 25,
        windowHours: 2,
        locality: 'Jubilee Hills, Hyderabad',
        active: true,
      ),
    );
  }

  void _put(RecurringTemplate t) {
    _templates[t.id] = t;
    _emit();
  }

  void _emit() => _controller.add(_templates.values.toList(growable: false));

  @override
  Stream<List<RecurringTemplate>> watchTemplates(String donorId) async* {
    yield _templates.values.where((t) => t.donorId == donorId).toList();
    yield* _controller.stream.map(
      (all) => all.where((t) => t.donorId == donorId).toList(),
    );
  }

  @override
  Future<RecurringTemplate> createTemplate({
    required String donorId,
    required String donorName,
    required String title,
    required int portions,
    required int windowHours,
    required String locality,
  }) async {
    final template = RecurringTemplate(
      id: 'rt-${_templates.length + 1}',
      donorId: donorId,
      donorName: donorName,
      title: title,
      portions: portions,
      windowHours: windowHours,
      locality: locality,
      active: true,
    );
    _put(template);
    return template;
  }

  @override
  Future<void> confirmToday(String templateId) async {
    final template = _templates[templateId];
    if (template == null) return;
    // The daily job (ARCHITECTURE.md §2 `recurring/`) posts this through the
    // same DonationRepository a manual post uses — no separate code path.
    await _donationRepository.create(
      donorId: template.donorId,
      donorName: template.donorName,
      title: template.title,
      portions: template.portions,
      pickupWindowStart: DateTime.now(),
      pickupWindowEnd: DateTime.now().add(Duration(hours: template.windowHours)),
      address: PickupAddress(locality: template.locality),
    );
    _put(template.copyWith(confirmedToday: true));
  }

  @override
  Future<void> skipToday(String templateId) async {
    final template = _templates[templateId];
    if (template == null) return;
    _put(template.copyWith(skippedToday: true));
  }

  @override
  Future<void> setActive(String templateId, bool active) async {
    final template = _templates[templateId];
    if (template == null) return;
    _put(template.copyWith(active: active));
  }
}
