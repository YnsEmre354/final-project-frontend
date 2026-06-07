import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// main.dart'ta bir kez çağrılmalı
  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Android 13+ için çalışma zamanında bildirim izni iste
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Anlık (immediate) telefon bildirimi gönderir
  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String channelId = 'level_unlock',
    String channelName = 'Seviye Bildirimleri',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Seviye kilidi açıldığında gelen bildirimler',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableLights: true,
      icon: '@mipmap/ic_launcher',
    );

    final details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details);
  }
}
