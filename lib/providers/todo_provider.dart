import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/task_monitor_service.dart';

class TodoProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final TaskMonitorService _taskMonitor = TaskMonitorService();
  List<TodoModel> _todos = [];
  bool _isLoading = false;

  List<TodoModel> get todos => _todos;
  bool get isLoading => _isLoading;

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await _databaseService.getAllTodos();
      // Start monitoring for due tasks
      _taskMonitor.startMonitoring(_todos);
    } catch (e) {
      print('Error loading todos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(TodoModel todo) async {
    try {
      final id = await _databaseService.insertTodo(todo);
      todo.id = id;
      _todos.add(todo);
      
      // Schedule notification
      await _notificationService.scheduleTodoNotification(todo);
      
      // Update task monitor
      _taskMonitor.updateTasks(_todos);
      
      notifyListeners();
    } catch (e) {
      print('Error adding todo: $e');
      rethrow;
    }
  }

  Future<void> updateTodo(TodoModel todo) async {
    try {
      await _databaseService.updateTodo(todo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        
        // Reschedule notification (convert string ID to hash code for notification ID)
        await _notificationService.cancelNotification(todo.id!.hashCode);
        if (!todo.isCompleted) {
          await _notificationService.scheduleTodoNotification(todo);
        } else {
          // Clear toast notifications for completed task
          _taskMonitor.clearTaskNotifications(todo.id!);
        }
        
        // Update task monitor
        _taskMonitor.updateTasks(_todos);
        
        notifyListeners();
      }
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _databaseService.deleteTodo(id);
      _todos.removeWhere((todo) => todo.id == id);
      
      // Cancel notification (convert string ID to hash code for notification ID)
      await _notificationService.cancelNotification(id.hashCode);
      
      // Clear toast notifications for deleted task
      _taskMonitor.clearTaskNotifications(id);
      
      // Update task monitor
      _taskMonitor.updateTasks(_todos);
      
      notifyListeners();
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }

  Future<void> toggleTodoCompletion(TodoModel todo) async {
    try {
      final updatedTodo = todo.copyWith(
        isCompleted: !todo.isCompleted,
        updatedAt: DateTime.now(),
      );
      await updateTodo(updatedTodo);
    } catch (e) {
      print('Error toggling todo: $e');
      rethrow;
    }
  }

  Future<void> searchTodos(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await _databaseService.searchTodos(query);
      // Update task monitor with search results
      _taskMonitor.updateTasks(_todos);
    } catch (e) {
      print('Error searching todos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getTodosByDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await _databaseService.getTodosByDate(date);
      // Update task monitor with filtered results
      _taskMonitor.updateTasks(_todos);
    } catch (e) {
      print('Error getting todos by date: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _taskMonitor.stopMonitoring();
    super.dispose();
  }
}
