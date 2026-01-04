import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import 'add_edit_todo_screen.dart';
import 'package:intl/intl.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodoProvider>(context, listen: false).loadTodos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Görevler'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Görevlerde ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                          Provider.of<TodoProvider>(context, listen: false)
                              .loadTodos();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                if (value.isNotEmpty) {
                  Provider.of<TodoProvider>(context, listen: false)
                      .searchTodos(value);
                } else {
                  Provider.of<TodoProvider>(context, listen: false).loadTodos();
                }
              },
            ),
          ),
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, todoProvider, child) {
                if (todoProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (todoProvider.todos.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Henüz görev yok. Bir tane ekleyin!'
                          : 'Görev bulunamadı',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }

                // Separate completed and incomplete todos
                final incompleteTodos = todoProvider.todos
                    .where((todo) => !todo.isCompleted)
                    .toList();
                final completedTodos = todoProvider.todos
                    .where((todo) => todo.isCompleted)
                    .toList();

                return ListView(
                  children: [
                    if (incompleteTodos.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Tamamlanmamış',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...incompleteTodos.map((todo) => _buildTodoCard(todo)),
                    ],
                    if (completedTodos.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Tamamlanmış',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...completedTodos.map((todo) => _buildTodoCard(todo)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditTodoScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoCard(TodoModel todo) {
    final isOverdue = todo.dueDate.isBefore(DateTime.now()) && !todo.isCompleted;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isOverdue ? Colors.red.withOpacity(0.1) : null,
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) {
            Provider.of<TodoProvider>(context, listen: false)
                .toggleTodoCompletion(todo);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(todo.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: isOverdue ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(todo.dueDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverdue ? Colors.red : Colors.grey,
                    fontWeight: isOverdue ? FontWeight.bold : null,
                  ),
                ),
                if (todo.dueTime != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    todo.dueTime!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditTodoScreen(todo: todo),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteDialog(context, todo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TodoModel todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: Text('"${todo.title}" görevini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TodoProvider>(context, listen: false)
                  .deleteTodo(todo.id!);
              Navigator.pop(context);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
