import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's ID
  String? get _userId => _auth.currentUser?.uid;

  // Get collection reference for current user's todos
  CollectionReference get _todosCollection {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(_userId).collection('todos');
  }

  Future<String> insertTodo(TodoModel todo) async {
    try {
      final docRef = await _todosCollection.add(todo.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding todo: $e');
      rethrow;
    }
  }

  Future<List<TodoModel>> getAllTodos() async {
    try {
      final querySnapshot = await _todosCollection
          .orderBy('dueDate', descending: false)
          .get();
      
      return querySnapshot.docs
          .map((doc) => TodoModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting todos: $e');
      return [];
    }
  }

  Future<List<TodoModel>> getTodosByDate(DateTime date) async {
    try {
      String dateStr = date.toIso8601String().split('T')[0];
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final querySnapshot = await _todosCollection
          .where('dueDate', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('dueDate', isLessThan: endOfDay.toIso8601String())
          .orderBy('dueDate', descending: false)
          .get();
      
      return querySnapshot.docs
          .map((doc) => TodoModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting todos by date: $e');
      return [];
    }
  }

  Future<List<TodoModel>> searchTodos(String query) async {
    try {
      final querySnapshot = await _todosCollection
          .orderBy('dueDate', descending: false)
          .get();
      
      final allTodos = querySnapshot.docs
          .map((doc) => TodoModel.fromFirestore(doc))
          .toList();
      
      // Filter locally since Firestore doesn't support LIKE queries
      return allTodos.where((todo) {
        return todo.title.toLowerCase().contains(query.toLowerCase()) ||
            todo.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('Error searching todos: $e');
      return [];
    }
  }

  Future<void> updateTodo(TodoModel todo) async {
    try {
      if (todo.id == null) {
        throw Exception('Todo ID is null');
      }
      await _todosCollection.doc(todo.id.toString()).update(todo.toMap());
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _todosCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }

  // Stream for real-time updates
  Stream<List<TodoModel>> getTodosStream() {
    try {
      return _todosCollection
          .orderBy('dueDate', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => TodoModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error getting todos stream: $e');
      return Stream.value([]);
    }
  }
}
