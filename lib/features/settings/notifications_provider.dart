import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kNotificationKey = 'notifications_enabled';

class NotificationsNotifier extends StateNotifier<bool> {
  NotificationsNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kNotificationKey) ?? true; // varsayılan: açık
  }

  Future<void> toggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotificationKey, value);
    state = value;
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, bool>(
      (ref) => NotificationsNotifier(),
    );
