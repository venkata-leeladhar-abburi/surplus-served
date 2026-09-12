import 'dart:async';

import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';

class NotificationRepositoryFixture implements NotificationRepository {
  final _notifications = <String, AppNotification>{};
  final _controller = StreamController<List<AppNotification>>.broadcast();
  bool _seeded = false;

  void _seedOnce() {
    if (_seeded) return;
    _seeded = true;
    final now = DateTime.now();
    for (final n in [
      AppNotification(
        id: 'n-1',
        title: 'Verification approved',
        body: 'Your NGO profile is verified — you can now request donations.',
        createdAt: now.subtract(const Duration(days: 2)),
        tone: NotificationTone.success,
        read: true,
      ),
      AppNotification(
        id: 'n-2',
        title: 'New donation nearby',
        body: 'Vegetable biryani, 40 portions, just went live in Jubilee Hills.',
        createdAt: now.subtract(const Duration(minutes: 15)),
        tone: NotificationTone.info,
      ),
    ]) {
      _notifications[n.id] = n;
    }
  }

  void _emit() => _controller.add(_notifications.values.toList(growable: false));

  @override
  Stream<List<AppNotification>> watchForUser(String userId) async* {
    _seedOnce();
    final sorted = _notifications.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    yield sorted;
    yield* _controller.stream.map(
      (all) => all.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  @override
  Future<void> markRead(String id) async {
    final n = _notifications[id];
    if (n == null) return;
    _notifications[id] = n.copyWith(read: true);
    _emit();
  }
}
