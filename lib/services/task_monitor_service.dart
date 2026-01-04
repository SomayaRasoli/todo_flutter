import 'dart:async';
import '../models/todo_model.dart';
import 'notification_service.dart';

class TaskMonitorService {
  static final TaskMonitorService _instance = TaskMonitorService._internal();
  factory TaskMonitorService() => _instance;
  TaskMonitorService._internal();

  Timer? _monitorTimer;
  final Set<String> _notifiedTasks = {};
  final NotificationService _notificationService = NotificationService();

  // Start monitoring tasks
  void startMonitoring(List<TodoModel> todos) {
    // Stop existing timer if any
    stopMonitoring();

    // Check immediately
    _checkDueTasks(todos);

    // Check every minute
    _monitorTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkDueTasks(todos);
    });
  }

  // Stop monitoring
  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  // Update the task list being monitored
  void updateTasks(List<TodoModel> todos) {
    _checkDueTasks(todos);
  }

  // Check for due tasks and show toast notifications
  void _checkDueTasks(List<TodoModel> todos) {
    final now = DateTime.now();

    for (var todo in todos) {
      // Skip completed tasks
      if (todo.isCompleted || todo.id == null) continue;

      DateTime taskDueTime = todo.dueDate;

      // If there's a specific time, parse it
      if (todo.dueTime != null && todo.dueTime!.isNotEmpty) {
        try {
          final timeParts = todo.dueTime!.split(':');
          if (timeParts.length >= 2) {
            taskDueTime = DateTime(
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

      final difference = taskDueTime.difference(now).inMinutes;
      final taskKey = '${todo.id}_${taskDueTime.toIso8601String()}';

      // Task is due now (within 1 minute window)
      if (difference >= 0 && difference <= 1 && !_notifiedTasks.contains(taskKey)) {
        _notificationService.showDueTaskToast(todo);
        _notifiedTasks.add(taskKey);
      }
      // Task is overdue
      else if (difference < 0 && difference > -60 && !_notifiedTasks.contains('${taskKey}_overdue')) {
        _notificationService.showOverdueTaskToast(todo);
        _notifiedTasks.add('${taskKey}_overdue');
      }
    }

    // Clean up old notifications from completed/deleted tasks
    _cleanupNotifications(todos);
  }

  // Remove notifications for tasks that no longer exist
  void _cleanupNotifications(List<TodoModel> todos) {
    final currentTaskKeys = todos
        .where((t) => t.id != null)
        .map((t) => t.id!)
        .toSet();

    _notifiedTasks.removeWhere((key) {
      final taskId = key.split('_')[0];
      return !currentTaskKeys.contains(taskId);
    });
  }

  // Clear notification history (useful when a task is completed)
  void clearTaskNotifications(String taskId) {
    _notifiedTasks.removeWhere((key) => key.startsWith(taskId));
  }
}
