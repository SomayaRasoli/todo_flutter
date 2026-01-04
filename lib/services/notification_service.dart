import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import '../models/todo_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    // iOS permissions are requested during initialization
    // No need for additional permission request on iOS
  }

  Future<void> scheduleTodoNotification(TodoModel todo) async {
    if (todo.id == null) return;

    // Convert string ID to int using hashCode
    final notificationId = todo.id!.hashCode;

    DateTime notificationTime = todo.dueDate;

    // If there's a specific time, parse it
    if (todo.dueTime != null && todo.dueTime!.isNotEmpty) {
      try {
        final timeParts = todo.dueTime!.split(':');
        if (timeParts.length >= 2) {
          notificationTime = DateTime(
            todo.dueDate.year,
            todo.dueDate.month,
            todo.dueDate.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }
      } catch (e) {
        print('Error parsing time: $e');
      }
    }

    // Only schedule if the notification time is in the future
    if (notificationTime.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        notificationId,
        'Görev Zamanı: ${todo.title}',
        todo.description,
        tz.TZDateTime.from(notificationTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'todo_channel',
            'Görev Bildirimleri',
            channelDescription: 'Görev öğeleri için bildirimler',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Show toast notification for due tasks
  void showDueTaskToast(TodoModel todo) {
    Fluttertoast.showToast(
      msg: "⏰ Görev Zamanı: ${todo.title}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 4,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Show toast for overdue tasks
  void showOverdueTaskToast(TodoModel todo) {
    Fluttertoast.showToast(
      msg: "🔴 Gecikmiş: ${todo.title}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 4,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
